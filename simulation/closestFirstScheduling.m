%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: closest first scheduling for line
%   description: from node 1 to n, node 0 is the BS; using Hou's
%   GlobeCom'13 model
%%
% @param v_i: traffic at each node i
% @param p_i: PDR from node i to (i - 1)
% p and v must be the same
% dimension
% @param d: deadline
% @return: # of packets reaching BS by d %set of packets reaching BS by d, identified by their sources
function y = closestFirstScheduling(v, p, d)
    y = 0;
    
    % each slot
    for t = 1 : d
        len = length(p);
%         v'
        
        i = 1;
        while i <= len
            if v(i) > 0
                % schedule i
                if rand <= p(i)
                    % tx success
                    v(i) = v(i) - 1;
                    if i > 1
                        v(i - 1) = v(i - 1) + 1;
                    else
                        % reaches BS
                        y = y + 1;
                    end
                end
                
                % skip the next node since it conflicts with me
                i = i + 1;
            end
            
            i = i + 1;
        end %while
        
        % evacuated
        if sum(v) == 0
            fprintf('evacuated at slot %d\n', t);
            break;
        end
    end
end
