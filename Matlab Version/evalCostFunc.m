function [error] = evalCostFunc(x, magData, magRefNorm)
%EVALCOSTFUNC Summary of this function goes here
%   Detailed explanation goes here
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

f = zeros(length(magData),1);

for v = 1:length(magData)
    % a function for each measurement
    Bxhat = magData(v, 1);
    Byhat = magData(v, 2);
    Bzhat = magData(v, 3);
    
    Bx = -(x0 - Bxhat + sIx)/a;
    By = -(y0 - Byhat + sIy + b*Bx*rho)/b;
    Bz = -(z0 - Bzhat + sIz + c*lam*Bx + c*phi*By)/c;
    f(v) = Bx^2 + By^2 + Bz^2;
end

error = magRefNorm.^2 - f;


end

