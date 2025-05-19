clear;
close all;

% INPUTS
numPoints = 9150;
biasType = "scale";
biasFactors = [2, 1.1, 1.01, 0.99, 0.9, 0.5];
zeroVec = [0; 0; 0];
%n = 2; % CHANGE

% Read Data

%for n=1:1:size(biasFactors)

    %fac = biasFactors(n);
    fac = 1;

    calParamsOrig = readmatrix("data_circles_scale_1.0_calibrationParameters.csv");
    calParamsNew = readmatrix("data_circles_scale_0.5_calibrationParameters.csv");
    calParamsNew = calParamsNew(2:end, 2);

%     if (biasType == "scale")
%         calParamsOrig = [fac; fac; fac; zeroVec; zeroVec];
%     elseif (biasType == "offset")
%         calParamsOrig = [zeroVec; fac; fac; fac; zeroVec];
%     else
%         calParamsOrig = [zeroVec; zeroVec; fac; fac; fac];
%     end

    errorSX = calParamsOrig(1) - calParamsNew(1);
    errorSY = calParamsOrig(2) - calParamsNew(2);
    errorSZ = calParamsOrig(3) - calParamsNew(3);
    errorOX = calParamsOrig(4) - calParamsNew(4);
    errorOY = calParamsOrig(5) - calParamsNew(5);
    errorOZ = calParamsOrig(6) - calParamsNew(6);
    errorNX = calParamsOrig(7) - calParamsNew(7);
    errorNY = calParamsOrig(8) - calParamsNew(8);
    errorNZ = calParamsOrig(9) - calParamsNew(9);

% PLOTS

figure;

if (biasType == "scale")

    yline(calParamsOrig(1), LineWidth=2, Color='k', DisplayName='Actual Scaling');
    hold on;
    yline(calParamsNew(1), LineWidth=2, Color='#0072BD', DisplayName='Output Scaling X');
    yline(calParamsNew(2), LineWidth=2, Color='#D95319', DisplayName='Output Scaling Y');
    yline(calParamsNew(3), LineWidth=2, Color='#EDB120', DisplayName='Output Scaling Z');
    ylim([0 2]);
    ylabel("Scaling Parameter");
    %title("Actual vs. Output Parameters - " + biasType + " by " + biasFactors(n));
    title("Actual vs. Output Parameters - " + biasType + " by " + 0.5);

    text(0.05, calParamsOrig(1)+0.07, "Actual Scaling (X, Y, Z)", Color='k');
    %text(0.05, calParamsNew(1)+0.07, "Output Scaling (X, Y)", Color='#D95319');
    %text(0.05, calParamsNew(3)-0.05, "Output Scaling (Z)", Color='#EDB120');
    legend(Location='best');

end

print("Errors_scale_05", "-dpng");

% function [dataCal] = calibrate(calibratedDatafile)
%     
%     
%     for n = [5.0 10.0 25.0 50.0 -5.0 -10.0 -25.0 -50.0]
%         inputFile = "offset_" + n + "_caliData.csv";
%         dataCal = readtable(calibratedDatafile);
%     end
% 
% end