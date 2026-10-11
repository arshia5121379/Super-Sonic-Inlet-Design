function f = darcy_turbulent(Re, rr, model)
    switch lower(model)
        case 'blasius'
            f = 0.316/Re^0.25;
        case {'haaland', 'colebrook'}
            f = (-1.8*log10((rr/3.7)^1.11 + 6.9/Re))^-2;                      % Haaland (also the Colebrook start value)
            if strcmpi(model, 'colebrook')
                for k = 1:60
                    fn = (-2*log10(rr/3.7 + 2.51/(Re*sqrt(f))))^-2;           % Colebrook-White
                    if abs(fn - f) < 1e-12, f = fn; break; end
                    f = fn;
                end
            end
        otherwise
            error('friction.model must be colebrook | haaland | blasius');
    end
end
