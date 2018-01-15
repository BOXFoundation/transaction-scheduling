%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Xiaohui Liu (whulxh@gmail.com)
%   Function: generate a tree and pdr for all its links
%   Description: generate a tree in a random network (undirected graph) specified; first, a root is randomly chosen;
%   then a shortest-path tree is built based on link ETX
%%
% @param n: number of nodes in the network
% @param rho: edge density, i.e., there are rho * n(n-1)/2 edges
% @param alpha: link pdr uniformly distributed btw. [alpha, beta]
% @return parents: tree
% @return p_i: PDR from node i to its parent
function [parents hop_cnts degrees] = generateTree(n, rho)
    % root selection
    root = 1; % ceil(rand * n);
%     fprintf('root is always %d\n', root);
    
    % randomly place nodes in a unit square
    x = rand(n, 1);
    y = rand(n, 1);
    
    % place root at origin
%     x(root) = 0;
%     y(root) = 0;
    
    hop_cnts = inf(n - 1, 1);
    % random network generation; connectivity matrix
    link_matrix = zeros(n);
    for i = 1 : n
        for j = (i + 1) : n
            if sqrt((x(i) - x(j)) ^ 2 + (y(i) - y(j)) ^ 2) <= rho
                link_matrix(i, j) = 1;
            end
        end
    end
    % symmetric undirected
    link_matrix = link_matrix + link_matrix';
    link_matrix(link_matrix == 0) = inf;
%     fprintf('edge density %f, %f\n', rho, sum(sum(~isinf(link_matrix))) / (n * (n - 1)));
    
    % shortest-path tree
    [ETXDist, parents] = dijkstra(link_matrix, root, n);
    
    % degrees
    degrees = zeros(n, 1);
    for i = 1: n
        degrees(i) = sum(parents == i);
        if i ~= root
            % plus one outbound edge to parent
            degrees(i) = degrees(i) + 1;
        end
    end
    
    % kick root out
    parents = parents - 1;
    parents(root) = [];
    if sum(isnan(parents)) > 0
        fprintf('no parent found, disconnected graph, regenerate; maybe with large rho\n');
        return;
    end
    hop_cnts = ETXDist(2:end, 2);
%     p(root) = [];
end
