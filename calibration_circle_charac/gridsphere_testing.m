% John Springmann
% 8/29/12
%
% Testing GridSphere() and FindNearestNeighbors()

clear all
clc
close all

curr_dir = pwd;

% create points on the sphere

%cd('GridSphere\')

% can only have 12, 42, 162, ... points
% This is 12 or 2 + 10*(4^k) points

k = 4
numPts = 2 + 10*(4^k)

[latGridDeg lonGridDeg] = GridSphere(numPts);

cd(curr_dir);

% convert lat/lon to cartesian

[X Y Z] = sph2cart(lonGridDeg*pi/180,latGridDeg*pi/180,ones(size(latGridDeg)));

% points2plot = find(X >= 0 & Y >= 0 & Z >= 0);
points2plot = 1:1:size(X,1);    % plot all points

% plot the points on a sphere
figure(1)
[x y z] = sphere;
plot3(x,y,z,'k');
hold on
plot3(x',y',z','k');
plot3(X(points2plot),Y(points2plot),Z(points2plot),'r.')
% overlay the icosahedron
plotIcosahedron
hold off
grid on
axis square

% determine the angle between each grid point and it's nearest neibor

numPts = size(X,1); % seems to be the numPts defined at line 20, -1.
minAng = zeros(size(X,1),1);  % to hold the angle between the current point 
                            % and it's closest neighbor
for i = 1:numPts
    % for each point

    
    % the dot procudt of the curret point with every other point
    dotProds = X(i).*X + Y(i).*Y + Z(i).*Z;
    
    angs = acos( dotProds );
    
    % sort the angles -- min angle should be zero
    angs = sort(angs);
    
    keyboard
    
    minAng(i) = angs(2);
    
end


figure(2)
subplot(1,2,1)
plot(minAng.*180/pi,'.')
title('Angle between each point and its closest neighbor')
ylabel('deg')
xlabel('index')
subplot(1,2,2)
hist(minAng.*180/pi)
ylabel('# of occurances')
xlabel('Min Angle')
