clear;
close all;

data_ico42 = readmatrix("data_ico42_calibrationParameters.csv", "Range", 'B2:B4');
data_ico162 = readmatrix("data_ico162_calibrationParameters.csv", "Range", 'B2:B4');
data_ico642 = readmatrix("data_ico642_calibrationParameters.csv", "Range", 'B2:B4');
data_ico2562 = readmatrix("data_ico2562_calibrationParameters.csv", "Range", 'B2:B4');
data_ico10242 = readmatrix("data_ico10242_calibrationParameters.csv", "Range", 'B2:B4');

data_fib42 = readmatrix("data_fib42_calibrationParameters.csv", "Range", 'B2:B4');
data_fib162 = readmatrix("data_fib162_calibrationParameters.csv", "Range", 'B2:B4');
data_fib642 = readmatrix("data_fib642_calibrationParameters.csv", "Range", 'B2:B4');
data_fib2562 = readmatrix("data_fib2562_calibrationParameters.csv", "Range", 'B2:B4');
data_fib10242 = readmatrix("data_fib10242_calibrationParameters.csv", "Range", 'B2:B4');

data_rand42 = readmatrix("data_rand42_calibrationParameters.csv", "Range", 'B2:B4');
data_rand162 = readmatrix("data_rand162_calibrationParameters.csv", "Range", 'B2:B4');
data_rand642 = readmatrix("data_rand642_calibrationParameters.csv", "Range", 'B2:B4');
data_rand2562 = readmatrix("data_rand2562_calibrationParameters.csv", "Range", 'B2:B4');
data_rand10242 = readmatrix("data_rand10242_calibrationParameters.csv", "Range", 'B2:B4');

% Plots ----------------------

colors = get(groot,"FactoryAxesColorOrder");
c1 = [colors(2, 1), colors(2, 2), colors(2, 3)];
c2 = [colors(3, 1), colors(3, 2), colors(3, 3)];
c3 = [colors(4, 1), colors(4, 2), colors(4, 3)];
c4 = [colors(5, 1), colors(5, 2), colors(5, 3)];
c5 = [colors(6, 1), colors(6, 2), colors(6, 3)];

% Icosahedron

figure;

yline(1, LineWidth=2, Color=[0 0 0], DisplayName='Expected Scaling Parameter');
hold on;
scatter([1 1 1], data_ico42, 15, 'filled', MarkerFaceColor=c1, DisplayName='42 points');
scatter([2 2 2], data_ico162, 15, 'filled', MarkerFaceColor=c2, DisplayName='162 points');
scatter([3 3 3], data_ico642, 15, 'filled', MarkerFaceColor=c3, DisplayName='142 points');
scatter([4 4 4], data_ico2562, 15, 'filled', MarkerFaceColor=c4, DisplayName='2562 points');
scatter([5 5 5], data_ico10242, 15, 'filled', MarkerFaceColor=c5, DisplayName='10242 points');

xticks([1 2 3 4 5]);

ylim([0.7 1.05]);
xlim([0.75 5.25]);
xlabel('Dataset');
ylabel('Scaling Parameters');
legend(Location='southeast');

% Fibonacci

figure;

yline(1, LineWidth=2, Color=[0 0 0], DisplayName='Expected Scaling Parameter');
hold on;
scatter([1 1 1], data_fib42, 15, 'filled', MarkerFaceColor=c1, DisplayName='42 points');
scatter([2 2 2], data_fib162, 15, 'filled', MarkerFaceColor=c2, DisplayName='162 points');
scatter([3 3 3], data_fib642, 15, 'filled', MarkerFaceColor=c3, DisplayName='142 points');
scatter([4 4 4], data_fib2562, 15, 'filled', MarkerFaceColor=c4, DisplayName='2562 points');
scatter([5 5 5], data_fib10242, 15, 'filled', MarkerFaceColor=c5, DisplayName='10242 points');

xticks([1 2 3 4 5]);

ylim([0.5 1.05]);
xlim([0.75 5.25]);
xlabel('Dataset');
ylabel('Scaling Parameters');
legend(Location='best');

% Random

figure;

yline(1, LineWidth=2, Color=[0 0 0], DisplayName='Expected Scaling Parameter');
hold on;
scatter([1 1 1], data_rand42, 15, 'filled', MarkerFaceColor=c1, DisplayName='42 points');
scatter([2 2 2], data_rand162, 15, 'filled', MarkerFaceColor=c2, DisplayName='162 points');
scatter([3 3 3], data_rand642, 15, 'filled', MarkerFaceColor=c3, DisplayName='142 points');
scatter([4 4 4], data_rand2562, 15, 'filled', MarkerFaceColor=c4, DisplayName='2562 points');
scatter([5 5 5], data_rand10242, 15, 'filled', MarkerFaceColor=c5, DisplayName='10242 points');

xticks([1 2 3 4 5]);

ylim([0.5 1.05]);
xlim([0.75 5.25]);
xlabel('Dataset');
ylabel('Scaling Parameters');
legend(Location='best');

