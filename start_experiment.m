% =========================================================================
% SCRIPT: start_experiment
% =========================================================================
% Purpose: Entry point for the Ethanol Distillation Simulator
%          Initializes experiment environment, sets up paths, collects
%          participant information, and launches the task interface
%
% Author: [XAI-Evaluation Team]
% Created: [Date]
% Modified: [Date]
%
% =========================================================================

% -------------------------------------------------------------------------
% SECTION 1: WORKSPACE INITIALIZATION
% -------------------------------------------------------------------------

% Clear workspace and command window
clc;
clear;

% Seed RNG for randomized sequences each run
rng('shuffle');

% Add all required module paths to MATLAB search path
addpath('main');
addpath('gui');
addpath('control');
addpath('utils');
addpath('monitoring');
addpath('data-collection');

% Suppress warnings and system beeps
warning off
beep off

% -------------------------------------------------------------------------
% SECTION 2: GLOBAL VARIABLES DECLARATION
% -------------------------------------------------------------------------

% Declare global variables for cross-function communication
global fid fid_click fault_time count_completed auto_matic_shutdown
global es_flag task_complete_flag no_of_tasks tasks id_num
global task fid_alarm_timing calibration_completed calibration_step
global task_no_current  % Track current task number for display configuration

% -------------------------------------------------------------------------
% SECTION 3: FILE HANDLERS INITIALIZATION
% -------------------------------------------------------------------------

% Initialize calibration flags
calibration_completed = false;
calibration_step = 0;

% Initialize current task number (will be updated for each task)
task_no_current = 1;

% Open log files for data recording
fid_click = fopen(sprintf('data\\text-logs\\Mouse_click_%s.txt', id_num),'wt+'); % per-user mouse click log
fid_alarm_timing = fopen(sprintf('data\\text-logs\\alarm_timing_%s.txt', id_num),'wt+'); % per-user alarm timing log
intro_file = fopen(sprintf('data\\text-logs\\Introduction_%s.txt', id_num),'wt+');

% Initialize experiment state flags
count_completed = 0;
auto_matic_shutdown = 0;

% Display welcome message
disp('================================================Welcome===================================================');

% -------------------------------------------------------------------------
% SECTION 4: PARTICIPANT INFORMATION COLLECTION
% -------------------------------------------------------------------------

% Collect participant identifier (roll number)
id_num = input('Please Enter Your roll Number: ','s');

% Log participant ID to introduction file
fprintf(intro_file,'\nID No: = %s \n',id_num);

% -------------------------------------------------------------------------
% SECTION 5: EXPERIMENT CONFIGURATION
% -------------------------------------------------------------------------

% Define experiment parameterssequence_task
no_of_tasks = 7;              % Total number of tasks
task_no = 1;                  % Start with first task
no_of_faults = 7;             % Number of fault scenarios

% Define allowed faults and randomize the sequence for this session
allowed_faults = [1 3 4 5 7 8 10];
idx = randperm(numel(allowed_faults), no_of_tasks);
fault_no_list = allowed_faults(idx);   % randomized unique faults for tasks
fault_no = fault_no_list(task_no);     % Get fault for current task

% Define task execution sequence (same as randomized fault order for logging)
sequence_task = fault_no_list;
task = sequence_task(1);  % Start with first task in sequence

% Log task sequence to introduction file
fprintf(intro_file,'\nsequence of task: = %s \n',num2str(sequence_task));

% -------------------------------------------------------------------------
% SECTION 6: FAULT TIMING AND RANDOMIZATION
% -------------------------------------------------------------------------

% Generate random numbers for potential timing variations
rand_num = randi([15 20], 1, no_of_tasks);

% Define fault occurrence timing (in seconds) for each task
% Randomize each task fault time between 15 and 20 seconds (inclusive)
fault_time = 1000 * ones(1, 12);

fault_time(allowed_faults) = rand_num;

% Log randomized fault timings to introduction file
fprintf(intro_file,'\nFault timings (s): = %s \n', num2str(fault_time));

% -------------------------------------------------------------------------
% SECTION 7: SESSION DATA STORAGE
% -------------------------------------------------------------------------

% Create filename for saving experiment data
temp_name = ['data\matlab-data\' num2str(id_num) '_info_expD'];

% Save current workspace state (participant info, configuration, etc.)
save(temp_name);

% -------------------------------------------------------------------------
% SECTION 8: TASK INITIALIZATION
% -------------------------------------------------------------------------

% Launch task preparation interface
making_ready_for(task_no,fault_no_list,fault_no);


