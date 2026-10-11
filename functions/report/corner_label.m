function s = corner_label(k, n)
    if k <= n, s = sprintf('External facet %d', k); else, s = sprintf('Internal facet %d', k-n); end
end
