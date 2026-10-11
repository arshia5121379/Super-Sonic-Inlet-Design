function D = fric_dh(A, fp)
% Local hydraulic diameter [m]: ramp -> rectangle W x h (D = 4A/P = 2Wh/(W+h)), cone -> circle (D = sqrt(4A/pi)).
    if fp.kind == 2
        Wm = fp.W*fp.lu;  h = A/Wm;
        D  = 2*Wm*h/(Wm + h);
    else
        D = sqrt(4*A/pi);
    end
end
