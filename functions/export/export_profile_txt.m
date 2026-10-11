function export_profile_txt(filename, pts)
% export_profile_txt
% Writes one polyline profile to a text file:
%   3d=true
%   polyline=true
%   X Y Z      (Z = 0 for every point)
%   X Y Z
%   ...
    if size(pts,2) == 2
        pts = [pts, zeros(size(pts,1), 1)];   % planar profile -> Z = 0
    end
    fid = fopen(filename, 'wt');
    if fid < 0
        error('Could not open %s for writing.', filename);
    end
    fprintf(fid, '3d=true\n');
    fprintf(fid, 'polyline=true\n');
    fprintf(fid, '%.8f %.8f %.8f\n', pts.');   % pts is N-by-3 [X Y Z]
    fclose(fid);
end
