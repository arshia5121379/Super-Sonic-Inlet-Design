function print_stage(s, name)
% Prints the stage table of an Oswatitsch oblique-shock system.
    fprintf('\n%s:\n', name);
    fprintf('  Mn* = %.6f (equal-strength normal Mach)\n', s.Mn_star);
    fprintf('  i     Mi        beta_i(deg)    theta_i(deg)    Mi+1       pi_i=P0_out/P0_in\n');
    for i = 1:s.n_oblique
        fprintf('  %d   %8.5f   %12.6f   %12.6f   %8.5f     %12.8f\n', ...
            i, s.M(i), rad2deg(s.beta(i)), rad2deg(s.theta(i)), s.M(i+1), s.pi_obl(i));
    end
end
