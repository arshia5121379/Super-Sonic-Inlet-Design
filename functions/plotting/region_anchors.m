function A = region_anchors(ctx, geo)
% Where the label of every region is placed on the inlet drawing (real, signed frame).
    n = ctx.n;  m = ctx.m;
    A = nan(n+m+3, 2);
    xs = geo.P_ult(1,1) - geo.P(1,1);
    A(1,:) = [geo.P(1,1) - 0.14*xs, 0.55*geo.X(2)];                       % freestream: upstream of the ramp tip
    for k = 1:n                                                           % region behind external shock k
        A(1+k,:) = mean([geo.P(k,:); geo.P(k+1,:); geo.X], 1);
    end
    for j = 1:m                                                           % region behind internal shock j
        A(1+n+j,:) = mean([geo.Q(j,:); geo.Q(j+1,:); geo.foot], 1);
    end
    S = geo.foot;  T = geo.term_top;
    A(n+m+2,:) = [mean([S(1) T(1)]) + 0.12*xs, mean([S(2) T(2)])];        % diffuser inlet
    A(n+m+3,:) = [geo.P_ult(1,1) + 0.03*xs, mean(geo.P_ult(:,2))];        % diffuser outlet
end
