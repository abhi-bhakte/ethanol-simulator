% function start_experiment
clc;
clear;
% close all;

warning off
beep off

global fid fid_click    fault_time count_completed auto_matic_shutdown es_flag task_complete_flag
global no_of_tasks  tasks id_num sequence_task task fid_alarm_timing
%% File handler for all files used in text writing
fid_click = fopen('data\text-logs\Mouse_click.txt','wt+');
fid_alarm_timing = fopen('data\text-logs\alarm_timing.txt','wt+');
intro_file = fopen('data\text-logs\Introduction.txt','wt+');
count_completed = 0;
auto_matic_shutdown = 0;
s = sprintf(' %cC', char(176));
disp('================================================Welcome===================================================');


id_num = input('Please Enter Your roll Number: ','s');


fprintf(intro_file,'\nID No: = %s \n',id_num);

no_of_tasks = 6; % this needs to be defined properly
task_no = 1;
no_of_faults = 6;

rand_num = floor(10*rand(12,1));
% fault_time = rand_num +30;
fault_no_list = [8 7 5 11 10 12];
% fault_no_list = [7 7 7 7 7 7 7 7 7 7];
fault_no = fault_no_list(task_no);

sequence_task = [1 2 3 4 5 6];

fprintf(intro_file,'\nsequence of task: = %s \n',num2str(sequence_task));
task = sequence_task(1);

fault_time = ([5 5 5 5 5 5 5 5 5 5 5 5]);
% fault_no_list = [1 2 5 7 1 2 5 7 1 2];
% fault_no_list = [7 7 7 7 7 7 7 7 7 7];
fault_no = fault_no_list(task_no);

% disp('An eye calibration test will be done to ensure smooth operation during the experiment.');

disp('Two green dots will be shown in the figure after you press any key.');
disp('Adjust yourself such that green dots come almost in the middle of the figure.');
disp('Press any key to continue...');

pause
clc

% tetio_init();
% 
% trackerId = 'TX300-010103300552.local.';
% tetio_connectTracker(trackerId);
% currentFrameRate = tetio_getFrameRate;
% % load('D:\Final Code Setup data mixed case-1\13310022_Eye_parameter');
% SetCalibParams; 
% close all;
% % Display the track status window showing the participant's eyes (to position the participant).
% TrackStatus; % Track status window will stay open until user key press.
% % disp('TrackStatus stopped');
% % % remove the comment when doing the practical first time as we need to
% % calilbrate the eyes
% clc;
% disp('Thank you. Press enter to start Calibration workflow');
% pause();
% % % Perform calibration
% % SetCalibParams; 
% 
% pts = HandleCalibWorkflow(Calib);
% 
% % disp('Calibration workflow stopped');
% 
% temp_name = ['C:\Users\acer\Desktop\case-1\' num2str(id_num) '_Eye_parameter'];
% save(temp_name);
% es_flag = 0;
% task_complete_flag = 0;
% % disp('Press any key to start experiment');
% pause();
% setDesktopVisibility('off')
making_ready_for(task_no,fault_no_list,fault_no);


% eye_track_automatic1(task_no,fault_no_list,fault_no);
% setDesktopVisibility('off')
% gui_changed_color(task_no,fault_no_list,fault_no);
% es_flag = 0;
% task_complete_flag = 0;
% making_ready_for(task_no,fault_no_list,fault_no);

