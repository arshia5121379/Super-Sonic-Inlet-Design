function s = off_label(st)
    s = sprintf('Off-design, %s  (M_\\infty = %.3f, h = %.0f m, \\alpha = %+.2f^\\circ)', st.title, st.M0, st.alt_m, st.alpha_deg);
end
