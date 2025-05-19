%% Merge smaller data files into one file

clear;
close all;

fileNames = ["data_1740244725", "data_1740186248", "data_1740188105", "data_1740188158", ...
             "data_1740188553", "data_1740188589", "data_1740189276", "data_1740189319", ...
             "data_1740189396", "data_1740189577", "data_1740232425", "data_1740232725", ...
             "data_1740233025", "data_1740233325", "data_1740233625", "data_1740233925", ...
             "data_1740234225", "data_1740234525", "data_1740234825", "data_1740235125", ...
             "data_1740235425", "data_1740235725", "data_1740236025", "data_1740236325", ...
             "data_1740236625", "data_1740236925", "data_1740237225", "data_1740237525", ...
             "data_1740237825", "data_1740238125", "data_1740238425", "data_1740238725", ...
             "data_1740239025", "data_1740239325", "data_1740239625", "data_1740239925", ...
             "data_1740240225", "data_1740240525", "data_1740240825", "data_1740241125", ...
             "data_1740241425", "data_1740241725", "data_1740242025", "data_1740242325", ...
             "data_1740242625", "data_1740242925", "data_1740243225", "data_1740243525", ...
             "data_1740243825", "data_1740244125", "data_1740244425"];
mergedMatrix = [];

for i = 1:length(fileNames)
    try
        data = readmatrix(fileNames(i) + ".csv"); % Read the CSV file
        mergedMatrix = [mergedMatrix; data];      % Append data to the combined matrix
    catch ME
        warning("Error reading file: %s. Skipping...", fileNames(i) + ".csv");
        disp(ME.message);
    end
end

mergedMatrix = mergedMatrix(37110:90443, :);

times = mergedMatrix(:, 1);
%writematrix(times, "data_ADSflight_times_original.csv");

%dataPNI = mergedMatrix(:, 13:15) ./ 75;
%dataIMU = mergedMatrix(:, 9:11) .* 0.15;

% n = 1;
% sizeVec = size(dataPNI);
% sz = sizeVec(1);
% while (n <= sz)
%     root = sqrt(dataPNI(n, 1)^2 + dataPNI(n, 2)^2 + dataPNI(n, 3)^2);
%     if (root > 600)
%         dataPNI(n, :) = [];
%         dataIMU(n, :) = [];
%         times(n) = [];
%         n = n - 1;
%     end
%     n = n + 1;
%     sizeVec = size(dataPNI);
%     sz = sizeVec(1);
% end

%dataPNI = mergedMatrix(:, 13:15);
%dataIMU = mergedMatrix(:, 9:11);

writematrix(times, "data_ADSflight_timesOG.csv");
%writematrix(mergedMatrix, "data_ADSflight.csv");
%writematrix(dataPNI, "data_ADSflight_pni.csv");
%writematrix(dataIMU, "data_ADSflight_imuOG.csv");
disp("Merging complete.");

