function write_stl(filename, F, V, solidname)
% Writes a triangle surface mesh as an ASCII STL file.
    fid = fopen(filename, 'wt');
    if fid < 0
        error('Could not open %s for writing.', filename);
    end
    N = cross(V(F(:,2),:) - V(F(:,1),:), V(F(:,3),:) - V(F(:,1),:), 2);
    len = sqrt(sum(N.^2, 2));
    len(len == 0) = 1;
    N = N ./ len;
    fprintf(fid, 'solid %s\n', solidname);
    for i = 1:size(F, 1)
        fprintf(fid, ' facet normal %.6e %.6e %.6e\n  outer loop\n', N(i,:));
        fprintf(fid, '   vertex %.8e %.8e %.8e\n', V(F(i,1),:));
        fprintf(fid, '   vertex %.8e %.8e %.8e\n', V(F(i,2),:));
        fprintf(fid, '   vertex %.8e %.8e %.8e\n', V(F(i,3),:));
        fprintf(fid, '  endloop\n endfacet\n');
    end
    fprintf(fid, 'endsolid %s\n', solidname);
    fclose(fid);
end
