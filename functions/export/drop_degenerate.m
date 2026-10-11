function F = drop_degenerate(F, V)
% Removes zero-area triangles.
    A = cross(V(F(:,2),:) - V(F(:,1),:), V(F(:,3),:) - V(F(:,1),:), 2);
    F = F(sqrt(sum(A.^2, 2)) > 1e-12, :);
end
