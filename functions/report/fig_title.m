function fig_title(str)
% Figure-wide title where sgtitle exists (R2018b+).
    if exist('sgtitle', 'file')
        sgtitle(str);
    end
end
