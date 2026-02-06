% =========================================================================
% FUNCTION: gui_changed_color
% =========================================================================
% Purpose: Creates and manages the main graphical user interface (GUI) for the
%          ethanol distillation plant control experiment. Displays the schematic,
%          alarms, process variables, and control elements for plant operation.
%
% Inputs:
%   task_no       - Current task number (identifies which scenario is running)
%   fault_no_list - Array of fault scenario numbers for all tasks
%   fault_no      - Fault number for the current task
%
% Outputs:
%   None (displays GUI windows and manages interactive controls)
%
% Key Features:
%   - Calibration window for initial setup (first task only)
%   - Schematic display window with plant diagram
%   - Alarm summary window with real-time alarm monitoring
%   - Historical trend plotting for process variables
%   - Manual control sliders for plant operation
%   - Data logging for mouse clicks and movements
%
% =========================================================================

function gui_changed_color(task_no,fault_no_list,fault_no)

% -------------------------------------------------------------------------
% SECTION 1: INITIALIZATION AND SETUP
% -------------------------------------------------------------------------

% Add necessary paths for supporting functions
addpath('monitoring');
addpath('utils');

% Disable MATLAB beep for cleaner user experience
beep off

% Import valve class for control elements
import valve.*


% -------------------------------------------------------------------------
% SECTION 2: GLOBAL VARIABLE DECLARATIONS
% -------------------------------------------------------------------------
% These global variables are used across the main experiment script and
% callback functions to maintain state and share data

% Task and timing variables
global task_no_lo fault_no_list_lo fault_no_lo no_of_tasks t_start_exp
global time_start time_start_first time_for_process_var time_track_for_experiment time_track_count
global time_duration_seconds

% GUI window handles and display elements
global f f1 f2 b_image f_ref f2_ref
global trendPanel varTrend closeTrendbh tag_for_plot

% Process variable display controls (text boxes showing real-time values)
global ans_pv_1 ans_pv_2 ans_pv_3 ans_pv_4 ans_pv_5 ans_pv_6 ans_pv_7 ans_pv_8
global ans_pv_9 ans_pv_10 ans_pv_11

% Slider value display controls
global ans_11 ans_12 ans_13 ans_14 ans_15 ans_18 ans_21 ans_24 ans_28 ans_29 ans_30

% Control buttons
global Start_Simu closeButton esd_box identification_opt

% Valve control objects (represent physical valves in the system)
global V102 V301 V401 V201

% Slider controls for valve operation
global slider_feed slider_coolant slider_reflux slider_flow_dist slider_for_temp
global slider_amn_feed slider_amn_cooling slider_amn_dist slider_amn_reflux

% Control status flags (0=automatic, 2=manual)
global control_stat_reflux control_stat_feed control_stat_cooling control_stat_dist

% Trend plot buttons for each process variable
global v1bh v2bh v3bh v4bh v5bh v6bh v7bh v8bh v9bh v10bh v11bh
global v12bh v13bh v14bh v15bh v16bh

% Calibration variables
global calibration_completed calibration_step

% File I/O handles
global fid fid_click fid_mouse_move fid_alarm_timing intro_file file_clk

% Data collection variables
global sequence_task Calib pts trackerId leftEyeAll rightEyeAll timeStampAll
global index_for_scenario alarm_var_store number_var_alarms slider_var_store

% Status flags
global es_flag task_complete_flag
global flag_flow_distill flag_for_reflux
global alarm_text posit control_pos control_stat curr_time
global ty

% AI Fault Prediction variables
global fault_prediction_text fault_prediction_axes
global fault_prediction_history time_prediction_history

% -------------------------------------------------------------------------
% SECTION 3: INITIALIZE STATE FLAGS AND VARIABLES
% -------------------------------------------------------------------------

% Initialize control mode flags (0 = automatic, 1 = initiated, 2 = manual)
flag_flow_distill = 0;
flag_for_reflux = 0;

% Set all control channels to manual mode initially
control_stat_reflux = 2;
control_stat_feed = 2;
control_stat_cooling = 2;
control_stat_dist = 2;

% -------------------------------------------------------------------------
% SECTION 3: INITIALIZE STATE FLAGS AND VARIABLES
% -------------------------------------------------------------------------

% Initialize control mode flags (0 = automatic, 1 = initiated, 2 = manual)
flag_flow_distill = 0;
flag_for_reflux = 0;

% Set all control channels to manual mode initially
control_stat_reflux = 2;
control_stat_feed = 2;
control_stat_cooling = 2;
control_stat_dist = 2;

% Store local copies of task parameters for use throughout the GUI
task_no_lo = task_no;
fault_no_lo = fault_no;
fault_no_list_lo = fault_no_list;

% Initialize AI fault prediction history
fault_prediction_history = [];
time_prediction_history = [];

% -------------------------------------------------------------------------
% SECTION 4: INITIALIZE CALIBRATION STATUS
% -------------------------------------------------------------------------
% The calibration window is only shown once at the beginning of the experiment.
% This section checks if calibration has been completed and creates appropriate windows.

% Initialize calibration tracking variables on first run
if isempty(calibration_completed)
    calibration_completed = false;
    calibration_step = 0; % Track which calibration step we are on
end

% Create appropriate windows based on calibration status
% First task: Show calibration window and hide schematic/alarms until calibration completes
if ~calibration_completed
    f1 = figure('Visible','on','Name','Calibration window',...
        'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
        'Position',[10,7,1425,880],'Resize','on','color',[127 127 127]./255);
    % Add title to calibration window
    uicontrol(f1,'Style','text','String','Eye Tracker Calibration','Units','normalized',...
        'Position',[0 0.95 1 0.05],'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0],...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
    
    f = figure('Visible','off','Name','Schematic Display',...
        'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
        'Position',[10,260,1425,530],'Resize','on','color',[127 127 127]./255);
    % Add title to schematic display window
    uicontrol(f,'Style','text','String','Plant Schematic Display','Units','normalized',...
        'Position',[0 0.97 1 0.04],'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0],...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
else
    f1 = []; % No calibration window for subsequent tasks
    f = figure('Visible','on','Name','Schematic Display',...
        'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
        'Position',[10,260,1425,530],'Resize','on','color',[127 127 127]./255);
    % Add title to schematic display window
    uicontrol(f,'Style','text','String','Plant Schematic Display','Units','normalized',...
        'Position',[0 0.97 1 0.04],'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0],...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
end

% Create alarm display window (second window for monitoring plant alarms)
if ~calibration_completed
    f2 = figure('Visible','off','Name','Alarms Display',...
        'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
        'Position',[10, 30, 1425, 230],'Resize','on', 'color', [127 127 127]./255);
    % Add title to alarms display window
    uicontrol(f2,'Style','text','String','Alarms Display','Units','normalized',...
        'Position',[0 0.92 1 0.08],'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0],...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
else
    f2 = figure('Visible','on','Name','Alarms Display',...
        'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
        'Position',[10, 30, 1425, 230],'Resize','on', 'color', [127 127 127]./255);
    % Add title to alarms display window
    uicontrol(f2,'Style','text','String','Alarms Display','Units','normalized',...
        'Position',[0 0.92 1 0.08],'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0],...
        'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');
end

% -------------------------------------------------------------------------
% NESTED FUNCTION: close_feedback_form
% -------------------------------------------------------------------------
% Closes the alarm display window when task ends or emergency shutdown occurs
function close_feedback_form(varargin)
       if es_flag == 1 || task_complete_flag == 1   
         close(f2);
       end
end

% Store window position references for resizing operations
f_ref = get(f,'Position');
f2_ref = get(f2,'Position');

% -------------------------------------------------------------------------
% SECTION 5: ALARM DISPLAY LAYOUT SETUP
% -------------------------------------------------------------------------
% Creates a 1x3 grid layout on the alarm display window for organizing
% alarm messages, trend plots, and explanatory text
try
    gl = uigridlayout(f2,[1 3],'ColumnWidth',{'1x','1x','1x'},'RowHeight',{'1x'});
catch
    % Fallback if uigridlayout is unavailable: use a parent panel with normalized thirds
    gl = uipanel('Parent',f2,'Units','normalized','Position',[0 0 1 1],'BorderType','none');
end

% Create three equal panels for alarm display layout
% Left panel: Alarm Summary table
% Middle panel: Historical Trend plotting
% Right panel: Explanation/Help text
leftPanel  = uipanel(gl,'BackgroundColor',[127 127 127]./255);
midPanel   = uipanel(gl,'BackgroundColor',[127 127 127]./255);
rightPanel = uipanel(gl,'BackgroundColor',[127 127 127]./255);

% Position panels manually if grid layout not available
if ~strcmp(get(gl,'Type'),'uigridlayout')
    set(leftPanel,'Units','normalized','Position',[0.000 0 0.333 1]);
    set(midPanel,'Units','normalized','Position',[0.333 0 0.334 1]);
    set(rightPanel,'Units','normalized','Position',[0.667 0 0.333 1]);
end

% -------------------------------------------------------------------------
% SECTION 6: SCHEMATIC DISPLAY SETUP
% -------------------------------------------------------------------------
% Displays the plant schematic image and sets up mouse click handlers
% for interactive monitoring of process variables

% Create axes for displaying the plant schematic diagram
b_image = axes('Parent',f,'HandleVisibility','callback','NextPlot','replacechildren', ...
    'Units','points', 'Position',[4,-30,1540,605]);

% Load and display the plant schematic image
imshow('media\images\Presentation44.png','Parent',b_image);

% Set up mouse event handlers for schematic display
set(f,'WindowButtonDownFcn',@mytestcallback);  % Mouse click on schematic
set(f2,'WindowButtonDownFcn',@mytestcallback2); % Mouse click on alarm summary

% -------------------------------------------------------------------------
% SECTION 7: DATA LOGGING FILES INITIALIZATION
% -------------------------------------------------------------------------
% Opens file handles for logging user interactions and system events

fid_click = fopen('data\text-logs\Mouse_click.txt','wt+');
fid_click = file_clk;
fid_mouse_move = fopen('data\text-logs\task_no.txt','wt+');
fid_alarm_timing = fopen('data\text-logs\alarm_timing.txt','wt+');

% -------------------------------------------------------------------------
% SECTION 8: PROCESS VARIABLE DISPLAY CONTROLS (TEXT BOXES)
% -------------------------------------------------------------------------
% Creates text boxes that display real-time values of process variables
% positioned on the schematic display. Variables include temperatures, 
% flow rates, concentrations, and tank levels.

% Note: Position coordinates are calculated pixel offsets from the schematic origin
[ans_pv_1 ff] = name_uicontrol(f); set(ans_pv_1, 'Position',[225+120-50-15+16-12,481-109+105+10+2+10, ff(3)+64+20, ff(4)-2+2]); % F101: Feed flow rate
[ans_pv_2 ff] = name_uicontrol(f); set(ans_pv_2, 'Position',[15+179+113-172-40,371-119+82-53-10+5+10, ff(3)+48+20+20 ,ff(4)]); % F102: Cooling water flow rate
[ans_pv_3 ff] = name_uicontrol(f); set(ans_pv_3, 'Position',[100+215-83,371-115+80-128-25+12+12+25-5, ff(3)+38+10 ,ff(4)-2+3]); % T101: Inlet water temperature
[ans_pv_4 ff] = name_uicontrol(f); set(ans_pv_4, 'Position',[420+120-15+37+70-12-8-8,297-103+233-59-18+10+10+20-3, ff(3)+32+20 ,ff(4)-2+5]); % T102: Jacket temperature
[ans_pv_5 ff] = name_uicontrol(f); set(ans_pv_5, 'Position',[610+123-23+130-4-6,280-33+30+18-74+12+7+10+20, ff(3)+44+20+14 ,ff(4)-2+2]); % F105: Distillation feed flow
[ans_pv_6 ff] = name_uicontrol(f); set(ans_pv_6, 'Position',[620+153+208-22-28-20-25-4,380+10-34+115+4-12+2+10+20-4, ff(3)+32+20 ,ff(4)-2+3]); % T106: Distillation tray 3 temperature
[ans_pv_7 ff] = name_uicontrol(f); set(ans_pv_7, 'Position',[800+163+250+19-8-13-25-25-13,270-53+125-27-16+10+15+13-3, ff(3)+32+20 ,ff(4)-2+2]); % T105: Distillation tray 5 temperature
[ans_pv_8 ff] = name_uicontrol(f); set(ans_pv_8, 'Position',[625+120+83+224+19-50-10-3-20-25-12-4,180-90+58-87-12+2-10+10+4, ff(3)+32+20 ,ff(4)-2+5]); % T104: Distillation tray 8 temperature
[ans_pv_9,ff] = name_uicontrol(f);set(ans_pv_9,'Position',[300+164-12-5-7,450-110+102+25-5+10+30-8,ff(3)+32+20,ff(4)-2+2],'visible','on'); % T103: CSTR temperature
[ans_pv_10,ff] = name_uicontrol(f);set(ans_pv_10,'Position',[255+202+160-58-5-2-35,200-128-10-30+10+20+4,ff(3)+75+20-13,ff(4)-2+5],'visible','on'); % C101: Ethanol concentration
[ans_pv_11,ff] = name_uicontrol(f); set(ans_pv_11,'Position',[425+220+25-11,425-120+93+30+18-19+45-14+10+10+25-5,ff(3)+36+20,ff(4)-2], 'visible','on'); % L101: CSTR tank level

% -------------------------------------------------------------------------
% SECTION 9: SLIDER VALUE LABEL DISPLAYS
% -------------------------------------------------------------------------
% Creates text labels displaying the current values of control sliders

[ans_11 ff] = name_uicontrol(f); set(ans_11, 'Position',[100+200-36+115-97-86-10-12,471-163+167-4+10+15, ff(3)+2+20 ,ff(4)-2.7+5],'visible','on','FontSize',16,'foregroundcolor',[0 0 0]); % Feed flow slider label
[ans_12 ff] = name_uicontrol(f); set(ans_12, 'Position',[23+120+90-165-17-26,268-33-35+38-30-6+10+25, ff(3)+2+20 ,ff(4)-2+5],'visible','on','FontSize',16,'foregroundcolor',[0 0 0]); % Coolant slider label
[ans_13 ff] = name_uicontrol(f); set(ans_13, 'Position',[930+100-5+265+20+38-6-12+10+13-10,500-138+100-50-8-4+20-5, ff(3)+2+20 ,ff(4)-2+5],'visible','on','FontSize',16,'foregroundcolor',[0 0 0]); % Reflux slider label
[ans_14,ff] = name_uicontrol(f); set(ans_14, 'Position',[545+103-18+182-80-13-10-12-35-20-8,520-33-35-110-65-108+52-4+10+20, ff(3)+2+20,ff(4)-2+5],'visible','on','FontSize',16,'foregroundcolor',[0 0 0]); % Distillation column flow slider label

% -------------------------------------------------------------------------
% SECTION 10: CONTROL MODE INDICATORS
% -------------------------------------------------------------------------
% Text displays showing control mode (Manual/Automatic) for each control system

[ans_15,ff] = name_uicontrol(f); set(ans_15,'Position',[50+120,485,ff(3)+4 ,ff(4)-2],'visible','off'); % Feed control mode
set(ans_15,'String','M','foregroundcolor',[.8 0 .5],'fontsize',14);

[ans_18,ff] = name_uicontrol(f); set(ans_18,'Position',[45+120,205,ff(3)+4 ,ff(4)-2],'visible','off'); % Cooling water control mode
set(ans_18,'String','M','foregroundcolor',[.8 0 .5],'fontsize',14);

[ans_21,ff] = name_uicontrol(f); set(ans_21,'Position',[540+120,315,ff(3)+3 ,ff(4)-2],'visible','off'); % Distillation inlet control mode
set(ans_21,'String','M','foregroundcolor',[.8 0 .5],'fontsize',14);

[ans_24,ff] = name_uicontrol(f); set(ans_24,'Position',[874+120,486,ff(3)+4 ,ff(4)-2],'visible','off'); % Reflux valve control mode
set(ans_24,'String','M','foregroundcolor',[.8 0 .5],'fontsize',14);

[ans_28,ff] = name_uicontrol(f); set(ans_28, 'Position',[800+120+15,365,ff(3)+44, ff(4)- 2],'visible','off'); % Reflux ratio display

% Scenario completion message (shown when task is finished)
ans_29 = uicontrol(f,'Style','text','Position',[500+250 140 320 70],'visible','off','String','Scenario Completed!!!','foregroundcolor',[33 61 33]./255,'fontsize',15);

% -------------------------------------------------------------------------
% SECTION 11: HISTORICAL TREND PLOT BUTTONS
% -------------------------------------------------------------------------
% Creates clickable buttons on the schematic for selecting which variable
% to plot in the trend chart. These appear on the plant diagram locations.

v1bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','F101','fontweight','bold','fontsize',10,'Units','points','Position',[305,445,45,45],'Callback',@v1Fcn,'visible','off'); % F101 trend button
v2bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','F102','fontweight','bold','fontsize',10,'Units','points','Position',[130,225,45,45],'Callback',@v2Fcn,'visible','off'); % F102 trend button
v3bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T101','fontweight','bold','fontsize',10,'Units','points','Position',[248,170,45,45],'Callback',@v3Fcn,'visible','off'); % T101 trend button
v4bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T102','fontweight','bold','fontsize',10,'Units','points','Position',[615,335,45,45],'Callback',@v4Fcn,'visible','off'); % T102 trend button
v5bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','F105','fontweight','bold','fontsize',10,'Units','points','Position',[868,208,45,45],'Callback',@v5Fcn,'visible','off'); % F105 trend button
v6bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T106','fontweight','bold','fontsize',10,'Units','points','Position',[898,435,45,45],'Callback',@v6Fcn,'visible','off'); % T106 trend button
v7bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T105','fontweight','bold','fontsize',10,'Units','points','Position',[1163,272,45,45],'Callback',@v7Fcn,'visible','off'); % T105 trend button
v8bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T104','fontweight','bold','fontsize',10,'Units','points','Position',[962,100,45,45],'Callback',@v8Fcn,'visible','off'); % T104 trend button
v9bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T103','fontweight','bold','fontsize',10,'Units','points','Position',[460,433,45,45],'Callback',@v9Fcn,'visible','off'); % T103 trend button
v10bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','C101','fontweight','bold','fontsize',10,'Units','points','Position',[460,61,45,45],'Callback',@v10Fcn,'visible','off'); % C101 trend button
v11bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','L101','fontweight','bold','fontsize',10,'Units','points','Position',[676,438,45,45],'Callback',@v11Fcn,'visible','off'); % L101 trend button

% -------------------------------------------------------------------------
% SECTION 12: CALIBRATION BUTTONS
% -------------------------------------------------------------------------
% Creates calibration buttons in a 5-step sequence (corners + center)
% These guide the user through eye tracker calibration on first task only

if ~isempty(f1)
    v12bh = uicontrol(f1,'Style','pushbutton','backgroundcolor',[0 1 0],'String','1','fontweight','bold','fontsize',26,'Units','points','Position',[10,735,35,35],'Callback',@v12Fcn,'visible','on');     % Calibration step 1 (top-left)
    v13bh = uicontrol(f1,'Style','pushbutton','backgroundcolor',[0 1 0],'String','2','fontweight','bold','fontsize',26,'Units','points','Position',[1363,735,35,35],'Callback',@v13Fcn,'visible','off');   % Calibration step 2 (top-right) 
    v14bh = uicontrol(f1,'Style','pushbutton','backgroundcolor',[0 1 0],'String','3','fontweight','bold','fontsize',26,'Units','points','Position',[1363,10,35,35],'Callback',@v14Fcn,'visible','off');   % Calibration step 3 (bottom-right)
    v15bh = uicontrol(f1,'Style','pushbutton','backgroundcolor',[0 1 0],'String','4','fontweight','bold','fontsize',26,'Units','points','Position',[10,10,35,35],'Callback',@v15Fcn,'visible','off');     % Calibration step 4 (bottom-left)
    v16bh = uicontrol(f1,'Style','pushbutton','backgroundcolor',[0 1 0],'String','5','fontweight','bold','fontsize',26,'Units','points','Position',[670,375,35,35],'Callback',@v16Fcn,'visible','off');  % Calibration step 5 (center)
end

% -------------------------------------------------------------------------
% SECTION 13: ALARM SUMMARY TABLE (LEFT PANEL)
% -------------------------------------------------------------------------
% Creates a table on the left panel displaying real-time alarm messages
% with Date & Time, Source, Condition, and Description columns

cvv = [127 127 127]./255; 
alarm_text = cell(14,4);

% Table title - Centered
uicontrol(leftPanel,'Style','text','String','Alarm Summary',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',12,'Position',[0 0.92 1 0.06],...
    'fontweight','bold','HorizontalAlignment','center');

% Column headers
uicontrol(leftPanel,'Style','text','String','Date & Time',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.03 0.84 0.25 0.05],...
    'fontweight','bold');

uicontrol(leftPanel,'Style','text','String','Source',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.28 0.84 0.20 0.05],...
    'fontweight','bold');

uicontrol(leftPanel,'Style','text','String','Condition',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.48 0.84 0.15 0.05],...
    'fontweight','bold');

uicontrol(leftPanel,'Style','text','String','Description',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.63 0.84 0.32 0.05],...
    'fontweight','bold');

% Create 14 rows of alarm data cells using normalized positions
colX = [0.03, 0.28, 0.48, 0.63];
colW = [0.25, 0.20, 0.15, 0.32];
rowTop = 0.77; rowStep = 0.07; rowH = 0.05;

for ii = 1:4
    for j = 1:14
        y = rowTop - (j-1)*rowStep;
        alarm_text{j,ii} = uicontrol(leftPanel,'Style','text','String','',...
            'backgroundcolor',cvv,'foregroundcolor',[0 0 0],'Units','normalized',...
            'fontsize',10,'Position',[colX(ii) y colW(ii) rowH],'fontweight','normal');
    end
end

% -------------------------------------------------------------------------
% SECTION 14: TREND PLOTTING PANELS (MIDDLE PANEL)
% -------------------------------------------------------------------------
% Creates panel for displaying historical process variable trends

% Middle panel contains the trend plot for selected process variable
trendPanel = uipanel('Parent',midPanel,'HandleVisibility','callback','Units','normalized','Position',[0 0 1 1],'BackgroundColor',[127 127 127]./255);

% Panel title - Centered
uicontrol(trendPanel,'Style','text','String','Process Variable Trend', ...
    'Units','normalized','Position',[0 0.92 1 0.08], ...
    'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0], ...
    'FontWeight','bold','FontSize',12,'HorizontalAlignment','center');

% Current variable and value display text
uicontrol(trendPanel,'Style','text','String',' -- ', ...
    'Units','normalized','Position',[0.03 0.83 0.94 0.06], ...
    'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0], ...
    'HorizontalAlignment','center','FontSize',10,'FontWeight','bold','Tag','var_display');

% Close button for trend panel (invisible but provides callback functionality)
closeTrendbh = uicontrol('Parent',trendPanel,'Style','pushbutton','backgroundcolor',[0.7 0.7 0.7],...
    'Units','normalized','Position',[0 0 0.001 0.001],'HandleVisibility','callback','String','',...
    'FontSize',1,'Callback',@closeTrendFcn);

% Axes for plotting historical trends with improved formatting
varTrend = axes('Parent',trendPanel,'HandleVisibility','callback','NextPlot','replacechildren',...
    'Units','normalized','Position',[0.15 0.15 0.83 0.68],'FontSize',8,'Color',[0.95 0.95 0.95],...
    'Box','on','XGrid','on','YGrid','on');
set(trendPanel,'Visible','off');

% -------------------------------------------------------------------------
% SECTION 15: EXPLANATION AND HELP TEXT (RIGHT PANEL)
% -------------------------------------------------------------------------
% Right panel contains AI fault prediction display

trendPanelRight = uipanel('Parent',rightPanel,'HandleVisibility','callback','Units','normalized','Position',[0 0 1 1],'BackgroundColor',[127 127 127]./255);

% Explanation title - Centered
uicontrol(trendPanelRight,'Style','text','String','Explanation', ...
    'Units','normalized','Position',[0 0.92 1 0.08], ...
    'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0], ...
    'FontWeight','bold','FontSize',12,'HorizontalAlignment','center');

% Current fault prediction text
fault_prediction_text = uicontrol(trendPanelRight,'Style','text', ...
    'String', 'Fault: Normal Operation', ...
    'Units','normalized','Position',[0.03 0.15 0.94 0.77], ...
    'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0], ...
    'HorizontalAlignment','left','FontSize',10,'FontWeight','bold');

% -------------------------------------------------------------------------
% SECTION 16: DIAGNOSIS SELECTION OPTIONS
% -------------------------------------------------------------------------
% List of possible fault diagnoses for user selection

name_list = {'Select Diagnosis';'Leak in Reactor Inlet';'Catalyst Poisoning';'Leak in cooling water Inlet';'Leak in Distillation Column Inlet';'Leak in reflux valve';'Reboiler power failure';'None of the above'};

% -------------------------------------------------------------------------
% SECTION 17: MANUAL CONTROL SLIDERS
% -------------------------------------------------------------------------
% Creates sliders for manual adjustment of process control variables
% Each slider controls a specific valve position (0 = closed, 1 = open)

% Feed flow rate control slider
slider_feed = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.5,...
    'Position',[160+75+215+70-170-78,650-33-30-15-20+20+2,18,75],...
    'SliderStep',[0.009 0.08],'visible','on','callback',@slider_feed_control);

% Coolant (cooling water) flow rate control slider
slider_coolant = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.5,...
    'Position',[55+120+82+74-218-22-12-8,342+29-172+25-2,18,75],...
    'SliderStep',[0.009 0.08],'visible','on','callback',@slider_coolant_control);

% Reflux flow rate control slider (distillation column)
slider_reflux = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.5,...
    'Position',[1265+120+20+284+60+30-8,670-33-173+40-9+15,18,75],...
    'SliderStep',[0.009 0.08],'visible','on','callback',@slider_reflux_control);

% Distillation column inlet flow control slider
slider_flow_dist = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.5,...
    'Position',[750+85+200+65-131-35-30-20,520-33-45-280+40+17-3+12+15,18,75],...
    'SliderStep',[0.009 0.08],'visible','on','callback',@slider_flow_dist_control);

% Temperature control slider (not currently used but kept for future expansion)
slider_for_temp = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.2,...
    'Position',[235+120,450-33-10,10,75],'SliderStep',[.009 .08],...
    'visible','off','callback',@slider_temp_control,'Enable','inactive');

% Initially disable all sliders until experiment starts
set(slider_reflux,'Enable','off');
set(slider_feed,'Enable','off');
set(slider_coolant,'Enable','off');
set(slider_flow_dist,'Enable','off');

% -------------------------------------------------------------------------
% SECTION 18: EMERGENCY SHUTDOWN AND CONTROL BUTTONS
% -------------------------------------------------------------------------
% Creates buttons for emergency shutdown and simulation control

% Emergency Shutdown button (red, always visible during operation)
esd_box = uicontrol(f,'Style','pushbutton','String','Emergency Shutdown',...
    'backgroundcolor',[1 0 0],'foregroundcolor',[0 0 0],'fontweight','bold',...
    'fontsize',12,'Units','points','Position',[5 485 140 25],...
    'Callback',@esd_call,'Visible','off');

% Start simulation button (green, initiates plant operation)
Start_Simu = uicontrol(f,'Style','pushbutton','String','Start',...
    'backgroundcolor',[0 1 0],'fontweight','bold','fontsize',12,...
    'Units','points','Position',[500+200-27+75 50-14+10+235+60 140 25],...
    'foregroundcolor',[0 0 0],'Callback',@myStartFcn1);

% Submit and close button (gray, shown at end of task)
closeButton = uicontrol(f,'Style','pushbutton','String','Submit & Close',...
    'backgroundcolor',[0.7 0.7 0.7],'fontweight','bold','fontsize',10,...
    'Units','points','Position',[1150+120 130-13+150 100 20],...
    'Callback',@myCloseFcn,'Visible','off');

% Instruction text for Start button
[text_for_start,ff] = name_uicontrol(f);
set(text_for_start,'String','Press Start button to run plant',...
    'foregroundcolor',[0 0 0],'Units','points',...
    'position',[450+200-27+75 7+10+235+60 250 30],'visible','on',...
    'fontweight','bold');

% -------------------------------------------------------------------------
% SECTION 20: TIMING DISPLAY
% -------------------------------------------------------------------------
% Displays current time during experiment execution

time_name = name_uicontrol(f);
set(time_name,'Position',[1325,58,ff(3)+6,ff(4)-2],'visible','on',...
    'String','Time','fontweight','bold','backgroundcolor',[127 127 127]./255,...
    'foregroundcolor',[0 0 0]);

curr_time = name_uicontrol_summary(f);
set(curr_time,'Position',[1250,40,ff(3)+150,ff(4)],'visible','on',...
    'String',datestr(now),'backgroundcolor',[127 127 127]./255,...
    'foregroundcolor',[0 0 0]);

% -------------------------------------------------------------------------
% SECTION 18: ALARM SUMMARY TABLE
% -------------------------------------------------------------------------
% Creates a table on the left panel displaying real-time alarm messages
% with Date & Time, Source, Condition, and Description columns

cvv = [127 127 127]./255; 
alarm_text = cell(14,4);

% Table title
uicontrol(leftPanel,'Style','text','String','Alarm Summary',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.03 0.92 0.94 0.05],...
    'fontweight','bold');

% Column headers
uicontrol(leftPanel,'Style','text','String','Date & Time',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.03 0.84 0.25 0.05],...
    'fontweight','bold');

uicontrol(leftPanel,'Style','text','String','Source',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.28 0.84 0.20 0.05],...
    'fontweight','bold');

uicontrol(leftPanel,'Style','text','String','Condition',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.48 0.84 0.15 0.05],...
    'fontweight','bold');

uicontrol(leftPanel,'Style','text','String','Description',...
    'backgroundcolor',cvv,'foregroundcolor',[0 0 0],...
    'Units','normalized','fontsize',10,'Position',[0.63 0.84 0.32 0.05],...
    'fontweight','bold');
% Create 14 rows of cells using normalized positions
colX = [0.03, 0.28, 0.48, 0.63];
colW = [0.25, 0.20, 0.15, 0.32];
rowTop = 0.77; rowStep = 0.07; rowH = 0.05;
for ii = 1:4
    for j = 1:14
        y = rowTop - (j-1)*rowStep;
        alarm_text{j,ii} = uicontrol(leftPanel,'Style','text','String','',...
            'backgroundcolor',cvv,'foregroundcolor',[0 0 0],'Units','normalized',...
            'fontsize',10,'Position',[colX(ii) y colW(ii) rowH],'fontweight','normal');
    end
end


%% Defining valve values

V102 = valve;
V301 = valve;
V401 = valve;
V201 = valve;

% Defining Initial values for V102 valve
V102.setpoint = .7;
V102.flowin = 1.4;
V102.flowout = .7;
V102.flowfinal = .7*10;
V102.valvepos = .5;

% Defining initial values for V301 valve
V301.setpoint = 6.5e3/50;
V301.flowin = 2*(6.5e3/50);
V301.flowout = 6.5e3/50;
V301.flowfinal = 6.5e3/50;
V301.valvepos = .5;


% Controlling of Reflux Ratio

V401.setpoint = .9;
V401.flowin = 1.9;
V401.flowout = 1;
V401.flowfinal = 1;
V401.valvepos =  0.526315789473684;

% Controlling of flow from CSTR to distillation column

V201. setpoint = .6481;
V201.flowin = .6481;
V201.flowout = .6481;
V201.flowfinal = .6481;
V201.valvepos = 1.0;





%% ========================================================================
% SECTION 20: CALLBACK FUNCTIONS AND EVENT HANDLERS
% ========================================================================
% This section contains all the callback functions triggered by user 
% interactions (button clicks, slider movements, mouse movements).
% Each function updates the plant state or logs user actions.
% ========================================================================

    % =====================================================================
    % CALLBACK: myStartFcn1 - Starts the experiment simulation
    % =====================================================================
    % Triggered when user clicks "Start" button
    % Initializes simulation, enables controls, and launches main control loop
    function myStartFcn1(varargin)
        
        es_flag = 0;
        task_complete_flag = 0;  
        time_start = datestr(clock); % clock is a function and so as datestr
       
        time_start_mili = datestr(now,'dd-mm-yyyy HH:MM:SS FFF');
        if task_no==1
            time_track_count = 1;
            time_track_for_experiment(time_track_count) = 0;
        else
             time_track_count = time_track_count + 1;
            time_track_for_experiment(time_track_count) = toc(t_start_exp);
        end
        %         tic
        set (f, 'WindowButtonMotionFcn', @mouseMove);
        set(f2,'WindowButtonMotionFcn',@mouseMove2);
        set(text_for_start,'visible','off');
        if task_no==1
            tic
            
%             t_start_exp = tic;
%             tetio_startTracking;
            time_start_first = time_start;
            time_mode= time_start;
            time_mode ([12 15 18]) = '_';
            
         
            
%             eval(sprintf(' TrackStart(1,''eye_track_data_%s'');',time_mode));
            
        end
        intro_file = fopen('data\text-logs\Introduction.txt','at+');
        fprintf(intro_file,'Start Time = %s \n',time_start_mili);
        set(slider_reflux,'Enable','on');
        set(slider_feed,'Enable','on');
        set(slider_coolant,'Enable','on');
        set(slider_flow_dist,'Enable','on');   
        set(Start_Simu,'Visible','off');
        %====================================
        % Hiding the close and submit option
        set(closeButton,'visible','off');
        %====================================
        set(esd_box,'visible','on');
        
        %% Hiding the pop up menu
        
        set(identification_opt,'visible','on');
        po = get(Start_Simu,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        te = toc(t_start_exp);
        fid_click = fopen('data\text-logs\Mouse_click.txt','at+');
        fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',...
            floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'Start',0000);
        main_file_kaushik_parameters(task_no_lo,fault_no_list_lo,fault_no_lo)
      
    end

    % =====================================================================
    % CALLBACK: myCloseFcn - Finalizes task and records diagnosis
    % =====================================================================
    % Triggered when user clicks "Submit & Close" button
    % Saves selected fault diagnosis and closes simulation windows
    function myCloseFcn(varargin)
        v = get(identification_opt,'Value');
        pr = name_list{v};
        fid = fopen('Diagnosis1.txt','at+');
        fprintf(fid,'%s \n',pr);
        fprintf(fid,'STOP TIME = %s \n',datestr(clock));
        
        po = get(closeButton,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,'%.2f    %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'Close_and_Submit');
        if v == 1
            fprintf(fid,'No Diagnosis is Submitted');
        else  if fault_no_lo == v-1
                fprintf(fid,'Diagnosis submitted is correct');
            else
                fprintf(fid,'Diagnosis submitted is false');
            end
        end
        close(f)
        close (f2)
        fclose(fid);
        
        fclose(fid_alarm_timing);
        fclose(fid_click);
        
        clc;
%         feedback_form_gui
    end

    % =====================================================================
    % CALLBACK: esd_call - Emergency shutdown
    % =====================================================================
    % Triggered when user clicks "Emergency Shutdown" button
    % Immediately stops simulation and saves all logged data to Excel files
    function esd_call(varargin)
        es_flag = 1;
        task_complete_flag = 1;
        time_track_count = time_track_count+1;
        time_track_for_experiment(time_track_count) = toc(t_start_exp);
        intro_file = fopen('data\text-logs\Introduction.txt','at+');
        fprintf(intro_file,'Stop Time = %s \n',datestr(clock,'dd-mm-yyyy HH:MM:SS FFF'));
        fclose(intro_file);
        clc;
         
        po = get(esd_box,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        te = toc(t_start_exp);
        
        fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'Emergency_Shutdown',0000);
        
%------------------writing ti mouse click---------------------------------
        global id_num;
        [a_c b_c c_c d_c e_c f_c g_c] = textread('data\text-logs\Mouse_click.txt','%s %s %s %s %s %s %s','whitespace',' ','bufsize',10000);
        ty = time_start_first;
        ty([12 15 18]) = '_';
        if ~isempty(a_c) && ~isempty(b_c) && ~isempty(c_c) && ~isempty(d_c) && ~isempty(e_c) && ~isempty(f_c) && ~isempty(g_c)
            eval(sprintf('xlswrite(''data\\excel-outputs\\Mouse_click_%s_%s.xlsx'',[a_c b_c c_c d_c e_c f_c g_c],%d);',id_num,ty,task_no));
        end
%  -------------------------------alarm data-----------------------------        
        [a_a b_a c_a ] = textread('data\text-logs\alarm_timing.txt','%s %s %s','whitespace',' ','bufsize',10000);
        ty = time_start_first;
        ty([12 15 18]) = '_';
        if ~isempty(a_a) && ~isempty(b_a) && ~isempty(c_a) 
            eval(sprintf('xlswrite(''data\\excel-outputs\\Alarm_timing_%s_%s.xlsx'',[a_a b_a c_a],%d);',id_num,ty,task_no));
            
        end

 %%--------------writing to process data-----------------------
        process_var_store = [time_for_process_var(1:index_for_scenario,:) alarm_var_store(1:number_var_alarms,1:index_for_scenario)' slider_var_store(1:4,1:index_for_scenario)'];
        ty = time_start_first;
        ty([12 15 18]) = '_';
        eval(sprintf('xlswrite(''data\\excel-outputs\\Process_data_%s_%s.xlsx'',process_var_store,%d);',id_num,ty,task_no));
        
        [a_c b_c c_c d_c e_c f_c] = textread('data\text-logs\task_no.txt','%s %s %s %s %s %s','whitespace',' ','bufsize',10000);
        ty = time_start_first;
        ty([12 15 18]) = '_';
        if ~isempty(a_c) && ~isempty(b_c) && ~isempty(c_c) && ~isempty(d_c) && ~isempty(e_c) && ~isempty(f_c)
            eval(sprintf('xlswrite(''data\\excel-outputs\\Mouse_move_%s_%s.xlsx'',[a_c b_c c_c d_c e_c f_c],%d);',id_num,ty,task_no));
        end

        pause(0.25);
        clc
        time_track_count = time_track_count+1;  % for start of feeedback form 
        time_track_for_experiment(time_track_count) = toc(t_start_exp);

    end

    % =====================================================================
    % CALLBACK GROUP: Slider Control Functions
    % =====================================================================
    % These callbacks are triggered when users adjust control sliders
    % Each updates the corresponding valve position and logs the action

    % Slider: Feed flow rate control (V102 valve)
    function slider_feed_control(varargin)
        
        po = get(slider_feed,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f    %.2f   %d   %s     %s \n',po_mid(1),po_mid(2),1,datestr(now),'Slider_feed_control');
te = toc(t_start_exp);
        
      
        V102.valvepos = get(slider_feed,'Value');
           fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'Slider_feed_control',V102.valvepos);
    end


    % Slider: Coolant (cooling water) flow rate control (V301 valve)
    function slider_coolant_control(varargin)
        
        po = get(slider_coolant,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        te = toc(t_start_exp);
        
        
       V301.valvepos  = get(slider_coolant,'Value');
         fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'Slider_coolant_control',V301.valvepos );
    end

    % Slider: Reflux flow rate control (V401 valve - distillation column)
    function slider_reflux_control(varargin)
%         flag_reflux_control = 1;
        po = get(slider_reflux,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
      te = toc(t_start_exp);
        flag_for_reflux = 1;
       
        V401.valvepos = get(slider_reflux,'Value');
         fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'Slider_reflux_control',V401.valvepos);
    end

    % Slider: Distillation column inlet flow control (V201 valve)
    function slider_flow_dist_control(varargin)
        
        po = get(slider_flow_dist,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
       te = toc(t_start_exp);
        flag_flow_distill = 1;
        
        V201.valvepos =  get(slider_flow_dist,'Value');
      fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'Slider_flow_disitillation_feed_control', V201.valvepos);
    end


    % Slider: Temperature control (reserved for future use)
    function slider_temp_control(varargin)
%         flag_temp_control = 1;
        po = get( slider_for_temp,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
         temp_slider_val = get( slider_for_temp,'Value');
        fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'Slider_for_temp_control',temp_slider_val);
       
        set(slider_for_temp,'Enable','on');
    end

    % =====================================================================
    % CALLBACK GROUP: Auto/Manual Mode Toggle Functions
    % =====================================================================
    % These callbacks toggle between automatic and manual control modes
    % for each control system. When manual (M), sliders are enabled.
    % When automatic (A), sliders are disabled and controller manages valve.

    % Auto/Manual toggle: Feed flow control
    function slider_amn_feed_control(varargin)
        
        a = get(slider_amn_feed,'Value');
        po = get(slider_amn_feed,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        te = toc(t_start_exp);
        
         fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'auto_manual_feed_flow_control',0000);
%         fprintf(fid_click,'%.2f  %.2f    %d   %s      %s\n',po_mid(1),po_mid(2),1,datestr(now),'auto_manual_feed_flow_control');
        if a==0
            set(slider_feed,'Enable','off');
            control_stat_feed = 0; % Automatic control
            set(slider_amn_feed,'String','A','backgroundcolor',[1 0 1]);
            
        else
            set(slider_feed,'Value',V102.valvepos);
            set(slider_feed,'Enable','on');
            set(slider_amn_feed,'String','M');
            set(slider_amn_feed,'backgroundcolor',[1 1 0]);
            control_stat_feed = 2; 
        end
       
        
    end



    % Auto/Manual toggle: Cooling water flow control
    function slider_amn_cooling_control(varargin)
        
        a = get(slider_amn_cooling,'Value');
        
        po = get(slider_amn_cooling,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        te = toc(t_start_exp);
      fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'auto_manual_cooling_water_flow_control',0000);
%         fprintf(fid_click,' %.2f   %.2f    %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'auto_manual_cooling_water_flow_control');
        if a==0
            set(slider_coolant,'Enable','off');
            set(slider_amn_cooling,'String','A');
            set(slider_amn_cooling,'backgroundcolor',[1 0 1]);
            control_stat_cooling = 0; % Automatic control
        else
            set(slider_coolant,'Value',V301.valvepos);
            set(slider_coolant,'Enable','on');
            set(slider_amn_cooling,'String','M');
            set(slider_amn_cooling,'backgroundcolor',[1 1 0]);
            control_stat_cooling = 2; % Manual
        end
        
    end


    % Auto/Manual toggle: Distillation column inlet flow control
    function slider_amn_dist_control(varargin)
        
        a = get(slider_amn_dist,'Value');
        
        
        po = get(slider_amn_dist,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'auto_manual_distillation_flow_control');
        te = toc(t_start_exp);
        
       fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f \n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'auto_manual_distillation_flow_control',0000);
        if a==0
            set(slider_flow_dist,'Enable','off');
            set(slider_amn_dist,'String','A');
            set(slider_amn_dist,'backgroundcolor',[1 0 1]);
            control_stat_dist = 0; % Automatic control
        else
            set(slider_flow_dist,'Value',V201.valvepos);
            set(slider_flow_dist,'Enable','on');
            set(slider_amn_dist,'String','M');
            set(slider_amn_dist,'backgroundcolor',[1 1 0]);
            
            control_stat_dist = 2; % Manual
        end
        
    end

    % Auto/Manual toggle: Reflux valve control
    function slider_amn_reflux_control(varargin)
        
        a = get(slider_amn_reflux,'Value');
        
        po = get(slider_amn_reflux,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,' %.2f   %.2f   %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'auto_manual_reflux_control');
te = toc(t_start_exp);
        
       fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'auto_manual_reflux_control',0000);
        if a==0
            set(slider_reflux,'Enable','off');
            set(slider_amn_reflux,'String','A');
            set(slider_amn_reflux,'backgroundcolor',[1 0 1]);
            control_stat_reflux = 0; % Automatic control
        else
            set(slider_reflux,'Value',V401.valvepos);
            set(slider_reflux,'Enable','on');
            set(slider_amn_reflux,'String','M');
            set(slider_amn_reflux,'backgroundcolor',[1 1 0]);
            control_stat_reflux = 2; % Manual
        end
    end

    % =====================================================================
    % CALLBACK GROUP: Historical Trend Plot Functions
    % =====================================================================
    % These callbacks display historical trends for the selected process variable
    % User clicks on a variable label (v1bh-v11bh) to see its trend over time

    % Show trend plot for F101 (Feed flow rate)
    function v1Fcn(varargin)
        refreshdata(trendPanel);
        refreshdata(varTrend);
        
        po = get(v1bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'V102');

        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v1bh,'UserData',1);
     
    end

    function v2Fcn(varargin)
        refreshdata(trendPanel);
        refreshdata(varTrend);
        po = get(v2bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f   %.2f    %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'F101');
        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
      
        set(v2bh,'UserData',1);
    end

    function v3Fcn(varargin)
        refreshdata(trendPanel);
        refreshdata(varTrend);
        po = get(v3bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f   %.2f    %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'T101');
        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v3bh,'UserData',1);
    end

    function v4Fcn(varargin)
        refreshdata(trendPanel);
        refreshdata(varTrend);
        po = get(v4bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f   %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'T103');
        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v4bh,'UserData',1);
    end

    function v5Fcn(varargin)
        refreshdata(trendPanel);
        refreshdata(varTrend);
        po = get(v5bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f    %.2f  %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'V201');
        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            % end
        end
        % set v1bh to 1 == activate
        set(v5bh,'UserData',1);
    end

    function v6Fcn(varargin)
        refreshdata(varTrend);
        refreshdata(trendPanel);
        po = get(v6bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f    %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'T106');
        
        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            % if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v6bh,'UserData',1);
    end

    function v7Fcn(varargin)
        refreshdata(trendPanel);
        refreshdata(varTrend);
        
        po = get(v7bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f    %.2f   %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'T105');
        
        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v7bh,'UserData',1);
    end

    function v8Fcn(varargin)
        refreshdata(trendPanel);
        refreshdata(varTrend);
        
        po = get(v8bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f   %.2f   %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'T104');
        % first set all v?bh UserData to 0 == deactivate
        
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v8bh,'UserData',1);
    end


    function v9Fcn(varargin)
        
        po = get(v9bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f   %.2f    %d   %s     %s \n',po_mid(1),po_mid(2),1,datestr(now),'T107');
        
        % first set all v?bh UserData to 0 == deactivate
        
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v9bh,'UserData',1);
    end


    function v10Fcn(varargin)
        
        po = get(v10bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f   %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'C101');
        
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v10bh,'UserData',1);
    end


    function v11Fcn(varargin)
        refreshdata(trendPanel);
        refreshdata(varTrend);
        po = get(v11bh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        fprintf(fid_click,' %.2f  %.2f   %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'L101');
        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v11bh,'UserData',1);
    end

    % =====================================================================
    % CALLBACK GROUP: Calibration Step Functions (v12Fcn through v16Fcn)
    % =====================================================================
    % These callbacks guide user through 5-point calibration sequence
    % for eye tracking during the first task (calibration window only)
    
    % Calibration step 1 (top-left corner)
function v12Fcn(hObject,eventdata,handles)   % Calibration button 1
        calibration_step = 1; % User clicked button 1
        set(v12bh,'visible','off')
        set(v13bh,'visible','on')
    end
    
    % Calibration step 2 (top-right corner)
function v13Fcn(hObject,eventdata,handles)
        calibration_step = 2; % User clicked button 2
        set(v13bh,'visible','off')
        set(v14bh,'visible','on')
end

    % Calibration step 3 (bottom-right corner)
function v14Fcn(hObject,eventdata,handles)
        calibration_step = 3; % User clicked button 3
        set(v14bh,'visible','off')
        set(v15bh,'visible','on')
    end

    % Calibration step 4 (bottom-left corner)
function v15Fcn(hObject,eventdata,handles)
        calibration_step = 4; % User clicked button 4
        set(v15bh,'visible','off')
         set(v16bh,'visible','on')
end
       
    % Calibration step 5 (center point) - Completes calibration sequence
function v16Fcn(hObject,eventdata,handles)
        calibration_step = 5; % User clicked button 5
        % Only mark as completed if user went through the full sequence
        if calibration_step == 5
            calibration_completed = true; % Mark calibration as completed after full sequence
        end
        set(f1,'visible','off')
        set(f,'visible','on')
        set(f2,'visible','on')
    end
    
    % =====================================================================
    % CALLBACK: closeTrendFcn - Closes the trend plot display
    % =====================================================================
    % Triggered when user closes the trend plot panel
    function closeTrendFcn(varargin)
       tag_for_plot = 0;
        set(closeTrendbh,'visible','off');
        set(trendPanel,'Visible','off');
        % set all v?bh UserData to 0 == deactivate
        po = get(closeTrendbh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
        te = toc(t_start_exp);
        
       fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'close_trend_plot',0000);
%         fprintf(fid_click,'%.2f    %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'Close_trend_plot');
        for iii = 1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        
    end


    % =====================================================================
    % CALLBACK GROUP: Mouse Event Handlers
    % =====================================================================
    % These callbacks track and log mouse interactions with the GUI
    
    % Callback for mouse click value selection (diagnosis dropdown)
    function mouse_click_val(varargin)
        
        po = get(identification_opt,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,' %.2f    %.2f   %d   %s    %s \n',po_mid(1),po_mid(2),2,datestr(now),'Arbitrary');
        te = toc(t_start_exp);
        
      fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s \n',floor(te),(te-floor(te)),po_mid(1),po_mid(2),1,'Arbitrary');
        
    end


    % Handles mouse click events on schematic display (process variable buttons)
    function mytestcallback(hObject,~)
        
        pos=get(hObject,'CurrentPoint');
        %         fprintf(fid_click,' %.2f    %.2f   %d   %s    %s \n',(pos(1)),(pos(2)),2,datestr(now),'Arbitrary');
        pos(1);
        pos(2);
        po_trend = get(trendPanel,'Position');
              
        if po_trend(1)<=pos(1) && pos(1)<=po_trend(3) && po_trend(2)<=pos(2) && pos(2)<=po_trend(4)
            %flag_text = 1;
        else
            flag_text = 0;
        end
        
        
        %% Checking for clicks
        
         % for F101
        if pos(1)<= 305+45 && pos(1)>=305 && pos(2)<=445+45 && pos(2)>=445
            %             v1Fcn;
%             fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',264,451,1,datestr(now),'F101');
            te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),264,451,1,'F101',0000);

            tag_for_plot = 1;
            %flag_text = 1;
        else
            
            % for F102
            if pos(1)<= 130+45 && pos(1)>=130 && pos(2)<=225+45 && pos(2)>=225
                %                 v2Fcn;
               te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),163,315,1,'F102',0000);

                tag_for_plot = 2 ;
                %flag_text = 1;
            else
                
                % for T101
                if pos(1)<= 248+45 && pos(1)>=248 && pos(2)<=170+45 && pos(2)>=170
                 te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),231,315,1,'T101',0000);

                    tag_for_plot = 3 ;
                    %                     v3Fcn;
                    %flag_text = 1;
                else
                    
                    % for T102
                    if pos(1)<= 615+45 && pos(1)>=615 && pos(2)<=335+45 && pos(2)>=335
                        te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),508,277,1,'T102',0000);

                        tag_for_plot = 4 ;
                        %                         v4Fcn;
                        %flag_text = 1;
                    else
                        % for F105
                        if pos(1)<= 868+45 && pos(1)>=868 && pos(2)<=208+45 && pos(2)>=208
                          te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),723,249,1,'F105',0000);

                            tag_for_plot = 5 ;
                            %                             v5Fcn;
                            %flag_text = 1;
                        else
                            
                            % for T106
                            if pos(1)<= 898+45 && pos(1)>=898 && pos(2)<=435+45 && pos(2)>=435
                              te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),762,328,1,'T106',0000);

                                tag_for_plot = 6 ;
                                %                                 v6Fcn;
                                %flag_text = 1;
                            else
                                % for T105
                                if pos(1)<= 1163+45 && pos(1)>=1163 && pos(2)<=272+45 && pos(2)>=272
                                 te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f \n',floor(te),(te-floor(te)),944,276,1,'T105',0000);

                                    tag_for_plot = 7 ;
                                    %                                     v7Fcn;
                                    %flag_text = 1;
                                else
                                    % for T104
                                    if pos(1)<= 962+45 && pos(1)>=962 && pos(2)<=100+45 && pos(2)>=100
                                        
                                       te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),770,178,1,'T104',0000);

                                        tag_for_plot = 8 ;
                                        %                                         v8Fcn;
                                        %flag_text = 1;
                                    else
                                        % for T103
                                        if pos(1)<= 460+45 && pos(1)>=460 && pos(2)<=433+45 && pos(2)>=433
                                           te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),420,396,1,'T103',0000);

                                            tag_for_plot = 9 ;
                                            %                                             v9Fcn;
                                            %flag_text = 1;
                                        else
                                            % for C101
                                            if pos(1)<= 460+45 && pos(1)>=460 && pos(2)<=61+45 && pos(2)>=61
                                            te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),379,202,1,'C101',0000);

                                                tag_for_plot = 10 ;
                                                %                                                 v10Fcn;
                                                %flag_text = 1;
                                            else
                                                % for L101
                                                if pos(1)<= 676+45 && pos(1)>=676 && pos(2)<=438+45 && pos(2)>=438
                                                 te = toc(t_start_exp);
     fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f \n',floor(te),(te-floor(te)),517,373,1,'L101',0000);

                                                    tag_for_plot = 11 ;
                                                    %                                                     v11Fcn;
                                                    %flag_text = 1;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        
        
        
    end


    % Handles mouse click events on alarm summary display
    function mytestcallback2(hObject,~)
        
        pos=get(hObject,'CurrentPoint');
         te = toc(t_start_exp);
                fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f \n',floor(te),(te-floor(te)),pos(1),pos(2),2,'Alarm_summary',0000);

        pos(1);
        pos(2);
        
        flag_text = 0;
        
    end



    % =====================================================================
    % CALLBACK GROUP: Mouse Movement Tracking Functions
    % =====================================================================
    % These callbacks log mouse position during experiment for gaze tracking
    
    % Tracks mouse movement on schematic display window
    function mouseMove (object, eventdata)
        
        C = get (object, 'CurrentPoint');
%         time_stamp_mouse = datestr(now,'dd-mm-yyyy HH:MM:SS FFF');
%         a1_t = str2num(time_stamp_mouse(18:19));
%         b1_t = str2num(time_stamp_mouse(21:23));

%     te = toc(t_start_exp);
%     a1_t = floor(te);
%     b1_t = te-floor(te);
         te = toc(t_start_exp);
%       fid_mouse_move =  eval(sprintf('fopen(''task_no_%d.txt'',''at+'');',task_no));
       
         fprintf(fid_mouse_move,'%d     %.6f  %s  %s   %d   \n',floor(te),(te-floor(te)),num2str(C(1,1)),num2str(C(1,2)),1);

%         fprintf(fid_mouse_move,'\n %d  %f  %d  %s   %s',a1_t,b1_t,1,num2str(C(1,1)),num2str(C(1,2)));
%         toc(t_start_exp)
        % 1 stands for schematic display
        % second column is for X coordinate
        % third column is for Y coordinate
        % title(gca, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']);
        
    end

    % Tracks mouse movement on alarm display window
    function mouseMove2 (object, eventdata)
        
        C = get (object, 'CurrentPoint');
%         time_stamp_mouse2 = datestr(now,'dd-mm-yyyy HH:MM:SS FFF');
%         a2_t = str2num(time_stamp_mouse2(18:19));
%         b2_t = str2num(time_stamp_mouse2(21:23));
%         
%      te = toc(t_start_exp);
%     a2_t = floor(te);
%     b2_t = te-floor(te);
%         fprintf(fid_mouse_move,'\n %d  %f  %d %s   %s',a2_t,b2_t,2,num2str(C(1,1)),num2str(C(1,2)));
        % 2 stands for alarms display
        
        
        te = toc(t_start_exp);
%          fid_mouse_move =  eval(sprintf('fopen(''task_no_%d.txt'',''at+'');',task_no));
         fprintf(fid_mouse_move,'%d     %.6f  %s  %s   %d   \n',floor(te),(te-floor(te)),num2str(C(1,1)),num2str(C(1,2)),2);
    end



end






