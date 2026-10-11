function ar = area_ratio(M, gam)
% Isentropic area ratio A/A* for Mach M
    ar = (1./M) .* ((2/(gam+1)) * (1 + 0.5*(gam-1)*M.^2)) .^ ((gam+1)/(2*(gam-1)));
end
