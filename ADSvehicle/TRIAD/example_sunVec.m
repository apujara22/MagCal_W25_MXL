clear;

% Define location
Lat = 42.220223;         % [degrees]
Long = -85.195439;       % [degrees]

% Create Time-stamp vector in the format [Year, Month, Day, Hour, Minute, Second]
TS = [2025, 2, 22, 14, 00, 00];

% Example 1: call function to evaluate sun position - using default coefficients
SP = sunpos(TS, Lat, Long)

% Sample output:
% SP = 
% 
%   struct with fields:
% 
%               ELong: 132.9135
%           ELong_deg: 7.6154e+03
%                EObl: 0.4090
%            EObl_deg: 23.4364
%      RightAscension: 0.9258
%         Declination: 0.3335
%           HourAngle: 133.6978
%     ZenithAngle_rad: 1.5084
%         Azimuth_rad: 5.0848
%         ZenithAngle: 86.4246
%             Azimuth: 291.3404
%              SunVec: [-0.9296 0.3632 0.0624]

% % Example 2: Sun path angles over a day
% hour = (1:24)';
% temp = ones(size(hour));
% TS = [2020*temp, 5*temp, 15*temp, hour, 0*temp, 0*temp];
% SP = sunpos(TS, Lat, Long);
% % Plot elevation angle = 90-Zenith Angle
% plot(SP.Azimuth, 90-SP.Zenith, '.-')
% xlabel('Azimuth angle, from North [degrees]')
% ylabel('Elevation angle, from Horizon [degrees]')
% grid on