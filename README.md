# Oswatitsch Supersonic Inlet Design Tool (MATLAB)

## Short description

A MATLAB tool that designs a supersonic air inlet (planar **ramp** or axisymmetric **cone**) using the
Oswatitsch equal-strength principle: a chosen number of oblique shocks compress the flow to a target Mach number,
followed by a terminal normal shock and a subsonic diffuser. It supports **external compression** (Mode 1) and
**mixed external + internal compression** (Mode 2). From the shock design it builds the full 2-D geometry
(faceted ramp, shocks focused on the cowl lip, cowl, smooth quintic diffuser walls), sizes the diffuser with
friction, and computes pressure recovery and exit pressures at an ISA altitude. The fixed hardware can then be
analysed at off-design Mach number, altitude and angle of attack, and swept over Mach, altitude and incidence.
Results are exported as profile polylines (`.txt`), 3-D bodies (`.stl`), station tables and sweep results (`.csv`),
figures and a run log.

---

## 1. Requirements

- MATLAB (base MATLAB functions only; `exportgraphics` is used for PNG/PDF/JPG when available, otherwise `saveas`).
- Run from any folder; the driver adds its own sub-folders to the path.

## 2. Project layout

```
run_inlet_design.m        driver - run this
config/                   user inputs (edit these)
  cfg_01_design_point.m
  cfg_02_compression_and_facets.m
  cfg_03_cowl.m
  cfg_04_diffuser_and_flight.m
  cfg_05_friction.m
  cfg_06_analysis_options.m
  cfg_07_output_options.m
stages/                   pipeline steps, run in order (stage_01 ... stage_16)
functions/                one function per file
  solver/ geometry/ export/ report/ plotting/ analysis/ sweeps/ friction/
```

The `config` and `stages` files are *scripts* that share the base workspace, so a variable set in a config file is
visible in every later stage. Do not rename variables unless you also change the stages that use them.

## 3. How to use

1. Open the `config/` files and set your inputs (Section 5 explains every one).
2. Run `run_inlet_design` in MATLAB.
3. Read the console report (also saved to `run_log.txt`), look at the figures, and collect the exported files from
   the results folder (Section 7).
4. Change inputs and re-run. By default each run goes into a new time-stamped folder, so nothing is overwritten.

Typical workflows:

- **First design:** keep all facet lengths `NaN` (automatic), `output_mode = '2D'`, `offdesign.enable = false`,
  `sweep.enable = false`. Check the geometry figure and the printed summary.
- **Tune mixed compression:** vary `M_int_in` until the printed "flow direction behind the internal shocks" is
  about 0 deg (diffuser entry parallel to the x axis).
- **CAD export:** set `output_mode = '3D'` and `scale_factor` to your CAD units; import the `.stl` bodies or the `.txt`
  polylines.
- **Off-design study:** set `offdesign.enable = true` (and optionally `incidence.enable = true`).
- **Performance maps:** set `sweep.enable = true`.

## 4. Two design modes

| | Mode 1 (`mixed = false`) | Mode 2 (`mixed = true`) |
|---|---|---|
| Compression | external oblique shocks only | external shocks, then internal shocks on the cowl |
| Shock focusing | all external shocks hit the cowl lip; terminal shock runs from the lip to the ramp | external shocks hit the cowl lip; internal shocks hit the ramp shoulder; terminal shock stands at the shoulder |
| Cowl lower surface | set by `cowl_upper_angle - cowl_angle` | first internal facet (set by the internal shock design); `cowl_angle` is not used |
| Last ramp facet | re-located automatically to the terminal shock foot (`ramp_lengths(end)` ignored) | can be fixed by the user |

Mode 2 follows the layout of Fig. 6.11 in Seddon & Goldsmith.

## 5. Inputs

Angles are in **degrees** in the config files. Lengths are in arbitrary design units unless stated otherwise.

### 5.1 `cfg_01_design_point.m`

| Variable | Default | Meaning |
|---|---|---|
| `gamma` | 1.4 | Ratio of specific heats. |
| `M1` | 2.0 | Freestream Mach number (design point). |
| `Mn_target` | 1.2 | Mach number just upstream of the terminal normal shock. Must be > 1. |
| `n_oblique` | 2 | Number of external oblique shocks (= number of ramp facets). |
| `inlet_type` | `'ramp'` | `'ramp'`: rectangular inlet, planar ramp, profile drawn below y = 0. `'cone'`: axisymmetric inlet, circular capture area, profile drawn above the axis y = 0 and revolved about it. |
| `W` | 3.0 | Ramp only: spanwise width of the rectangular inlet. Must be > 0. |
| `output_mode` | `'2D'` | `'2D'`: 2-D graph only. `'3D'`: also write STL bodies and show a 3-D view. The profile `.txt` files are written in both modes. Ramp: profiles extruded along z from 0 to W. Cone: profiles revolved 360 deg about the x axis. |
| `n_revolve` | 72 | Cone, 3D only: number of angular segments of the revolve. |
| `scale_factor` | 100 | Uniform scale applied to all exported geometry (2-D polylines and 3-D STL, including W). The design, printed values and 2-D graph stay in design units. |

### 5.2 `cfg_02_compression_and_facets.m`

| Variable | Default | Meaning |
|---|---|---|
| `mixed` | `true` | `false` = Mode 1, `true` = Mode 2 (Section 4). |
| `M_int_in` | 1.5 | Mode 2: Mach number entering the internal compression (after the external shocks). Must satisfy `M1 > M_int_in > Mn_target > 1`. Tip: the flow behind the internal shocks is parallel to the x axis when the external and internal turning angles are equal; the summary prints that flow direction. |
| `n_internal` | 2 | Mode 2: number of internal oblique shocks on the cowl (positive integer). |
| `ramp_lengths` | `nan(1,n_oblique)` | Ramp facet lengths, measured along each facet from the ramp tip. `NaN` = automatic: facet 1 has length 1 (the reference) and the others are solved so the shocks focus. A number fixes the length. Each fixed length (other than facet 1) removes one focusing condition, so the next shock then misses its target point; the miss distance is printed and the shock is drawn at its true angle. Example: `[1.0 0.8 1.2]` for 3 shocks. Must have exactly `n_oblique` entries, all positive or `NaN`. |
| `cowl_lengths` | `nan(1,n_internal-1)` | Mode 2 only: internal cowl facet lengths from the lip downstream. The last cowl facet ends on the terminal shock, so there are `n_internal-1` entries. `NaN` = automatic. Ignored (with a warning) in Mode 1 if you set numbers. |

### 5.3 `cfg_03_cowl.m`

| Variable | Default | Meaning |
|---|---|---|
| `cowl_upper_angle` | 20 | Angle of the upper (outer) cowl surface from horizontal; positive = same sense as the ramp. |
| `cowl_angle` | 8 | Included wedge angle between upper and lower cowl surfaces. **Mode 1 only.** The lower (inner) surface angle is `cowl_upper_angle - cowl_angle`, and the terminal shock is perpendicular to it. In Mode 2 the resulting wedge angle is printed instead. |
| `cowl_outer_curvature` | 0.15 | Curvature [1/length] of the outer wall at the lip. 0 = straight, > 0 = convex (bends back toward the axial direction, like a nacelle shoulder), < 0 = concave. Radius = 1/curvature. Must be a finite scalar. |
| `cowl_mean_thickness` | 0.15 | Mean vertical thickness of the cowl wall (outer wall to inner cowl surface plus cowl-side diffuser wall), averaged from the lip to the diffuser exit plane. Must be > 0. |

How the outer wall is built: a quintic in x that leaves the lip along `cowl_upper_angle` with curvature
`cowl_outer_curvature` and arrives at the diffuser exit plane horizontal with zero curvature. Its free coefficients are
solved so the mean thickness equals `cowl_mean_thickness`. The lip is always sharp (thickness 0). The exit-plane
thickness (a result, not an input) and min/max thickness are printed. A warning is issued if the wall would cross the
inner wall (very strong curvature with very small thickness). Changing the outer wall does not move the shocks or the
aerodynamic design.

### 5.4 `cfg_04_diffuser_and_flight.m`

| Variable | Default | Meaning |
|---|---|---|
| `M_exit` | 0.5 | Design Mach number at the diffuser exit (engine face). Must be subsonic. |
| `diffuser_length` | 5.0 | Streamwise (x) length of the diffuser. |
| `diffuser_split` | 0.7 | Share (0..1) of the area growth taken by the lower wall; the cowl wall takes the rest. |
| `diffuser.lower_curvature` | -0.1 | Wall curvature at the throat of the wall **drawn lower** in the graph [1/length]. Sign convention `kappa = -y''/(1+y'^2)^(3/2)`; 0 = zero curvature at the throat. |
| `diffuser.upper_curvature` | 0.0 | Same, for the wall drawn upper. |
| `diffuser.lower_slope_deg` | 10 | Start slope of the lower-drawn wall right after the final ramp/cowl facet, absolute angle from the x axis, same sign convention as the ramp/cowl angles. `NaN` = automatic (wall continues tangent to the last facet). A value different from the automatic one creates a slope break (corner); the wall then blends into the horizontal exit through the quintic. Must be `NaN` or finite with abs < 90. The automatic values are printed. |
| `diffuser.upper_slope_deg` | 8 | Same, for the upper-drawn wall. |
| `altitude` | 10500 | Flight altitude [m], ISA standard atmosphere, 0..71000. The freestream static pressure and temperature are derived from it and used for all absolute pressures. |
| `terminal_shock_model` | `'normal'` | Mode 1 only. `'normal'`: Mach and total-pressure loss behind the terminal shock are those of a normal shock at the Mach number in front of it. `'tilted'`: oblique shock using the normal Mach component `M_b*cos(phi)`, consistent with the drawn (tilted) shock; `phi` is the flow direction behind the ramp shocks minus the lower cowl angle. If the normal component is not supersonic the code warns and falls back to `'normal'`. In Mode 2 the terminal shock is exactly normal, so both choices give the same result. |

"Lower" and "upper" refer to the wall **as drawn** (smaller y / larger y):
cone inlet: lower = ramp (cone) side, upper = cowl side. Ramp inlet: the cowl lies below the ramp in the drawing, so
lower = cowl side, upper = ramp side.

Diffuser sizing: the throat height is the terminal-shock length; the exit height follows from A/A* at the Mach number
behind the terminal shock and at `M_exit` (corrected for friction when friction is enabled). Both walls are quintic
curves that start tangent to (or at the set slope of) the ramp/cowl surface with the chosen throat curvature and end
horizontal with zero curvature at the exit plane.

### 5.5 `cfg_05_friction.m`

The subsonic diffuser is treated as adiabatic flow with friction and area change; the ODE is space-marched along the
real diffuser, and the exit height is solved so the marched Mach number equals `M_exit`. The same hardware is
marched in off-design, incidence and sweeps.

| Variable | Default | Meaning |
|---|---|---|
| `friction.enable` | `true` | `false` = isentropic diffuser. |
| `friction.length_unit_m` | 1.0 | Metres per design length unit. Reynolds number and friction need real dimensions. Must be > 0. |
| `friction.roughness_m` | 2e-5 | Absolute wall roughness [m]. Must be >= 0. |
| `friction.model` | `'haaland'` | Darcy friction factor: `'colebrook'`, `'haaland'` or `'blasius'` (laminar 64/Re below Re = 2300). |
| `friction.compressibility_correction` | `true` | Apply `f*(1+(g-1)/2*M^2)^(-0.47)`. |
| `friction.method` | `'rk4'` | ODE scheme: `'euler'`, `'implicit'` (Euler with Newton), `'heun'`, `'rk4'`. |
| `friction.n_grid` | 101 | Grid points of the march (dx = L/(n-1)); integer >= 11. |
| `friction.re_dh` | `'inlet'` | Hydraulic diameter in the Reynolds number: `'inlet'` = capture face (ramp: 2WH/(W+H); cone: circle of the capture area), `'local'` = local diffuser D_h(x). The f/D term and eps/D always use the local D_h. |

### 5.6 `cfg_06_analysis_options.m`

The designed geometry is treated as **fixed hardware** and evaluated at other conditions. Off-design model (first
order): ramp/cowl geometry frozen; each facet turns the flow by its design angle (the first by theta_1 + alpha); shock
angle from the theta-beta-M relation, weak branch; if the turn exceeds theta_max the shock is detached (modelled as a
normal shock and flagged); spillage from tracing the lip streamline back through the actual shock pattern (mass-flow
capture ratio A_c/A_cap); terminal shock = normal shock at the Mach number in front of it (critical position); diffuser
exit from continuity with the fixed exit area.

| Variable | Default | Meaning |
|---|---|---|
| `run_audit` | `true` | Independent re-computation of p0, Mach, static pressure, mass flow and diffuser area; each line flagged OK / CHECK. |
| `station_map` | `true` | Table and graphs of Mach, static and total pressure in every region (freestream, after each shock, diffuser inlet and outlet) plus the annotated inlet drawing. |
| `offdesign.enable` | `false` | Analyse the fixed inlet at the freestream below. |
| `offdesign.M` | 1.5 | Off-design freestream Mach (> 1). |
| `offdesign.altitude` | 6000 | Off-design altitude [m] (ISA, 0..71000). |
| `incidence.enable` | `false` | Evaluate the off-design point and the sweeps with incidence. |
| `incidence.alpha_deg` | 15 | Pitch angle [deg] in the drawing plane. Positive = freestream turned toward the first ramp facet (first turn becomes theta_1 + alpha: more compression, larger capture area). Negative = away from it (less compression; expansion if theta_1 + alpha < 0). Ramp: planar flow. Cone: windward (+abs alpha) and leeward (-abs alpha) meridian planes are solved with planar relations and capture-area weighted (first-order estimate). |
| `sweep.enable` | `false` | Master switch for all sweeps and maps. |
| `sweep.mach` | `true` | Sweep freestream Mach number. |
| `sweep.M_range` | `[1.4 2.6 25]` | `[M_min M_max n_points]`. |
| `sweep.altitude` | `true` | Sweep altitude (ISA); only absolute pressures change with altitude, ratios and recovery do not. |
| `sweep.alt_range` | `[4000 20000 9]` | `[h_min h_max n_points]` in m. |
| `sweep.shock_plots` | `true` | Draw the shock pattern (foot, slope, terminal shock) for selected sweep conditions. |
| `sweep.shock_n` | 6 | Maximum number of conditions drawn (<= 9). |
| `sweep.alpha` | `true` | Sweep incidence (used only when `incidence.enable = true`). |
| `sweep.alpha_range` | `[-6 6 13]` | `[alpha_min alpha_max n_points]` in deg. |
| `sweep.map` | `true` | 2-D maps Mach x incidence (only when `incidence.enable = true`). |
| `sweep.map_n` | `[21 13]` | `[n_Mach n_alpha]` grid of the map (uses the `M_range` and `alpha_range` limits). |
| `sweep.export_csv` | `true` | Write every sweep point to CSV. |
| `sweep.csv_file` | `'inlet_sweep_results.csv'` | CSV name (written inside the results folder). |

Sweeps hold the other variables at the **base** condition: Mach and altitude of `offdesign.*` if
`offdesign.enable` (else the design values), and alpha = `incidence.alpha_deg` if `incidence.enable` (else 0).

### 5.7 `cfg_07_output_options.m`

| Variable | Default | Meaning |
|---|---|---|
| `ramp_file` | `'inlet_ramp_profile.txt'` | Ramp polyline (X Y Z, Z = 0), written in both modes. |
| `cowl_file` | `'inlet_cowl_profile.txt'` | Closed cowl outline. |
| `diffuser_file` | `'inlet_diffuser_profile.txt'` | Closed diffuser outline (lower wall, exit plane, cowl wall, terminal shock). |
| `stl_files` | 3 names | STL body names for ramp, cowl, diffuser (3D mode). |
| `output_dir` | `'inlet_results'` | Folder for every output file (created if missing). Relative paths start from the current folder; absolute paths work. |
| `output_timestamp` | `true` | `true` = new sub-folder `<output_dir>/<yyyymmdd_HHMMSS>` per run; `false` = reuse/overwrite `output_dir`. |
| `save_figures` | `true` | Save every figure drawn. |
| `figure_formats` | `{'png','fig'}` | Any of `'png'`, `'fig'`, `'pdf'`, `'jpg'`. |
| `save_stations` | `true` | Write flow-station tables to CSV. |
| `save_log` | `true` | Write the whole console output to `run_log.txt`. |
| `save_script_copy` | `true` | Copy the driver, `config`, `stages` and `functions` to `<results>/code_used` for reproducibility. |

## 6. Input rules and common errors

The code validates inputs and stops with a message when:

- `inlet_type` is not `'ramp'`/`'cone'`, `output_mode` is not `'2D'`/`'3D'`, `scale_factor` is not a positive scalar, or `W <= 0` for a ramp.
- `ramp_lengths` or `cowl_lengths` has the wrong number of entries or contains non-positive values.
- Mode 2 and `M1 > M_int_in > Mn_target > 1` is violated, or `n_internal` is not a positive integer.
- `cowl_outer_curvature` is not finite, `cowl_mean_thickness <= 0`, `M_exit >= 1`, or a diffuser slope is not `NaN`/|angle| < 90.
- Friction settings are invalid (unknown model/method/`re_dh`, `n_grid < 11`, `length_unit_m <= 0`, `roughness_m < 0`).
- The Oswatitsch system is infeasible: no attached shock system reaches `Mn_target` with that many equal-strength shocks. The error reports the reachable range; change `Mn_target`, `M1` or `n_oblique`.

Warnings you may see:

- *Outer cowl wall crosses the inner wall* - reduce the curvature magnitude, increase the mean thickness, or adjust the cowl angles.
- *Diffuser walls cross each other* - increase `diffuser_length` or adjust the split/cowl.
- *Terminal shock attached-oblique check* - the required wall turning exceeds theta_max; an attached oblique terminal shock is not possible there (a detached or lambda shock is possible). Reported at the end of the run.
- *Off-design solver does not reproduce the design point* - theta/beta feasibility problem; check the shock design.
- *Mixed compression does not self-start* (start check < 1) - needs overspeed, bleed or variable geometry.

## 7. Outputs

Everything is written to `<output_dir>[/<timestamp>]/`:

| File | Content |
|---|---|
| `run_log.txt` | Full console output (if `save_log`). |
| `inlet_ramp_profile.txt`, `inlet_cowl_profile.txt`, `inlet_diffuser_profile.txt` | Polylines with header lines `3d=true`, `polyline=true`, then `X Y Z` rows (Z = 0), scaled by `scale_factor`. |
| `inlet_ramp_body.stl`, `inlet_cowl_body.stl`, `inlet_diffuser_body.stl` | 3-D bodies (`output_mode = '3D'`). |
| `stations_design.csv`, `stations_offdesign_N.csv` | Mach, p0/p0inf, p/pinf, T/Tinf, static and total pressure per station. |
| `inlet_sweep_results.csv` | One row per sweep point. |
| `NN_<figure name>.png/.fig/...` | All figures. |
| `run_inlet_design_used.m`, `code_used/` | Copy of the code used. |

Console report sections: Oswatitsch stage tables (Mn*, beta, theta, Mach, pi per shock), terminal shock and total
pressure recovery `pi_d`, cowl lip and capture geometry (H_inf, capture area), facet lengths and shock focusing miss
distances, diffuser summary (throat/exit heights, exit Mach, curvatures, slopes, cowl thickness), exit static and total
pressure at the chosen altitude, friction summary, fixed-geometry check, optional audit, stations, off-design and sweeps.

## 8. Geometry conventions

- Ramp inlet: profile drawn below the y = 0 line (flag = 2). Cone inlet: profile drawn above the axis y = 0 (flag = 1).
- Capture height `H_inf` = axis (y = 0) to cowl lip. Ramp capture area = `W*H_inf`; cone capture area = `pi*H_inf^2`.
- The cowl lip (a sharp 2-D wedge tip) sits at the focus point where the external shocks meet.
- Design values, printed results and the 2-D graph are in design units; only exported geometry is multiplied by `scale_factor`.

## 9. Example configurations

**A. Simple external-compression ramp** (`cfg_02`: `mixed = false`; `cfg_01`: `M1 = 2.0`, `Mn_target = 1.2`, `n_oblique = 3`, `inlet_type = 'ramp'`): keep facet lengths `NaN`, `cowl_angle = 8`, `cowl_upper_angle = 20`.

**B. Mixed-compression cone, 3-D export** (`inlet_type = 'cone'`, `mixed = true`, `M_int_in = 1.5`, `n_internal = 2`, `output_mode = '3D'`, `n_revolve = 72`).

**C. Off-design with incidence and sweeps** (`offdesign.enable = true`, `offdesign.M = 1.5`, `incidence.enable = true`, `incidence.alpha_deg = 5`, `sweep.enable = true`).

## 10. Extending the code

Add a new stage by creating `stages/stage_NN_name.m` and calling it in `run_inlet_design.m`. Add a new helper as one
file in the matching `functions/` sub-folder (file name = function name). The main geometry builder is
`functions/geometry/inlet_geometry.m`; friction solvers are in `functions/friction/`.

## References

Seddon, J. and Goldsmith, E. L., *Intake Aerodynamics* (Fig. 6.11, mixed compression layout).
