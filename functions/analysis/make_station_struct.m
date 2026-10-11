function st = make_station_struct(names, short, M, p0r, M0, p_s, gam)
% Station table from Mach number and total-pressure ratio p0/p0_inf at every station.
    st.names = names;  st.short = short;
    st.M   = M(:)';
    st.p0r = p0r(:)';
    kk = gam/(gam-1);
    f  = @(x) 1 + 0.5*(gam-1)*x.^2;
    st.pr  = st.p0r .* f(M0)^kk ./ f(st.M).^kk;    % static pressure / freestream static pressure
    st.Tr  = f(M0) ./ f(st.M);                     % static temperature / freestream static temperature
    st.p0_inf = p_s*f(M0)^kk;                      % freestream total pressure [Pa]
    st.p   = st.pr*p_s;                            % static pressure [Pa]
    st.p0  = st.p0r*st.p0_inf;                     % total pressure [Pa]
    st.M0  = M0;  st.p_s = p_s;  st.alpha_deg = 0;  st.title = '';  st.alt_m = NaN;
end
