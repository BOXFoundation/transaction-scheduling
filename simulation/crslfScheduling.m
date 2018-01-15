%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: Channel Reuse-based Smallest Latest-start-time First (CR-SLF) scheduling, see Huan Li RTAS'05
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
function [y flow_delivery_cnts] = crslfScheduling(parents, v, p, d)
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
    
    % rank nodes by nonincreasing path delay to root
    path_delays = pathLen(parents, p);
    [x ix] = sort(path_delays, 'descend');
    
    % each slot
    for t = 1 : d        
        nodes = (1 : n)';
        % farthest first
        set = [];
        
        for i = 1 : n
            % from longest to shortest
            idx = ix(i);
            node = nodes(idx);
            
            % empty
            if 0 == v(node)
                continue;
            end
            
            % interfere w/ any existing tx
            is_conflict = false;
            for j = 1 : length(set)
                x = set(j);
                % two links interfere if they share a common node
                if node == parents(x) || parents(node) == x || parents(node) == parents(x)
                    is_conflict = true;
                    break;
                end
            end
            if ~is_conflict
                set = [set; node];
            end
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
