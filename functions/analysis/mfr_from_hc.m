function mfr = mfr_from_hc(ctx, hc)
% Mass-flow capture ratio from the capture heights h_c (freestream height of the lip streamline).
    if ctx.cone
        mfr = mean(max(hc, 0).^2)/ctx.H_inf^2;     % circular capture area ~ radius^2
    else
        mfr = hc(1)/ctx.H_inf;                     % rectangular capture area ~ height
    end
end
