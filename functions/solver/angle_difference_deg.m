function d = angle_difference_deg(a, b)
% Smallest unsigned angle between two directed surface/flow slopes [deg].
    d = abs(rad2deg(atan2(sin(deg2rad(a-b)), cos(deg2rad(a-b)))));
end
