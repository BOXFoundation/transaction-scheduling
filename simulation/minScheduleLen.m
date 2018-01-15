%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: compute shortest schedule length for general tree based on Equation 11 in [Floren JSAC'04]
%               only for ideal links, to sanity check scheduling algorithms, i.e., x must be the shortest deadline to reach dcr 100%
%% linearize branchs based on hops
% line 1 38
v1(1) = v(1);
v1(2) = sum(v(3:4));
v1(3) = v(8);
% line 2 25
v2(1) = v(2);
v2(2) = sum(v(5:7));
% v2(3) = 0;
v3(1) = v(9);
v3(2) = v(10);
% sum(v1) + sum(v2)
%% convert each branch into N_e
u = v3;
% truncate the last node w/ pkts to the end (i.e., trailing zeros) bcoz they do not matter as far as scheduling is concerned; otherwise mistake for T(i) when i > n
% u = [1 1 1 1 0 2];
% u = [u zeros(1, 100)];    % removing trailing 0's
idx = find(u, 1, 'last');
u = u(1 : idx);

n = length(u);
% last active time
T = zeros(n, 1);

for i = 1 : n
    if u(i) > 0
        if i > 1
            T(i) = i - 2 + 2 * sum(u(i : end));
        else
            T(i) = u(i) + 2 * sum(u(i + 1 : end));
        end
    else
        T(i) = i - 1 + 2 * sum(u(i + 1 : end));
    end
end
len = max(T);

q = [];
q(1) = u(1);
for i = 2 : n
    l = u(i);
    if l < 1
        continue;
    end
    for j = 0 : (l - 1)
        q(len - T(i) + 2 * j + i) = 1;
    end
end

%%
u3 = q;

%% x is shortest schedule length
% if length(u1) > length(u2)
%     u2 = [u2 zeros(1, length(u1) - length(u2))];
% else
%     u1 = [u1 zeros(1, length(u2) - length(u1))];
% end
u1 = [u1 zeros(1, 3)];
u3 = [u3 zeros(1, 36)];
u = u1 + u2 + u3;
% u = q;
x = -inf;
for i = 1 : length(u)
    tmp = i - 1 + sum(u(i : end));
    if x < tmp
        x = tmp;
    end
end


%% formular to compute packets' arrival time
% t_i: i-th non-empty node's last packet arrival time at BS
% s_i: total # of evacuated packets up to i-th non-empty node
ix = find(v > 0);
len = length(ix);
t = zeros(len, 1);
s = zeros(len, 1);
for i = 1 : len
    idx = ix(i);
    if i > 1
        t(i) = max(t(i - 1), idx - 2) + 2 * v(idx);
    else
        if 1 == idx
            t(i) = v(idx);
        else
            t(i) = idx - 2 + 2 * v(idx);
        end
    end
    s(i) = sum(v(1 : idx));
end
sum(y(t) ~= s)
%%
% % line
% v_ = [1 1 1 1 0 2];
% v_ = [v_ zeros(1, 100)];    % removing trailing 0's
% idx = find(v_, 1, 'last');
% v_ = v_(1 : idx);
% % % 1-degree BS tree
% % v_(1) = v(1);
% % v_(2) = sum(v(2:4));
% % v_(3) = sum(v(5:7));
% % v_(4) = v(8);
% 
% x = -inf;
% for i = 1 : length(v_) %(N - 1)
%     tmp = i - 1 + v_(i) + 2 * sum(v_(i + 1 : end));
%     if x < tmp
%         x = tmp;
%     end
% end
% 
% %% tree 
% v_(1) = sum(v(1:2));
% v_(2) = 0;
% v_(3) = 1;
% v_(5) = 1;
% v_(7) = 1;
% x = -inf;
% for i = 1 : length(v_) %(N - 1)
%     tmp = i - 1 + sum(v_(i : end));
%     if x < tmp
%         x = tmp;
%     end
% end
