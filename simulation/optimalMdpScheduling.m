%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: optimal scheduling computed
%   Description: finite horizon Markov decision process
%           states:     <i_1, i_2, ..., i_n>    i_j: # of packets at j
%           action:     schedule a concurrent set
%           reward:     1 if one packet arrives at BS; 0 otherwise
%           tx prob.:   a packet goes from i -> i's parent w/ prob. p_i if i is scheduled
%           horizon:    relative deadline
%   Limitation: only apply to the following topology
%           0
%          /  \
%         1     2
%        / \   /|\
%       3   4 5 6 7
%      /
%     8
%%
% clc;
% clear all;
% @param parents(i): parent for node i
% @param v(i): traffic at each node i
% @param p(i): PDR from node i to its parent
% p and v must be the same dimension
% @param d: deadline
% @return: expected # of packets reaching BS by 1, 2, .., d
function y = optimalMdpScheduling(parents, v, p, d)
    %y = 0;
    
%     N = 3;
%     v = ones(N, 1);
%     %v(end) = 10;
%     p = ones(N, 1) * 0.8;
%     d = 5; %2 * N - 1;
    
    n = length(v);

    % compute state space size, each node forwards at most packets at the subtree rooted at itself
%     buf_size = ones(n, 1) * sum(v);
    for i = 1 : n
        buf_size(i) = subTreePktNum(i, parents, v);
    end
    
    
    % each state
    % u_k_{i_1}_{i_2}_{i_3}_{i_4} stores k-step to go value of state <i_1, i_2, i_3, i_4>
    t = 0;
    for i_1 = 0 : buf_size(1)
    for i_2 = 0 : buf_size(2)
    for i_3 = 0 : buf_size(3)
    for i_4 = 0 : buf_size(4)
	for i_5 = 0 : buf_size(5)
	for i_6 = 0 : buf_size(6)
	for i_7 = 0 : buf_size(7)
	for i_8 = 0 : buf_size(8)
        % subtree rooted at 0
        if (i_1 + i_2 + i_3 + i_4 + i_5 + i_6 + i_7 + i_8) > sum(v)
            continue;
        end
        % 1
        if (i_1 + i_3 + i_4 + i_8) > (v(1) + v(3) + v(4) + v(8))
            continue;
        end
        % 2
        if (i_2 + i_5 + i_6 + i_7) > (v(2) + v(5) + v(6) + v(7))
            continue;
        end
        % 3
        if (i_3 + i_8) > (v(3) + v(8))
            continue;
        end
        str = sprintf('u_%d_%d_%d_%d_%d_%d_%d_%d_%d = 0;', t, i_1, i_2, i_3, i_4, i_5, i_6, i_7, i_8);
        eval(str);
    end
    end
    end
    end
    end
    end
    end
    end
    
    
    % each slot
    for t = 1 : d
        fprintf('slot %d\n', t);
        
        % each state
        % i_m: # of pkts at node m
        for i_1 = 0 : buf_size(1)
        for i_2 = 0 : buf_size(2)
        for i_3 = 0 : buf_size(3)
        for i_4 = 0 : buf_size(4)
        for i_5 = 0 : buf_size(5)
        for i_6 = 0 : buf_size(6)
        for i_7 = 0 : buf_size(7)
        for i_8 = 0 : buf_size(8)
            % subtree rooted at 0
            if (i_1 + i_2 + i_3 + i_4 + i_5 + i_6 + i_7 + i_8) > sum(v)
                continue;
            end
            % 1
            if (i_1 + i_3 + i_4 + i_8) > (v(1) + v(3) + v(4) + v(8))
                continue;
            end
            % 2
            if (i_2 + i_5 + i_6 + i_7) > (v(2) + v(5) + v(6) + v(7))
                continue;
            end
            % 3
            if (i_3 + i_8) > (v(3) + v(8))
                continue;
            end
            str = sprintf('u_%d_%d_%d_%d_%d_%d_%d_%d_%d = 0;', t, i_1, i_2, i_3, i_4, i_5, i_6, i_7, i_8);
            eval(str);

            % no reward bcoz no pkt
            if 0 == (i_1 + i_2 + i_3 + i_4 + i_5 + i_6 + i_7 + i_8) 
                %fprintf('evacuated at slot %d\n', t);
                continue;
            end

            % each action: an independent set, not neccessarily maximal
            % TODO: optimize to require MIS later if necessary
            % j_m: boolean, whether node m is active
            max = -inf;
            for j_1 = 0 : 1
                % a node should not be active if holding no packet
                if j_1 == 1 && i_1 == 0
                    continue;
                end

            for j_2 = 0 : 1
                if j_2 == 1 && i_2 == 0
                    continue;
                end
                % TODO: hardcoded
                % conflict?
                if j_2 == 1 && j_1 == 1
                    continue;
                end

            for j_3 = 0 : 1
                if j_3 == 1 && i_3 == 0
                    continue;
                end
                if j_3 == 1 && j_1 == 1
                    continue;
                end

            for j_4 = 0 : 1
                if j_4 == 1 && i_4 == 0
                    continue;
                end
                if j_4 == 1 && (j_1 == 1 || j_3 == 1)
                    continue;
                end

            for j_5 = 0 : 1
                if j_5 == 1 && j_5 == 0
                    continue;
                end
                if j_5 == 1 && j_2 == 1
                    continue;
                end

            for j_6 = 0 : 1
                if j_6 == 1 && i_6 == 0
                    continue;
                end
                if j_6 == 1 && (j_2 == 1 || j_5 == 1)
                    continue;
                end

            for j_7 = 0 : 1
                if j_7 == 1 && i_7 == 0
                    continue;
                end
                if j_7 == 1 && (j_2 == 1 || j_5 == 1 || j_6 == 1)
                    continue;
                end

            for j_8 = 0 : 1
                if j_8 == 1 && i_8 == 0
                    continue;
                end
                if j_8 == 1 && j_3 == 1
                    continue;
                end


                % once reach here, concurrent set S is {i | j_i == 1}
                cs = [];
                for idx = 1 : n
                    str = sprintf('j_%d == 1;', idx);
                    if eval(str)
                        str = sprintf('cs = [cs; %d];', idx);
                        eval(str);
                    end
                end
%                 if length(cs) == 3
%                     if sum(cs ~= [1; 5; 8]) == 0
%                         disp('');
%                     end
%                 end

                % ensure S is non-empty
                concurrency = length(cs);
                if 0 == concurrency
                    continue;
                end
                if concurrency > 3
                    fprintf('concurrent set error %d\n', concurrency);
                    return;
                end

                % each output state
                % k_m: is m's tx successful
                total = 0;
                transit_prob_total = 0;

                if 1 == concurrency
                    m = cs(1);
                    % 
                    for k = 0 : 1
                        % everything is known here for value iteration
                        for idx = 1 : n
                            str = sprintf('i_%d_ = i_%d;', idx, idx);
                            eval(str);
                        end
                        reward = 0;
                        % transition probability
                        transit_prob = 1;
                        if k > 0
                            transit_prob = transit_prob * p(m);
                            str = sprintf('i_%d_ = i_%d_ - 1;', m, m);
                            eval(str);
                            parent = parents(m);
                            % root absorbs pkts
                            if parent > 0
                                str = sprintf('i_%d_ = i_%d_ + 1;', parent, parent);
                                eval(str);
                            else
                                reward = 1;
                            end
                        else
                            transit_prob = transit_prob * (1 - p(m));
                        end
                        transit_prob_total = transit_prob_total + transit_prob;

                        str = sprintf('exist(''u_%d_%d_%d_%d_%d_%d_%d_%d_%d'', ''var'');', t - 1, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_);
                        % valid state
                        if eval(str)
                            str = sprintf('u = u_%d_%d_%d_%d_%d_%d_%d_%d_%d;', t - 1, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_);
                            eval(str);
                            val = transit_prob * (reward + u);
                            total = total + val;
%                             fprintf('state: <%d, %d, %d, %d, %d, %d, %d, %d>, action: <%d, %d, %d, %d, %d, %d, %d, %d>, ... new state: <%d, %d, %d, %d, %d, %d, %d, %d>, transition prob: %f, reward: %f, u: %f, total: %f\n', ... 
%                                       i_1, i_2, i_3, i_4, i_5, i_6, i_7, i_8, j_1, j_2, j_3, j_4, j_5, j_6, j_7, j_8, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_, transit_prob, reward, u, total);
                        end
                    end % output state
                end

                if 2 == concurrency
                    m_1 = cs(1);
                    m_2 = cs(2);
                    %
                    for k_1 = 0 : 1
                        for k_2 = 0 : 1
                            % everything is known here for value iteration
                            for idx = 1 : n
                                str = sprintf('i_%d_ = i_%d;', idx, idx);
                                eval(str);
                            end
                            reward = 0;

                            % transition probability
                            transit_prob = 1;
                            if k_1 > 0
                                transit_prob = transit_prob * p(m_1);
                                str = sprintf('i_%d_ = i_%d_ - 1;', m_1, m_1);
                                eval(str);
                                parent = parents(m_1);
                                % root absorbs pkts
                                if parent > 0
                                    str = sprintf('i_%d_ = i_%d_ + 1;', parent, parent);
                                    eval(str);
                                else
                                    reward = 1;
                                end
                            else
                                transit_prob = transit_prob * (1 - p(m_1));
                            end
                            if k_2 > 0
                                transit_prob = transit_prob * p(m_2);
                                str = sprintf('i_%d_ = i_%d_ - 1;', m_2, m_2);
                                eval(str);
                                parent = parents(m_2);
                                % root absorbs pkts
                                if parent > 0
                                    str = sprintf('i_%d_ = i_%d_ + 1;', parent, parent);
                                    eval(str);
                                else
                                    reward = 1;
                                end
                            else
                                transit_prob = transit_prob * (1 - p(m_2));
                            end
                            transit_prob_total = transit_prob_total + transit_prob;

                            str = sprintf('exist(''u_%d_%d_%d_%d_%d_%d_%d_%d_%d'', ''var'');', t - 1, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_);
                            % valid state
                            if eval(str)
                                str = sprintf('u = u_%d_%d_%d_%d_%d_%d_%d_%d_%d;', t - 1, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_);
                                eval(str);
                                val = transit_prob * (reward + u);
                                total = total + val;
%                                 fprintf('state: <%d, %d, %d, %d, %d, %d, %d, %d>, action: <%d, %d, %d, %d, %d, %d, %d, %d>, ... new state: <%d, %d, %d, %d, %d, %d, %d, %d>, transition prob: %f, reward: %f, u: %f, total: %f\n', ... 
%                                       i_1, i_2, i_3, i_4, i_5, i_6, i_7, i_8, j_1, j_2, j_3, j_4, j_5, j_6, j_7, j_8, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_, transit_prob, reward, u, total);
                            end
                        end % each output state
                    end
                end

                if 3 == concurrency
                    m_1 = cs(1);
                    m_2 = cs(2);
                    m_3 = cs(3);
                    if sum([i_1, i_2, i_3, i_4, i_5, i_6, i_7, i_8] ~= [1 1 1 1 1 1 1 1]) == 0 ...
                                            &&  sum(cs ~= [1; 5; 8]) == 0
                        disp('');
                    end
                    %
                    for k_1 = 0 : 1
                        for k_2 = 0 : 1
                            for k_3 = 0 : 1
                                % everything is known here for value iteration
                                for idx = 1 : n
                                    str = sprintf('i_%d_ = i_%d;', idx, idx);
                                    eval(str);
                                end
                                reward = 0;

                                % transition probability
                                transit_prob = 1;
                                if k_1 > 0
                                    transit_prob = transit_prob * p(m_1);
                                    str = sprintf('i_%d_ = i_%d_ - 1;', m_1, m_1);
                                    eval(str);
                                    parent = parents(m_1);
                                    % root absorbs pkts
                                    if parent > 0
                                        str = sprintf('i_%d_ = i_%d_ + 1;', parent, parent);
                                        eval(str);
                                    else
                                        reward = 1;
                                    end
                                else
                                    transit_prob = transit_prob * (1 - p(m_1));
                                end
                                if k_2 > 0
                                    transit_prob = transit_prob * p(m_2);
                                    str = sprintf('i_%d_ = i_%d_ - 1;', m_2, m_2);
                                    eval(str);
                                    parent = parents(m_2);
                                    % root absorbs pkts
                                    if parent > 0
                                        str = sprintf('i_%d_ = i_%d_ + 1;', parent, parent);
                                        eval(str);
                                    else
                                        reward = 1;
                                    end
                                else
                                    transit_prob = transit_prob * (1 - p(m_2));
                                end
                                if k_3 > 0
                                    transit_prob = transit_prob * p(m_3);
                                    str = sprintf('i_%d_ = i_%d_ - 1;', m_3, m_3);
                                    eval(str);
                                    parent = parents(m_3);
                                    % root absorbs pkts
                                    if parent > 0
                                        str = sprintf('i_%d_ = i_%d_ + 1;', parent, parent);
                                        eval(str);
                                    else
                                        reward = 1;
                                    end
                                else
                                    transit_prob = transit_prob * (1 - p(m_3));
                                end
                                transit_prob_total = transit_prob_total + transit_prob;

                                str = sprintf('exist(''u_%d_%d_%d_%d_%d_%d_%d_%d_%d'', ''var'');', t - 1, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_);
                                % valid state
                                if eval(str)
                                    str = sprintf('u = u_%d_%d_%d_%d_%d_%d_%d_%d_%d;', t - 1, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_);
                                    eval(str);
                                    val = transit_prob * (reward + u);
                                    total = total + val;
%                                     if sum([i_1, i_2, i_3, i_4, i_5, i_6, i_7, i_8] ~= [1 1 1 1 1 1 1 1]) == 0 ...
%                                             && sum([i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_] ~= [0 2 2 1 0 1 1 0]) == 0 ...
%                                             && t == 3
%                                         disp();
%                                     end
%                                     fprintf('state: <%d, %d, %d, %d, %d, %d, %d, %d>, action: <%d, %d, %d, %d, %d, %d, %d, %d>, ... new state: <%d, %d, %d, %d, %d, %d, %d, %d>, transition prob: %f, reward: %f, u: %f, total: %f\n', ... 
%                                          i_1, i_2, i_3, i_4, i_5, i_6, i_7, i_8, j_1, j_2, j_3, j_4, j_5, j_6, j_7, j_8, i_1_, i_2_, i_3_, i_4_, i_5_, i_6_, i_7_, i_8_, transit_prob, reward, u, total);
                                end
                            end % each output state
                        end
                    end
                end

                % sanity check
                if abs(transit_prob_total - 1) > 10 ^ (-6) % epsilon for floating point
                    fprintf('transit_prob_total %f not 1!\n', transit_prob_total);
                    return;
                end

                if max < total
                    max = total;
                end
            end
            end
            end
            end
            end
            end
            end
            end % action

            str = sprintf('u_%d_%d_%d_%d_%d_%d_%d_%d_%d = max;', t, i_1, i_2, i_3, i_4, i_5, i_6, i_7, i_8);
            eval(str);

        end
        end
        end
        end
        end
        end
        end
        end % state
    
        str = sprintf('y(%d) = u_%d_%d_%d_%d_%d_%d_%d_%d_%d;', t, t, v(1), v(2), v(3), v(4), v(5), v(6), v(7), v(8));
        eval(str);    
    end % slot    
end


% n = 1; %length(v);
% str = '';
% for idx = 1 : n
%     str = [str, 'for i_', num2str(idx), ' = 1 : ', num2str(idx), '\n'];
% end
% %str = [str, 'fprintf(''%d'', eval(i_1));'];
% str = [str, 'disp(i_1);\n'];
% for idx = 1 : n
%     str = [str, 'end\n'];
% end
% fprintf(str);
% 
% 
% %     str = [' for i = 1 : 3 ', ...
% %              'disp(i); ', ...
% %              'end'];
% eval(str);
