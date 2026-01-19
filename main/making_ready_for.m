
% function making_ready_for()
function making_ready_for(task_no,fault_no_list,fault_no)
% fault_no = 5;
% task_no = 1;
% no_of_tasks = 1;
% fault_no_list = [1 2 1 2 1 2 1 2 1 2];
% clc;

global task_name no_of_tasks sequence_task ty intro_file t_start_exp fid_click
addpath('data-collection');
addpath('gui');
addpath('utils');
addpath('monitoring');
% Initialize with a test to ensure the path is correct
fid_click = fopen('data/text-logs/Mouse_click.txt','wt+');
if fid_click == -1
    error('Could not open Mouse_click.txt file. Check path and permissions.');
end
fclose(fid_click); % Close it initially, will reopen when needed

f_mess = figure('Visible','off','Name','Operating details and Goal',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[380 200,350,400],'Resize','off','color',.9.*[ 1 1 1]);  %400,250,550,515   [330 170

f_task = figure('Visible','on','Name','Task Introduction',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[380 200,350,400],'Resize','off','color',.9.*[ 1 1 1]); %[330 170 

f_finish  = figure('Visible','off','Name','End of demo tasks and start first scenario',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[380,200,350,400],'Resize','off','color',.9.*[ 1 1 1]);

task_name = { 'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
          'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
          'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
          'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
          'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
          'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
          'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
          'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
          'Maintain the ethanol plant at normal operating conditions with all variables within specified limits'
        };
% task_name = { 'Adjust the coolant valve to maintain the coolant flow rate'
%           'Maintain the plant in normal operating condition ( all the variables within the range )'
%           'Adjust the reflux valve in order to bring the plant into normal condition'
%           'Maintain the plant in normal operating condition ( all the variables within the range )'
%           'Maintain the plant in normal operating condition ( all the variables within the range )'
%           'Maintain the plant in normal operating condition ( all the variables within the range )'
%           'Maintain the plant in normal operating condition ( all the variables within the range )'
%           'Maintain the plant in normal operating condition ( all the variables within the range )'
%           'Maintain the plant in normal operating condition ( all the variables within the range )'
%         };

finish_task = uicontrol(f_finish,'Style','pushbutton','String','Start Experiment','Units','points','fontsize',12,'Position',[225 250,125,30],'visible','on','Callback',@finish_task_call);

% Title for the panel
title_text = uicontrol(f_mess,'Style','text','HorizontalAlignment','center','Units','Points','Position',[10,360,330,25],'String','ETHANOL PLANT CONTROL','backgroundcolor',.9.*[ 1 1 1],'foregroundcolor',[0.1 0.1 0.5],'fontsize',14,'fontweight','bold');

% Add operator image at the top of the popup (circular crop)
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

% Apply mask - set outside circle to background color
imgCircular = imgSquare;
for i = 1:size(imgSquare, 3)
    channel = imgSquare(:,:,i);
    channel(~circleMask) = 230; % Match background color
    imgCircular(:,:,i) = channel;
end

imshow(imgCircular, 'Parent', ax);
axis(ax, 'off');
axis(ax, 'equal');

% Rewritten instructions - clear, direct, operator-friendly
Start_string = sprintf('YOUR TASK:\n• Keep the ethanol plant operating normally\n• All variables must stay WITHIN RANGE\n\nWHEN AN ALARM OCCURS:\n• You will hear a BEEP sound\n• A variable will CHANGE COLOR (red)\n• You have 2 MINUTES to restore normal operation\n\nIMPORTANT: No hints provided. Work independently.');

mess_fow = uicontrol(f_mess,'Style','text','HorizontalAlignment','left','Units','Points','Position',[15,90,320,130],'String',Start_string,'backgroundcolor',.9.*[ 1 1 1],'foregroundcolor',[0 0 0],'fontsize',10,'fontweight','bold');

start_make = uicontrol(f_mess,'Style','pushbutton','String','Next','Units','points','fontsize',12,'Position',[137.5 40,75,30],'visible','on','Callback',@start_make_call);

% task_message = uicontrol

task_mess = uicontrol(f_task,'Style','text','Units','Points','Position',[20,200,310,120],'backgroundcolor',.9.*[1 1 1],'foregroundcolor',[0 0 0],'fontsize',13,'fontweight','bold');

% task_go = uicontrol(f_task,'Style','pushbutton','String','Start','Units','points','fontsize',12,'Position',[300 140,75,30],'visible','on','Callback',@task_go_call);


finish_button = uicontrol(f_task,'Style','pushbutton','String','Finish','Units','points','fontsize',12,'Position',[137.5 80,75,30],'visible','off','Callback',@finish_button_callback);
 
next_task = uicontrol(f_task,'Style','pushbutton','String','Next','Units','points','fontsize',12,'Position',[137.5 80,75,30],'visible','off','Callback',@start_next_task_call);

start_next_task =  uicontrol(f_task,'Style','pushbutton','String','Start','Units','points','fontsize',12,'Position',[137.5 80,75,30],'visible','on','Callback',@start_next_button_callback);
  if task_no < no_of_tasks  
        fault_no = fault_no_list(task_no);
  end
 if task_no <= no_of_tasks    
     if task_no==1
          set(f_mess,'visible','on');
           set(f_task,'visible','off');
%             set(task_mess,'String',cell2mat(task_name(fault_no)));
     else
%          set(trendPanel,'visible','off');
         set(start_next_task,'visible','off');
         set(f_task,'visible','on');
%          if task_no < no_of_task
            set(next_task,'visible','on');
            eval(sprintf('set(task_mess,''String'',''End of task %d.  Press Next button to start next task'');',task_no - 1));
            clc;
%          end
         
     end
 else
%      set(task_go,'visible','off');
     set(f_task,'visible','on');
     set(task_mess,'String','You have completed all the task. Press finish to fill up the feedback form.');
     set(start_next_task,'visible','off');
     set(finish_button,'visible','on');
 end
 
% function next_task_button_callback(varargin)
%      set(next_task,'visible','off');
%      set(start_next_task,'visible','on');
%      set(task_mess,'String',cell2mat(task_name(fault_no)));
%      
% end
%              
    function start_make_call(varargin)
         if task_no == 1
              close(f_mess);
               t_start_exp = tic;

              te = toc(t_start_exp);
              fid_temp = fopen('data/text-logs/Mouse_click.txt','at+');
              fprintf(fid_temp,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),0,0,1,'Ready_next_task',0000);
              fclose(fid_temp);
              gui_changed_color(task_no,fault_no_list,fault_no);
         end
    end
    function start_next_task_call(varargin)
         if task_no == 1
              close(f_mess);
              set(f_task,'visible','on')

              te = toc(t_start_exp);
              intro_file = fopen('data\text-logs\Introduction.txt','at+');
              fprintf(intro_file,'start_time task no: %d %d  %.6f \n',task_no,floor(te),(te-floor(te)));

         end
      te = toc(t_start_exp);
%       intro_file = fopen('Introduction.txt','at+');
%       fid_click = file_clk;
      fid_temp = fopen('data/text-logs/Mouse_click.txt','at+');
      fprintf(fid_temp,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),0,0,1,'Ready_next_task',0000);
      fclose(fid_temp);
%       fprintf(intro_file,'Ready_next_task: %d %d  %.6f \n',task_no,floor(te),(te-floor(te)));

        set(next_task,'visible','off');
        set(start_next_task,'visible','on');
       
%         set(start_next_task,'visible','on');
        if fault_no == 8
           set(task_mess,'String',task_name(1));
        elseif fault_no == 7
            set(task_mess,'String',task_name(2));
        elseif fault_no == 9
            set(task_mess,'String',task_name(3));
        elseif fault_no == 10
            set(task_mess,'String',task_name(4));
        elseif fault_no == 11
            set(task_mess,'String',task_name(5));
        elseif fault_no == 12
            set(task_mess,'String',task_name(6));
        elseif fault_no == 1
            set(task_mess,'String',task_name(7));
        elseif fault_no == 5
            set(task_mess,'String',task_name(8));
        elseif fault_no == 6
            set(task_mess,'String',task_name(9));
        end
    end
    function start_next_button_callback(varargin)
        
        set(f_task,'visible','off');
         te = toc(t_start_exp);
%          intro_file = fopen('Introduction.txt','at+');
%        fprintf(intro_file,'Entering the GUI after instruction for task no: %d %d  %.6f \n',task_no,floor(te),(te-floor(te)));
         % Open file each time to avoid handle issues
         fid_click = fopen('data/text-logs/Mouse_click.txt','at+');
         fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),0,0,1,'Start_next_task',0000);
         fclose(fid_click);
%         eye_track_automatic1(task_no,fault_no_list,fault_no);
%            setDesktopVisibility('off')

        gui_changed_color(task_no,fault_no_list,fault_no);
    end
    function finish_button_callback(varargin)
             set(finish_button,'visible','off');
             set(task_mess,'String',' ');
             feedback_per_task;
             set(task_mess,'Position',[50,250,1,1]);
%              imshow('Thanks.png');
             fclose(intro_file);
             
               
  %-------------------------Writing the Gaze data -------------------           
%              tetio_stopTracking;
%              pauseTimeInSeconds = 0.01;
%              durationInSeconds = 0.01;
%              [leftEyeAll, rightEyeAll, timeStampAll] = DataCollect(durationInSeconds, pauseTimeInSeconds);
             
%              for i = 2:length(timeStampAll)
%                  timeStampAll(i) = timeStampAll(i-1) + timeStampAll(i);
%              end
%              sec = floor(timeStampAll/1e6);   % TO CONVERT INTO SECS
%              microsec  = timeStampAll - sec*1e6;       
%              eval(sprintf('xlswrite(''gaze_rawdata_%s.xlsx'',[sec microsec leftEyeAll rightEyeAll])',ty));

             
%              tetio_disconnectTracker; 
%              tetio_cleanUp;
%              pause(3);
%              setDesktopVisibility('on');
    end
end

