% This function generates a noisy attitude sphere. It takes a perfect
% attitude sphere and adds noise to the the magnetic field strength values.
% Visually, this changes the radii from the origin to the points on the
% sphere.
%
% INPUTS:
%   "radius": the radius of the sphere. this is also the average magnetic
%             field strength.
%   "noise": the noise range as a fraction of the sphere radius. ex: for a
%            sphere radius of 10, to uniformly distribute the new radii
%            values between 8 and 12, enter 0.2 for the noise.
% OUTPUTS:
%   "coordsXYZ": an nx3 matrix of the x,y,z coordinates of the modified
%                attitude sphere.
%
% Author: Ayush Pujara
% Date Modified: 13 May 2025

function [coordsXYZ] = generateNoisySphere(radius, noise)

    close all;
    
    noiseMagnitude = noise;     % INPUT - max noise deviation - MAGNITUDE

% DO NOT CHANGE ___________________________________
    % Generate points for three orthogonal sets of circles on a sphere with positional noise
    numPoints = 50; % Number of points per circle
    totalOffset = deg2rad(90); % INPUT - angular offset of extra circles from originals
    angleOffset = deg2rad(3); % Offset for additional circles
    numCircles = 2 + 2*(totalOffset / angleOffset); % Number of circles per axis
    r = radius; % Sphere radius
% DO NOT CHANGE ____________________________________
    
    % Generate base angles
    theta = linspace(0, 2*pi, numPoints);
    phiOffsets = linspace(-totalOffset, totalOffset, numCircles); % Small variations in phi
    
    % Initialize storage for all points
    x = [];
    y = [];
    z = [];
    
    % Generate multiple nearby circles in the XY plane
    for phi = pi/2 + phiOffsets
        radius =  r + noiseMagnitude .* 2 .* (rand(1, numPoints) - 0.5);
        x = [x, radius .* cos(theta) * sin(phi)];
        y = [y, radius .* sin(theta) * sin(phi)];
        z = [z, radius .* cos(phi)];
    end
    
    % Generate multiple nearby circles in the XZ plane
    for phi = phiOffsets
        radius =  r + noiseMagnitude .* 2 .* (rand(1, numPoints) - 0.5);
        x = [x, radius .* cos(theta) * cos(phi)];
        y = [y, radius .* sin(phi)];
        z = [z, radius .* sin(theta) * cos(phi)];
    end
    
    % Generate multiple nearby circles in the YZ plane
    for phi = phiOffsets
        radius =  r + noiseMagnitude .* 2 .* (rand(1, numPoints) - 0.5);
        x = [x, radius .* sin(phi)];
        y = [y, radius .* cos(theta) * cos(phi)];
        z = [z, radius .* sin(theta) * cos(phi)];
    end

    x = transpose(x);
    y = transpose(y);
    z = transpose(z);

    norms = sqrt(x.^2 + y.^2 + z.^2)

    mag_x = x(1:end);
    mag_y = y(1:end);
    mag_z = z(1:end);

    coordsXYZ = table(mag_x, mag_y, mag_z);
    %str = ['data_circles_', num2str(numPoints * numCircles * 3), '.csv'];
    str = strcat('data_noisy_', num2str(r), '_', num2str(noise), '.csv');

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