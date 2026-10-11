function chk_range(r, name, lo_min)
    if ~(isnumeric(r) && numel(r) == 3 && all(isfinite(r)) && r(2) > r(1) && r(3) >= 2 && r(3) == round(r(3)))
        error('%s must be [min max n_points] with max > min and n_points an integer >= 2.', name);
    end
    if r(1) <= lo_min
        error('%s: the minimum must be > %g.', name, lo_min);
    end
end
