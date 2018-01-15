%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: total # of pkts in the subtree rooted at node i, including i
%%
% @param parents(i): parent for node i
function y = subTreePktNum(i, parents, v)
%     if i > 0
%         y = v(i);
%     else
%         y = 0;
%     end
%     
%     children = find(parents == i);        
%     for j = 1 : length(children)
%         y = y + subTreePktNum(children(j), parents, v);
%     end
    
    % BFS of the tree
    % start from BS
    y = 0;
    roots = i;
    while ~isempty(roots)
        next_roots = [];
        % each subtree
        for i = 1 : length(roots)
            root = roots(i);
            next_roots = [next_roots; find(parents == root)];
            if root > 0
                y = y + v(root);
            end
        end
        roots = next_roots;
    end
end
