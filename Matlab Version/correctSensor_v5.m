% John Springmann
% 2/4/11
%
% Correct the senor measurements based on the calibration parameters
%
%   2/5/11 v3
%       Uses model that includes SP currents
%   4/4/11 v4
%       Uses 5th current telem point to try to get beacons out
%   5/21/15 v5
%       Generalizing to accept output from extractParameters_v6

function [bxOut, byOut, bzOut] = correctSensor_v5(x,bxhat,byhat,bzhat,all_curr)
% inputs:
%   x: vector of calibration parameters. Order is 
%       [a b c x0 y0 z0 rho phi lam]
%   bxhat: x-component of raw measurements (vector)
%   byhat: y-component of raw measurements (vector)
%   bzhat: z-component of raw measurements (vector)
%   all_curr: Matrix of currents on board. NxM matrix for N data points and
%   M current sources on board

[data_num, num_curr_sources] = size(all_curr);

a = x(1);
b = x(2);
c = x(3);
x0 = x(4);
y0 = x(5);
z0 = x(6);
rho = x(7);
phi = x(8);
lam = x(9);

sIx = 0; sIy = 0; sIz = 0;

% Sum current sources with new calibration parameters
for j = 1:num_curr_sources
    sIx = sIx + x(j+9)*all_curr(:,j);
    sIy = sIy + x(j+9+num_curr_sources)*all_curr(:,j);
    sIz = sIz + x(j+9+num_curr_sources*2)*all_curr(:,j);
end

% Recalculate magnetic field vectors
bxOut = -(x0 - bxhat + sIx)/a;
byOut = -(y0 - byhat + sIy + b*bxOut*rho)/b;
bzOut = -(z0 - bzhat + sIz + c*lam*bxOut + c*phi*byOut)/c;

end
