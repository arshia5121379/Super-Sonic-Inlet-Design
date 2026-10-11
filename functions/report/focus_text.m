function s = focus_text(d, kind)
% Describes a signed shock miss distance (see inlet_geometry: miss_ext / miss_int).
    if abs(d) < 1e-6
        s = 'on target';
    elseif strcmp(kind, 'ext')
        if d > 0, s = 'passes on the flow-path side of the lip, enters the duct';
        else,     s = 'passes on the outer side of the lip, spillage'; end
    else
        if d > 0, s = 'reaches the ramp upstream of the shoulder';
        else,     s = 'passes downstream of the shoulder'; end
    end
end
