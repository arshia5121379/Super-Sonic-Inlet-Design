function s = status_text(R)
    c = {};
    if R.detached,  c{end+1} = 'DETACHED SHOCK'; end
    if R.choked,    c{end+1} = 'EXIT CHOKED'; end
    if ~R.lip_ok,   c{end+1} = 'lip shock detached'; end
    if R.interact,  c{end+1} = 'shock merging'; end
    if R.fric_fail, c{end+1} = 'friction march failed (frictionless diffuser used)'; end
    if isempty(c), s = R.regime_short; else, s = strjoin(c, ', '); end
end
