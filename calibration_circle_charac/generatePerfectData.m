% This program has various functions that generate perfect attitude spheres
% with different distributions of data across their surfaces. Sphere
% methods:
%   "icosahedron": Icosahedron-Based Approach
%   "random": Random Distribution
%   "fibonacci": Fibonacci Lattice
%
% INPUTS:
%   "numPoints": Number of data points on sphere
%   "radius": Radius of sphere
% OUTPUTS:
%   "coordsXYZ": Coordinates of resulting sphere as three columns:
%                [x, y, z]
%
% Author: Ayush Pujara
% Date Modified: 15 May 2025

clear;
close all;

% Icosahedron Method - using "icosphere" function in this folder
[ico42, V1] = icosphere(1);
[ico162, V2] = icosphere(2);
[ico642, V3] = icosphere(3);
[ico2562, V4] = icosphere(4);
[ico10242, V5] = icosphere(5);
writetable(ico42, "data_ico42.csv");
writetable(ico162, "data_ico162.csv");
writetable(ico642, "data_ico642.csv");
writetable(ico2562, "data_ico2562.csv");
writetable(ico10242, "data_ico10242.csv");
% Plot
x = table2array(ico2562(2:end, 1));
y = table2array(ico2562(2:end, 2));
z = table2array(ico2562(2:end, 3));
figure;
scatter3(x, y, z, 10, 'filled');
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Perfect Sphere - Icosahedron Method (Radius = 1, numPoints = 2562)');
axis equal;

% Orthogonal Circles Method
% circles42 = circles(42);
% circles162 = circles(162);
% circles642 = circles(642);
% circles2562 = circles(2562);
% writetable(circles42, "data_circles42.csv");
% writetable(circles162, "data_circles162.csv");
% writetable(circles642, "data_circles642.csv");
% writetable(circles2562, "data_circles2562.csv");

% Random Distribution Method
rand42 = random(42);
rand162 = random(162);
rand642 = random(642);
rand2562 = random(2562);
rand10242 = random(10242);
writetable(rand42, "data_rand42.csv");
writetable(rand162, "data_rand162.csv");
writetable(rand642, "data_rand642.csv");
writetable(rand2562, "data_rand2562.csv");
writetable(rand10242, "data_rand10242.csv");

% Fibonacci Lattice Method
fib42 = fibonacci(42);
fib162 = fibonacci(162);
fib642 = fibonacci(642);
fib2562 = fibonacci(2562);
fib10242 = fibonacci(10242);
writetable(fib42, "data_fib42.csv");
writetable(fib162, "data_fib162.csv");
writetable(fib642, "data_fib642.csv");
writetable(fib2562, "data_fib2562.csv");
writetable(fib10242, "data_fib10242.csv");


function [coordsXYZ] = icosahedron(numPoints)

    % This script is adapted from John Springmann's code in the MXL GDrive.

    % Define the vertices of the Icosahedron. The x,y,z coordinates 
    % are given in Table 1 of the Teanby paper.
    phi = 2*cos(pi/5);
    icos_verts = [  -1,  phi,  0;
                     1,  phi,  0;
                    -1, -phi,  0;
                     1, -phi,  0;
                     0, -1,  phi;
                     0,  1,  phi;
                     0, -1, -phi;
                     0,  1, -phi;
                     phi,  0, -1;
                     phi,  0,  1;
                    -phi,  0, -1;
                    -phi,  0,  1;
                  ];

    % normalize the the length of each vector (origin to vertices)
    numVerts = size(icos_verts,1);

    for i = 1:numVerts
        icos_verts(i,:) = icos_verts(i,:)/norm(icos_verts(i,:));
    end

    % define an array of triangles, where each triangle is defined by 3
    % adjacent vertices

    % vertices of the 20 triangles formed from the vertices
%     As = [2; 5; 9; 7; 11; 4; 6; 2; 1; 5; 3; 9; 8; 7; 12; 12; 6; 1; 3; 10];
%     Bs = [4; 11; 5; 9; 7; 2; 12; 5; 6; 9; 1; 7; 3; 4; 8; 6; 1; 3; 10; 8];
%     Cs = [11; 2; 11; 11; 4; 12; 2; 6; 5; 1; 9; 3; 7; 8; 4; 10; 10; 10; 8; 12];

    As = [1; 1; 1; 1; 1; 2; 6; 12; 11; 8; 4; 4; 4; 4; 4; 5; 3; 7; 9; 10];
    Bs = [12; 6; 2; 8; 11; 6; 12; 11; 8; 2; 10; 5; 3; 7; 9; 10; 5; 3; 7; 9];
    Cs = [6; 2; 8; 11; 12; 10; 5; 3; 7; 9; 5; 3; 7; 9; 10; 6; 12; 11; 8; 2];
    
    triangles = zeros(3, 3, 20);
    
    for i = 1:20
        icos_verts(As(i), :)
        triangles(1, 1, i) = icos_verts(As(i), 1);
        triangles(1, 2, i) = icos_verts(As(i), 2);
        triangles(1, 3, i) = icos_verts(As(i), 3);
        
        triangles(2, 1, i) = icos_verts(Bs(i), 1);
        triangles(2, 2, i) = icos_verts(Bs(i), 2);
        triangles(2, 3, i) = icos_verts(Bs(i), 3);

        triangles(3, 1, i) = icos_verts(Cs(i), 1);
        triangles(3, 2, i) = icos_verts(Cs(i), 2);
        triangles(3, 3, i) = icos_verts(Cs(i), 3);
    end


%     figure;
%     hold on;
%     axis equal;
%     view(3);
% 
%     for i = 1:20
%         plot3([triangles(1, 1, i), triangles(1, 2, i), triangles(1, 3, i), triangles(1, 1, i)], ...
%         [triangles(2, 1, i), triangles(2, 2, i), triangles(2, 3, i), triangles(2, 1, i)], ...
%         [triangles(3, 1, i), triangles(3, 2, i), triangles(3, 3, i), triangles(3, 1, i)], ...
%         LineWidth=2);
%     end

    figure;
    hold on;
    axis equal;
    view(3);

    for i = 1:size(As)
        tri = icos_verts([As(i), Bs(i), Cs(i), As(i)], :);
        plot3(tri(:,1), tri(:,2), tri(:,3), LineWidth=2);
    end

    close all;

    % bisect each side of each triangle and normalize the vector. this
    % leads to three additional vertices per triangle

    new_verts = zeros(30, 3);

    n = 1;
    for i = 1:20
        vert1 = icos_verts(As(i), :) + icos_verts(Bs(i), :)
        vert1 = vert1 / norm(vert1)
        vert2 = icos_verts(Bs(i), :) + icos_verts(Cs(i), :)
        vert2 = vert2 / norm(vert2)
        vert3 = icos_verts(As(i), :) + icos_verts(Cs(i), :)
        vert3 = vert3 / norm(vert3)

        if ~ismember(vert1, new_verts, 'rows')
            new_verts(n, :) = vert1;
            n = n + 1;
        end

        if ~ismember(vert2, new_verts, 'rows')
            new_verts(n, :) = vert2;
            n = n + 1;
        end

        if ~ismember(vert3, new_verts, 'rows')
            new_verts(n, :) = vert3;
            n = n + 1;            
        end
    end

    verts = [icos_verts; new_verts];

    figure;
    plot3(verts(:,1), verts(:,2), verts(:,3), '.', MarkerSize=15)
    grid on;
    axis square;

    mag_x = verts(:, 1);
    mag_y = verts(:, 2);
    mag_z = verts(:, 3);

    coordsXYZ = table(mag_x, mag_y, mag_z);

end

function [coordsXYZ] = circles(numPoints)

    % DO NOT CHANGE ___________________________________
        % Generate points for three orthogonal sets of circles on a sphere
        numPoints = 50; % Number of points per circle
        totalOffset = deg2rad(90); % INPUT - angular offset of extra circles from originals
        angleOffset = deg2rad(3); % Offset for additional circles
        numCircles = 2 + 2*(totalOffset / angleOffset); % Number of circles per axis
        r = 1; % Sphere radius
    % DO NOT CHANGE____________________________________
    
    % Generate base angles
    theta = linspace(0, 2*pi, pointsPerCircle);
    phiOffsets = linspace(-totalOffset, totalOffset, pointsPerCircle); % Small variations in phi
    
    % Initialize storage for all points
    x = [];
    y = [];
    z = [];
    
    % Generate multiple nearby circles in the XY plane
    for phi = pi/2 + phiOffsets
        x = [x, radius * cos(theta) * sin(phi)];
        y = [y, radius * sin(theta) * sin(phi)];
        z = [z, radius * cos(phi) * ones(size(theta))];
    end
    
    % Generate multiple nearby circles in the XZ plane
    for phi = phiOffsets
        x = [x, radius * cos(theta) * cos(phi)];
        y = [y, radius * sin(phi) * ones(size(theta))];
        z = [z, radius * sin(theta) * cos(phi)];
    end
    
    % Generate multiple nearby circles in the YZ plane
    for phi = phiOffsets
        x = [x, radius * sin(phi) * ones(size(theta))];
        y = [y, radius * cos(theta) * cos(phi)];
        z = [z, radius * sin(theta) * cos(phi)];
    end

    x = transpose(x);
    y = transpose(y);
    z = transpose(z);

    norms = sqrt(x.^2 + y.^2 + z.^2);

    mag_x = x(1:end);
    mag_y = y(1:end);
    mag_z = z(1:end);

    coordsXYZ = table(mag_x, mag_y, mag_z);
    
    % Plot the points
    figure;
    scatter3(mag_x, mag_y, mag_z, 10, 'filled');
    axis equal;
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    
    grid on;
    daspect([1 1 1]);

end

function [coordsXYZ] = random(numPoints)

    zNoise = 0;
    radius = 1;

    % Generate random surface points
    theta = 2 * pi * rand(numPoints, 1);
    phi = acos(1 - 2 * rand(numPoints, 1));
    
    % Convert spherical coordinates to Cartesian
    x = radius .* cos(theta) .* sin(phi);
    y = radius .* sin(theta) .* sin(phi);
    z = radius .* cos(phi);

    x = radius .* x ./ sqrt(x.^2 + y.^2 + z.^2);
    y = radius .* y ./ sqrt(x.^2 + y.^2 + z.^2);
    z = radius .* z ./ sqrt(x.^2 + y.^2 + z.^2);

    norms = sqrt(x.^2 + y.^2 + z.^2)

    mag_x = x(1:end);
    mag_y = y(1:end);
    mag_z = z(1:end);

    coordsXYZ = table(mag_x, mag_y, mag_z);
    
    % Plot
    figure;
    scatter3(x, y, z, 10, 'filled');
    axis equal;
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    title(['Perfect Sphere - Random Distribution (Radius = ', num2str(radius), ', numPoints = ' num2str(numPoints), ')']);
    
    grid on;
    daspect([1 1 1]);

end

function [coordsXYZ] = fibonacci(numPoints)

    epsilon = 0.5;
    radius = 1;

    % Generate uniformly distributed sphere surface points using Fibonacci lattice
    goldenRatio = (1 + sqrt(5)) / 2;
    indices = (0:numPoints-1)';

    x = mod(indices/goldenRatio, 1);
    y = (indices + epsilon) / (numPoints-1 + 2*epsilon) ;

    theta = 2 * pi * x;
    phi = acos(1 - 2*y);
    
    % Compute spherical coordinates using Fibonacci lattice
%     phi = acos(1 - 2 * (indices + 0.5) / numPoints);
%     theta = 2 * pi * indices / goldenRatio;
    
    % Convert spherical coordinates to Cartesian
    x = radius * cos(theta) .* sin(phi);
    y = radius * sin(theta) .* sin(phi);
    z = radius * cos(phi);

    norms = sqrt(x.^2 + y.^2 + z.^2);

    mag_x = x(1:end);
    mag_y = y(1:end);
    mag_z = z(1:end);

    coordsXYZ = table(mag_x, mag_y, mag_z);
    
    % Plot
    figure;
    scatter3(mag_x, mag_y, mag_z, 10, 'filled');
    axis equal;
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    title(['Perfect Sphere - Fibonacci Lattice (Radius = ', num2str(radius), ', numPoints = ' num2str(numPoints), ')']);
    
    grid on;
    daspect([1 1 1]);
end