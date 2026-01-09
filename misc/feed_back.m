clc
task_no = 1;
fault_no = 1;
fault_no_list = 1;
global  fid_task_ques f_feedback_task edit_box_task f_new_task time_start fid_only_ans text_submit
beep off
global task_no_feed fault_no_list_feed fault_no_feed
global queans1 queans2 queans3 queans4 queans5 no_of_tasks
global submit_flag
global time_track_count time_track_for_experiment t_start_exp

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

close_button_press = uicontrol(f_feedback_task,'Visible','on','Style','text','Position',[650,680,200,50], 'fontsize',14,'foregroundcolor',[1 0 0],'Units','points','String','Give answer to each question and press Submit');

ques_text1 = uicontrol(f_feedback_task,'Style','text','String','1. How many sliders were present in the scematic ?','foregroundcolor',[0 0 0],'Units','points','fontsize',15,...
    'Position',[10, 495,400,20],'visible','on');

%---------------first question-----------------------
one_option_2  = uibuttongroup(f_feedback_task,'visible','on');
set(one_option_2,'SelectionChangeFcn',@one_option_2_callback);

que_1_opt_1 = uicontrol(f_feedback_task,'parent',one_option_2,'Style','radiobutton','String','3','fontsize',15,...
    'Position',[100, 465,200,20],'Units','points','visible','on');

que_1opt_2 = uicontrol(f_feedback_task,'parent',one_option_2,'Style','radiobutton','String','4','fontsize',15,...
    'Position',[100, 465-30,200,20],'Units','points','visible','on');

%---------------second question-----------------------
ques_text1 = uicontrol(f_feedback_task,'Style','text','String','2. Which slider you used to track the set point?','foregroundcolor',[0 0 0],'Units','points','fontsize',15,...
    'Position',[0, 465-70,400,20],'visible','on');

two_opt_4 = uibuttongroup(f_feedback_task,'visible','on');
que_2_opt_1 = uicontrol(f_feedback_task,'parent',two_opt_4,'Style','radiobutton','String','Input feed flow rate','fontsize',15,...
    'Position',[100, 465-100,400,20],'Units','points','visible','on');
que_2_opt_2 = uicontrol(f_feedback_task,'parent',two_opt_4,'Style','radiobutton','String','Cooling water inlet flow','fontsize',15,...
    'Position',[100, 465-130,500,20],'Units','points','visible','on');
que_2_opt_3 = uicontrol(f_feedback_task,'parent',two_opt_4,'Style','radiobutton','String','Distillation column feed flow rate','fontsize',15,...
    'Position',[100, 465-160,500,20],'Units','points','visible','on');
que_2_opt_4 = uicontrol(f_feedback_task,'parent',two_opt_4,'Style','radiobutton','String','Change of reflux ration','fontsize',15,...
    'Position',[100, 465-190,500,20],'Units','points','visible','on');

function one_option_2(source,eventdata)
    
        queans2= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        if flag==1
            set(text_submit,'visible','off');
        end
end