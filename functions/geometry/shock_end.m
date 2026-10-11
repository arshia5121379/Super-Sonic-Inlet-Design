function E = shock_end(P0, ang, A, angA)
% End point of a shock drawn from P0 at absolute angle ang: its intersection with the line through A
% at angle angA (a focused shock ends exactly on A). Falls back to |A-P0| if there is no forward hit.
    d   = [cos(ang), sin(ang)];
    dA  = [cos(angA), sin(angA)];
    den = cross2(d, dA);
    t   = norm(A - P0);
    if abs(den) > 1e-9
        t1 = cross2(A - P0, dA) / den;
        if isfinite(t1) && t1 > 0, t = t1; end
    end
    E = P0 + t*d;
end
