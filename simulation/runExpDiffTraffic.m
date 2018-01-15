%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: run the final experiments: the effect of traffic
%%
str = 'figures/dcr_vs_traffic';

Qs = [2 5 : 5 : 40]; %[2 10 : 10 : 30];
len = length(Qs);
vs = zeros(N - 1, len);

%% yxs(i, j): # of pkts collected in repetition i by slot j
y1s = zeros(REPETITION, len);
y2s = zeros(REPETITION, len);
y3s = zeros(REPETITION, len);
y4s = zeros(REPETITION, len);

for i = 1 : len
    Q = Qs(i);
    v = floor(rand(N - 1, 1) * Q);
    % save for LDF
    vs(:, i) = v;
    
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

for i = 1 : len
    v = vs(:, i);

    %% largest debt first
    % flow's req is uniformly set as aggregate dcr
    req = mean(y1s(:, i)) / sum(v);
    q = ones(sum(v), 1) * req;
    
    y2 = largestDebtFirstScheduling(parents, v, p, q, D, REPETITION);
    y2s(:, i) = y2(:, end);
end

%% compare
y = [mean(y1s); mean(y2s); mean(y3s); mean(y4s)] ./ repmat(sum(vs), 4, 1);

figure;
plot(Qs, y * 100);
legend(legend_str, 'location', 'best');

%% use w/ caution; do not overwrite
save([str '.mat'], 'y');
saveas(gcf, [str '.fig']);
