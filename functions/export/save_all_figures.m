function save_all_figures(out_dir, formats)
% Saves every open figure into out_dir as NN_<figure name>.<format>.
    figs = findobj(0, 'Type', 'figure');
    if isempty(figs), return; end
    [~, ord] = sort(arrayfun(@(f) f.Number, figs));
    figs = figs(ord);
    fprintf('\nSaving %d figure(s) to %s:\n', numel(figs), out_dir);
    for i = 1:numel(figs)
        f  = figs(i);
        nm = strtrim(get(f, 'Name'));
        if isempty(nm), nm = sprintf('figure_%d', f.Number); end
        stem = regexprep(lower(nm), '[^a-z0-9]+', '_');
        stem = regexprep(stem, '^_+|_+$', '');
        stem = sprintf('%02d_%s', i, stem(1:min(end, 70)));
        for k = 1:numel(formats)
            fmt  = lower(char(formats{k}));
            file = fullfile(out_dir, [stem '.' fmt]);
            try
                switch fmt
                    case 'fig'
                        savefig(f, file);
                    case {'png', 'jpg', 'pdf'}
                        if exist('exportgraphics', 'file') > 0
                            exportgraphics(f, file, 'Resolution', 200);
                        else
                            saveas(f, file);
                        end
                    otherwise
                        saveas(f, file);
                end
                fprintf('  %s\n', [stem '.' fmt]);
            catch err
                warning('Could not save %s: %s', [stem '.' fmt], err.message);
            end
        end
    end
end
