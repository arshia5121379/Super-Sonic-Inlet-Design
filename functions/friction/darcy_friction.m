function f = darcy_friction(Re, rr, model)
% Incompressible Darcy friction factor: laminar 64/Re (Re <= 2300), turbulent correlation (Re >= 4000), blend in between.
    Re = max(Re, 1);
    if Re <= 2300
        f = 64/Re;
    elseif Re >= 4000
        f = darcy_turbulent(Re, rr, model);
    else
        w = (Re - 2300)/1700;
        f = (1-w)*64/Re + w*darcy_turbulent(Re, rr, model);
    end
end
