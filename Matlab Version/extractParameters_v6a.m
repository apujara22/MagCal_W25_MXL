% John Springmann 
% 2/4/11
%
% This function uses non-linear least-squares to extract the calibration
% parameters utilizing a known but time-varying magnetic field magnitude.
%
%   2/5/11 v3
%       Add SP currents & scaling factors
%   4/4/11 v4
%       Add telemetry point for beacons (EPS Vbatt current)
%   5/15/15 v5 Editor: Nathanael England
%       Cleaning up syntax of the code and generalizing current portions
%   5/22/15 v6 Editor: Nathanael England
%       Generalizing code for arbitrary current inputs
%       Removed initial guess as input. Monte Carlo simulation in
%       Springmann's paper shows initial estimate isn't important for
%       convergence

function cal_params = extractParameters_v6a(x,bxhat,byhat,bzhat,bmag,all_curr)
% inputs:
%   bxhat: x-component of the sensor reading
%   byhat: y-component of the sensor reading
%   bzhat: z-component of the sennsor reading
%   bmag: the magnitude of the mag field used for calibration. This is a
%           vector the same size as the measurements.
%   all_curr: Matrix of currents on board. NxM matrix for N data points and
%   M current sources on board

eps = 1;    

% the "measurements" is the array of field magnitude squared
meas = bmag.^2;

J = [0];    % need to store the loss function values
ctr = 2;    % counter, start at 2

cts_max = 50;    % upper limit on the number of iterations

[data_num, num_curr_sources] = size(all_curr);

while eps > 1e-14;  
    
    dfdx = zeros(length(bxhat),length(x));
    f = zeros(length(bxhat),1);
    a = x(1);
    b = x(2);
    c = x(3);
    x0 = x(4);
    y0 = x(5);
    z0 = x(6);
    rho = x(7);
    phi = x(8);
    lam = x(9);
    
    for v = 1:length(bxhat)
        sIx = 0; sIy = 0; sIz = 0;
        % a function for each measurement
        Bxhat = bxhat(v);
        Byhat = byhat(v);
        Bzhat = bzhat(v);
                
        % Sum the current effects
        for j = 1:num_curr_sources
            sIx = sIx + x(j+9)*all_curr(v,j);
            sIy = sIy + x(j+9+num_curr_sources)*all_curr(v,j);
            sIz = sIz + x(j+9+num_curr_sources*2)*all_curr(v,j);
        end
      
        % Generate B^2 = Bx^2 + By^2 + Bz^2 by inverting equations below
        % Bxhat = a*Bx + x0 + sIx
        % Byhat = b*(By + rho*Bx) + y0 + sIy
        % Bzhat = c*(lam*Bx + phi*By + Bz) + z0 + sIz
        Bx = -(x0 - Bxhat + sIx)/a;
        By = -(y0 - Byhat + sIy + b*Bx*rho)/b;
        Bz = -(z0 - Bzhat + sIz + c*lam*Bx + c*phi*By)/c;
        f(v) = Bx^2 + By^2 + Bz^2;
        
        % Generate Jacobian
        dfdx(v,1) = 2*Bx*(-Bx/a)+2*By*(Bx*rho/a)+2*Bz*(Bx/a)*(lam-phi*rho);
        dBy_db = (By*(-b)-Bx*rho*b)/b^2;
        dBz_db = -phi*dBy_db;
        dfdx(v,2) = 2*Bx*(0) + 2*By*dBy_db + 2*Bz*dBz_db;
        dfdx(v,3) = 2*Bx*(0)+2*By*(0)+2*Bz*(Bz*(-c)-c*(lam*Bx+phi*By))/c^2;
        dfdx(v,4) = 2*Bx*(-1/a)+2*By*(rho/a)+2*Bz*(1/a)*(lam-phi*rho);
        dfdx(v,5) = 2*Bx*(0)+2*By*(-1/b)+2*Bz*(phi/b);
        dfdx(v,6) = 2*Bx*(0)+2*By*(0)+2*Bz*(-1/c);
        dfdx(v,7) = 2*Bx*(0)+2*By*(-Bx)+2*Bz*(phi*Bx);
        dfdx(v,8) = 2*Bx*(0)+2*By*(0)+2*Bz*(-By);
        dfdx(v,9) = 2*Bx*(0)+2*By*(0)+2*Bz*(-Bx);
        for w = 1:num_curr_sources
            I_curr = all_curr(v,w);
            k1 = w + 9;
            k2 = w + 9 + num_curr_sources;
            k3 = w + 9 + num_curr_sources*2;
            dfdx(v,k1)= 2*Bx*(-I_curr/a)+2*By*(rho*I_curr/a)+2*Bz*(I_curr/a)*(lam-phi*rho);
            dfdx(v,k2)= 2*Bx*(0)+2*By*(-I_curr/b)+2*Bz*(phi*I_curr/b);
            dfdx(v,k3)= 2*Bx*(0)+2*By*(0)+2*Bz*(-I_curr/c);
        end
    end
    
    deltay = meas - f;  % measurements are the mag field magnitude
    
    mean(deltay);
    
    Jhere = deltay'*deltay;
    J = [J; Jhere]; % store the J's
    
    H = dfdx;
    
    alpha = 0.01;    % regularization parameter
    
    deltax = (H'*H + alpha*eye(9))^(-1)*H'*deltay;
    eps = abs(J(ctr) - J(ctr-1))/J(ctr);
    x = x+deltax;
    
    % check that the scaling factors are positive
    x(1:3) = abs(x(1:3)); 
    
    ctr = ctr+1;
    
    if ctr > cts_max
        disp('Max iterations reached')
        break
    end
    
end

cal_params = x;

end
