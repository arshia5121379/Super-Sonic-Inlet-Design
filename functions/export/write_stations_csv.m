function write_stations_csv(file, st)
% Writes the flow-station table (Mach number, static and total pressure of every region) to a CSV file.
    fid = fopen(file, 'wt');
    if fid < 0
        warning('Could not open %s for writing.', file);
        return;
    end
    fprintf(fid, '# M_inf=%.6f, altitude_m=%.2f, p_inf_Pa=%.4f, p0_inf_Pa=%.4f, alpha_deg=%.4f, case=%s\n', ...
        st.M0, st.alt_m, st.p_s, st.p0_inf, st.alpha_deg, st.title);
    fprintf(fid, 'station,short_name,M,p0_over_p0inf,p_over_pinf,T_over_Tinf,p_static_Pa,p0_total_Pa\n');
    for i = 1:numel(st.M)
        fprintf(fid, '"%s",%s,%.6f,%.8f,%.8f,%.6f,%.4f,%.4f\n', st.names{i}, st.short{i}, st.M(i), ...
            st.p0r(i), st.pr(i), st.Tr(i), st.p(i), st.p0(i));
    end
    fclose(fid);
    fprintf('Flow-station table written to %s\n', file);
end
