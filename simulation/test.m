%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: driver
%%
clear all;
clc;
REPETITION = 10;
%% generate tree
% @param n: number of nodes in the network, including the root
% @param rho: edge density, i.e., there are rho * n(n-1)/2 edges
% @param alpha: link pdr uniformly distributed btw. [alpha, 1]
N = 100;
RHO = 0.1;
ALPHA = 0;
BETA = 1;
[ETXDist parents] = generateTree(N, RHO);
% exclude root
N = N - 1;
p = rand(N, 1) * (BETA - ALPHA) + ALPHA;
cdfplot(p);
%% generate traffic
v = floor(rand(N, 1) * 10) + 1;
% v = floor(rand(N, 1) * 1.2);
% v = [v; floor(rand(N/2, 1) * 10)];
% v(end) = 0;
% v = ones(N, 1);
fprintf('total # of pkts %d\n', sum(v));
%% deadline
D = 100;

%% 
N = 100;
% v = ones(N, 1);
v = floor(rand(N, 1) * 10) + 1;
% v = floor(rand(N, 1) * 1.2);
% v = [v; floor(rand(N/2, 1) * 10)];
% v(end) = 0;
p = ones(N, 1) * 1;
% p = rand(N, 1);
% p = rand(N, 1) * 0.5 + 0.5;
% line
parents = (0 : (N - 1))';
% tree
% parents = [0 0 2]';
% parents = [0 1 1 0]';
% parents = [0 0 1 1 2 2 2 3]';
% parents = [0 1 1 1 2 2 4 6]';
%%
D = 1000;
% D = sum(v);
sum(v)
%% optimal dcr
% y = optimalMdpScheduling(parents, v, p, D);
% ref = y / sum(v)

%% greedy dcr
% 31000
y = largestBranchFirstScheduling(parents, v, p, D);
figure;
plot(y / sum(v));
%%
% ratios = zeros(REPETITION, 1);
% reqs = [];
% for round = 1 : REPETITION
% %     [y flow_delivery_cnts] = mostReliableFirstScheduling(parents, v, p, D);
%     [y flow_delivery_cnts] = largestBranchFirstScheduling(parents, v, p, D);
%     reqs = [reqs; (flow_delivery_cnts ./ v)'];
%     ratios(round) = y(end) / sum(v);
% end
% ratio = mean(ratios)
% req = mean(reqs);
% ratios = [];
% for round = 1 : REPETITION
%     % samples per round
%     SAMPLE_CNT = 1; % 10000
%     ratio = [];
%     for i = 1 : SAMPLE_CNT
%         % line
%         %y = closestFirstScheduling(v, p, D);
%         % tree
%         y = mostReliableFirstScheduling(parents, v, p, D);
%         ratio = [ratio; y / sum(v)];
%     end
%     y = mean(ratio);
%     ratios = [ratios; y];
% end
% hold off;
% plot(ratios);
% mean(ratios)
%
% hold on;
% plot(ones(REPETITION) * ref(D));
% mean(ratios * sum(v))

%% largest debt first
% transform ratio into pdr requirement
q = [];
for i = 1 : length(v)
    q = [q; ones(v(i), 1) * req(i)];
end
% q = ones(sum(v), 1) * 0.5;
[y flow_delivery_cnts] = largestDebtFirstScheduling(parents, v, p, q, D, REPETITION);
y / sum(v)

%% CR-SLF
%y = pathLen(parents, p)
[y1 flow_delivery_cnts] = crslfScheduling(parents, v, p, D);


%% largest branch first
[y1 flow_delivery_cnts] = largestBranchFirstScheduling(parents, v, p, D);

%%
clc;
for rho = 0.1 : 0.1: 1
    fprintf('%f: ', rho);
    [parents hop_cnts degrees] = generateTree(100, rho);
    fprintf('hop count %f %f, ', median(hop_cnts), mean(hop_cnts));
    t = degrees;
%     cdfplot(t(t > 1));
    % intermediate node ratio & degree
    fprintf('degree %f %f %f\n', sum(t == 1) / length(t), median(t(t > 1)), mean(t(t > 1)));
end

%%
str = 'dcr_vs_deadline';
% str = 'dcr_vs_link_quality';
% str = 'dcr_vs_traffic';
% str = 'hop_cnt_hist';
saveas(gcf, [str '.fig']);

%% a snapshot
save('collection_tree.mat', 'parents', 'hop_cnts', 'v', 'p');

%%
y = [mean(y1s); mean(y2s); mean(y3s)] / sum(v);
figure;
plot(1 : D_STEP_SIZE : D, y, 'linewidth', 2);

%%
[cnt x] = hist(hop_cnts, 7);
bar(x, 100 * cnt / sum(cnt));
% cdfplot(hop_cnts);
