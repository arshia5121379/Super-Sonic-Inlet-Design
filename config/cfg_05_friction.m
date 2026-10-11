% cfg_05_friction.m - Configuration block (user inputs). Run by run_inlet_design.m in the base workspace.
%  Diffuser friction (adiabatic flow with friction AND area change) 
% The subsonic diffuser is no longer isentropic. The ODE  0.5*g*M^2*f/D = (1/A)dA/dx + 2(1-M^2)/(M[2+(g-1)M^2]) dM/dx
% is space-marched along the real diffuser (area A(x) taken from the drawn walls) together with
% d(ln p0)/dx = -0.5*g*M^2*f/D. The Mach number behind the terminal shock and the design exit Mach number M_exit are GIVEN,
% so the diffuser exit height is solved such that the marched Mach number equals M_exit (friction makes it larger than the
% isentropic A/A* value). The total and static pressure drop of the diffuser and the exit pressures p_ext follow from it.
% Works for ramp / cone, Mode 1 / Mode 2, off-design, incidence and every sweep (the same hardware is marched everywhere).
friction.enable = true;       % false -> isentropic diffuser (previous behaviour)
friction.length_unit_m = 1.0; % [m per design length unit]: Reynolds number / friction need REAL dimensions (design units are arbitrary)
friction.roughness_m   = 2e-5;       % absolute wall roughness epsilon [m]
friction.model  = 'haaland';       % incompressible Darcy factor: 'colebrook' | 'haaland' | 'blasius'  (laminar 64/Re below Re = 2300)
friction.compressibility_correction = true;   % f_c = f*(1+(g-1)/2*M^2)^(-0.47)
friction.method = 'rk4';             % 'euler' (explicit) | 'implicit' (Euler, Newton) | 'heun' (predictor-corrector) | 'rk4'
friction.n_grid = 101;               % number of grid points of the space march (dx = L/(n-1))
friction.re_dh  = 'inlet';           % hydraulic diameter in the Reynolds number: 'inlet' = capture face
                                     %   (ramp: 2*W*H/(W+H) from W and H_inf; cone: 2*R = circle of the capture area), 'local' = D_h(x) of the diffuser.
                                     % The f/D term and eps/D always use the LOCAL diffuser hydraulic diameter (ramp: rectangle W x h, cone: circle).
if ~any(strcmpi(friction.model, {'colebrook', 'haaland', 'blasius'}))
    error('friction.model must be ''colebrook'', ''haaland'' or ''blasius''.');
end
if ~any(strcmpi(friction.method, {'euler', 'implicit', 'heun', 'rk4'}))
    error('friction.method must be ''euler'', ''implicit'', ''heun'' or ''rk4''.');
end
if ~any(strcmpi(friction.re_dh, {'inlet', 'local'}))
    error('friction.re_dh must be ''inlet'' or ''local''.');
end
if ~(isscalar(friction.n_grid) && friction.n_grid >= 11 && friction.n_grid == round(friction.n_grid))
    error('friction.n_grid must be an integer >= 11.');
end
if ~(friction.length_unit_m > 0 && friction.roughness_m >= 0)
    error('friction.length_unit_m must be > 0 and friction.roughness_m >= 0.');
end
