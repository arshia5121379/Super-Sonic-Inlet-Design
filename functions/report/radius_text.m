function s = radius_text(k)
% Radius of curvature as text (infinite for a straight wall).
    if abs(k) < 1e-12, s = 'inf'; else, s = sprintf('%.4g', 1/abs(k)); end
end
