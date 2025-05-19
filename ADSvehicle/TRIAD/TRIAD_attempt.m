% Use TRIAD method to obtain attitude estimation using known
% orientation of vehicle (after it landed) from ADS payload during CFL W25
% Flight 1
%
% Author: Ayush Pujara
% Date Modified: 09 May 2025

clear;
close all;

% Inputs

albedoMethod = true;   % INPUT true to account for albedo

% Constants

lat = 42.220223;                         % [deg]
lon = -85.195439;                        % [deg]
alt = 270;                               % [m]
timestamp = [2024, 6, 1, 17, 00, 00];    % [Year, Month, Day, Hour, Minute, Second] (UTC)
wgs84 = wgs84Ellipsoid;                  % [m]


%% Known Reference Vectors in NED frame

% Magnetic Field Vector, m_N
magVecNED = [19.344; -2.0160; 49.3032]; % ref. magnetic field vec, North-East-Down
% [x, y, z] = ned2ecef(magVecNED(1), magVecNED(2), magVecNED(3), ...
%             lat, lon, alt, wgs84);  % NED to ECEF
% 
% magVecECEF = [x; y; z];
% magVecECI = ecef2eci(timestamp, magVecECEF);
magVecENU = [magVecNED(2); magVecNED(1); -magVecNED(3)];

% Sun Vector, s_N

sunInfo = sunpos(timestamp, lat, lon);   
sunVecENU = sunInfo.SunVec;                   % sun vec, East-North-Up
sunVecENU = sunVecENU';
% [a, b, c] = enu2ecef(sunVecENU(1), sunVecENU(2), sunVecENU(3), ...
%                      lat, lon, alt, wgs84);  % ENU to ECEF
% 
% sunVecECEF = [a; b; c];
% sunVecECI = ecef2eci(timestamp, sunVecECEF);
% sunVecNED = [sunVecENU(2); sunVecENU(1); -sunVecENU(3)];


%% Measured Sun and Magnetometer Vectors in body-fixed frame, s_B and m_B

% Constants
Vref = 3.0;         % [V]
sigma = 0.05;       % [V]
data = readmatrix("data_landing.csv");

% Measured magnetic field vector
magX = data(1, 13) / 75;    % convert LSB to [uT]
magY = data(1, 14) / 75;    % "
magZ = data(1, 15) / 75;    % "
%magVecMeasured = [magX; magY; magZ];    % Uncomment for uncalibrated mag vector
magVecMeasured = [-17.861131517851607;-49.53927852013921; -9.950987194917662];

% Measured sun vector
Xplus = data(1, 22) / 4095 * Vref;  % convert bits to [V]
Yplus = data(1, 23) / 4095 * Vref;
Xminus = data(1, 24) / 4095 * Vref * -1;
Yminus = data(1, 25) / 4095 * Vref * -1;
Zminus = data(1, 26) / 4095 * Vref * -1;

tricA = data(1, 28) / 4095 * Vref;
tricB = data(1, 29) / 4095 * Vref;
tricC = data(1, 30) / 4095 * Vref;

if (albedoMethod == false)

    % Optimization method - ignoring albedo

    y = [Xplus; Yplus; Xminus; Yminus; Zminus; tricA; tricB; tricC] ./ Vref;  % y-vector
    H = [1, 0, 0; ...
         0, 1, 0; ...
         -1, 0, 0; ...
         0, -1, 0; ...
         0, 0, -1; ...
         sind(10)*cosd(60), -sind(10)*sind(60), cosd(10); ...
         -sind(10), 0, cosd(10); ...
         sind(10)*cosd(60), sind(10)*sind(60), cosd(10)];                     % H-vector
    
    R = eye(8) .* sigma^2 ./ Vref;                          % Measurement Covariance
    sunVecMeasured = (H' * inv(R) * H) \ H' * inv(R) * y;   % sEst-vector

else

    % Optimization method - accounting for albedo

    if (abs(Xplus) > abs(Xminus))
        sunX = Xplus;
    else
        sunX = Xminus;
    end
    
    if (abs(Yplus) > abs(Yminus))
        sunY = Yplus;
    else
        sunY = Yminus;
    end
    
    y = [tricA; tricB; tricC] ./ Vref;    % y-vector
    H = [sind(10)*cosd(60), -sind(10)*sind(60), cosd(10); ...
         -sind(10), 0, cosd(10); ...
         sind(10)*cosd(60), sind(10)*sind(60), cosd(10)];   % H-vector
    
    R = eye(3) .* sigma^2 ./ Vref;                  % Measurement Covariance
    tempZ = (H' * inv(R) * H) \ H' * inv(R) * y;    % sEst-vector
    
    Zplus = tempZ(3);
    
    if (abs(Zplus) > abs(Zminus))
        sunZ = Zplus;
    else
        sunZ = Zminus;
    end
    
    sunVecMeasured = [sunX; sunY; sunZ];

end

%% Attitude Estimation

% sunVecMeasured = [-sunVecENU(2); sunVecENU(3); -sunVecENU(1)];
% magVecMeasured = [-magVecENU(2); magVecENU(3); -magVecENU(1)];

% Reference and Measured Vectors (normalized)
m_N = magVecENU / norm(magVecENU);
s_N = sunVecENU / norm(sunVecENU);

m_B = magVecMeasured / norm(magVecMeasured);
s_B = sunVecMeasured / norm(sunVecMeasured);

norm(m_N)
norm(s_N)
norm(m_B)
norm(s_B)

% TRIAD Method
t1_B = m_B;
t2_B = cross(m_B, s_B) / norm(cross(m_B, s_B));
t3_B = cross(t1_B, t2_B);

barBT = [ t1_B t2_B t3_B ];

t1_N = m_N;
t2_N = cross(m_N, s_N) / norm(cross(m_N, s_N));
t3_N = cross(t1_N, t2_N);

NT = [ t1_N t2_N t3_N ];

barBN = barBT * NT';    % from inertial to body-fixed
NbarB = inv(barBN)      % Final rotation matrix from body-fixed to inertial frame


%% Plot Results

close all;
newMag = NbarB * magVecMeasured;
newMag = newMag / norm(newMag);
newSun = NbarB * sunVecMeasured;
newSun = newSun / norm(newSun);

figure(1);
p1 = plot3([0, newMag(1)], [0, newMag(2)], [0, newMag(3)], LineWidth=2, DisplayName='Measured Mag');
hold on;
p2 = plot3([0, newSun(1)], [0, newSun(2)], [0, newSun(3)], LineWidth=2, DisplayName='Measured Sun');
p3 = plot3([0, m_N(1)], [0, m_N(2)], [0, m_N(3)], Color='b', LineWidth=2, DisplayName='Reference Mag');
p4 = plot3([0, s_N(1)], [0, s_N(2)], [0, s_N(3)], Color='r', LineWidth=2, DisplayName='Reference Sun');
xlabel("east");
ylabel("north");
zlabel("up");
legend();

% Create Unit Vectors
xB = [1 0 0]';
yB = [0 1 0]';
zB = [0 0 1]';
xN = NbarB * xB;
yN = NbarB * yB;
zN = NbarB * zB;
xN = xN / norm(xN);
yN = yN / norm(yN);
zN = zN / norm(zN);

f = figure(2);
%plot3([0, m_N(1)], [0, m_N(2)], [0, m_N(3)], LineWidth=1);
xB = plot3([0, xN(1)], [0, xN(2)], [0, xN(3)], Color='#0072BD', LineWidth=2, DisplayName='Body x');
hold on;
yB = plot3([0, yN(1)], [0, yN(2)], [0, yN(3)], Color='#D95319', LineWidth=2, DisplayName='Body y');
zB = plot3([0, zN(1)], [0, zN(2)], [0, zN(3)], Color='#EDB120', LineWidth=2, DisplayName='Body z');
%plot3([0, barMagN(1)], [0, barMagN(2)], [0, barMagN(3)], LineWidth=1);
%plot3([0, s_N(1)], [0, s_N(2)], [0, s_N(3)], LineWidth=1);
%plot3([0, s_B(1)], [0, s_B(2)], [0, s_B(3)], LineWidth=1);

% Unit Vectors
xNbasis = plot3([0, 0.4], [0, 0], [0, 0], Color='k', LineWidth=1, DisplayName='Unit Vector for E-N-U');
plot3([0, 0], [0, 0.4], [0, 0], Color='k', LineWidth=1);
plot3([0, 0], [0, 0], [0, 0.4], Color='k', LineWidth=1);

% Ground plane
[x, y] = meshgrid(-1:0.1:1); % Generate x and y data
z = zeros(size(x, 1)); % Generate z data
plane = surf(x, y, z, FaceColor=[0.4660 0.6740 0.1880], FaceAlpha=0.2, EdgeColor='none', DisplayName='Ground');

% Misc
axis equal;
xlabel("East");
ylabel("North");
zlabel("Up");
title("ADS Vehicle Flight 1 Attitude Upon Landing - Accounting for Albedo");

xlim([-1 1]);
ylim([-1 1]);
zlim([-1 1]);
legend([xB, yB, zB, xNbasis, plane]);
