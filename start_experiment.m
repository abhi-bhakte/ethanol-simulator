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
global es_flag task_complete_flag no_of_tasks tasks id_num sequence_task
global task fid_alarm_timing calibration_completed calibration_step

% -------------------------------------------------------------------------
% SECTION 3: FILE HANDLERS INITIALIZATION
% -------------------------------------------------------------------------

% Initialize calibration flags
calibration_completed = false;
calibration_step = 0;

% Open log files for data recording
fid_click = fopen('data\text-logs\Mouse_click.txt','wt+');
fid_alarm_timing = fopen('data\text-logs\alarm_timing.txt','wt+');
intro_file = fopen('data\text-logs\Introduction.txt','wt+');

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

% Define experiment parameters
no_of_tasks = 6;              % Total number of tasks
task_no = 1;                  % Start with first task
no_of_faults = 6;             % Number of fault scenarios

% Define fault sequence for all tasks
fault_no_list = [1 3 4 5 7 8];
fault_no = fault_no_list(task_no);  % Get fault for current task

% Define task execution sequence
sequence_task = [1 3 4 5 7 8];
task = sequence_task(1);  % Start with first task in sequence

% Log task sequence to introduction file
fprintf(intro_file,'\nsequence of task: = %s \n',num2str(sequence_task));

% -------------------------------------------------------------------------
% SECTION 6: FAULT TIMING AND RANDOMIZATION
% -------------------------------------------------------------------------

% Generate random numbers for potential timing variations
rand_num = floor(10*rand(1,12));

% Define fault occurrence timing (in seconds) for each task
% All tasks set to 20 seconds before fault occurs
fault_time = [20 20 20 20 20 20 20 20 20 20 20 20];

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


