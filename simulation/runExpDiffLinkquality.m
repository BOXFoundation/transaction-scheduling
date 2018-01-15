%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: run the final experiments: the effect of link quality
%%
str = 'figures/dcr_vs_link_quality';

ALPHAS = 0 : 0.1 : 1;
len = length(ALPHAS);
ps = zeros(N - 1, len);

%% yxs(i, j): # of pkts collected in repetition i by slot j
y1s = zeros(REPETITION, len);
y2s = zeros(REPETITION, len);
y3s = zeros(REPETITION, len);
y4s = zeros(REPETITION, len);

for i = 1 : len
    ALPHA = ALPHAS(i);
    p = rand(N - 1, 1) * (BETA - ALPHA) + ALPHA;
    % save for LDF
    ps(:, i) = p;
    
%% execution
for repetition = 1 : REPETITION
    fprintf('repetition %d\n', repetition);
    
    y1 = mostReliableFirstScheduling(parents, v, p, D);
    y1s(repetition, i) = y1(end);
    % not y2 to be consistent with legend
    y3 = crslfScheduling(parents, v, p, D);
    y3s(repetition, i) = y3(end);
    
    y4 = largestBranchFirstScheduling(parents, v, p, D);
    y4s(repetition, i) = y4(end);
end
end
%%
for i = 1 : len
    p = ps(:, i);

    %% largest debt first
    % flow's req is uniformly set as aggregate dcr
    req = mean(y1s(:, i)) / sum(v);
    q = ones(sum(v), 1) * req;
    
    y2 = largestDebtFirstScheduling(parents, v, p, q, D, REPETITION);
    y2s(:, i) = y2(:, end);
end

%% compare
y = [mean(y1s); mean(y2s); mean(y3s); mean(y4s)] / sum(v);

figure;
plot(ALPHAS * 100, y * 100);
legend(legend_str, 'location', 'best');

%% use w/ caution; do not overwrite
% save([str '.mat'], 'y');
% saveas(gcf, [str '.fig']);
