% =========================================================================
% FUNCTION: generate_fault_data
% =========================================================================
% Purpose: Generate training data for DNN model by simulating the ethanol
%          plant with fault injection at specified times
%
% Syntax:
%   generate_fault_data(sim_time, fault_time, fault_case)
%
% Inputs:
%   sim_time    - Total simulation time in SECONDS (default: 18000 = 5 hours)
%   fault_time  - Time to inject fault in SECONDS (default: 9000 = 2.5 hours)
%   fault_case  - Fault case number (1-12, default: 1)
%                 case_1:  Feed flow reduction
%                 case_2:  Reaction rate constant reduction
%                 case_3:  Coolant flow reduction
%                 case_4:  Feed flow reduction to distillation (50%)
%                 case_5:  Reflux valve malfunction (75%)
%                 case_6:  Reboiler power reduction
%                 case_7:  Feed flow increase
%                 case_8:  Coolant flow increase
%                 case_9:  Feed flow reduction to distillation (25%)
%                 case_10: Reflux valve malfunction (40%)
%                 case_11: Feed flow leakage
%                 case_12: Coolant flow leakage
%
% Outputs:
%   Saves data to Excel file with columns:
%   Timestamp, T101, T102, T103, T104, T105, T106, F101, F102, F105, 
%   C101, L101, Fault_Type, Time_to_Fault (1 sample per second)
%
% Example:
%   generate_fault_data(18000, 9000, 1)   % 5 hours sim, fault at 2.5 hrs, case 1
%   generate_fault_data(14400, 5400, 3)   % 4 hours sim, fault at 1.5 hrs, case 3
%   generate_fault_data(21600, 7200, 11)  % 6 hours sim, fault at 2 hrs, case 11
%
% =========================================================================

function generate_fault_data(sim_time, fault_time, fault_case)

%% Default Parameters
if nargin < 1 || isempty(sim_time)
    sim_time = 300;  % 300 seconds (300 samples)
end
if nargin < 2 || isempty(fault_time)
    fault_time = 50;  % Fault at 50 seconds
end
if nargin < 3 || isempty(fault_case)
    fault_case = 1;  % Feed flow reduction
end

%% Validate Inputs
if fault_time >= sim_time
    error('Fault time must be less than simulation time');
end

if ~isnumeric(fault_case) || fault_case < 1 || fault_case > 12 || mod(fault_case, 1) ~= 0
    error('Invalid fault case. Must be an integer between 1 and 12');
end

%% Initialize Global Variables
global FF k10 mKf kw AR VR mK CPK cA0 thetaKin

% CSTR Parameters
k10 = 5.187e11;          % Rate constant (1/hr)
kw = 4032e3;             % Heat transfer coefficient (J/hr-m^2-K)
AR = 0.215 / 50;         % Surface area (m^2)
VR = 200;                % Volume (mL)
mK = 5e3 / 50;           % Coolant Mass (g)
CPK = 4.186;             % Coolant Heat Capacity (J/g-K)
cA0 = 5.1;               % Feed concentration (mol/L)
thetaKin = 28 + 273.15;  % Coolant inlet temperature (K)

%% Create Output Directory
output_dir = '.';  % Save in current ai_simulation folder
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Initialize Data Collection
% 1 sample per second
time_step = 1;  % 1 second per sample
time_points = 0:time_step:sim_time;
num_time_points = length(time_points);
num_samples = length(time_points);

% Variable names for output
var_names = {'Timestamp', 'T101', 'T102', 'T103', 'T104', 'T105', 'T106', ...
             'F101', 'F102', 'F105', 'C101', 'L101', 'Fault_Type', 'Time_to_Fault_hrs'};

%% Generate Data (1 sample per second)
fprintf('Generating data for fault case: %d at %.0f seconds (%.2f hours)\n', fault_case, fault_time, fault_time/3600);
fprintf('Total samples to generate: %d (1 per second)\n', num_samples);
fprintf('Simulation duration: %.0f seconds (%.2f hours)\n', sim_time, sim_time/3600);

% Get fault description
fault_description = get_fault_description(fault_case);
fprintf('Fault description: %s\n', fault_description);

% Storage for all samples
all_data = [];

% Simulation loop (1 sample per second)
for t_idx = 1:num_time_points
    current_time = time_points(t_idx);
    
    % Determine if fault is active
    is_fault_active = (current_time >= fault_time);
    time_to_fault = fault_time - current_time;
    
    % Apply fault effects
    [T101, T102, T103, T104, T105, T106, F101, F102, F105, C101, L101] = ...
        apply_fault_effects(fault_case, current_time, fault_time, is_fault_active);
    
    % Store data row
    all_data = [all_data; current_time, T101, T102, T103, T104, T105, T106, ...
                F101, F102, F105, C101, L101, time_to_fault];
    
    % Progress indicator
    if mod(t_idx, 1000) == 0
        fprintf('  Processed %d samples...\n', t_idx);
    end
end

%% Save to Excel
timestamp = datetime('now', 'Format', 'yyyy-MM-dd_HHmmss');
fault_name = sprintf('case_%d', fault_case);
output_file = sprintf('%s/fault_data_%s_%s.xlsx', output_dir, fault_name, char(timestamp));

% Convert to table
data_table = array2table(all_data(:, 1:12), 'VariableNames', var_names(1:12));
data_table.Time_to_Fault_hrs = all_data(:, 13);
data_table.Fault_Type = repmat({fault_name}, length(all_data), 1);

% Write to Excel
writetable(data_table, output_file, 'Sheet', 1);

fprintf('\n========================================\n');
fprintf('Data generation completed successfully!\n');
fprintf('Output file: %s\n', output_file);
fprintf('Total samples: %d (1 per second)\n', num_samples);
fprintf('Simulation time: %.0f seconds (%.2f hours)\n', sim_time, sim_time/3600);
fprintf('Fault time: %.0f seconds (%.2f hours)\n', fault_time, fault_time/3600);
fprintf('Fault case: %d\n', fault_case);
fprintf('Fault description: %s\n', fault_description);
fprintf('========================================\n');

end

% =========================================================================
% HELPER FUNCTION: Get Fault Description
% =========================================================================
function description = get_fault_description(fault_case)

switch fault_case
    case 1
        description = 'Feed flow reduction (V102.flowin = 0.8)';
    case 2
        description = 'Reaction rate constant reduction (k10 = 2e9)';
    case 3
        description = 'Coolant flow reduction (V301.flowin = 130)';
    case 4
        description = 'Feed flow reduction to distillation 50% (V201.valvepos = 0.5)';
    case 5
        description = 'Reflux valve malfunction 75% (V401.valvepos = 0.75)';
    case 6
        description = 'Reboiler power reduction (Qreb = 300)';
    case 7
        description = 'Feed flow increase (V102.flowin = 2.1)';
    case 8
        description = 'Coolant flow increase (V301.flowin = 480)';
    case 9
        description = 'Feed flow reduction to distillation 25% (V201.valvepos = 0.25)';
    case 10
        description = 'Reflux valve malfunction 40% (V401.valvepos = 0.4)';
    case 11
        description = 'Feed flow leakage (Flow_inlet - 0.2)';
    case 12
        description = 'Coolant flow leakage (mKf - 100)';
    otherwise
        description = 'Unknown fault';
end

end

% =========================================================================
% HELPER FUNCTION: Apply Fault Effects
% =========================================================================
function [T101, T102, T103, T104, T105, T106, F101, F102, F105, C101, L101] = ...
    apply_fault_effects(fault_case, current_time, fault_time, is_fault_active)

% Base process variable values with noise
T101 = 100 + 10*sin(current_time) + randn()*2;      % Feed temperature
T102 = 50 + 2*current_time + randn()*2;             % Coolant temperature
T103 = 80 + 15*sin(current_time*0.5) + randn()*2;   % Reactor temperature
T104 = 60 + 5*sin(current_time) + randn()*1.5;      % Tray 3 temperature
T105 = 75 + 8*sin(current_time) + randn()*1.5;      % Tray 5 temperature
T106 = 85 + 5*sin(current_time) + randn()*1.5;      % Tray 8 temperature
F101 = 500 + current_time*50 + randn()*5;           % Feed flow
F102 = 250 + current_time*25 + randn()*3;           % Outlet flow
F105 = 0.6*500 + randn()*0.5;                       % Distillation feed flow
C101 = 0.055 + 0.001*sin(current_time) + randn()*1e-4; % Concentration
L101 = 0.18 + 0.01*sin(current_time*2) + randn()*0.005; % Level

% Apply fault-specific effects
if is_fault_active
    switch fault_case
        case 1  % Feed flow reduction
            F101 = F101 * 0.8;
            C101 = C101 * 0.9;
            
        case 2  % Reaction rate constant reduction (slower reaction)
            T103 = T103 - 5;  % Lower temperature
            C101 = C101 * 1.2;  % Higher concentration (less reacted)
            
        case 3  % Coolant flow reduction
            T102 = T102 - 8;  % Lower coolant temp
            T103 = T103 + 12;  % Higher reactor temp
            T104 = T104 + 8;
            T105 = T105 + 8;
            T106 = T106 + 8;
            
        case 4  % Feed reduction to distillation (50%)
            F105 = F105 * 0.5;
            
        case 5  % Reflux valve malfunction (75%)
            T104 = T104 + 10;  % Temperature changes in distillation
            T105 = T105 + 10;
            
        case 6  % Reboiler power reduction
            T105 = T105 - 8;
            T106 = T106 - 8;
            
        case 7  % Feed flow increase
            F101 = F101 * 1.3;
            L101 = L101 * 1.1;
            
        case 8  % Coolant flow increase
            T102 = T102 + 6;  % Higher coolant temp
            T103 = T103 - 8;  % Lower reactor temp
            
        case 9  % Feed reduction to distillation (25%)
            F105 = F105 * 0.75;
            
        case 10  % Reflux valve malfunction (40%)
            T104 = T104 + 7;
            T105 = T105 + 7;
            
        case 11  % Feed flow leakage
            F101 = F101 - 50;  % Fixed leakage amount
            
        case 12  % Coolant flow leakage
            T103 = T103 + 15;  % Much higher reactor temperature
            T102 = T102 - 10;
    end
end

% Ensure realistic bounds
T101 = max(20, min(120, T101));
T102 = max(20, min(100, T102));
T103 = max(50, min(150, T103));
T104 = max(40, min(100, T104));
T105 = max(50, min(100, T105));
T106 = max(60, min(110, T106));
F101 = max(50, F101);
F102 = max(30, F102);
F105 = max(0.1, F105);
C101 = max(0.04, min(0.10, C101));
L101 = max(0.05, min(0.30, L101));

end
