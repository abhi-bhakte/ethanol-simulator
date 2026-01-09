function feedback_form_case1()
% task_no,fault_no_list,fault_no
clc
addpath('..\utils');
task_no = 1;
fault_no = 1;
fault_no_list = 1;
global timeStampAll leftEyeAll rightEyeAll
global  fid_task_ques f_feedback_task edit_box_task f_new_task time_start fid_only_ans text_submit fid_feedback_ans
beep off
global task_no_feed fault_no_list_feed fault_no_feed ind
global queans1 queans2 no_of_tasks
global submit_flag flag
global time_track_count time_track_for_experiment t_start_exp time_start_first

task_no_feed = task_no;
fault_no_feed = fault_no;
fault_no_list_feed = fault_no_list;
submit_flag = 0;
f_feedback_task = figure('Visible','on','Name','Feedback Form',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[330,40,940,750],'Resize','on','color',[1 1 1]);

f_thank = figure('Visible','off','Name','Thank You',...
    'Menubar','none','Toolbar','none','Units','points','NumberTitle','off',...
    'Position',[330,240,750,375],'Resize','off','color',[1 1 1]);

text_submit  = uicontrol(f_feedback_task,'Style','text','foregroundcolor',[1 0 0],'Units','points',...
    'fontsize',14,'Position',[650,40,200,25],'visible','on','String','Give answer to each question');

close_button_press = uicontrol(f_feedback_task,'Visible','off','Style','text','Position',[650,680,200,50], 'fontsize',14,'foregroundcolor',[1 0 0],'Units','points','String','Give answer to each question and press Submit');

%---------------first question-----------------------
ques_text1 = uicontrol(f_feedback_task,'Style','text','String','1. How many sliders were present in the scematic ?','foregroundcolor',[0 0 0],'Units','points','fontsize',15,...
    'Position',[10, 495,400,20],'visible','on');

one_opt_2  = uibuttongroup(f_feedback_task,'visible','on');
set(one_opt_2,'SelectionChangeFcn',@one_option_2_callback);

que_1_opt_1 = uicontrol(f_feedback_task,'parent',one_opt_2,'Style','radiobutton','String','3','fontsize',15,...
    'Position',[100, 465,200,20],'Units','points','visible','on');
que_1_opt_2 = uicontrol(f_feedback_task,'parent',one_opt_2,'Style','radiobutton','String','4','fontsize',15,...
    'Position',[100, 465-30,200,20],'Units','points','visible','on');

%---------------second question-----------------------
ques_text1 = uicontrol(f_feedback_task,'Style','text','String','2. Which slider you used to track the set point?','foregroundcolor',[0 0 0],'Units','points','fontsize',15,...
    'Position',[0, 465-70,400,20],'visible','on');

two_opt_4 = uibuttongroup(f_feedback_task,'visible','on');
set(two_opt_4,'SelectionChangeFcn',@two_option_4_callback);
que_2_opt_1 = uicontrol(f_feedback_task,'parent',two_opt_4,'Style','radiobutton','String','Input feed flow rate','fontsize',15,...
    'Position',[100, 465-100,400,20],'Units','points','visible','on');
que_2_opt_2 = uicontrol(f_feedback_task,'parent',two_opt_4,'Style','radiobutton','String','Cooling water inlet flow','fontsize',15,...
    'Position',[100, 465-130,500,20],'Units','points','visible','on');
que_2_opt_3 = uicontrol(f_feedback_task,'parent',two_opt_4,'Style','radiobutton','String','Distillation column feed flow rate','fontsize',15,...
    'Position',[100, 465-160,500,20],'Units','points','visible','on');
que_2_opt_4 = uicontrol(f_feedback_task,'parent',two_opt_4,'Style','radiobutton','String','Change of reflux ratio','fontsize',15,...
    'Position',[100, 465-190,500,20],'Units','points','visible','on');



next_box = uicontrol(f_feedback_task,'Style','pushbutton','Units','points','Position',[725,20,100,25],...
    'String','Submit','fontsize',15,'visible','on','Callback',@feed_ques_next);

uncheck_all
flag = 0;
function one_option_2_callback(source,eventdata)
    
        queans1= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        if flag==1
            set(text_submit,'visible','off');
        end
end

function two_option_4_callback(source,eventdata)
    
        queans2= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        if flag==1
            set(text_submit,'visible','off');
        end
end

function feed_ques_next(varargin)
         [flag,ind] = check_for_next;
if flag==1
         
    for i = 1:no_of_tasks
       t_store =  eval(sprintf('textread(''task_no_%d.txt'');',i));
       ty = time_start_first;
       ty([12 15 18]) = '_' 
       eval(sprintf('xlswrite(''data\\excel-outputs\\Mouse_movement_%s.xlsx'',t_store,%d);',ty,i));
       eval(sprintf('delete(''task_no_%d.txt'');',i));
    end
         
       time_track_count = time_track_count+1;
       time_track_for_experiment(time_track_count) = toc(t_start_exp);
       set(f_feedback_task,'visible','off');
        clc;
        setDesktopVisibility('on');
        pause(1);
        set(f_thank,'visible','on'); 
        imshow('media\images\Thanks.png',f_thank);
        
       time_St = datestr(now);
       fid_feedback_ans = fopen('data\text-logs\feedback_form_ans.txt','wt+');
       fprintf(fid_feedback_ans,'\n--------------------------------------------------------------\n');
        ch = '1. How many sliders were present in the scematic ?';
        temp =cell2mat(ind(1));
        fprintf(fid_feedback_ans,'\n%s \n %s\n\n',ch,(temp));

        
        ch = '2. Which slider you used to track the set point?';
        temp =cell2mat(ind(2));
        fprintf(fid_feedback_ans,'\n%s \n %s\n\n',ch,(temp));

        fprintf(fid_feedback_ans,'\n--------------------------------------------------------------\n');
        uncheck_all
        
        
        for i = 2:length(timeStampAll)
            timeStampAll(i) = timeStampAll(i-1) + timeStampAll(i);
        end
        sec = floor(timeStampAll/1e6);   % TO CONVERT INTO SECS
        microsec  = timeStampAll - sec*1e6;       
        eval(sprintf('xlswrite(''data\\excel-outputs\\gazedata_%s.xlsx'',[sec microsec leftEyeAll rightEyeAll])',ty));

           
        submit_flag = 1;
        fclose(fid_feedback_ans);
        fclose('all');
        delete('Mouse_click.txt');
        
        

end
end

function [flag,ind] = check_for_next
        
        ch1=[];
        ch2=[];
              
        ind=cell(2,1);
        if ~isempty(queans1)
            ind{1} = queans1;
            ch1 = 1;
        end
           
        if ~isempty(queans2)
            ind{2} = queans2;
            ch2 = 1;
        end
        
        if ~isempty(ch1) && ~isempty(ch2)
            flag = 1;
        else 
            flag = 0;
        end
        
end
    
function uncheck_all(varargin)
    for iii = 1:2
            
            eval(sprintf('set(que_1_opt_%d,''Value'',0);',iii));
            
    end
    for iii = 1:4
            
            eval(sprintf('set(que_2_opt_%d,''Value'',0);',iii));
            
    end
        queans1=[];
        queans2=[];
end
end
