function print_sweep_table(S, ttl)
    fprintf('\n--- %s ---\n', ttl);
    fprintf('  %7s %8s %10s %7s %9s %9s %8s %8s %10s %12s %12s  %s\n', 'M_inf', 'h[m]', 'p_inf[Pa]', 'alpha', 'pi_d', 'Ac/Acap', ...
        'M_ahead', 'M_exit', 'p_e/p_inf', 'p_exit[Pa]', 'p0_exit[Pa]', 'status');
    for i = 1:numel(S.R)
        R = S.R{i};
        fprintf('  %7.3f %8.0f %10.1f %7.2f %9.5f %9.5f %8.4f %8.4f %10.5f %12.2f %12.2f  %s\n', R.M0, R.alt, R.p_s, R.alpha_deg, ...
            R.pi_d, R.MFR, R.M_b, R.M_exit, R.pr_exit, R.p_exit, R.p0_exit, status_text(R));
    end
    [~, ib] = max(S.pi_d);
    fprintf('  Best recovery: pi_d = %.5f at M_inf = %.3f, alpha = %+.2f deg;  attached-shock points: %d of %d\n', ...
        S.pi_d(ib), S.M0(ib), S.alpha(ib), nnz(~S.detached), numel(S.R));
end
