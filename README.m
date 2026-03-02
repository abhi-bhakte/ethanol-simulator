%=========================================================================
% ETHANOL SIMULATOR - QUICK START
%=========================================================================
%
% Purpose:
% MATLAB simulator for CSTR + distillation with alarms, operator actions,
% and experiment logging.
%
%=========================================================================
% 1) SETUP ON A NEW WINDOWS PC
%=========================================================================
%
% Step 1: Copy project folder
%   Copy full `ethanol-simulator` folder to the new PC.
%
% Step 2: Install required software
%   - MATLAB (R2021a or newer recommended)
%   - Python 3.10+ (only if you want API-based fault prediction)
%
% Step 3: Open project in MATLAB
%   In MATLAB Command Window, from project root run:
%
%       addpath(genpath(pwd));
%       savepath;
%
%=========================================================================
% 2) RUN THE SIMULATOR
%=========================================================================
%
% From project root in MATLAB:
%
%       start_experiment
%
% Main entry files:
%   - start_experiment.m
%   - main/main_file_kaushik_parameters.m
%
%=========================================================================
% 3) OUTPUT LOCATIONS
%=========================================================================
%
% Generated outputs:
%   - data/excel-outputs/
%   - data/text-logs/
%
%=========================================================================
% 4) OPTIONAL: START PYTHON FAULT API
%=========================================================================
%
% If MATLAB uses prediction via `utils/predict_fault_api.m`, start API first.
% Setup steps are in:
%   explaination_module/README.md
%
%=========================================================================