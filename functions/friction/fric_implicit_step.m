function z = fric_implicit_step(rhs, x, y, dx)
% Implicit Euler step: z = y + dx*F(x+dx, z), solved with Newton's method (finite-difference Jacobian).
    z = y + dx*rhs(x, y);                                              % explicit first guess
    for it = 1:40
        G = z - y - dx*rhs(x + dx, z);
        J = zeros(2);
        for j = 1:2
            h  = 1e-7*max(1, abs(z(j)));
            zp = z;  zp(j) = zp(j) + h;
            J(:,j) = ((zp - y - dx*rhs(x + dx, zp)) - G)/h;
        end
        dz = J\(-G);
        z  = z + dz;
        if max(abs(dz)) < 1e-11, return; end
    end
    error('fric:implicit', 'implicit step did not converge');
end
