function th = theta_of_beta(M, b, gam)
% theta-beta-M relation: flow deflection for shock angle b.
    th = atan(2*cot(b).*(M^2*sin(b).^2 - 1)./(M^2*(gam + cos(2*b)) + 2));
end
