% The function generatePlots takes the name of a dataset and creates the
% following plots:
%   - raw data vs. time
%   - ...
% INPUTS:
%   - datasetName: 
%   - rawData: 
%   - calibratedData: 

function generatePlots(datasetName, rawDatafile, calibratedDatafile, plots)

    close all;
    
    %% Read Data
    dataOrig =  readtable(rawDatafile);
    dataCal = readtable(calibratedDatafile);
    
    magX = dataOrig.mag_x(1:end);
    magY = dataOrig.mag_y(1:end);
    magZ = dataOrig.mag_z(1:end);
    magOrigNorm = sqrt(magX.^2 + magY.^2 + magZ.^2);
    
    magXcal = dataCal.cali_x;
    magYcal = dataCal.cali_y;
    magZcal = dataCal.cali_z;
    magCalNorm = sqrt(magXcal.^2 + magYcal.^2 + magZcal.^2);

    avgNorm = mean(magCalNorm)
    
    %t = (dataOrig.UnixTime - dataOrig.UnixTime(1));
    t = 1:1:size(magXcal);

    if (plots)
    
    %% Create Ellipse for Raw Data
    % Step 1: Create the design matrix
    D = [magX.^2, magY.^2, magZ.^2, 2*magX.*magY, 2*magX.*magZ, 2*magY.*magZ, 2*magX, 2*magY, 2*magZ, ones(size(magX))];
    
    % Step 2: Solve for the coefficients
    [~, ~, V] = svd(D, 0);  % Singular value decomposition
    A = V(:, end);          % Coefficients for the ellipsoid
    
    % Step 3: Form the quadratic matrix Q
    Q = [A(1)  A(4)  A(5)  A(7); 
         A(4)  A(2)  A(6)  A(8);
         A(5)  A(6)  A(3)  A(9);
         A(7)  A(8)  A(9)  A(10)];
    
    % Step 4: Extract the center
    % Center is -inv(Q33) * Q34, where Q33 is top-left 3x3, Q34 is top-right 3x1
    Q33 = Q(1:3, 1:3);
    Q34 = Q(1:3, 4);
    center = -0.5 * (Q33 \ Q34);
    
    % Step 5: Extract axes and orientation
    % Use eigenvalue decomposition to find axes lengths and directions
    [vecs, vals] = eig(Q33 / -Q(4, 4));
    axes_lengths = sqrt(1 ./ diag(vals));  % Semi-axes lengths
    [magXe, magYe, magZe] = ellipsoid(center(1), center(2), center(3), ...
                              axes_lengths(1), axes_lengths(2), axes_lengths(3), 50);
    
    
    %% Create Ellipse for Calibrated Data
    % Step 1: Create the design matrix
    D = [magXcal.^2, magYcal.^2, magZcal.^2, 2*magXcal.*magYcal, 2*magXcal.*magZcal, 2*magYcal.*magZcal, 2*magXcal, 2*magYcal, 2*magZcal, ones(size(magXcal))];
    
    % Step 2: Solve for the coefficients
    [~, ~, V] = svd(D, 0);  % Singular value decomposition
    A = V(:, end);          % Coefficients for the ellipsoid
    
    % Step 3: Form the quadratic matrix Q
    Q = [A(1)  A(4)  A(5)  A(7); 
         A(4)  A(2)  A(6)  A(8);
         A(5)  A(6)  A(3)  A(9);
         A(7)  A(8)  A(9)  A(10)];
    
    % Step 4: Extract the center
    % Center is -inv(Q33) * Q34, where Q33 is top-left 3x3, Q34 is top-right 3x1
    Q33 = Q(1:3, 1:3);
    Q34 = Q(1:3, 4);
    center = -0.5 * (Q33 \ Q34);
    
    % Step 5: Extract axes and orientation
    % Use eigenvalue decomposition to find axes lengths and directions
    [vecs, vals] = eig(Q33 / -Q(4, 4));
    axes_lengths = sqrt(1 ./ diag(vals));  % Semi-axes lengths
    [magXcalE, magYcalE, magZcalE] = ellipsoid(center(1), center(2), center(3), ...
                              axes_lengths(1), axes_lengths(2), axes_lengths(3), 50);
    
    %% CREATE RAW DATA PLOTS
    % Raw Data vs Time
    figure;
    plot(t/60, magOrigNorm, 'Color', '#D95319', LineWidth=2);
    %ylim([10 160]);
    xlabel("Time (min)");
    ax = gca;
    ax.XAxis.Exponent = 0;
    ylabel("Magnitude of Magnetic Field (uT)");
    title("Raw Magnetometer Data - " + datasetName);
    print("RawData_" + datasetName, "-dpng");
    
    % Histogram of Raw Data
    figure;
    histogram(magOrigNorm, 75, 'FaceColor', '#D95319');
    %xlim([10 160]);
    xlabel("Magnitude of Magnetic Field (uT)");
    ylabel("Number of Measurements");
    title("Raw Magnetometer Data Histogram - " + datasetName);
    print("RawHist_" + datasetName, "-dpng");
    
    % Attitude Sphere of Raw Data
    figure;
    scatter3(magX, magY, magZ, 'filled');
    hold on;
    surf(magXe, magYe, magZe, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', '#77AC30'); % Ellipsoid
    % xlim([-60 60]);
    % ylim([-60 60]);
    % zlim([-60 60]);
    axis equal;
    xlabel('Mag X');
    ylabel('Mag Y');
    zlabel('Mag Z');
    title('Raw Data Scatter');
    print("RawAttitudeSphere_" + datasetName, "-dpng");
    
    %% CREATE CALIBRATED DATA PLOTS
    % Calibrated Data vs. Time
    figure;
    plot(t/60, magCalNorm, 'Color', '#0072BD', LineWidth=2);
    %ylim([10 160]);
    xlabel("Time (min)");
    ax = gca;
    ax.XAxis.Exponent = 0;
    ylabel("Magnitude of Magnetic Field (uT)");
    title("Calibrated Magnetometer Data - " + datasetName);
    %ylim([35 60]);
    print("CaliData_" + datasetName, "-dpng");
    
    % Histogram of Calibrated Data
    figure;
    histogram(magCalNorm, 75, 'FaceColor', '#0072BD');
    %xlim([10 160]);
    xlabel("Magnitude of Magnetic Field (uT)");
    ylabel("Number of Measurements");
    title("Calibrated Data Histogram - " + datasetName);
    print("CaliHist_" + datasetName, "-dpng");
    
    % Attitude Sphere of Calibrated Data
    figure;
    scatter3(magXcal, magYcal, magZcal, 'filled');
    hold on;
    surf(magXcalE, magYcalE, magZcalE, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', '#77AC30'); % Ellipsoid
    % xlim([-60 60]);
    % ylim([-60 60]);
    % zlim([-60 60]);
    axis equal;
    xlabel('Mag X');
    ylabel('Mag Y');
    zlabel('Mag Z');
    title('Calibrated Data Scatter');
    print("CaliAttitudeSphere_" + datasetName, "-dpng");

    end

end