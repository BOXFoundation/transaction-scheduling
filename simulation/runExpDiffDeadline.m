%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: run the final experiments: the effect of deadline
%%
str = 'figures/dcr_vs_deadline';

D = 5000 + 1; %sum(v);
D_STEP_SIZE = 500;
Ds = 1 : D_STEP_SIZE : D;
len = length(Ds);

%% yxs(i, j): # of pkts collected in repetition i by slot j
y1s = zeros(REPETITION, len);
y2s = zeros(REPETITION, len);
y3s = zeros(REPETITION, len);
y4s = zeros(REPETITION, len);

%% execution
for repetition = 1 : REPETITION
    fprintf('repetition %d\n', repetition);
    
    y1 = mostReliableFirstScheduling(parents, v, p, D);
    y1s(repetition, :) = y1(Ds);
    % not y2 to be consistent with legend
    y3 = crslfScheduling(parents, v, p, D);
    y3s(repetition, :) = y3(Ds);
    
    y4 = largestBranchFirstScheduling(parents, v, p, D);
    y4s(repetition, :) = y4(Ds);
end


for i = 1 : len
    D = Ds(i);
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
plot(Ds, y * 100);
legend(legend_str, 'location', 'best');

%% use w/ caution; do not overwrite
save([str '.mat'], 'y');
saveas(gcf, [str '.fig']);
