function nu = pm_nu(M, gam)
% Prandtl-Meyer function [rad].
    a  = sqrt((gam+1)/(gam-1));
    nu = a*atan(sqrt((gam-1)/(gam+1)*(M.^2 - 1))) - atan(sqrt(M.^2 - 1));
end
