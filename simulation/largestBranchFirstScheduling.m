%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: Largest branch first scheduling, see Time-Optimum Packet Scheduling for Many-to-One Routing in Wireless Sensor Networks by Song MASS'06
%   Description: 
%       1) from node 1 to n, node 0 is the BS
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
%     % queued pkts at each node, identified by source id
%     queues = cell(n, 1);
%     % initialize queues
%     for i = 1 : n
%         queues{i} = ones(v(i), 1) * i;
%     end
    
    % compute branch size once for all, which does not change as packets get forwarded
    branch_sizes = zeros(n, 1);
    for i = 1 : n
        branch_sizes(i) = subTreePktNum(i, parents, v);
    end
    
%     % sanity check: calculate evacuation time for deterministic links according to Theorem 5
%     children = find(parents == 0);
%     largest_branch_size = -inf;
%     largest_branch_idx = [];
%     for i = 1 : length(children)
%         child = children(i);
%         if largest_branch_size < subTreePktNum(child, parents, v)
%             largest_branch_size = subTreePktNum(child, parents, v);
%             largest_branch_idx = child;
%         end
%     end
%     total_slots = 0;
%     for i = 1 : length(children)
%         child = children(i);
%         if child ~= largest_branch_idx
%             total_slots = total_slots + v(child) - 1;
%         end
%     end
%     total_slots = total_slots + 2 * subTreePktNum(largest_branch_idx, parents, v) - v(largest_branch_idx);
%     % subTreePktNum(0, parents, v) assumes sink also has a packet?
%     total_pkts = subTreePktNum(0, parents, v);
%     if total_slots < total_pkts
%         total_slots = total_pkts;
%     end
%     fprintf('time slots required to evacuate %d\n', total_slots);
    
    
    % each slot
    for t = 1 : d
%         fprintf('slot %d\n', t);
%         v
        
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
                largest_branch_size = max(branch_sizes(children_with_pkt));
                % index in children, not node ID
                max_p_child = find(branch_sizes(children_with_pkt) == largest_branch_size, 1);
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
%                     flow_delivery_cnts(pkt) = flow_delivery_cnts(pkt) + 1;
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
end


