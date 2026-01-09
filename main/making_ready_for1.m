
% function making_ready_for()
function making_ready_for(task_no,fault_no_list,fault_no)
% fault_no = 5;
% task_no = 1;
% no_of_tasks = 1;
clc;

global task_name no_of_tasks sequence_task ty fid_click t_start_exp
addpath('utils');
addpath('gui');
addpath('monitoring');
f_mess = figure('Visible','off','Name','Operating details and Goal',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[330 170,750,515],'Resize','off','color',.9.*[ 1 1 1]);  %400,250,550,515   [330 170

f_task = figure('Visible','off','Name','Task Introduction',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[330 170,730,515],'Resize','off','color',.9.*[ 1 1 1]); %[330 170 

f_finish  = figure('Visible','off','Name','End of demo tasks and start first scenario',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[330,170,730,515],'Resize','off','color',.9.*[ 1 1 1]);

task_name = { 'Monitor the plant and if the abnormality happens then handle it'
          'Monitor the plant and if the abnormality happens then handle it'
          'Monitor the plant and if the abnormality happens then handle it'
          'Monitor the plant and if the abnormality happens then handle it'
          'Monitor the plant and if the abnormality happens then handle it'
          'Monitor the plant and if the abnormality happens then handle it'
          'Monitor the plant and if the abnormality happens then handle it'
          'Monitor the plant and if the abnormality happens then handle it'
          'Monitor the plant and if the abnormality happens then handle it'
        };
     

finish_task = uicontrol(f_finish,'Style','pushbutton','String','Start Experiment','Units','points','fontsize',12,'Position',[225 250,125,30],'visible','on','Callback',@finish_task_call);

Start_string = ' You are playing the role of an operator for ethenol plant. Your superviser is going to assign you certain task. Get ready to perform them. Press Next button to continue.';


mess_fow = uicontrol(f_mess,'Style','text','HorizontalAlignment','left','Units','Points','Position',[50,200,500,140],'String',Start_string,'backgroundcolor',.9.*[ 1 1 1],'foregroundcolor',[0 0 0],'fontsize',14,'fontweight','bold');

start_make = uicontrol(f_mess,'Style','pushbutton','String','Next','Units','points','fontsize',12,'Position',[350 125,75,30],'visible','on','Callback',@start_make_call);

% task_message = uicontrol

task_mess = uicontrol(f_task,'Style','text','Units','Points','Position',[50,250,500,60],'backgroundcolor',.9.*[ 1 1 1],'foregroundcolor',[0 0 0],'fontsize',14,'fontweight','bold');

% task_go = uicontrol(f_task,'Style','pushbutton','String','Start','Units','points','fontsize',12,'Position',[300 150,75,30],'visible','on','Callback',@task_go_call);


finish_button = uicontrol(f_task,'Style','pushbutton','String','Finish','Units','points','fontsize',12,'Position',[350 125,75,30],'visible','off','Callback',@finish_button_callback);
 
next_task = uicontrol(f_task,'Style','pushbutton','String','Next','Units','points','fontsize',12,'Position',[350 125,75,30],'visible','off','Callback',@start_next_task_call);

start_next_task =  uicontrol(f_task,'Style','pushbutton','String','Start','Units','points','fontsize',12,'Position',[350 125,75,30],'visible','on','Callback',@start_next_button_callback);
  if task_no <= no_of_tasks  
        fault_no = fault_no_list(sequence_task(task_no));
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
     set(task_mess,'String','You have completed all the task. Press finish to complete the experiment');
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
              set(f_task,'visible','on')
               t_start_exp = tic;
   %             tetio_startTracking;
              te = toc(t_start_exp);
              fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),0,0,1,'Ready_next_task',0000);
              set(f_task,'visible','on')
         end
   

              te = toc(t_start_exp);
              fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),0,0,1,'Ready_next_task',0000);

        set(next_task,'visible','off');
        set(start_next_task,'visible','on');
       
%         set(start_next_task,'visible','on');[8 7 9 10 11 12 1 5 6];
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
    function start_next_task_call(varargin)
         if task_no == 1
              close(f_mess);
              set(f_task,'visible','on')
         end
      
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
        fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f\n',floor(te),(te-floor(te)),0,0,1,'Start_next_task',0000);

%         eye_track_automatic1(task_no,fault_no_list,fault_no);
%            setDesktopVisibility('off')
        gui_changed_color(task_no,fault_no_list,fault_no);
    end
    function finish_button_callback(varargin)
             set(finish_button,'visible','off');
             set(task_mess,'String',' ');
             set(task_mess,'Position',[50,250,1,1]);
             imshow('media\images\Thanks.png');
             fclose(intro_file);
             
               
  %-------------------------Writing the Gaze data -------------------           
             tetio_stopTracking;
             pauseTimeInSeconds = 0.01;
             durationInSeconds = 0.01;
             [leftEyeAll, rightEyeAll, timeStampAll] = DataCollect(durationInSeconds, pauseTimeInSeconds);
             
             for i = 2:length(timeStampAll)
                 timeStampAll(i) = timeStampAll(i-1) + timeStampAll(i);
             end
             sec = floor(timeStampAll/1e6);   % TO CONVERT INTO SECS
             microsec  = timeStampAll - sec*1e6;       
             eval(sprintf('xlswrite(''data\\excel-outputs\\gaze_rawdata_%s.xlsx'',[sec microsec leftEyeAll rightEyeAll])',ty));

             
             tetio_disconnectTracker; 
             tetio_cleanUp;
             pause(3);
             setDesktopVisibility('on');
    end
end

