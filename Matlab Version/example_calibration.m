% Prince Kuevor
% January 18, 2022

% This script is meant to be an example of how to use Springman's
% Magnetometer calibration code. 

% I've included the needed functions here for convenience, but know that
% they also exist in the MXL SVN repos at...
%   SVN/grifex/Operations/Data_Analysis/Magnetometer/functions/

% In addition, these funcitons exist in Prince's private research code Git
% repo. 

% Please contact Prince Kuevor (kuevpr@umich.edu) if you have any trouble
% finding the necesasary code for this example script. 

% The raw data included here was gathered by Prince Kuevor on April 23,
% 2021. It is included here for instructional purposes of using this
% example script.
% Note: the raw data has A LOT of columns that are irrelevant to this
% calibration process. The data is from a drone used for Prince's research.

% The columns you are most interested in are
%   Raw MPU9250 Magnetometer (included on BeagleBone Blue)
%       - mag_X [uT]
%       - mag_Y [uT]
%       - mag_Z [uT]
%   Raw PNI RM3100 Magnetometer (added to drone by Prince Kuevor)
%       - rm3100_x [uT]
%       - rm3100_y [uT]
%       - rm3100_z [uT]
%   Timestamps
%       - tPNI [nano-seconds since Epoch] (time that RM3100 data was taken)
%       - epoch_time_ns [nano-seconds since Epoch] (time that MPU9250 data was taken)
clear
clc

%% Global Settings
% This is really just a bunch of settings for plots


set(groot,'defaultLineLineWidth',1.5) %Defualt line width
set(groot,'DefaultAxesXGrid',1)     %Grid for X-axes
set(groot,'DefaultAxesYGrid',1)     %Grid for Y-axes
set(groot,'DefaultAxesZGrid',1)     %Grif for Z-axes

%% Optional Parameters
% Options for plotting and/or saving parameters

% 'true' if you want plots of results. 
% 'false' otherwise
show_plots = 'true'; 

% 'true' if you want the magnetometer calibration parameters saved to a
% file. Ensure 'outfile_folder' and 'outfile_suffix' are set to desired
% values if you want this to be 'true'.
% 'false' otherwise
save_params = 'false';

% Apply median filter to magnetometer data in body frame
% This is to help smooth some noise of the sensor. This parameter
% can/should be adjusted based on your needs and your sensor. Other
% smoothing techniques (moving average filter, low-pass filter, etc...) can
% be used as well. 
median_filter_window_rm3100 = 4;
median_filter_window_mpu9250 = 4;

%% Reference Magnetic Field Norm
% Constant magnetic field reference value needed to calibrate magnetometer
% data

% When using this script to calibrate, you must update this value with the
% actualy ambient magnetic field _magnitude_ at the location you are
% calibrating. 

% Note: calibrating indoors is difficult because the magnitude of the
% ambient magnetic field is very sensitive to small movements
magRefNorm = 57.13; % [uT] 

%% Select Filenames

%Select Desired folder and file for BBB
infile_folder = './20210423_mag_cali/';
filename = "test0_esti";
file_extension = ".csv";

% Output File Folder
outfile_folder = "./calibrated_magnetometer_params/";

% Suffix added to calibrated magnetometer data
outfile_suffix = "_calibrationParameters";


%% Make directory for outfile so rest of things work smoothly
if( exist(outfile_folder, 'dir') ~= 7)
    try
        mkdir(outfile_folder);
    catch
       error("Unable to make folder %s", outfile_folder); 
    end
end

%% Iterate Over Each Flight Number
%Construct input and output filenames
infile= strcat(infile_folder, filename, file_extension);

outfile = strcat(outfile_folder, filename, outfile_suffix, file_extension);

%If the output file already exists, move on
if(exist(outfile, 'file') == 2)
    fprintf("File Already Exists -> %s\n", outfile);
    error("Stopping calibration script to avoid needless computation");
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in Logfile Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Read data from 'infile'
try
    data = readtable(infile);
catch
    %Can't find a file? Skip it and move on
    fprintf("Could not find %s\n", infile);
    error("Update 'infile', 'infile_folder', 'filename', and 'file_extension' variables then run again");
end

%% Calibrate RM3100
% Select PNI RM3100 data from huge data struct
% Indeces we're selecting here are 'rm3100_x', 'rm3100_y', and 'rm3100_z'
rm3100_indx = find(strcmp("rm3100_x", data.Properties.VariableNames));
rm3100_indx = rm3100_indx:rm3100_indx+2; % Indeces of X,Y,and Z components

% Convert data from Matlab Table to Matlab Matrix
mag_data = data(:, rm3100_indx);
mag_data = mag_data{:,:};

% Make reference scalar into a vector
magRefNorm_vec = magRefNorm * ones(height(data), 1);

% Initial guess for (scale factors, bias, and non-orthogonality angles)
x0 = [ 1 1 1, 0 0 0, 0 0 0]';


% Apply moving median filter with window size of 'median_filter_window_rm3100'

lb = median_filter_window_rm3100/2;     %lowerbound
ub = median_filter_window_rm3100 - lb;  %upperbound
mag_data = [movmedian(mag_data(:,1), [lb, ub], 1), ...
              movmedian(mag_data(:,2), [lb, ub], 1), ...
              movmedian(mag_data(:,3), [lb, ub], 1)];

% Corrections for high-current-carrying wires near magnetometer
% This is for time-varying effects which I (Prince) do not account for in
% my applications
allCurrents = [];

% Calibration parameters (Body frame)
% This is one of Springman's functions that actually does the magnetomer
% calibration. 
calParams_B_rm3100 = extractParameters_v6a(...
    x0, mag_data(:,1), mag_data(:,2), mag_data(:,3), ...
    magRefNorm_vec, allCurrents);

%Get Corrected magnetometer measurements
mag_data_cal_B = zeros(size(mag_data));

% This is another of Springman's functions. This one takes the calibrated
% magnetometer parameters in 'calParams_B_rm3100' and uses them to adjust
% the raw sensor data. 
[mag_data_cal_B(:,1), mag_data_cal_B(:,2), mag_data_cal_B(:,3)] = correctSensor_v5(...
   calParams_B_rm3100, mag_data(:,1),mag_data(:,2),mag_data(:,3), allCurrents);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot RM3100 Calibration Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You honestly don't need to read through this if you don't want to. It's
% just to make the plots. Definitely easier to just look at/interpret the
% results rather than parsing through this source code. 
if(strcmp(show_plots, 'true'))
    t = (data.epoch_time_ns - data.epoch_time_ns(1))/1e9;

    magVecAxes = [min(min([mag_data, mag_data_cal_B])), ...
                   max(max([mag_data, mag_data_cal_B]))];
    magNormAxes = [min(min([magRefNorm_vec, vecnorm(mag_data, 2,2), vecnorm(mag_data_cal_B, 2,2)])), ...
                   max(max([magRefNorm_vec, vecnorm(mag_data, 2,2), vecnorm(mag_data_cal_B, 2,2)]))];

    figure(1); clf;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Raw Magnetometer Data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(3,2,[1 3])
    plot(t, mag_data, 'linewidth', 2);
    ylabel('Mag Field [uT]')
    title('Raw Magnetometer Output')
    legend('$\tilde{B}_x$', '$\tilde{B}_y$', '$\tilde{B}_z$', 'fontsize', 12, ...
        'interpreter','latex', 'location', 'best')

    ax = gca;
    ax.FontSize = 12;
    axis([ax.XLim, magVecAxes(1), magVecAxes(2)])

    subplot(3,2,5)
    hold on; 
    plot(t, magRefNorm_vec, 'r--', 'linewidth', 2);
    plot(t, vecnorm(mag_data, 2,2), 'k-', 'linewidth', 2);
    hold off;
    xlabel('Time [s]')
    ylabel('Mag Field [uT]')
    title('Magnitude of Field (Raw)')
    grid on;

    legend('$\| B_E \|$', '$\| \tilde{B}_{raw} \|$', 'fontsize', 12, ...
            'interpreter','latex', 'location', 'best')

    ax = gca;
    ax.FontSize = 12;
    axis([ax.XLim, magNormAxes(1), magNormAxes(2)])


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calibrated Magnetometer Data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(3,2,[2 4])
    plot(t, mag_data_cal_B, 'linewidth', 2);
    ylabel('Mag Field [uT]')
    title('Calibrated Magnetometer Output')
    legend('$\tilde{B}_x$', '$\tilde{B}_y$', '$\tilde{B}_z$', 'fontsize', 12, ...
        'interpreter','latex', 'location', 'best')

    ax = gca;
    ax.FontSize = 12;
    axis([ax.XLim, magVecAxes(1), magVecAxes(2)])

    subplot(3,2,6)
    hold on; 
    plot(t, magRefNorm_vec, 'r--', 'linewidth', 2);
    plot(t, vecnorm(mag_data_cal_B, 2,2), 'k-', 'linewidth', 2);
    hold off;
    xlabel('Time [s]')
    ylabel('Mag Field [uT]')
    title('Magnitude of Field (Calibrated)')
    grid on;

    legend('$\| B_E \|$', '$\| \tilde{B}_{raw} \|$', 'fontsize', 12, ...
            'interpreter','latex', 'location', 'best')

    ax = gca;
    ax.FontSize = 12;
    axis([ax.XLim, magNormAxes(1), magNormAxes(2)])
end

%% Save Params
if(strcmp(save_params, 'true'))
    try
        params = table(calParams_B_rm3100, ...
                     'VariableNames', {'rm3100'} );
        writetable(params, outfile);
        fprintf("Finished processing -> %s\n", outfile);
    catch
        error("Unable to write -> %s", outfile);   
    end
end