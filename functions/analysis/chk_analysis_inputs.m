function chk_analysis_inputs(offdesign, incidence, sweep)
% Validates the analysis options.
    if offdesign.enable
        if ~(isscalar(offdesign.M) && isfinite(offdesign.M) && offdesign.M > 1)
            error('offdesign.M must be a scalar > 1.');
        end
        if ~(isscalar(offdesign.altitude) && isfinite(offdesign.altitude) && offdesign.altitude >= -2000 && offdesign.altitude <= 71000)
            error('offdesign.altitude must be a scalar between -2000 and 71000 m.');
        end
    end
    if incidence.enable
        if ~(isscalar(incidence.alpha_deg) && isfinite(incidence.alpha_deg) && abs(incidence.alpha_deg) < 30)
            error('incidence.alpha_deg must be a scalar with |alpha| < 30 deg.');
        end
    end
    if sweep.enable
        chk_range(sweep.M_range,  'sweep.M_range',  1.0);
        chk_range(sweep.alt_range, 'sweep.alt_range', -2001);
        if sweep.alt_range(2) > 71000, error('sweep.alt_range: the maximum altitude is 71000 m.'); end
        if ~(isscalar(sweep.shock_n) && sweep.shock_n >= 1 && sweep.shock_n <= 9 && sweep.shock_n == round(sweep.shock_n))
            error('sweep.shock_n must be an integer between 1 and 9.');
        end
        if incidence.enable
            chk_range(sweep.alpha_range, 'sweep.alpha_range', -inf);
            if ~(numel(sweep.map_n) == 2 && all(sweep.map_n >= 2) && all(sweep.map_n == round(sweep.map_n)))
                error('sweep.map_n must be [n_Mach n_alpha], integers >= 2.');
            end
        end
    end
end
