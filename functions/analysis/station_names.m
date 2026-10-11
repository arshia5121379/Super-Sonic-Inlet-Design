function [names, short] = station_names(ctx)
% Names of the flow stations (same order as every station array).
    n = ctx.n;  m = ctx.m;
    names = {'Freestream (0)'};  short = {'Free'};
    for k = 1:n
        names{end+1} = sprintf('After oblique shock %d', k);   %#ok<AGROW>
        short{end+1} = sprintf('OS%d', k);                     %#ok<AGROW>
    end
    for j = 1:m
        names{end+1} = sprintf('After internal shock %d', j);  %#ok<AGROW>
        short{end+1} = sprintf('IS%d', j);                     %#ok<AGROW>
    end
    names{end} = [names{end} ' (ahead of terminal shock)'];
    names{end+1} = 'Behind terminal shock (diffuser inlet)';  short{end+1} = 'Diff. in';
    names{end+1} = 'Diffuser exit (engine face)';             short{end+1} = 'Diff. out';
end
