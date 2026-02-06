% function gui_changed_color
function gui_changed_color_training(task_training_no)
% clc;
% clear all;
% close all;

% Add monitoring functions to path
addpath('monitoring');
addpath('data-collection');
addpath('utils');

beep off
import valve
global task_no_lo fault_no_list_lo fault_no_lo
global f f2 b_image ans_pv_1 ans_pv_2 ans_pv_3 ans_pv_4 ans_pv_5 ans_pv_6 ans_pv_7 ans_pv_8 trendPanel closeTrendbh V102 V301 V401 V201
global varTrend Start_Simu closeButton alarm_text posit control_pos control_stat   ans_pv_9 ans_pv_10 ans_pv_11 ans_11
global slider_reflux  ans_12 ans_13 ans_14 ans_28 ans_29 identification_opt slider_flow_dist slider_for_temp
global slider_amn_feed slider_amn_cooling slider_amn_dist slider_amn_reflux
global control_stat_reflux control_stat_feed control_stat_cooling control_stat_dist fid_mouse_move
global  fid fid_click curr_time
global fid_alarm_timing esd_box
% global  flag_temp_control  flag_reflux_control
global time_start
global time_start_first

global tag_for_plot
global number_var_alarms

control_stat_reflux = 2;
control_stat_feed  = 2;
control_stat_cooling = 2;
control_stat_dist=2;
% task_no_lo = task_no;
% fault_no_lo = fault_no;
% fault_no_list_lo = fault_no_list;




% flag_reflux_control  = 0 ;
% flag_temp_control = 0;
f = figure('Visible','on','Name','Schematic Display',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[80,280,1220,515],'Resize','off','color',[127 127 127]./255); % place [ 0 0 0] to get previous color
% Add title to schematic display window
uicontrol(f,'Style','text','String','Plant Schematic Display','Units','normalized',...
    'Position',[0 0.97 1 0.04],'BackgroundColor',[127 127 127]./255,'ForegroundColor',[0 0 0],...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');

f2 = figure('Visible','on','Name','Alarms Display',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[80, -170, 1220, 455],'Resize','off', 'color', [1 1 1]);
% Add title to alarms display window
uicontrol(f2,'Style','text','String','Alarms Display','Units','normalized',...
    'Position',[0 0.95 1 0.05],'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','center');


% This is used to plot alarm display
alarm_summary =axes('Parent',f2,'Units','points', 'NextPlot','replacechildren','Position',[30,45,950,375],'color',[0.95 0.95 0.95]); %axes ('Parent',f2, 'HandleVisibility','callback','NextPlot','replacechildren', 'Units','points', 'Position',[15,290,990,215]);
table_alarm(alarm_summary); % list of alarms - bottom part


b_image = axes('Parent',f,'HandleVisibility','callback','NextPlot','replacechildren', 'Units','points', 'Position',[5 -17-33-5 1387 528]);
imshow('image_with_final_pic.png','Parent',b_image);

% for obtaining mouse coordinates for remianing screen for points which
% do not have callbacks
set(f,'WindowButtonDownFcn',@mytestcallback);% for mouse click on schematic display
set(f2,'WindowButtonDownFcn',@mytestcallback2); % for mouse click on alarm summary
% for alaready obtained call back function
% set (f, 'WindowButtonMotionFcn', @mouseMove);

% fid_click = fopen('Mouse_click.txt','wt+');
% fid_mouse_move =  eval(sprintf('fopen(''fault_no_%d.txt'',''wt+'');',fault_no));

% fprintf(fid_click,'\n=============================================================================');
% fprintf(fid_click,'\n=============================================================================');
% fprintf(fid_click,'\n-----------------------------------Task %d---------------------------',task_no);
% fprintf(fid_click,'\n-----------------------------------Fault No %d-----------------------\n',fault_no);

% fid_alarm_timing = fopen('alarm_timing.txt','wt+');
% fprintf(fid_alarm_timing,'\n=============================================================================');
% fprintf(fid_alarm_timing,'\n=============================================================================');
% fprintf(fid_alarm_timing,'\n %d %d',task_no);
% fprintf(fid_alarm_timing,'\n-----------------------------------Fault No %d-----------------------\n',fault_no);

click_status = 1; % For call back function
% 2 for non call back function


%% Assigning the static textbox %%
% the following are for textboxes to display variable values in the schematic
% position is [left bottom width height
% ff contains the extent, which is width and height of the text -> used to
% specify width and height of the textbox/uicontrol

[ans_pv_1 ff] = name_uicontrol(f); set(ans_pv_1, 'Position',[225+120-50-15+5,481-33, ff(3)+68, ff(4)-2]); % input flow rate F101
[ans_pv_2 ff] = name_uicontrol(f); set(ans_pv_2, 'Position',[15+120-20,371-33, ff(3)+48+20 ,ff(4)]); % cooling water flow rate F102
[ans_pv_3 ff] = name_uicontrol(f); set(ans_pv_3, 'Position',[100+120-10,371-33, ff(3)+38 ,ff(4)-2]); % Inlet water tempearture T101
[ans_pv_4 ff] = name_uicontrol(f); set(ans_pv_4, 'Position',[420+120-15+10,297-33, ff(3)+32 ,ff(4)-2]);  % Jacket temperature T103
[ans_pv_5 ff] = name_uicontrol(f); set(ans_pv_5, 'Position',[610+120-30,280-33+30-5, ff(3)+44+20 ,ff(4)-2]); % Flow rate to distillation column F105
[ans_pv_6 ff] = name_uicontrol(f); set(ans_pv_6, 'Position',[620+120,380-33, ff(3)+32 ,ff(4)-2]); % Temp of 3rd tray T106
[ans_pv_7 ff] = name_uicontrol(f); set(ans_pv_7, 'Position',[800+120,270-33, ff(3)+32 ,ff(4)-2]); % Temp of 5th tray T105
[ans_pv_8 ff] = name_uicontrol(f); set(ans_pv_8, 'Position',[625+120+30-20,180-33, ff(3)+32 ,ff(4)-2]); % Temp of 8th tray T104

[ans_pv_9,ff] = name_uicontrol(f);set(ans_pv_9,'Position',[300+120-15,450-33,ff(3)+32,ff(4)-2],'visible','on'); %CSTR Temperature T107
[ans_pv_10,ff] = name_uicontrol(f);set(ans_pv_10,'Position',[255+120-35,200-33,ff(3)+80,ff(4)-2],'visible','on'); % Ethanol Concentration C101

[ans_pv_11,ff] = name_uicontrol(f); set(ans_pv_11,'Position',[425+120-20-30,425-33,ff(3)+36,ff(4)-2], 'visible','on'); % cstr height

[ans_11 ff] = name_uicontrol(f); set(ans_11, 'Position',[100+120+10,471-33+25-15+30, ff(3)+2 ,ff(4)-2.7],'visible','on','FontSize',14); % Feed Slider
[ans_12 ff] = name_uicontrol(f); set(ans_12, 'Position',[23+120-10,268-33-10, ff(3)+2 ,ff(4)-2],'visible','on','FontSize',14); % Coolant Slider
[ans_13 ff] = name_uicontrol(f); set(ans_13, 'Position',[930+120+8,500-33, ff(3)+2 ,ff(4)-2],'visible','on','FontSize',14); % Reflux Slider
[ans_14,ff] = name_uicontrol(f); set(ans_14, 'Position',[545+120,520-33-45-110-65-30, ff(3)+2,ff(4)-2],'visible','on','FontSize',14);% distillation cloumn flow

%=========================================================================
%=================Text box for control option=============================

%=======================For Feed=========================================
[ans_15,ff] = name_uicontrol(f); set(ans_15,'Position',[50+120,485,ff(3)+4 ,ff(4)-2],'visible','off'); % Automatic for feed

set(ans_15,'String','M','foregroundcolor',[.8 0 .5],'fontsize',14);

%====================For Cooling========================================

[ans_18,ff] = name_uicontrol(f); set(ans_18,'Position',[45+120,205,ff(3)+4 ,ff(4)-2],'visible','off'); % Automatic for feed
set(ans_18,'String','M','foregroundcolor',[.8 0 .5],'fontsize',14);

%======================For distillation column inlet=====================

[ans_21,ff] = name_uicontrol(f); set(ans_21,'Position',[540+120,315,ff(3)+3 ,ff(4)-2],'visible','off'); % Automatic for feed
set(ans_21,'String','M','foregroundcolor',[.8 0 .5],'fontsize',14);

%=======================For reflux valve=================================
[ans_24,ff] = name_uicontrol(f); set(ans_24,'Position',[874+120,486,ff(3)+4 ,ff(4)-2],'visible','off'); % Automatic for feed
set(ans_24,'String','M','foregroundcolor',[.8 0 .5],'fontsize',14);


%======================== For Reflux Ratio ==============================
[ans_28,ff] = name_uicontrol(f); set(ans_28, 'Position',[800+120+15,365,ff(3)+44, ff(4)- 2],'visible','off'); % for reflux ratio

%=========================== For Text Printing ===========================
ans_29 =  uicontrol(f,'Style','text','Position',[500+260 200 320 70],'visible','off','String','Scenario Completed!!!','foregroundcolor',[33 61 33]./255,'fontsize',15);

%% Historical Trend in Schematics Display
% button for each variable
% gray color
buttonColor = [0.5 0.5 0.5];

v1bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','F101','fontweight','bold','fontsize',10,'Units','points','Position',[246+10 441-7 30 30],'Callback',@v1Fcn,'visible','off');    %F101
v2bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','F102','fontweight','bold','fontsize',10,'Units','points','Position',[144+10,300-1,30,30],'Callback',@v2Fcn,'visible','off');    %F102
v3bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T101','fontweight','bold','fontsize',10,'Units','points','Position',[214+5,301-1,30,30],'Callback',@v3Fcn,'visible','off');    %T101
v4bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T102','fontweight','bold','fontsize',10,'Units','points','Position',[492+0,264,30,30],'Callback',@v4Fcn,'visible','off');    %T102
v5bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','F105','fontweight','bold','fontsize',10,'Units','points','Position',[705+3,234,30,30],'Callback',@v5Fcn,'visible','off');    %F105
v6bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T106','fontweight','bold','fontsize',10,'Units','points','Position',[742+10 312+3 30 30],'Callback',@v6Fcn,'visible','off');    %T106
v7bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T105','fontweight','bold','fontsize',10,'Units','points','Position',[929-5 259 30 30],'Callback',@v7Fcn,'visible','off');  %T105
v8bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T104','fontweight','bold','fontsize',10,'Units','points','Position',[754+8 167-2 30 30],'Callback',@v8Fcn,'visible','off');  %T104
v9bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','T107','fontweight','bold','fontsize',10,'Units','points','Position',[403+4 381-3 30 30],'Callback',@v9Fcn,'visible','off');  %T107
v10bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','C101','fontweight','bold','fontsize',10,'Units','points','Position',[362+8 189 30 30],'Callback',@v10Fcn,'visible','off');  %C101
v11bh = uicontrol(f,'Style','pushbutton','backgroundcolor',[0 128 192]./255,'String','L101','fontweight','bold','fontsize',10,'Units','points','Position',[500-5 359 30 30],'Callback',@v11Fcn,'visible','off'); % L101


%%
trendPanel = uipanel('Parent',f,'HandleVisibility','callback','Units','points','Position',[15 10 275+40 135+50]);

%close Trend Panel button
closeTrendbh = uicontrol('Parent',trendPanel,'Style','pushbutton','backgroundcolor',[0.7 0.7 0.7],'Units','points','Position',[0 0 20 12],...
    'HandleVisibility','callback','String','Close','FontSize',6.5,'Callback',@closeTrendFcn);
varTrend = axes('Parent',trendPanel,'HandleVisibility','callback','NextPlot','replacechildren','Units','points','Position',[28 15 240+30 110+30],'FontSize',8);
set(trendPanel,'Visible','off');


name_list = {'Select Diagnosis';'Leak in Reactor Inlet';'Catalyst Poisoning';'Leak in cooling water Inlet';'Leak in Distillation Column Inlet';'Leak in reflux valve';'Reboiler power failure';'None of the above'};

%% For slider and slider values
slider_feed = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.5,'Position',[160+120+10,650-33-30-15+15,18,75],'SliderStep',[0.009 0.08],'visible','on','callback',@slider_feed_control);

slider_coolant = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.5,'Position',[55+120-15,320-33-10,18,75],'SliderStep',[0.009 0.08],'visible','on','callback',@slider_coolant_control);

slider_reflux = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.5,'Position',[1265+120+10,670-33-45+10,18,75],'SliderStep',[0.009 0.08],'visible','on','callback',@slider_reflux_control);

slider_flow_dist = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.5,'Position',[750+120,520-33-45-110-30,18,75],'SliderStep',[0.009 0.08],'visible','on','callback',@slider_flow_dist_control);

slider_amn_feed = uicontrol(f,'Style','togglebutton','String','M','fontsize',12,'fontweight','bold','Min',0,'Max',1,'Value',1,'Position',[100+120+10,650-15,30,30],'Slider',[1 1],'backgroundcolor',[1 1 0],'visible','on','callback',@slider_amn_feed_control);

slider_amn_cooling = uicontrol(f,'Style','togglebutton','String','M','fontsize',12,'fontweight','bold','Min',0,'Max',1,'Value',1,'Position',[95+120-100,275,30,30],'Slider',[1 1],'backgroundcolor',[1 1 0],'visible','on','callback',@slider_amn_cooling_control);

slider_amn_dist = uicontrol(f,'Style','togglebutton','String','M','fontsize',12,'fontweight','bold','Min',0,'Max',1,'Value',1,'Position',[750+120,390,30,30],'Slider',[1 1],'backgroundcolor',[1 1 0],'visible','on','callback',@slider_amn_dist_control);

slider_amn_reflux = uicontrol(f,'Style','togglebutton','String','M','fontsize',12,'fontweight','bold','Min',0,'Max',1,'Value',1,'Position',[1195+120,645,30,30],'Slider',[1 1],'backgroundcolor',[1 1 0],'visible','on','callback',@slider_amn_reflux_control);

slider_for_temp  = uicontrol(f,'Style','Slider','Min',0,'Max',1,'Value',.2,'Position',[235+120,450-33-10,10,75],'SliderStep',[.009 .08],'visible','off','callback',@slider_temp_control,'Enable','inactive');

set(slider_reflux,'Enable','on');
set(slider_feed,'Enable','on');
set(slider_coolant,'Enable','on');
set(slider_flow_dist,'Enable','on');


esd_box = uicontrol(f,'Style','pushbutton','String','Emergency Shutdown','backgroundcolor',[1 0 0],'foregroundcolor',[0 0 0],'fontweight','bold','fontsize',12,'Units','points','Position',[500+120 50 150 30],...
    'Callback',@esd_call,'Visible','off');

%% Set up Control Boxes

Start_Simu= uicontrol(f,'Style','pushbutton','String','Start','backgroundcolor',[0 1 0],'fontweight','bold', 'fontsize',12,...
    'Units','points','Position',[500+120 50 150 30], 'foregroundcolor',[0 0 0],'Callback', @myStartFcn1);
closeButton = uicontrol(f,'Style','pushbutton','String','Submit & Close','backgroundcolor',[0.7 0.7 0.7],'fontweight','bold','fontsize',10,...
    'Units','points','Position',[1150+120 130-13+150 100 20],'Callback', @myCloseFcn, 'Visible','off');


%% For showing current time on alarm summary

time_name = name_uicontrol(f2);set(time_name,'Position',[1100,285,ff(3)+6,ff(4)-2],'visible','on','String','Time','fontweight','bold','backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0]);
curr_time = name_uicontrol_summary(f2);  set(curr_time,'Position',[1025,265,ff(3)+150,ff(4)],'visible','on','String',datestr(now),'backgroundcolor',[1 1 1],'foregroundcolor',[.8 .6 .3]);

%% Alarm Summary %%
% List of alarms
posit{1} = [32 375 220 15]; posit{2} = [250 375 220 15];posit{3} = [505 375 220 15];posit{4} = [731 375 240 15];
% posit{5} = [761 375 215 15];
cvv = [0.95 0.95 0.95];alarm_text=cell(14,5);



uicontrol(f2,'Style','text','String', 'Alarm Summary','backgroundcolor',cvv, 'foregroundcolor',[0 0 0], 'Units', 'points',...
    'fontsize',12,'Position',[32 400 945 15],'fontweight','bold','HorizontalAlignment','center');
uicontrol(f2,'Style','text','String', 'Date & Time','backgroundcolor',cvv, 'foregroundcolor',[0 0 0], 'Units', 'points',...
    'fontsize',11,'Position',[32 375 220 15],'fontweight','bold');
% uicontrol(f2,'Style','text','String', 'Location','backgroundcolor',cvv, 'foregroundcolor',[0 0 0], 'Units', 'points',...
%     'fontsize',11,'Position',[215 377 175 15],'fontweight','bold');
uicontrol(f2,'Style','text','String', 'Source','backgroundcolor',cvv, 'foregroundcolor',[0 0 0], 'Units', 'points',...
    'fontsize',11,'Position',[250 375 220 15],'fontweight','bold');
uicontrol(f2,'Style','text','String', 'Condition','backgroundcolor',cvv, 'foregroundcolor',[0 0 0], 'Units', 'points',...
    'fontsize',11,'Position',[505 375 220 15],'fontweight','bold');
uicontrol(f2,'Style','text','String', 'Description','backgroundcolor',cvv, 'foregroundcolor',[0 0 0], 'Units', 'points',...
    'fontsize',11,'Position',[731 375 240 15],'fontweight','bold');

% alarm_text is placeholder for List of alarms table
for ii = 1:4
    for j = 1:14
        alarm_text{j,ii} =uicontrol(f2,'Style','text','String','','backgroundcolor',cvv, 'foregroundcolor',[0 0 0],...
            'Units','points','fontsize',10,'Position',[posit{ii}(1) posit{ii}(2)-(j*18) posit{ii}(3) posit{ii}(4)]);
    end
end


%% Defining valve values

V102=valve;
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
V201.valvepos = 1;




%% Functions
    function myStartFcn1(varargin)
        time_start = datestr(clock); % clock is a function and so as datestr
        time_start_mili = datestr(now,'dd-mm-yyyy HH:MM:SS FFF');
        %         tic
%         set (f, 'WindowButtonMotionFcn', @mouseMove);
%         set(f2,'WindowButtonMotionFcn',@mouseMove2);
%         if task_no==1
%             tic
%             
%             time_start_first = time_start;
%             time_mode= time_start;
%             time_mode ([12 15 18]) = '_';
%             eval(sprintf(' TrackStart(0,''eye_track_data_%s'');',time_mode));
%             
%         end
%         
%         fid = fopen('Diagnosis1.txt','at+');
%         
%         fprintf(fid,'\n=================================================================');
%         fprintf(fid,'\n-----------------------Task %d-----------------------------------',task_no_lo);
%         fprintf(fid,'\n-----------------------Fault No %d-------------------------------',fault_no_lo);
%         fprintf(fid,'\nSTART TIME = %s \n',time_start_mili);
%         
        set(Start_Simu,'Visible','off');
        %====================================
        % Hiding the close and submit option
        set(closeButton,'visible','off');
        %====================================
        set(esd_box,'visible','on');
        
        %% Hiding the pop up menu
        
        set(identification_opt,'visible','off');
        po = get(Start_Simu,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f   %.2f    %d   %s     %s \n',po_mid(1),po_mid(2),1,datestr(now),'Start');
        main_file_kaushik_parameters_training(task_training_no);
        
    end

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
        feedback_form_gui
    end


    function esd_call(varargin)
%         fprintf(fid,'STOP TIME = %s \n',datestr(clock,'dd-mm-yyyy HH:MM:SS FFF'));
        clc;
%         fclose(fid_mouse_move);
%         fid = fopen('Diagnosis1.txt','at+');
%          
%         po = get(esd_box,'Position');
%         po_mid(1) = po(1) + (po(3)/2);
%         po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f   %.2f    %d   %s     %s \n',po_mid(1),po_mid(2),1,datestr(now),'Emergency_Shutdown');
%         
%         fprintf(fid,'Emergency Shutdown\n');
%                
%         [a_a b_a c_a f_a] = textread('alarm_timing.txt','%s %s %s %s','whitespace',' ','bufsize',10000);
%         ty = time_start_first;
%         ty([12 15 18]) = '_';
%         if ~isempty(a_a) && ~isempty(b_a) && ~isempty(c_a) && ~isempty(f_a)
%             eval(sprintf('xlswrite(''Alarm_timing_%s.xlsx'',[a_a b_a c_a f_a],%d);',ty,fault_no_lo));
%             
%         end
%         
%         [a_c b_c c_c d_c e_c f_c] = textread('Mouse_click.txt','%s %s %s %s %s %s','whitespace',' ','bufsize',10000);
%         ty = time_start_first;
%         ty([12 15 18]) = '_';
%         if ~isempty(a_c) && ~isempty(b_c) && ~isempty(c_c) && ~isempty(d_c) && ~isempty(e_c) && ~isempty(f_c)
%             eval(sprintf('xlswrite(''Mouse_click_%s.xlsx'',[a_c b_c c_c d_c e_c f_c],%d);',ty,fault_no_lo));
%             
%         end
%       
        close(f)
        close (f2);
        pause(5);
        clc
%         feedback_per_task(task_no_lo,fault_no_list_lo,fault_no_lo)
      task_training_no = task_training_no + 1;
making_ready_for(task_training_no);
    end

    function slider_feed_control(varargin)
        
        po = get(slider_feed,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f    %.2f   %d   %s     %s \n',po_mid(1),po_mid(2),1,datestr(now),'Slider_feed_control');
        V102.valvepos = get(slider_feed,'Value');
        
    end


    function slider_coolant_control(varargin)
        
        po = get(slider_coolant,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f   %.2f    %d  %s     %s \n',po_mid(1),po_mid(2),1,datestr(now),'Slider_Coolant_Control');
       V301.valvepos  = get(slider_coolant,'Value');
         
    end

    function slider_reflux_control(varargin)
%         flag_reflux_control = 1;
        po = get(slider_reflux,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f   %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'Slider_Reflux_Control');
        V401.valvepos = get(slider_reflux,'Value');
         
    end

    function slider_flow_dist_control(varargin)
        
        po = get(slider_flow_dist,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f  %.2f   %d   %s   %s \n',po_mid(1),po_mid(2),1,datestr(now),'Slider_Flow_Distilation_Column_Control');
        V201.valvepos =  get(slider_flow_dist,'Value');
      
    end


    function slider_temp_control(varargin)
%         flag_temp_control = 1;
        po = get( slider_for_temp,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f   %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'Slider_For_Temperature_Control');
        temp_slider_val = get( slider_for_temp,'Value');
        set(slider_for_temp,'Enable','on');
    end

    function slider_amn_feed_control(varargin)
        
        a = get(slider_amn_feed,'Value');
        po = get(slider_amn_feed,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
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



    function slider_amn_cooling_control(varargin)
        
        a = get(slider_amn_cooling,'Value');
        
        po = get(slider_amn_cooling,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
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


    function slider_amn_dist_control(varargin)
        
        a = get(slider_amn_dist,'Value');
        
        
        po = get(slider_amn_dist,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'auto_manual_distillation_flow_control');
        
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

    function slider_amn_reflux_control(varargin)
        
        a = get(slider_amn_reflux,'Value');
        
        po = get(slider_amn_reflux,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,' %.2f   %.2f   %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'auto_manual_reflux_control');
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
%         fprintf(fid_click,' %.2f   %.2f    %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'F101');
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
%         fprintf(fid_click,' %.2f   %.2f    %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'T101');
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
%         fprintf(fid_click,' %.2f   %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'T103');
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
%         fprintf(fid_click,' %.2f    %.2f  %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'V201');
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
%         fprintf(fid_click,' %.2f    %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'T106');
        
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
%         fprintf(fid_click,' %.2f    %.2f   %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'T105');
        
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
%         fprintf(fid_click,' %.2f   %.2f   %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'T104');
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
%         fprintf(fid_click,' %.2f   %.2f    %d   %s     %s \n',po_mid(1),po_mid(2),1,datestr(now),'T107');
        
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
%         fprintf(fid_click,' %.2f   %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'C101');
        
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
%         fprintf(fid_click,' %.2f  %.2f   %d   %s    %s \n',po_mid(1),po_mid(2),1,datestr(now),'L101');
        % first set all v?bh UserData to 0 == deactivate
        for iii = 1:1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        % set v1bh to 1 == activate
        set(v11bh,'UserData',1);
    end


    function closeTrendFcn(varargin)
       tag_for_plot = 0;
        set(closeTrendbh,'visible','off');
        set(trendPanel,'Visible','off');
        % set all v?bh UserData to 0 == deactivate
        po = get(closeTrendbh,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,'%.2f    %.2f    %d   %s      %s \n',po_mid(1),po_mid(2),1,datestr(now),'Close_trend_plot');
        for iii = 1:number_var_alarms
            %if iii ~= 10
            eval(sprintf('set(v%dbh,''UserData'',0);',iii));
            %end
        end
        
    end


    function mouse_click_val(varargin)
        
        po = get(identification_opt,'Position');
        po_mid(1) = po(1) + (po(3)/2);
        po_mid(2) = po(2) + (po(4)/2);
%         fprintf(fid_click,' %.2f    %.2f   %d   %s    %s \n',po_mid(1),po_mid(2),2,datestr(now),'Arbitrary');
        
    end


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
        if pos(1)<= 283 && pos(1)>=246 && pos(2)<=466 && pos(2)>=436
            %             v1Fcn;
%             fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',264,451,1,datestr(now),'F101');
            tag_for_plot = 1;
            %flag_text = 1;
        else
            
            % for F102
            if pos(1)<= 183 && pos(1)>=144 && pos(2)<=331 && pos(2)>=300
                %                 v2Fcn;
%                 fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',163,315,1,datestr(now),'F102');
                tag_for_plot = 2 ;
                %flag_text = 1;
            else
                
                % for T101
                if pos(1)<= 249 && pos(1)>=214 && pos(2)<=333 && pos(2)>=301
%                     fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',231,315,1,datestr(now),'T101');
                    tag_for_plot = 3 ;
                    %                     v3Fcn;
                    %flag_text = 1;
                else
                    
                    % for T102
                    if pos(1)<= 525 && pos(1)>=492 && pos(2)<=291 && pos(2)>=264
%                         fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',508,277.5,1,datestr(now),'T102');
                        tag_for_plot = 4 ;
                        %                         v4Fcn;
                        %flag_text = 1;
                    else
                        % for F105
                        if pos(1)<= 742 && pos(1)>=705 && pos(2)<=264 && pos(2)>=234
%                             fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',723,249.5,1,datestr(now),'F105');
                            tag_for_plot = 5 ;
                            %                             v5Fcn;
                            %flag_text = 1;
                        else
                            
                            % for T106
                            if pos(1)<= 783 && pos(1)>=742 && pos(2)<=345 && pos(2)>=312
%                                 fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',762,328,1,datestr(now),'T106');
                                tag_for_plot = 6 ;
                                %                                 v6Fcn;
                                %flag_text = 1;
                            else
                                % for T105
                                if pos(1)<= 959 && pos(1)>=929 && pos(2)<=292 && pos(2)>=261
%                                     fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',944,276,1,datestr(now),'T105');
                                    tag_for_plot = 7 ;
                                    %                                     v7Fcn;
                                    %flag_text = 1;
                                else
                                    % for T104
                                    if pos(1)<= 786 && pos(1)>=754 && pos(2)<=189 && pos(2)>=167
                                        
%                                         fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',770,178,1,datestr(now),'T104');
                                        tag_for_plot = 8 ;
                                        %                                         v8Fcn;
                                        %flag_text = 1;
                                    else
                                        % for T103
                                        if pos(1)<= 439 && pos(1)>=401 && pos(2)<=411 && pos(2)>=381
%                                             fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',420,396,1,datestr(now),'T103');
                                            tag_for_plot = 9 ;
                                            %                                             v9Fcn;
                                            %flag_text = 1;
                                        else
                                            % for C101
                                            if pos(1)<= 397 && pos(1)>=362 && pos(2)<=216 && pos(2)>=189
%                                                 fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',379,202,1,datestr(now),'C101');
                                                tag_for_plot = 10 ;
                                                %                                                 v10Fcn;
                                                %flag_text = 1;
                                            else
                                                % for L101
                                                if pos(1)<= 535 && pos(1)>=500 && pos(2)<=387 && pos(2)>=360
%                                                     fprintf(fid_click,'%.2f   %.2f    %d   %s    %s \n',517,373,1,datestr(now),'L101');
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


    function mytestcallback2(hObject,~)
        
        pos=get(hObject,'CurrentPoint');
        %         fprintf(fid_click,' %.2f    %.2f   %d   %s    %s \n',(pos(1)),(pos(2)),2,datestr(now),'Arbitrary');
        pos(1);
        pos(2);
        
        flag_text = 0;
        
    end



%     function mouseMove (object, eventdata)
%         
%         C = get (object, 'CurrentPoint');
%         time_stamp_mouse = datestr(now,'dd-mm-yyyy HH:MM:SS FFF');
%         a1_t = str2num(time_stamp_mouse(18:19));
%         b1_t = str2num(time_stamp_mouse(21:23));
%         
%         fprintf(fid_mouse_move,'\n %d  %d  %d  %s   %s',a1_t,b1_t,1,num2str(C(1,1)),num2str(C(1,2)));
%         % 1 stands for schematic display
%         % second column is for X coordinate
%         % third column is for Y coordinate
%         % title(gca, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']);
%         
%     end
% 
%     function mouseMove2 (object, eventdata)
%         
%         C = get (object, 'CurrentPoint');
%         time_stamp_mouse2 = datestr(now,'dd-mm-yyyy HH:MM:SS FFF');
%         a2_t = str2num(time_stamp_mouse2(18:19));
%         b2_t = str2num(time_stamp_mouse2(21:23));
%         
%         fprintf(fid_mouse_move,'\n %d  %d   %d %s   %s',a2_t,b2_t,2,num2str(C(1,1)),num2str(C(1,2)));
%         % 2 stands for alarms display
%     end



end






