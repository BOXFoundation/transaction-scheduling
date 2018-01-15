%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: given a tree and its link pdr, compute the distance to the root from each node; link
%   length is link ETX
%   Description: from node 1 to n, node 0 is the BS
%%
function path_lens = pathLen(parents, p)
    n = length(parents);
    path_lens = zeros(n, 1);
    
    % each node
    for i = 1 : n
        node = i;
        
        path_len = 0;
        while node ~= 0
            path_len = path_len + 1 / p(node);
            node = parents(node);
        end
        path_lens(i) = path_len;
    end
end
