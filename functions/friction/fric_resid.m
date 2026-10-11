function v = fric_resid(fp, M_in, p01, T0, A1m, r, M_tar, gam)
    [Me, ~, ~, ok] = fric_march(fp, M_in, p01, T0, A1m, r, gam, false);
    if ok, v = Me - M_tar; else, v = NaN; end
end
