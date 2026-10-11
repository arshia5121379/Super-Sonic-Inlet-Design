function plot_inlet_3d(bodies, colors, alphas, ttl)
% 3-D view of the extruded / revolved bodies.
    figure('Name', 'Inlet 3D View');
    hold on
    for k = 1:numel(bodies)
        patch('Faces', bodies{k}.F, 'Vertices', bodies{k}.V, 'FaceColor', colors{k}, ...
              'EdgeColor', 'none', 'FaceAlpha', alphas(k), 'FaceLighting', 'gouraud');
    end
    axis equal; grid on; view(3);
    xlabel('x'); ylabel('y'); zlabel('z');
    camlight('headlight'); material dull;
    title(ttl);
    hold off
end
