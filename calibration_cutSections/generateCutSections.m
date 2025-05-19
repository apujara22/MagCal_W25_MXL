% This function generates a modified attitude sphere with some data taken
% out. You can either remove data along one of the axes, or remove a
% triangular section ("chunk") of data from the bottom left corner.
% INPUTS:
%   "modification": enter either: 'right', 'front', 'top', or 'chunk' to
%                   preserve the right side, preserve the front side,
%                   preserve the top, or remove a chunk.
%   "threshold": the cutoff value below which data points are removed. for
%                example, if the cutoff value is -0.5, all data points with
%                value less than -0.5 will be removed from the sphere. the
%                radius of the sphere is 1 unit.
% OUTPUTS:
%   "coordsXYZ": an nx3 matrix of the x,y,z coordinates of the modified
%                attitude sphere.
%
% Author: Ayush Pujara
% Date Modified: 11 May 2025

function [coordsXYZ] = generateCutSections(modification, threshold)

    close all;

% DO NOT CHANGE ___________________________________
    % Generate points for three orthogonal sets of circles on a sphere with positional noise
    numPoints = 50; % Number of points per circle
    totalOffset = deg2rad(90); % INPUT - angular offset of extra circles from originals
    angleOffset = deg2rad(3); % Offset for additional circles
    numCircles = 2 + 2*(totalOffset / angleOffset); % Number of circles per axis
    radius = 1; % Sphere radius
% DO NOT CHANGE____________________________________
    
    % Generate base angles
    theta = linspace(0, 2*pi, numPoints);
    phiOffsets = linspace(-totalOffset, totalOffset, numCircles); % Small variations in phi
    
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

    mag_x = x(1:end);
    mag_y = y(1:end);
    mag_z = z(1:end);

    % Modify the sphere

    n = 1;
    sizeVec = size(mag_x);
    sz = sizeVec(1);

    while (n <= sz)
        if (condition == "right")
            if (mag_x(n) < threshold)
                mag_x(n) = [];
                mag_y(n) = [];
                mag_z(n) = [];
            end
        elseif (condition == "front")
            if (mag_y(n) < threshold)
                mag_x(n) = [];
                mag_y(n) = [];
                mag_z(n) = [];
            end
        elseif (condition == "top")
            if (mag_z(n) < threshold)
                mag_x(n) = [];
                mag_y(n) = [];
                mag_z(n) = [];
            end
        else
            if (mag_x(n) < threshold && mag_y(n) < threshold && mag_z(n) < threshold)
                mag_x(n) = [];
                mag_y(n) = [];
                mag_z(n) = [];
                n = n - 1;
            end
        end
        n = n + 1;
        sizeVec = size(mag_x);
        sz = sizeVec(1);
    end

    coordsXYZ = table(mag_x, mag_y, mag_z);
    str = strcat('data_circles_', modification, num2str(threshold), '.csv');

    writetable(coordsXYZ, str);
    
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