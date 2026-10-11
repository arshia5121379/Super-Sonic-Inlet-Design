% cfg_01_design_point.m - Configuration block (user inputs). Run by run_inlet_design.m in the base workspace.
%  Inputs 
gamma = 1.4;
M1 = 2.0;          % freestream Mach
Mn_target = 1.2;   % upstream Mach of the terminal normal shock
n_oblique = 2;     % number of (external) oblique shocks on the ramp

%  Inlet type (defines the capture area) 
inlet_type = 'ramp';   % 'ramp' : rectangular inlet, planar ramp of spanwise width W
                       % 'cone' : axisymmetric inlet, circular capture area (profile revolved about y = 0)
W          = 3.0;      % (ramp) spanwise width of the rectangular inlet (arb. units)

%  Output option 
output_mode = '2D';    % '2D' : 2-D graph only
                       % '3D' : STL bodies + 3-D view (plus the 2-D graph)
                       % (the profile .txt polylines are exported in BOTH modes)
                       %        ramp -> profiles extruded along z from 0 to W
                       %        cone -> profiles revolved 360 deg about the x axis (y = 0)
n_revolve   = 72;      % (cone, 3D) number of angular segments of the revolve
scale_factor = 100.0;    % uniform scale applied to ALL exported geometry (2D polylines and 3D STL, incl. W);
                       % the design, printed values and 2-D graph stay in design units

switch lower(inlet_type)
    case 'ramp'
        flag = 2;      % planar ramp (profile drawn below the y = 0 line)
        if ~(W > 0), error('W (spanwise length) must be > 0 for a ramp inlet.'); end
    case 'cone'
        flag = 1;      % axisymmetric (profile drawn above the axis y = 0)
    otherwise
        error('inlet_type must be ''ramp'' or ''cone''.');
end
if ~(isscalar(scale_factor) && scale_factor > 0)
    error('scale_factor must be a positive scalar.');
end
if ~any(strcmpi(output_mode, {'2D','3D'}))
    error('output_mode must be ''2D'' or ''3D''.');
end
