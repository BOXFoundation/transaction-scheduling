%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: configure the final experiments
%%
clear all;
clc;
%% shared parameters
% @param n: number of nodes in the network, including the root
N = 100;

REPETITION = 1000;
% to be consistent with order in related work
legend_str = {'BLF', 'LDF', 'CR-SLF', 'LBF'};

%% restore previous configuration
load('collection_tree.mat');


%% deadline
% 1000 for evacuation ideal links
D = 1000 + 1; %sum(v);

%% assign link pdr
% @param alpha: link pdr uniformly distributed btw. [alpha, 1]
ALPHA = 0;
BETA = 1;
% for ALPHA = 0.1 : 0.2 : 1
% cdfplot(p);
% cdfplot(hop_cnts);
p = rand(N - 1, 1) * (BETA - ALPHA) + ALPHA;
% [0 ALPHA]
% p = rand(N - 1, 1) * ALPHA + 0.5;
% p = ones(N - 1, 1) * 1;

%% generate tree
% @param rho: edge density, i.e., there are rho * n(n-1) edges
% for RHO = 0.2 : 0.2 : 0.2
RHO = 0.2; % 1.5 fully connected
% [parents] = generateTree(N, RHO);
[parents hop_cnts] = generateTree(N, RHO);
if sum(isinf(hop_cnts)) > 0
    fprintf('skip rho %f\n', RHO);
%     continue;
else
    fprintf('%f\n', mean(hop_cnts));
end
% cdfplot(hop_cnts);

%% generate traffic
% for Q = 2 : 4 : 20
% max # of sensors; must be > 1
Q = 20; %3;
%v = floor(rand(length(parents), 1) * Q);
v = floor(rand(N - 1, 1) * Q);
% v = ones(length(parents), 1);
fprintf('total # of pkts %d\n', sum(v));

