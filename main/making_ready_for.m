% =========================================================================
% FUNCTION: making_ready_for
% =========================================================================
% Purpose: Prepares and displays task introduction and instruction windows
%          for the ethanol distillation experiment
%
% Inputs:
%   task_no       - Current task number (1 to no_of_tasks)
%   fault_no_list - Array of fault scenario numbers for all tasks
%   fault_no      - Fault number for the current task
%
% =========================================================================

function making_ready_for(task_no,fault_no_list,fault_no)

% -------------------------------------------------------------------------
% SECTION 1: INITIALIZATION
% -------------------------------------------------------------------------

% Declare global variables
global task_name no_of_tasks ty intro_file t_start_exp fid_click
global id_num
global task_no_current
global condition_mode
global calibration_completed

% Add necessary paths
addpath('data-collection');
addpath('gui');
addpath('utils');
addpath('monitoring');

% Update global task number for display configuration
task_no_current = task_no;

% -------------------------------------------------------------------------
% CONDITION ORDER CONFIG
% -------------------------------------------------------------------------
% Edit this list to change the condition sequence.
% 1 = Baseline, 2 = Quantitative, 3 = LLM
condition_order = [1 2 3]; % Example: Baseline first, then Quantitative, then LLM

% Tasks per condition (full study = 5)
tasks_per_condition = 5;

% Compute condition mode for this task based on the configured order
condition_index = ceil(task_no / tasks_per_condition);
condition_index = min(max(condition_index, 1), numel(condition_order));
condition_mode = condition_order(condition_index);

needs_calibration = (task_no == 1) && (isempty(calibration_completed) || ~calibration_completed);

% Verify file path is accessible
fid_click = fopen(sprintf('data/text-logs/Mouse_click_%s.txt', id_num),'wt+');
if fid_click == -1
    error('Could not open per-user Mouse_click file. Check path and permissions.');
end
fclose(fid_click); % Close initially, will reopen when needed

% -------------------------------------------------------------------------
% SECTION 2: FIGURE WINDOW SETUP
% -------------------------------------------------------------------------

% Define common figure dimensions
figWidth = 350;
figHeight = 400;

% Create instruction window (f_mess) - hidden initially
f_mess = figure('Visible','off','Name','Operating details and Goal',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[0, 0, figWidth, figHeight],'Resize','off','color',.9.*[1 1 1]);
movegui(f_mess,'center');

% Create task introduction window (f_task) - hidden initially
f_task = figure('Visible','off','Name','Task Introduction',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[0 0,figWidth,figHeight],'Resize','off','color',.9.*[1 1 1]);
movegui(f_task,'center');

% Create finish/start window (f_finish) - hidden initially
f_finish = figure('Visible','off','Name','End of demo tasks and start first scenario',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[0,0,figWidth,figHeight],'Resize','off','color',.9.*[1 1 1]);
movegui(f_finish,'center');

% -------------------------------------------------------------------------
% SECTION 3: TASK DEFINITIONS
% -------------------------------------------------------------------------

% Define task description (same for all scenarios to maintain consistent objectives)
task_description = 'Maintain the ethanol plant at normal operating conditions with all variables within specified limits';

% Create task names array - all tasks have the same objective
task_name = repmat({task_description}, 1, no_of_tasks);

% -------------------------------------------------------------------------
% SECTION 4: UI CONTROLS - INSTRUCTION WINDOW (f_mess)
% -------------------------------------------------------------------------

% Title text
title_text = uicontrol(f_mess,'Style','text','HorizontalAlignment','center','Units','Points',...
    'Position',[10,360,330,25],'String','ETHANOL PLANT CONTROL','backgroundcolor',.9.*[1 1 1],...
    'foregroundcolor',[0.1 0.1 0.5],'fontsize',14,'fontweight','bold');

% Operator image with circular crop
ax = axes('Parent',f_mess,'Units','points','Position',[125 240 110 110]);
[scriptDir,~,~] = fileparts(mfilename('fullpath'));
imgPath = fullfile(scriptDir, '..', 'media', 'images', 'operator.jpg');
img = imread(imgPath);

% Resize image to square
imgSize = min(size(img,1), size(img,2));
centerX = round(size(img,2)/2);
centerY = round(size(img,1)/2);
halfSize = round(imgSize/2);
imgSquare = img(max(1,centerY-halfSize):min(size(img,1),centerY+halfSize), ...
                max(1,centerX-halfSize):min(size(img,2),centerX+halfSize), :);

% Create circular mask
[rows, cols, ~] = size(imgSquare);
[X, Y] = meshgrid(1:cols, 1:rows);
centerX = cols / 2;
centerY = rows / 2;
radius = min(cols, rows) / 2;
circleMask = ((X - centerX).^2 + (Y - centerY).^2) <= radius^2;

% Apply circular mask
imgCircular = imgSquare;
for i = 1:size(imgSquare, 3)
    channel = imgSquare(:,:,i);
    channel(~circleMask) = 230; % Match background color
    imgCircular(:,:,i) = channel;
end
imshow(imgCircular, 'Parent', ax);
axis(ax, 'off');
axis(ax, 'equal');

Start_string = sprintf(['YOUR TASK:\n• Keep the ethanol plant operating normally\n'...
    '• All variables must stay WITHIN RANGE\n\n'...
    'WHEN AN ALARM OCCURS:\n• You will hear a BEEP sound\n'...
    '• A variable will CHANGE COLOR (red)\n• You have 2 MINUTES to restore normal operation\n\n'...
    ]);

mess_fow = uicontrol(f_mess,'Style','text','HorizontalAlignment','left','Units','Points',...
    'Position',[15,90,320,130],'String',Start_string,'backgroundcolor',.9.*[1 1 1],...
    'foregroundcolor',[0 0 0],'fontsize',10,'fontweight','bold');

% Next button for instruction window
start_make = uicontrol(f_mess,'Style','pushbutton','String','Next','Units','points',...
    'fontsize',12,'Position',[137.5 40,75,30],'visible','on','Callback',@start_make_call);

% -------------------------------------------------------------------------
% SECTION 5: UI CONTROLS - TASK WINDOW (f_task)
% -------------------------------------------------------------------------

% Task message display
task_mess = uicontrol(f_task,'Style','text','Units','Points','Position',[20,200,310,120],...
    'backgroundcolor',.9.*[1 1 1],'foregroundcolor',[0 0 0],'fontsize',13,'fontweight','bold',...
    'HorizontalAlignment','center');

% Condition line (shown only at condition start)
condition_mess = uicontrol(f_task,'Style','text','Units','Points','Position',[20,175,310,25],...
    'backgroundcolor',.9.*[1 1 1],'foregroundcolor',[0 0 0],'fontsize',12,'fontweight','bold',...
    'HorizontalAlignment','center','String','');

% Finish button
finish_button = uicontrol(f_task,'Style','pushbutton','String','Finish','Units','points',...
    'fontsize',12,'Position',[137.5 80,75,30],'visible','off','Callback',@finish_button_callback);
 
% Next task button
next_task = uicontrol(f_task,'Style','pushbutton','String','Next','Units','points',...
    'fontsize',12,'Position',[137.5 80,75,30],'visible','off','Callback',@start_next_task_call);

% Start next task button
start_next_task = uicontrol(f_task,'Style','pushbutton','String','Start','Units','points',...
    'fontsize',12,'Position',[137.5 60,75,30],'visible','on','Callback',@start_next_button_callback);

% -------------------------------------------------------------------------
% SECTION 6: UI CONTROLS - FINISH WINDOW (f_finish)
% -------------------------------------------------------------------------

finish_task = uicontrol(f_finish,'Style','pushbutton','String','Start Experiment','Units',...
    'points','fontsize',12,'Position',[225 250,125,30],'visible','on','Callback',@finish_task_call);

% -------------------------------------------------------------------------
% SECTION 7: TASK FLOW CONTROL
% -------------------------------------------------------------------------

% Update fault number if not at the last task
if task_no < no_of_tasks  
    fault_no = fault_no_list(task_no);
end

% Control window visibility based on task progress
if task_no <= no_of_tasks    
    % Task 1 sequence: Operating details -> Calibration -> Task Introduction
    if task_no == 1 && needs_calibration
        % Show Operating details and Goal first
        set(f_mess,'visible','on');
        set(start_make,'visible','on');
        clc;
    elseif task_no == 1
        % After calibration: show Task Introduction window for task 1
        set(f_task,'visible','on');
        set(next_task,'visible','off');
        set(start_next_task,'visible','on');
        if condition_mode == 1
            condition_line = 'Decision Support: No Decision Support';
        elseif condition_mode == 2
            condition_line = 'Decision Support: Quantitative Feature Explanations';
        else
            condition_line = 'Decision Support: LLM Descriptive Explanations';
        end
        set(task_mess,'String',task_description);
        set(condition_mess,'String',condition_line);
        clc;
    else
        % Between tasks: show task completion message
        set(f_task,'visible','on');
        eval(sprintf('set(task_mess,''String'',''End of task %d.  Press Next button to start next task'');',task_no - 1));
        set(condition_mess,'String','');
        set(start_next_task,'visible','off');
        set(next_task,'visible','on');
        clc;
    end
else
    % All tasks completed: show finish screen
    set(f_task,'visible','on');
    set(task_mess,'String','You have completed all the task. Press finish to fill up the feedback form.');
    set(condition_mess,'String','');
    set(start_next_task,'visible','off');
    set(finish_button,'visible','on');
end

% -------------------------------------------------------------------------
% SECTION 8: CALLBACK FUNCTIONS
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Callback: start_make_call
% Triggered when user clicks "Next" on instruction window (at condition start)
% -------------------------------------------------------------------------
function start_make_call(varargin)
    close(f_mess);
    % After Operating details, run calibration for task 1 (if pending)
    if task_no == 1 && (isempty(calibration_completed) || ~calibration_completed)
        gui_changed_color(task_no,fault_no_list,fault_no);
        return;
    end
end

% -------------------------------------------------------------------------
% Callback: start_next_task_call
% Triggered when user clicks "Next" button between tasks
% -------------------------------------------------------------------------
function start_next_task_call(varargin)
    % Condition-start tasks show Task Introduction;
    % otherwise start the next task immediately.
    is_condition_start = (mod(task_no - 1, tasks_per_condition) == 0);

    if is_condition_start
        set(next_task,'visible','off');
        set(start_next_task,'visible','on');

        if condition_mode == 1
            condition_line = 'BASELINE: Manual monitoring only';
        elseif condition_mode == 2
            condition_line = 'QUANTITATIVE: AI feature explanations';
        else
            condition_line = 'LLM: AI descriptive explanations';
        end
        set(task_mess,'String',task_description);
        set(condition_mess,'String',condition_line);
    else
        % Start task immediately (skip Task Introduction popup)
        set(f_task,'visible','off');
        set(condition_mess,'String','');
        te = toc(t_start_exp);
        fid_click = fopen(sprintf('data/text-logs/Mouse_click_%s.txt', id_num),'at+');
        fprintf(fid_click,'%.0f     %.6f  %.2f   %.2f    %d   %s %.2f\n',...
            floor(te),(te-floor(te)),0,0,1,'Start_next_task',0000);
        fclose(fid_click);
        gui_changed_color(task_no,fault_no_list,fault_no);
    end
end

% -------------------------------------------------------------------------
% Callback: start_next_button_callback
% Triggered when user clicks "Start" button to begin a task
% -------------------------------------------------------------------------
function start_next_button_callback(varargin)
    set(f_task,'visible','off');
    if task_no == 1
        t_start_exp = tic;

        % Log start time to Introduction.txt
        intro_file = fopen(sprintf('data\\text-logs\\Introduction_%s.txt', id_num),'at+');
        te = toc(t_start_exp);
        fprintf(intro_file,'start_time task no: %d %d  %.6f \n',...
            task_no,floor(te),(te-floor(te)));
        fclose(intro_file);
    end
    te = toc(t_start_exp);
    
    % Log event to Mouse_click.txt
    fid_click = fopen(sprintf('data/text-logs/Mouse_click_%s.txt', id_num),'at+');
    fprintf(fid_click,'%.0f     %.6f  %.2f   %.2f    %d   %s %.2f\n',...
        floor(te),(te-floor(te)),0,0,1,'Start_next_task',0000);
    fclose(fid_click);
    
    % Launch GUI for the task
    gui_changed_color(task_no,fault_no_list,fault_no);
end

% -------------------------------------------------------------------------
% Callback: finish_button_callback
% Triggered when user completes all tasks and clicks "Finish"
% -------------------------------------------------------------------------
function finish_button_callback(varargin)
    set(finish_button,'visible','off');
    set(task_mess,'String',' ');
    
    % Display feedback form
    feedback_per_task;
    set(task_mess,'Position',[50,250,1,1]);
    
    % Close introduction file
    fclose(intro_file);
end

end

