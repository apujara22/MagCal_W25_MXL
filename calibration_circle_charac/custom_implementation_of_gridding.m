% John Springmann
% 8/29/12
%
% Code to grid/pixelate a sphere using icosahedron method of Tegmark
% (1996) and Teanby (2006)

clear all
clc
close all

%% step 1: define the vertices of the Icosahedron. The x,y,z coordinates 
% are given in Table 1 of the Teanby paper

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

%% step 2: define an array of triangles, where each triangle is formed by 
% the nearest 3 vertices of the icosahedron

% using the method of GridSphere()...

% vertices of the 20 triangles formed from the vertices
As = [2; 5; 9; 7; 11; 4; 6; 2; 1; 5; 3; 9; 8; 7; 12; 12; 6; 1; 3; 10];
Bs = [4; 11; 5; 9; 7; 2; 12; 5; 6; 9; 1; 7; 3; 4; 8; 6; 1; 3; 10; 8];
Cs = [11; 2; 11; 11; 4; 12; 2; 6; 5; 1; 9; 3; 7; 8; 4; 10; 10; 10; 8; 12];

triangles = zeros(20,3,3);
%   dim 1: triangle number
%   dim 2: row number of each triangle. Each row is a vertex
%   dim 3: column number of each triangle. Cols are x y z vertices

% for i = 1:20
%     triangles(i,:,:) = [ icos_verts(As(i)), icos_verts(Bs(i)), icos_verts(Cs(i))];
% end



%% plot
figure(1)
[X Y Z] = sphere;
surf(X,Y,Z);
colormap('white')
hold on
plot3(icos_verts(:,1),icos_verts(:,2),icos_verts(:,3),'b.','markersize',20)
hold off
grid on
axis square



