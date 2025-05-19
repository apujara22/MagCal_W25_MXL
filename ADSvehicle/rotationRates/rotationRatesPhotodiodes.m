% This is a script to determine z-axis rotation rate for a vehicle being
% shined on by a floodlight. We find the rotation rate using photodiode
% data and compare this to gyroscope data. 10 sets of data were
% collected: for each of the five rates, there is a set of data with the
% light shined normal to the side of the vehicle, and a set with the light
% shined down at a 30deg angle. So far, only the normal data has been
% processed. Five plots are produced - one for each rotation rate.
%
% Author: Ayush Pujara
% Date Modified: 09 May 2025

clear;
close all;

% Read in data

data20 = readmatrix('data_1745446091.csv');
data40 = readmatrix('data_1745446137.csv');
data80 = readmatrix('data_1745446173.csv');
data140 = readmatrix('data_1745446265.csv');
data220 = readmatrix('data_1745446317.csv');

% data20tilt = readmatrix('data_1745446830.csv');
% data40tilt = readmatrix('data_1745446878.csv');
% data80tilt = readmatrix('data_1745446917.csv');
% data140tilt = readmatrix('data_1745446966.csv');

overlap = false;
twoD = false;
threeD = false;

[gyro20, photo20] = calcRates(data20, 20, overlap, twoD, threeD);
[gyro40, photo40] = calcRates(data40, 40, overlap, twoD, threeD);
[gyro80, photo80] = calcRates(data80, 80, overlap, twoD, threeD);
[gyro140, photo140] = calcRates(data140, 140, overlap, twoD, threeD);
[gyro220, photo220] = calcRates(data220, 220, overlap, twoD, threeD);

disp("Gyroscope Mean: " + gyro20 + " ; Photo Mean: " + photo20);
disp("Gyroscope Mean: " + gyro40 + " ; Photo Mean: " + photo40);
disp("Gyroscope Mean: " + gyro80 + " ; Photo Mean: " + photo80);
disp("Gyroscope Mean: " + gyro140 + " ; Photo Mean: " + photo140);
disp("Gyroscope Mean: " + gyro220 + " ; Photo Mean: " + photo220);


% This is the function that does the work. It plots the gyroscope and
% derived rotation rates.
%
% INPUTS:
%   "dataset": name of the dataset
%   "knownRate": true, known rotation rate
%   "overlap": whether to plot all measured sun vectors on one plot
%   "twoD": whether to do an animated 2D plot of measured sun vectors
%   "threeD": whether to do an animated 3D plot of measured sun vectors
%
% OUTPUTS:
%   "gyroMean": mean value of rotation rate from gyroscope
%   "photoMean": mean value of rotation rate derived from photodiodes
function [gyroMean, photoMean] = calcRates(dataset, knownRate, overlap, twoD, threeD)

    % Constants
    Vref = 3.0;         % [V]
    sigma = 0.05;       % [V]
    
    % Rotation Rate = 20 deg/s
    
    time = dataset(:, 1) - dataset(1, 1);
    %gyroX = dataset(:, 6) / 32.8;
    %gyroY = dataset(:, 7) / 32.8;
    gyroZ = dataset(:, 8) / 32.8;
    
    % Measured sun vector
    Xplus = dataset(:, 22) / 4095 * Vref;  % convert bits to [V]
    Yplus = dataset(:, 23) / 4095 * Vref;
    Xminus = dataset(:, 24) / 4095 * Vref * -1;
    Yminus = dataset(:, 25) / 4095 * Vref * -1;
    Zminus = dataset(:, 26) / 4095 * Vref * -1;
    
    tricA = dataset(:, 28) / 4095 * Vref;
    tricB = dataset(:, 29) / 4095 * Vref;
    tricC = dataset(:, 30) / 4095 * Vref;
    
    sunX = zeros(size(Xplus, 1), 1);
    sunY = zeros(size(Yplus, 1), 1);
    sunZ = zeros(size(tricA, 1), 1);
    sunVecMeasured = zeros(size(Xplus, 1), 3);
    
    for n=1:1:size(tricA)
    
        % For both X and Y, pick the face (+ or -) that detects brighter
        % source:

        if (abs(Xplus(n)) > abs(Xminus(n)))
            sunX(n) = Xplus(n);
        else
            sunX(n) = Xminus(n);
        end
        
        if (abs(Yplus(n)) > abs(Yminus(n)))
            sunY(n) = Yplus(n);
        else
            sunY(n) = Yminus(n);
        end
    
        % Use Springmann's method to find the Zplus component of the measured
        % sun vector by using the three photodiodes on the Triclops:

        y = [tricA(n); tricB(n); tricC(n)] ./ Vref;    % y-vector
        H = [sind(10)*cosd(60), -sind(10)*sind(60), cosd(10); ...
             -sind(10), 0, cosd(10); ...
             sind(10)*cosd(60), sind(10)*sind(60), cosd(10)];       % H-vector
        
        R = eye(3) .* sigma^2 ./ Vref;                              % Measurement Covariance
        tempZ = (H' * inv(R) * H) \ H' * inv(R) * y;                % sEst-vector
        
        Zplus = tempZ(3);
    
        % Account for albedo

        if (abs(Zplus) > abs(Zminus))
            sunZ(n) = Zplus;
        else
            sunZ(n) = Zminus(n);
        end
    
        sunVecIndividual = [sunX(n), sunY(n), sunZ(n)];
        sunVecMeasured(n, 1) = sunVecIndividual(1) / norm(sunVecIndividual);
        sunVecMeasured(n, 2) = sunVecIndividual(2) / norm(sunVecIndividual);
        sunVecMeasured(n, 3) = sunVecIndividual(3) / norm(sunVecIndividual);
    
    end

    % Calculate rotation rates using change in angle between consecutive
    % vectors

    % Take the moving average of the measured sun vectors
    %sunVecMeasured(:, 1) = movmean(sunVecMeasured(:, 1), 3);
    %sunVecMeasured(:, 2) = movmean(sunVecMeasured(:, 2), 3);

    angles = zeros(size(sunVecMeasured, 1) - 1, 1);

    for n = 1:1:size(angles, 1)
        v1 = sunVecMeasured(n, 1:2);
        v2 = sunVecMeasured(n+1, 1:2);
        dotProd = dot(v1, v2);
        norms = norm(v1) * norm(v2);
        angles(n) = acosd(dotProd / norms);
    end

    rates = angles ./ diff(time);

    % OUTPUTS
    gyroMean = mean(gyroZ);
    photoMean = mean(rates);

    % ------------------------ PLOTS ----------------------------

    % Plot new rotation rates vs. known rotation rates

    figure;
    plot(time(1:end-1), rates, LineWidth=2, DisplayName="Dervied from Photodiodes");
    hold on;
    plot(time, gyroZ, LineWidth=2, DisplayName="Gyroscope Output");

    xlim([0 10]);

    xlabel("Time (sec)");
    ylabel("z-axis Rotation Rate (dps)");
    title("Measured Rotation Rate for Known " + knownRate + " dps");
    legend(Location="Northwest");

    print(["ratesPlot_" + knownRate], "-dpng");

    % TWO-D Overlaped Plot of Sun Vectors

    if (overlap)

        figure;
        xlabel('X-Axis');
        ylabel('Y-Axis');
        xlim([-1 1]);
        ylim([-1 1]);
        hold on;
    
        for i=1:size(sunVecMeasured, 1)
                quiver(0, 0, sunVecMeasured(i, 1), sunVecMeasured(i, 2), ...
                    LineWidth=2, MaxHeadSize=0.1);
        end

    end

    % TWO-D Animated plot showing measured "sun" vectors over time

    if (twoD)
            
        figure;
        xlabel('X-Axis');
        ylabel('Y-Axis');
        xlim([-1 1]);
        ylim([-1 1]);
        set(gca, 'XLimMode', 'manual', 'YLimMode', 'manual');
        axis equal;
        
        for i=1:1:size(sunVecMeasured, 1)
        
            delete(findall(gca, 'Type', 'Quiver')); 
            quiver(0, 0, sunVecMeasured(i, 1), sunVecMeasured(i, 2), ...
                LineWidth=2, MaxHeadSize=0.1);
        
            drawnow;
            pause(0.1);
            i
        end

    end % end of 2d plot
    
    % THREE-D Animated plot showing measured "sun" vectors over time

    if (threeD)
    
        figure;
        xlabel('X-Axis');
        ylabel('Y-Axis');
        zlabel('Z-Axis');
        xlim([-1 1]);
        set(gca, 'XLimMode', 'manual', 'YLimMode', 'manual', 'ZLimMode', 'manual')
        
        axis equal;
        
        for i=1:1:size(sunVecMeasured, 1)
        
            delete(findall(gca, 'Type', 'Quiver')); 
            quiver3(0, 0, 0, sunVecMeasured(i, 1), sunVecMeasured(i, 2), sunVecMeasured(i, 3), ...
                0, LineWidth=2, MaxHeadSize=0.1);
        
            drawnow;
            pause(0.1);
            i
        end

    end % end of 3d plot
    
    % Determine angle between normal plane and cone of possible sun locations
    % V = Vref * cos(theta);
    % thetaX = acosd(sunX / Vref);
    % thetaY = acosd(sunY / Vref);

end % end of function

