%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: largest debt first scheduling for tree, see Hou's GlobeCom'13 paper
%   Description: from node 1 to n, node 0 is the BS
%%
% @param v_i: traffic at each node i
% @param p_i: PDR from node i to (i - 1)
% @param q_i: e2e dcr requirement for node i
% p and v must be the same dimension
% @param d: deadline
% @param period_cnt: # of periods to run
% @return y: # of new packets reaching BS by d in each period, not accumulative, size period_cnt * d
% @return flow_delivery_cnts: % # of packets reaching root by deadline from each flow
function [y flow_delivery_cnts] = largestDebtFirstScheduling(parents, v, p, q, d, period_cnt)
    n = length(v);
    % further divide into flows: each pkt constitutes a flow
    flow_cnt = sum(v);
    debts = zeros(flow_cnt, 1);
    flow_delivery_cnts = zeros(flow_cnt, 1);
    % queued flows at each node
    queues = cell(n, 1);
    y = zeros(period_cnt, d);
    
    % each period
    for k = 1 : period_cnt
        fprintf('period %d\n', k);
        % all previous (k - 1) periods
        debts = (k - 1) * q - flow_delivery_cnts;
        % debts^+
        debts(debts < 0) = 0;
        
        % initialize queues
        for i = 1 : n
            queues{i} = (sum(v(1 : (i - 1))) + 1 : sum(v(1:i)))';
        end
        total = 0;

        % each slot
        for t = 1 : d
            nodes = (1 : n)';

            % BFS of the tree
            % start from BS
            roots = 0;
            set = [];
            while ~isempty(roots)
                next_roots = [];
                % each subtree
                for i = 1 : length(roots)
                    root = roots(i);
                    next_roots = [next_roots; nodes(parents == root)];
                    % a child cannot be scheduled if parent is
                    if sum(set == root) > 0
                        continue;
                    end
                    
                    % choose largest debt child
                    largest_debt = -inf;
                    largest_debt_child = [];
                    children = nodes(parents == root);
                    for j = 1 : length(children)
                        child = children(j);
                        % flows at this child
                        child_flows = queues{child};
                        largest_child_debt = max(debts(child_flows));
                        if largest_debt < largest_child_debt
                            largest_debt = largest_child_debt;
                            largest_debt_child = child;
                        end
                    end
                    set = [set; largest_debt_child];
                end
                roots = next_roots;
            end
            
            % schedule concurrent set
            for j = 1 : length(set)
                i = set(j);
                flows = queues{i};
                [largest_debt ix] = max(debts(flows));
                largest_debt_flow = flows(ix);
                
                % schedule i
                if rand <= p(i)
                    % tx success
                    queues{i} = setdiff(queues{i}, largest_debt_flow);
                    
                    parent = parents(i);
                    if parent > 0
                        queues{parent} = [queues{parent}; largest_debt_flow];
                    else
                        % reaches BS
                        flow_delivery_cnts(largest_debt_flow) = flow_delivery_cnts(largest_debt_flow) + 1;
                        total = total + 1;
                    end
                end
            end
            
            y(k, t) = total;
            
            % sanity check: pkt # conservation
            queue_flow_cnt = 0;
            for i = 1 : n
                queue_flow_cnt = queue_flow_cnt + length(queues{i});
            end
            if (queue_flow_cnt + total) ~= flow_cnt
                fprintf('error: %d %d vs %d\n', queue_flow_cnt, total, flow_cnt);
                return;
            end
            
        end % slot
    end % period
%     y = sum(flow_delivery_cnts) / period_cnt;
    % sanity check
    if sum(y(:, end)) ~= sum(flow_delivery_cnts)
        fprintf('error: %d vs %d\n', sum(y(:, end)), sum(flow_delivery_cnts));
        return;
    end
end
