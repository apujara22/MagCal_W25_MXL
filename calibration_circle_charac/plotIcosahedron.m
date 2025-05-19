function plotIcosahedron()

% function to plot icosohedron in the current figure

phi = 2*cos(pi/5);

icos_verts = [0     phi     1;...
              0     -phi    1;...
              0     phi     -1;...
              0     -phi    -1;...
              1     0       phi;...
              -1    0       phi;...
              1     0       -phi;...
              -1    0       -phi;...
              phi   1       0;...
              -phi  1       0;...
              phi   -1      0;...
              -phi  -1      0];
% normalize the lengths
numVerts = size(icos_verts,1);
for i = 1:numVerts
    icos_verts(i,:) = icos_verts(i,:)/norm(icos_verts(i,:));
end

% using the method of GridSphere()...

% vertices of the 20 triangles fomed from the vertices
As = [2; 5; 9; 7; 11; 4; 6; 2; 1; 5; 3; 9; 8; 7; 12; 12; 6; 1; 3; 10];
Bs = [4; 11; 5; 9; 7; 2; 12; 5; 6; 9; 1; 7; 3; 4; 8; 6; 1; 3; 10; 8];
Cs = [11; 2; 11; 11; 4; 12; 2; 6; 5; 1; 9; 3; 7; 8; 4; 10; 10; 10; 8; 12];

triangles = cell(20,1);
%   dim 1: triangle number
%   dim 2: row number of each triangle. Each row is a vertix
%   dim 3: column number of each triangle. Cols are x y z vertices

rows2plot = [1 2 3 1];  % to connect the vertices
hold on
for i = 1:20
    triangles{i} = [ icos_verts(As(i),:); icos_verts(Bs(i),:); icos_verts(Cs(i),:)];

    plot3(triangles{i}(rows2plot,1),triangles{i}(rows2plot,2),...
        triangles{i}(rows2plot,3),'b','linewidth',2);
end
hold off
