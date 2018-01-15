%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: most reliable first scheduling for tree
%   Description: from node 1 to n, node 0 is the BS; using Hou's GlobeCom'13 model
%%
% @param v_i: traffic at each node i
% @param p_i: PDR from node i to (i - 1)
% p and v must be the same dimension
% @param d: deadline
% @return: # of packets reaching BS by 1, 2, 3, .., d %set of packets reaching BS by d, identified by their sources
% warninng flow_delivery_cnts disabled
% @return flow_delivery_cnts(n * d): % # of packets reaching root by d from each node
% function [y flow_delivery_cnts] = mostReliableFirstScheduling(parents, v, p, d)
function [y] = mostReliableFirstScheduling(parents, v, p, d)
    n = length(v);
    total = 0;
    y = zeros(d, 1);
%     flow_delivery_cnts = zeros(n, d);
%     flow_delivery_cnt = zeros(n, 1);
%     % queued pkts at each node, identified by source id
%     queues = cell(n, 1);
%     % initialize queues
%     for i = 1 : n
%         queues{i} = ones(v(i), 1) * i;
%     end
    
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

                % w/ pkts buffered
                children_with_pkt = (parents == root) & (v > 0);
                max_p = max(p(children_with_pkt));
                % index in children, not node ID
                max_p_child = find(p(children_with_pkt) == max_p, 1);
                % activate children w/ largest pdr
                tmp = nodes(children_with_pkt);
                set = [set;  tmp(max_p_child)];
            end
            roots = next_roots;
        end
        
        % schedule concurrent set
        for j = 1 : length(set)
            i = set(j);
            % schedule i
            if rand <= p(i)
                % tx success
                v(i) = v(i) - 1;
%                 % fifo
%                 pkt = queues{i}(1);
%                 queues{i}(1) = [];
                
                parent = parents(i);
                if parent > 0
                    v(parent) = v(parent) + 1;
%                     queues{parent} = [queues{parent}; pkt];
                else
                    % reaches BS
%                     flow_delivery_cnt(pkt) = flow_delivery_cnt(pkt) + 1;
                    total = total + 1;
                end
            end
        end
        
        y(t) = total;
%         flow_delivery_cnts(:, t) = flow_delivery_cnt;
%         % sanity check
%         if total ~= sum(flow_delivery_cnt)
%             fprintf('error at slot %d: %d vs %d\n', t, total, sum(flow_delivery_cnt));
%             return;
%         end
        
        % evacuated
        if sum(v) == 0
            % no more arrivals at BS from now on
            y(t : end) = repmat(total, d - t + 1, 1);
    %             fprintf('evacuated at slot %d\n', t);
            break;
        end
    end
end
