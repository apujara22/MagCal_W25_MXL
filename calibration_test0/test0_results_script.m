clear;
close all;

% Read Data
dataOrig =  readtable("test0_esti.csv");
dataCal = readtable("test0_calibrated.csv");

magX = dataOrig.rm3100_x;
magY = dataOrig.rm3100_y;
magZ = dataOrig.rm3100_z;
magOrigNorm = sqrt(magX.^2 + magY.^2 + magZ.^2);

magXcal = dataCal.Column1;
magYcal = dataCal.Column2;
magZcal = dataCal.Column3;
magCalNorm = sqrt(magXcal.^2 + magYcal.^2 + magZcal.^2);

t = (dataOrig.tIMU - dataOrig.tIMU(1)) / 1e9; % convert from ns to s

% Create Ellipse for Raw Data
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


% Create Ellipse for Calibrated Data
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


% Raw Data vs Time
figure;
plot(t, magOrigNorm, 'Color', '#D95319');
xlabel("Time (sec)");
ylabel("Magnitude of Magnetic Field (uT)");
title("Raw Magnetometer Data - Test 0");
print("RawData", "-dpng");

% Histogram of Raw Data
figure;
histogram(magOrigNorm, 75, 'FaceColor', '#D95319');
xlabel("Magnitude of Magnetic Field (uT)");
ylabel("Number of Measurements");
title("Raw Magnetometer Data Histogram - Test 0");
print("RawHist", "-dpng");

% Attitude Sphere of Raw Data
figure;
scatter3(magX, magY, magZ, 'filled');
hold on;
surf(magXe, magYe, magZe, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', '#77AC30'); % Ellipsoid
xlim([-60 60]);
ylim([-60 60]);
zlim([-60 60]);
xlabel('Mag X');
ylabel('Mag Y');
zlabel('Mag Z');
title('Raw Data and Best Fit Ellipsoid');
print("RawAttitudeSphere", "-dpng");


% Calibrated Data vs. Time
figure;
plot(t, magCalNorm, 'Color', '#0072BD');
xlabel("Time (sec)");
ylabel("Magnitude of Magnetic Field (uT)");
title("Calibrated Magnetometer Data - Test 0");
ylim([35 60]);
print("CaliData", "-dpng");

% Histogram of Calibrated Data
figure;
histogram(magCalNorm, 75, 'FaceColor', '#0072BD');
xlim([38 60]);
xlabel("Magnitude of Magnetic Field (uT)");
ylabel("Number of Measurements");
title("Calibrated Data Histogram - Test 0");
print("CaliHist", "-dpng");

% Attitude Sphere of Calibrated Data
figure;
scatter3(magXcal, magYcal, magZcal, 'filled');
hold on;
surf(magXcalE, magYcalE, magZcalE, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', '#77AC30'); % Ellipsoid
xlim([-60 60]);
ylim([-60 60]);
zlim([-60 60]);
xlabel('Mag X');
ylabel('Mag Y');
zlabel('Mag Z');
title('Calibrated Data and Best Fit Ellipsoid');
print("CaliAttitudeSphere", "-dpng");

