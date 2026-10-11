function [Fr, Ffull, Lfull, Lcfull] = geometry_residual(u, c)
% Concurrency residuals (signed perpendicular distances of a shock line to its target point).
% u = [X(1:2), free L(2..n), free Lc(1..m-1)]   (Lc only in mixed mode); user-fixed lengths are in
% c.Lfix / c.Lcfix (NaN = unknown). Ffull holds every condition, Fr only the enforced ones (c.keep).
% Mode 1: n oblique shocks + terminal shock all pass through the lip X (n+1 eqs).
% Mode 2: n external shocks pass through X; m internal shocks (from cowl corners Q_j)
%         pass through the ramp end S (n+m eqs).
    n  = c.n;
    Xr = u(1:2);
    Lfull  = c.Lfix(:)';
    isf    = isnan(Lfull);
    nfL    = nnz(isf);
    Lfull(isf) = u(3:2+nfL);
    Lcfull = c.Lcfix(:)';
    isc    = isnan(Lcfull);
    Lcfull(isc) = u(3+nfL:2+nfL+nnz(isc));
    Pr = ramp_points(c.L1, Lfull, n, c.Phi0, c.sgn);
    Sr = Pr(n+1,:);
    Ffull = zeros(c.neq, 1);
    for kk = 1:n
        Pk = Pr(kk,:);                        % corner that GENERATES shock kk
        Ffull(kk) = (Xr(2)-Pk(2))*cos(c.psi_obl(kk)) - (Xr(1)-Pk(1))*sin(c.psi_obl(kk));
    end
    if ~c.mixed
        Ffull(n+1) = (Xr(2)-Sr(2))*cos(c.psi_norm) - (Xr(1)-Sr(1))*sin(c.psi_norm);
    else
        Qk = Xr;                              % first cowl corner = lip
        for jj = 1:c.m
            Ffull(n+jj) = (Sr(2)-Qk(2))*cos(c.psi_int(jj)) - (Sr(1)-Qk(1))*sin(c.psi_int(jj));
            if jj < c.m
                Qk = Qk + Lcfull(jj)*[cos(c.dirC(jj)), sin(c.dirC(jj))];
            end
        end
    end
    Fr = Ffull(c.keep);
end
