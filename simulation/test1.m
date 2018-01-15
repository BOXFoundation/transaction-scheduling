%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: driver
% %%
% clear all;
% clc;
% N = 3;
% v = floor(rand(N, 1) * 10);
% %v(end) = 10;
% % p = ones(N, 1) * 1;
% p = rand(N, 1);
% %%
% D = 3; %2 * N - 1;
% 
% %% optimal dcr
% y = optimalMdpScheduling(v, p, D);
% ref = y / sum(v);
% 
% %% greedy dcr
% ratios = [];
% REPETITION = 100;
% for round = 1 : REPETITION
%     % samples per round
%     SAMPLE_CNT = 1000;
%     ratio = [];
%     for i = 1 : SAMPLE_CNT
%         y = closestFirstScheduling(v, p, D);
%         ratio = [ratio; y / sum(v)];
%     end
%     y = mean(ratio);
%     ratios = [ratios; y];
% end
% hold off;
% plot(ratios);
% mean(ratios)
% %
% hold on;
% plot(ones(REPETITION) * ref);
% 
% %% min_collection_time: for ideal links
% x = -inf;
% for i = 1 : (N - 1)
%     tmp = i - 1 + v(i) + 2 * sum(v(i + 1 : end));
%     if x < tmp
%         x = tmp;
%     end
% end
% min_collection_time = x;

function test
    N = 3;
    v = ones(N, 1); % floor(rand(N, 1) * 10);
    parents = 0 : (N - 1);
        
    for i = 1 : n
        buf_size(i) = subTreePktNum(i);
    end
    % @return: total # of pkts in the subtree rooted at node i, including i
    function x = subTreePktNum(i)
        x = v(i);
        
        children = find(parents == i);        
        for j = 1 : length(children)
            x = x + subTreePktNum(children(j));
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: Largest branch first scheduling, see Time-Optimum Packet Scheduling for Many-to-One Routing in Wireless Sensor Networks by Song MASS'06
%   Description: 
%       1) from node 1 to n, node 0 is the BS
%       2) essentially, smallest SLF reduces to furthest first scheduling bcoz LST = effective_deadline -
%       remaining_path_delay and effective_deadline is the same for all all packets
%       3) we assume tx delay is 1 slot here: TODO, change to ETX?
%%
% @param v_i: traffic at each node i
% @param p_i: PDR from node i to (i - 1)
% p and v must be the same dimension
% @param d: deadline
% @return: # of packets reaching BS by 1, 2, 3, .., d %set of packets reaching BS by d, identified by their sources
% @return flow_delivery_cnts: % # of packets reaching root by deadline from each node
function [y flow_delivery_cnts] = largestBranchFirstScheduling(parents, v, p, d)
    n = length(v);
    total = 0;
    y = zeros(d, 1);
    flow_delivery_cnts = zeros(n, 1);
    % queued pkts at each node, identified by source id
    queues = cell(n, 1);
    % initialize queues
    for i = 1 : n
        queues{i} = ones(v(i), 1) * i;
    end
    
    % compute branch size once for all, which does not change as packets get forwarded
    branch_sizes = zeros(n, 1);
    for i = 1 : n
        branch_sizes(i) = subTreePktNum(i);
    end
    % is blocked bcoz larger branch is being collected
    is_blocked = repmat(false, n, 1);
    % is node going to tx in this slot; for wavelike forwarding
    is_active =  repmat(false, n, 1);
    
    % each slot
    for t = 1 : d
        set = [];
        % update state: is_blocked and is_active
        subtreeScheduling(0);
        
        % wavelike forwarding
%         for i = 1 : n
%             % only unblocked nodes participate in forwarding
%             % TODO: the only exception is the children of root can forward alternatively
%             if ~is_blocked(i)
%                 is_active(i) = ~is_active(i);
%                 if is_active(i)
%                     set = [set; i];
%                 end
%             end
%         end
        
        % schedule concurrent set
        for j = 1 : length(set)
            i = set(j);
            % schedule i
            if rand <= p(i)
                % tx success
                v(i) = v(i) - 1;
                % fifo
                pkt = queues{i}(1);
                queues{i}(1) = [];
                
                parent = parents(i);
                if parent > 0
                    v(parent) = v(parent) + 1;
                    queues{parent} = [queues{parent}; pkt];
                else
                    % reaches BS
                    flow_delivery_cnts(pkt) = flow_delivery_cnts(pkt) + 1;
                    total = total + 1;
                end
            end
        end
        
        y(t) = total;
        % evacuated
        if 0 == sum(v)
            % no more arrivals at BS from now on
            y(t : end) = repmat(total, d - t + 1, 1);
    %             fprintf('evacuated at slot %d\n', t);
            break;
        end
    end
    
    % subtree scheduling
    % @param root: root of the subtree
    function subtreeScheduling(root)
        children = find(parents == root);        
        
        
        % largest non-empty branch
        largest_branch_size = -inf;
        largest_branch_idx = [];
        for k = 1 : length(children)
            child = children(k);
            % note: queue size uses latest v, branch size initial v
            if subTreePktNum(child) > 0
                if largest_branch_size < branch_sizes(child)
                    largest_branch_size = branch_sizes(child);
                    largest_branch_idx = child;
                end
            end
            
            % all children other than the largest non-empty branch one is blocked
            is_blocked(children) = true;
            is_blocked(largest_branch_idx) = false;
            
            if 0 == root
                % active in even slot
                if 1 == mod(t, 2)
                    set = [set; largest_branch_child];
                end
            end
            
            % recursively schedule subtree rooted at each child
            subtreeScheduling(child);
        end
        
    end
end


