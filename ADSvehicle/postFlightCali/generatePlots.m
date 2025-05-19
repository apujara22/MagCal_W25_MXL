% This function takes in a raw dataset and calibrated dataset and creates a
% set of plots. The plots produce are:
%   - raw data vs. time
%   - calibrated data vs. time
%   - raw data histogram
%   - calibrated data histogram
%   - raw data attitude sphere
%   - calibrated data attitude sphere
% INPUTS:
%   - datasetName: name of the dataset
%   - rawData: name of the raw data file
%   - calibratedData: name of the calibrated data file
%
% Author: Ayush Pujara
% Date Modified: 09 May 2025

function generatePlots(datasetName, rawDatafile, calibratedDatafile)

    close all;
    
    %% Read Data
    dataOrig =  readmatrix(rawDatafile);
    dataCal = readtable(calibratedDatafile);
    dataTime = readmatrix("data_ADSflight_times.csv");
    
    magX = dataOrig(:, 1);
    magY = dataOrig(:, 2);
    magZ = dataOrig(:, 3);
    magOrigNorm = sqrt(magX.^2 + magY.^2 + magZ.^2);
    
    magXcal = dataCal.cali_x;
    magYcal = dataCal.cali_y;
    magZcal = dataCal.cali_z;
    magCalNorm = sqrt(magXcal.^2 + magYcal.^2 + magZcal.^2);

    t = dataTime - dataTime(1);
        
    %% CREATE RAW DATA PLOTS

    % Raw Data vs Time
    figure;
    plot(t, magOrigNorm, 'Color', '#D95319', LineWidth=1);
    ylim([0 110]);
    xlabel("Time (sec)");
    ax = gca;
    ax.XAxis.Exponent = 0;
    ylabel("Magnitude of Magnetic Field (uT)");
    title("Raw Magnetometer Data - " + datasetName);
    print("RawData_" + datasetName, "-dpng");
    
    % Histogram of Raw Data
    figure;
    histogram(magOrigNorm, 75, 'FaceColor', '#D95319');
    xlim([0 110]);
    xlabel("Magnitude of Magnetic Field (uT)");
    ylabel("Number of Measurements");
    title("Raw Magnetometer Data Histogram - " + datasetName);
    print("RawHist_" + datasetName, "-dpng");
    
    % Attitude Sphere of Raw Data
    syms z;
    numPoints = size(magOrigNorm, 1);

    [center, radii, ~, v, ~] = ellipsoid_fit([magX, magY, magZ]);
    [X, Y, Z] = ellipsoid(center(1), center(2), center(3), radii(1), radii(2), radii(3), 80);

    innerPoints = zeros(numPoints, 3);
    outerPoints = zeros(numPoints, 3);
    
    for n=1:1:numPoints
        syms z;
        x = magX(n);
        y = magY(n);
        eqn1 = v(1)*x^2 + v(2)*y^2 + v(3)*z^2 + 2*v(4)*x*y + 2*v(5)*x*z + ...
                2*v(6)*y*z + 2*v(7)*x + 2*v(8)*y + 2*v(9)*z + v(10) == 0;
        z = double(solve(eqn1, z));

        normEllipse = sqrt((x-center(1))^2 + (y-center(2))^2 + (z(1)-center(3))^2);

        if ( ((x-center(1)^2) + (y-center(2))^2 + (magZ(n)-center(3))^2) < normEllipse)
            innerPoints(n, 1) = x;
            innerPoints(n, 2) = y;
            innerPoints(n, 3) = magZ(n);
        else
            outerPoints(n, 1) = x;
            outerPoints(n, 2) = y;
            outerPoints(n, 3) = magZ(n);
        end
        n
        if (n > 20)
            break;
        end
    end

    figure;
    scatter3(outerPoints(:,1), outerPoints(:,2), outerPoints(:,3), 20, 'filled', MarkerFaceColor='#7E2F8E', MarkerEdgeColor='none');
    hold on;
    scatter3(innerPoints(:,1), innerPoints(:,2), innerPoints(:,3), 20, 'filled', MarkerFaceColor='#4DBEEE', MarkerEdgeColor='none');

    surf(X, Y, Z, FaceAlpha=0.2, EdgeColor='none', FaceColor='#77AC30'); % Ellipsoid
%     xlim([-80 80]);
%     ylim([-80 80]);
%     zlim([-80 80]);
    axis equal;
    xlabel('Mag X');
    ylabel('Mag Y');
    zlabel('Mag Z');
    title('Raw Data Scatter');
    %print("RawAttitudeSphere_" + datasetName, "-dpng");
    
    %% CREATE CALIBRATED DATA PLOTS

    % Calibrated Data vs. Time
    figure;
    plot(t, magCalNorm, 'Color', '#0072BD', LineWidth=1);
    ylim([0 110]);
    xlabel("Time (sec)");
    ax = gca;
    ax.XAxis.Exponent = 0;
    ylabel("Magnitude of Magnetic Field (uT)");
    title("Calibrated Magnetometer Data - " + datasetName);
    print("CaliData_" + datasetName, "-dpng");
    
    % Histogram of Calibrated Data
    figure;
    histogram(magCalNorm, 75, 'FaceColor', '#0072BD');
    xlim([0 110]);
    xlabel("Magnitude of Magnetic Field (uT)");
    ylabel("Number of Measurements");
    title("Calibrated Data Histogram - " + datasetName);
    print("CaliHist_" + datasetName, "-dpng");
    
    % Attitude Sphere of Calibrated Data
    figure;
    scatter3(magXcal, magYcal, magZcal, 5, 'filled');
    hold on;
    %surf(magXcalE, magYcalE, magZcalE, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', '#77AC30'); % Ellipsoid
    xlim([-80 80]);
    ylim([-80 80]);
    zlim([-80 80]);
    axis equal;
    xlabel('Mag X');
    ylabel('Mag Y');
    zlabel('Mag Z');
    title('Calibrated Data Scatter');
    print("CaliAttitudeSphere_" + datasetName, "-dpng");

end