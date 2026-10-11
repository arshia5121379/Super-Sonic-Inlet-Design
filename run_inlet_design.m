% run_inlet_design.m - driver for the Oswatitsch supersonic inlet design tool.
%
% Edit the inputs in  config/cfg_*.m,  then run this file. The pipeline is split into small units:
%   config/     user inputs, one file per topic (scripts, share the base workspace)
%   stages/     the design / report / export pipeline, one file per step (scripts, same workspace)
%   functions/  one function per file, grouped by topic (solver, geometry, export, report,
%               plotting, analysis, sweeps, friction)
% Stage order and variable flow are exactly those of the original single-file script.

clear; clc; close all;

project_root = fileparts(mfilename('fullpath'));
addpath(genpath(project_root));

%% 1) Inputs
cfg_01_design_point;
cfg_02_compression_and_facets;
cfg_03_cowl;
cfg_04_diffuser_and_flight;
cfg_05_friction;
cfg_06_analysis_options;
cfg_07_output_options;

%% 2) Design
stage_01_output_directory;
stage_02_solve_oswatitsch;
stage_03_print_design_summary;
stage_04_build_geometry;

%% 3) Design reports
stage_05_report_cowl_capture;
stage_06_report_facets_focusing;
stage_07_report_diffuser;

%% 4) Export
stage_08_export_profiles;
stage_09_export_3d_bodies;

%% 5) Fixed-geometry analysis (stations, off-design, sweeps)
stage_10_fixed_geometry_model;
stage_11_station_map;
stage_12_offdesign_point;
stage_13_sweeps;

%% 6) Wrap-up
stage_14_save_figures;
stage_15_terminal_shock_check;
stage_16_finish;
