function feedback_per_task()

% clc
task_no = 1;
fault_no = 1;
fault_no_list = 1;
% clear submit_flag
global  fid_task_ques f_feedback_task edit_box_task f_new_task time_start fid_only_ans text_submit
beep off
global task_no_feed fault_no_list_feed fault_no_feed
global queans1 queans2 queans3 queans4 queans5 no_of_tasks
global submit_flag
global time_track_count time_track_for_experiment t_start_exp

% Also need the participant id for per-user logging
global id_num

% task_no_feed = task_no;
% fault_no_feed = fault_no;
% fault_no_list_feed = fault_no_list;
submit_flag = 0;
f_feedback_task = figure('Visible','on','Name','Feedback Form',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[330,40,940,750],'Resize','on','color',[1 1 1]);%[127 127 127]./255);

% curr_axe = get(f_feedback_task,'CurrentAxes');

text_submit  = uicontrol(f_feedback_task,'Style','text','foregroundcolor',[1 0 0],'Units','points',...
    'fontsize',14,'Position',[650,40,200,25],'visible','off','String','Give answer to each question');

% f_new_task = figure('Visible','off','Name','Go to next scenario',...
%     'Menubar','none','Toolbar','none','Units','points','NumberTitle','off',...
%     'Position',[330,240,750,375],'Resize','off','color',[1 1 1]);


% set(f_feedback_task,'CloseRequestFcn',@close_feedback_form);

close_button_press = uicontrol(f_feedback_task,'Visible','off','Style','text','Position',[650,680,200,50], 'fontsize',14,'foregroundcolor',[1 0 0],'Units','points','String','Give answer to each question and press Submit');

% ch = 
% bold1 = uicontrol(f_feedback_task,'Style','text','String','cause','Units','points','fontsize',15,'Position',[325, 705,80,20],'visible','on','fontweight','bold');
% 

inst_text1 = uicontrol(f_feedback_task,'Style','text','String','Give your answers in the range from 1 - 5','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 650,600,50],'visible','on','backgroundcolor',[1 1 1]);

ques_text1 = uicontrol(f_feedback_task,'Style','text','String','1. How much physical activity was required (e.g. pushing, controlling activating etc.)?                                 ','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 600,600,50],'visible','on','backgroundcolor',[1 1 1]);

ques_text2 = uicontrol(f_feedback_task,'Style','text','String','2. How much time pressure you did you feel due to the rate or pace at which the task or element occurred?                          ','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 500,800,50],'visible','on','backgroundcolor',[1 1 1]);

ques_text3 = uicontrol(f_feedback_task,'Style','text','String','3. How successful were you in accomplishing what you were asked to do?                                                            ','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 400,700,50],'visible','on','backgroundcolor',[1 1 1]);
% 
% text_for_q3 = uicontrol(f_feedback_task,'Style','text','String','[Please type your answer in box below. Try to give precise answer.]','foregroundcolor',[0 0 0],'Units','points',...
%     'fontsize',12,'Position',[120, 375,600,50],'visible','off');

ques_text4 = uicontrol(f_feedback_task,'Style','text','String','4.How hard did you have to work (mentally or physically) to accomplish your level of performance in accomplishing these tasks?            ','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 290,900,50],'visible','on','backgroundcolor',[1 1 1]);

ques_text5 = uicontrol(f_feedback_task,'Style','text','String','5. How discouraged/ irritated/ stressed/ annoyed did you feel during tasks?                                    ','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 195,600,45],'visible','on','backgroundcolor',[1 1 1]);




five_option_1 = uibuttongroup(f_feedback_task,'visible','on','pos',[0.05   0.75   0.7   0.0463],'backgroundcolor',[1 1 1]);

five_option_2 = uibuttongroup(f_feedback_task,'visible','on','pos',[0.05   0.62   0.7   0.0463],'backgroundcolor',[1 1 1]);
five_option_3 = uibuttongroup(f_feedback_task,'visible','on','pos',[0.05   0.48   0.7   0.0463],'backgroundcolor',[1 1 1]);
five_option_4 = uibuttongroup(f_feedback_task,'visible','on','pos',[0.05   0.335   0.7   0.0463],'backgroundcolor',[1 1 1]);
five_option_5 = uibuttongroup(f_feedback_task,'visible','on','pos',[0.05   0.20   0.7   0.0463],'backgroundcolor',[1 1 1]);


set(five_option_1,'SelectionChangeFcn',@five_option_callback_1);
set(five_option_2,'SelectionChangeFcn',@five_option_callback_2);
set(five_option_3,'SelectionChangeFcn',@five_option_callback_3);
set(five_option_4,'SelectionChangeFcn',@five_option_callback_4);
set(five_option_5,'SelectionChangeFcn',@five_option_callback_5);

fid_task_ques = fopen(sprintf('data\\text-logs\\feedback_for_tasks_%s.txt', id_num),'wt+');

% fprintf(fid_task_ques,'\n-----------------------------------Task %d---------------------------',task_no);
% fprintf(fid_task_ques,'\n-----------------------------------Fault No %d-----------------------',fault_no);
fprintf(fid_task_ques,'\n START TIME = %s',datestr(now));

buttonColor = [ 1 1 1];

% Check box for question 1
% Edit by Aatif

option1_1 = uicontrol(f_feedback_task,'parent',five_option_1, ...
    'Style','radiobutton','String','1','Units','Normalized', ...
    'Position',[0.1,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]); %335

option2_1 = uicontrol(f_feedback_task,'parent',five_option_1, ...
    'Style','radiobutton','String','2','Units','Normalized', ...
    'Position',[0.1 + 0.2,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option3_1 = uicontrol(f_feedback_task,'parent',five_option_1, ...
    'Style','radiobutton','String','3','Units','Normalized', ...
    'Position',[0.1 + 0.4,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option4_1 = uicontrol(f_feedback_task,'parent',five_option_1, ...
    'Style','radiobutton','String','4','Units','Normalized', ...
    'Position',[0.1 + 0.6,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option5_1 = uicontrol(f_feedback_task,'parent',five_option_1, ...
    'Style','radiobutton','String','5','Units','Normalized', ...
    'Position',[0.1 + 0.8,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);


% Old version
% option1_1 = uicontrol(f_feedback_task,'parent',five_option_1,'Style','radiobutton','String','1','Units','points','Position',[175 590,10,10],'visible','on'); %335
% option2_1 = uicontrol(f_feedback_task,'parent',five_option_1,'Style','radiobutton','String','2','Units','points','Position',[275 590,10,10],'visible','on');
% option3_1 = uicontrol(f_feedback_task,'parent',five_option_1,'Style','radiobutton','String','3','Units','points','Position',[375 590,10,10],'visible','on');
% option4_1 = uicontrol(f_feedback_task,'parent',five_option_1,'Style','radiobutton','String','4','Units','points','Position',[475 590,10,10],'visible','on');
% option5_1 = uicontrol(f_feedback_task,'parent',five_option_1,'Style','radiobutton','String','5','Units','points','Position',[575 590,10,10],'visible','on');

text_1_1 = uicontrol(f_feedback_task,'Style','text','String', ...
    '1','Units','points','fontsize',15,'Position',[127 575,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_2_1 = uicontrol(f_feedback_task,'Style','text','String', ...
    '2','Units','points','fontsize',15,'Position',[127+130 573,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_3_1 = uicontrol(f_feedback_task,'Style','text','String', ...
    '3','Units','points','fontsize',15,'Position',[388 573,15,15],'visible','on','backgroundcolor',[1 1 1]);


text_4_1 = uicontrol(f_feedback_task,'Style','text','String', ...
    '4','Units','points','fontsize',15,'Position',[517 573,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_5_1 = uicontrol(f_feedback_task,'Style','text','String', ...
    '5','Units','points','fontsize',15,'Position',[649 573,15,15],'visible','on','backgroundcolor',[1 1 1]);

% text_1_1 = uicontrol(f_feedback_task,'Style','text','String','1','Units','points','fontsize',15,'Position',[190 590,15,15],'visible','on');
% text_2_1 = uicontrol(f_feedback_task,'Style','text','String','2','Units','points','fontsize',15,'Position',[290 590,15,15],'visible','on');
% text_3_1 = uicontrol(f_feedback_task,'Style','text','String','3','Units','points','fontsize',15,'Position',[390 590,15,15],'visible','on');
% text_4_1 = uicontrol(f_feedback_task,'Style','text','String','4','Units','points','fontsize',15,'Position',[490 590,15,15],'visible','on');
% text_5_1 = uicontrol(f_feedback_task,'Style','text','String','5','Units','points','fontsize',15,'Position',[590 590,15,15],'visible','on');

% Check box for question 2
% edit by Aatif

option1_2 = uicontrol(f_feedback_task,'parent',five_option_2, ...
    'Style','radiobutton','String','1','Units','Normalized', ...
    'Position',[0.1,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]); %335

option2_2 = uicontrol(f_feedback_task,'parent',five_option_2, ...
    'Style','radiobutton','String','2','Units','Normalized', ...
    'Position',[0.1 + 0.2,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option3_2 = uicontrol(f_feedback_task,'parent',five_option_2, ...
    'Style','radiobutton','String','3','Units','Normalized', ...
    'Position',[0.1 + 0.4,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option4_2 = uicontrol(f_feedback_task,'parent',five_option_2, ...
    'Style','radiobutton','String','4','Units','Normalized', ...
    'Position',[0.1 + 0.6,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option5_2 = uicontrol(f_feedback_task,'parent',five_option_2, ...
    'Style','radiobutton','String','5','Units','Normalized', ...
    'Position',[0.1 + 0.8,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

% old
% option1_2 = uicontrol(f_feedback_task,'parent',five_option_2,'Style','radiobutton','String','1','Units','points','Position',[175 490,10,10],'visible','on'); %335
% option2_2 = uicontrol(f_feedback_task,'parent',five_option_2,'Style','radiobutton','String','2','Units','points','Position',[275 490,10,10],'visible','on');
% option3_2 = uicontrol(f_feedback_task,'parent',five_option_2,'Style','radiobutton','String','3','Units','points','Position',[375 490,10,10],'visible','on');
% option4_2 = uicontrol(f_feedback_task,'parent',five_option_2,'Style','radiobutton','String','4','Units','points','Position',[475 490,10,10],'visible','on');
% option5_2 = uicontrol(f_feedback_task,'parent',five_option_2,'Style','radiobutton','String','5','Units','points','Position',[575 490,10,10],'visible','on');


text_1_2 = uicontrol(f_feedback_task,'Style','text','String','1', ...
    'Units','points','fontsize',15,'Position',[127 575 - 100,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_2_2 = uicontrol(f_feedback_task,'Style','text','String','2','Units', ...
    'points','fontsize',15,'Position',[127+130 573-97,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_3_2 = uicontrol(f_feedback_task,'Style','text','String','3', ...
    'Units','points','fontsize',15,'Position',[388 573-97,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_4_2 = uicontrol(f_feedback_task,'Style','text','String','4', ...
    'Units','points','fontsize',15,'Position',[517 573-97,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_5_2 = uicontrol(f_feedback_task,'Style','text','String','5', ...
    'Units','points','fontsize',15,'Position',[649 573-97,15,15],'visible','on','backgroundcolor',[1 1 1]);


% Check box for question 3
% edit by Aatif

option1_3 = uicontrol(f_feedback_task,'parent',five_option_3, ...
    'Style','radiobutton','String','1','Units','Normalized', ...
    'Position',[0.1,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]); %335

option2_3 = uicontrol(f_feedback_task,'parent',five_option_3, ...
    'Style','radiobutton','String','2','Units','Normalized', ...
    'Position',[0.1 + 0.2,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option3_3 = uicontrol(f_feedback_task,'parent',five_option_3, ...
    'Style','radiobutton','String','3','Units','Normalized', ...
    'Position',[0.1 + 0.4,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option4_3 = uicontrol(f_feedback_task,'parent',five_option_3, ...
    'Style','radiobutton','String','4','Units','Normalized', ...
    'Position',[0.1 + 0.6,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option5_3 = uicontrol(f_feedback_task,'parent',five_option_3, ...
    'Style','radiobutton','String','5','Units','Normalized', ...
    'Position',[0.1 + 0.8,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

text_1_3 = uicontrol(f_feedback_task,'Style','text','String','1', ...
    'Units','points','fontsize',15,'Position',[127 575 - 205,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_2_3 = uicontrol(f_feedback_task,'Style','text','String','2','Units', ...
    'points','fontsize',15,'Position',[127+130 573-202,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_3_3 = uicontrol(f_feedback_task,'Style','text','String','3', ...
    'Units','points','fontsize',15,'Position',[388 573-202,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_4_3 = uicontrol(f_feedback_task,'Style','text','String','4', ...
    'Units','points','fontsize',15,'Position',[517 573-202,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_5_3 = uicontrol(f_feedback_task,'Style','text','String','5', ...
    'Units','points','fontsize',15,'Position',[649 573-202,15,15],'visible','on','backgroundcolor',[1 1 1]);

% old
% option1_3 = uicontrol(f_feedback_task,'parent',five_option_3,'Style','radiobutton','String','1','Units','points','Position',[175 390,10,10],'visible','on'); %335
% option2_3 = uicontrol(f_feedback_task,'parent',five_option_3,'Style','radiobutton','String','2','Units','points','Position',[275 390,10,10],'visible','on');
% option3_3 = uicontrol(f_feedback_task,'parent',five_option_3,'Style','radiobutton','String','3','Units','points','Position',[375 390,10,10],'visible','on');
% option4_3 = uicontrol(f_feedback_task,'parent',five_option_3,'Style','radiobutton','String','4','Units','points','Position',[475 390,10,10],'visible','on');
% option5_3 = uicontrol(f_feedback_task,'parent',five_option_3,'Style','radiobutton','String','5','Units','points','Position',[575 390,10,10],'visible','on');

% text_1_3 = uicontrol(f_feedback_task,'Style','text','String','1','Units','points','fontsize',15,'Position',[190 390,15,15],'visible','on');
% text_2_3 = uicontrol(f_feedback_task,'Style','text','String','2','Units','points','fontsize',15,'Position',[290 390,15,15],'visible','on');
% text_3_3 = uicontrol(f_feedback_task,'Style','text','String','3','Units','points','fontsize',15,'Position',[390 390,15,15],'visible','on');
% text_4_3 = uicontrol(f_feedback_task,'Style','text','String','4','Units','points','fontsize',15,'Position',[490 390,15,15],'visible','on');
% text_5_3 = uicontrol(f_feedback_task,'Style','text','String','5','Units','points','fontsize',15,'Position',[590 390,15,15],'visible','on');

% Check box for question 4
% Edit by Aatif

option1_4 = uicontrol(f_feedback_task,'parent',five_option_4, ...
    'Style','radiobutton','String','1','Units','Normalized', ...
    'Position',[0.1,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]); %335

option2_4 = uicontrol(f_feedback_task,'parent',five_option_4, ...
    'Style','radiobutton','String','2','Units','Normalized', ...
    'Position',[0.1 + 0.2,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option3_4 = uicontrol(f_feedback_task,'parent',five_option_4, ...
    'Style','radiobutton','String','3','Units','Normalized', ...
    'Position',[0.1 + 0.4,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option4_4 = uicontrol(f_feedback_task,'parent',five_option_4, ...
    'Style','radiobutton','String','4','Units','Normalized', ...
    'Position',[0.1 + 0.6,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option5_4 = uicontrol(f_feedback_task,'parent',five_option_4, ...
    'Style','radiobutton','String','5','Units','Normalized', ...
    'Position',[0.1 + 0.8,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

text_1_4 = uicontrol(f_feedback_task,'Style','text','String','1', ...
    'Units','points','fontsize',15,'Position',[127 575 - 311,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_2_4 = uicontrol(f_feedback_task,'Style','text','String','2','Units', ...
    'points','fontsize',15,'Position',[127+130 573-311,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_3_4 = uicontrol(f_feedback_task,'Style','text','String','3', ...
    'Units','points','fontsize',15,'Position',[388 573-311,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_4_4 = uicontrol(f_feedback_task,'Style','text','String','4', ...
    'Units','points','fontsize',15,'Position',[517 573-311,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_5_4 = uicontrol(f_feedback_task,'Style','text','String','5', ...
    'Units','points','fontsize',15,'Position',[649 573-311,15,15],'visible','on','backgroundcolor',[1 1 1]);


% old
% option1_4 = uicontrol(f_feedback_task,'parent',five_option_4,'Style','radiobutton','String','1','Units','points','Position',[175 290,10,10],'visible','on'); %335
% option2_4 = uicontrol(f_feedback_task,'parent',five_option_4,'Style','radiobutton','String','2','Units','points','Position',[275 290,10,10],'visible','on');
% option3_4 = uicontrol(f_feedback_task,'parent',five_option_4,'Style','radiobutton','String','3','Units','points','Position',[375 290,10,10],'visible','on');
% option4_4 = uicontrol(f_feedback_task,'parent',five_option_4,'Style','radiobutton','String','4','Units','points','Position',[475 290,10,10],'visible','on');
% option5_4 = uicontrol(f_feedback_task,'parent',five_option_4,'Style','radiobutton','String','5','Units','points','Position',[575 290,10,10],'visible','on');
% 
% text_1_4 = uicontrol(f_feedback_task,'Style','text','String','1','Units','points','fontsize',15,'Position',[190 290,15,15],'visible','on');
% text_2_4 = uicontrol(f_feedback_task,'Style','text','String','2','Units','points','fontsize',15,'Position',[290 290,15,15],'visible','on');
% text_3_4 = uicontrol(f_feedback_task,'Style','text','String','3','Units','points','fontsize',15,'Position',[390 290,15,15],'visible','on');
% text_4_4 = uicontrol(f_feedback_task,'Style','text','String','4','Units','points','fontsize',15,'Position',[490 290,15,15],'visible','on');
% text_5_4 = uicontrol(f_feedback_task,'Style','text','String','5','Units','points','fontsize',15,'Position',[590 290,15,15],'visible','on');

% Check box for question 5
% Edit by Aatif
option1_5 = uicontrol(f_feedback_task,'parent',five_option_5, ...
    'Style','radiobutton','String','1','Units','Normalized', ...
    'Position',[0.1,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]); %335

option2_5 = uicontrol(f_feedback_task,'parent',five_option_5, ...
    'Style','radiobutton','String','2','Units','Normalized', ...
    'Position',[0.1 + 0.2,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option3_5 = uicontrol(f_feedback_task,'parent',five_option_5, ...
    'Style','radiobutton','String','3','Units','Normalized', ...
    'Position',[0.1 + 0.4,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option4_5 = uicontrol(f_feedback_task,'parent',five_option_5, ...
    'Style','radiobutton','String','4','Units','Normalized', ...
    'Position',[0.1 + 0.6,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

option5_5 = uicontrol(f_feedback_task,'parent',five_option_5, ...
    'Style','radiobutton','String','5','Units','Normalized', ...
    'Position',[0.1 + 0.8,  0.2, 0.5,0.5],'visible','on','backgroundcolor',[1 1 1]);

text_1_5 = uicontrol(f_feedback_task,'Style','text','String','1', ...
    'Units','points','fontsize',15,'Position',[127 575 - 413,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_2_5 = uicontrol(f_feedback_task,'Style','text','String','2','Units', ...
    'points','fontsize',15,'Position',[127+130 573-413,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_3_5 = uicontrol(f_feedback_task,'Style','text','String','3', ...
    'Units','points','fontsize',15,'Position',[388 573-413,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_4_5 = uicontrol(f_feedback_task,'Style','text','String','4', ...
    'Units','points','fontsize',15,'Position',[517 573-413,15,15],'visible','on','backgroundcolor',[1 1 1]);

text_5_5 = uicontrol(f_feedback_task,'Style','text','String','5', ...
    'Units','points','fontsize',15,'Position',[649 573-413,15,15],'visible','on','backgroundcolor',[1 1 1]);



% old version
% option1_5 = uicontrol(f_feedback_task,'parent',five_option_5,'Style','radiobutton','String','1','Units','points','Position',[175 190,10,10],'visible','on'); %335
% option2_5 = uicontrol(f_feedback_task,'parent',five_option_5,'Style','radiobutton','String','2','Units','points','Position',[275 190,10,10],'visible','on');
% option3_5 = uicontrol(f_feedback_task,'parent',five_option_5,'Style','radiobutton','String','3','Units','points','Position',[375 190,10,10],'visible','on');
% option4_5 = uicontrol(f_feedback_task,'parent',five_option_5,'Style','radiobutton','String','4','Units','points','Position',[475 190,10,10],'visible','on');
% option5_5 = uicontrol(f_feedback_task,'parent',five_option_5,'Style','radiobutton','String','5','Units','points','Position',[575 190,10,10],'visible','on');
% 
% text_1_5 = uicontrol(f_feedback_task,'Style','text','String','1','Units','points','fontsize',15,'Position',[190 190,15,15],'visible','on');
% text_2_5 = uicontrol(f_feedback_task,'Style','text','String','2','Units','points','fontsize',15,'Position',[290 190,15,15],'visible','on');
% text_3_5 = uicontrol(f_feedback_task,'Style','text','String','3','Units','points','fontsize',15,'Position',[390 190,15,15],'visible','on');
% text_4_5 = uicontrol(f_feedback_task,'Style','text','String','4','Units','points','fontsize',15,'Position',[490 190,15,15],'visible','on');
% text_5_5 = uicontrol(f_feedback_task,'Style','text','String','5','Units','points','fontsize',15,'Position',[590 190,15,15],'visible','on');



% Check box for question 1
% task_check5 = uicontrol(f_feedback_task,'Style','checkbox','backgroundcolor',buttonColor,'Units','points','Position',[305+170+240 425,10,10],'Callback',@c5,'visible','on');

next_box = uicontrol(f_feedback_task,'Style','pushbutton','Units','points','Position',[725,20,100,25],'String','Submit','fontsize',15,'visible','on','Callback',@feed_ques_next);

% for new question 
uncheck_all


    function five_option_callback_1(source,eventdata)
        queans1= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        if flag==1
            set(text_submit,'visible','off');
        end
    end

    function five_option_callback_2(source,eventdata)
        queans2= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        if flag==1
            set(text_submit,'visible','off');
        end
    end
    function five_option_callback_3(source,eventdata)
        queans3= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        if flag==1
            set(text_submit,'visible','off');
        end
    end
    function five_option_callback_4(source,eventdata)
        queans4= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        if flag==1
            set(text_submit,'visible','off');
        end
    end
    function five_option_callback_5(source,eventdata)
        queans5= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        if flag==1
            set(text_submit,'visible','off');
        end
    end



    function uncheck_all(varargin)
            for i = 1:5
                    eval(sprintf('set(option%d_1,''Value'',0);',i));
                    eval(sprintf('set(option%d_2,''Value'',0);',i));
                    eval(sprintf('set(option%d_3,''Value'',0);',i));
                    eval(sprintf('set(option%d_4,''Value'',0);',i));
                    eval(sprintf('set(option%d_5,''Value'',0);',i));
            end
        queans1=[];
        queans2=[];
        queans3=[];
        queans4=[];
        queans5=[];
     end

    function [flag,ind] = check_for_next
        
        ch=[];
        ch1=[];
        ch2=[];
        ch3=[];
        ch4=[];
        ch5=[];
        
        ind=cell(5,1);
        if ~isempty(queans1)
            ind{1} = queans1;
            ch = 1;
        end
           
        if ~isempty(queans2)
            ind{2} = queans2;
            ch1 = 1;
        end
        
        if ~isempty(queans3)
            ind{3} = queans3;
            ch2 = 1;
        end
        
        if ~isempty(queans4)
            ind{4} = queans4;
            ch3 = 1;
        end
        
        
        if ~isempty(queans5)
            ind{5} = queans5;
            ch4 = 1;
        end
        
        if ~isempty(ch) && ~isempty(ch1) && ~isempty(ch2) && ~isempty(ch3) && ~isempty(ch4)
            flag = 1;
        else 
            flag = 0;
        end
        
    end


    function feed_ques_next(varargin)
        
        
        [flag,ind] = check_for_next;
        
%         flag
%         pause(2)
         if flag==1
%              time_track_count = time_track_count+1;
%              time_track_for_experiment(time_track_count) = toc(t_start_exp);
             clc;
             time_St = datestr(now);
      
            fprintf(fid_task_ques,'\n--------------------------------------------------------------\n');
           ch = 'How much physical activity was required (e.g. pushing, controlling activating etc.)?';
            temp =cell2mat(ind(1));
        fprintf(fid_task_ques,'\n%s \n %s\n\n',ch,(temp));
%         fprintf(fid_only_ans,'\n%s',temp);
        
        ch = 'How much time pressure you did you feel due to the rate or pace at which the task or element occurred?';
         temp =cell2mat(ind(2));
        fprintf(fid_task_ques,'\n%s \n %s\n\n',ch,(temp));
%        fprintf(fid_only_ans,'\n%s',temp);
       
       ch = 'How successful were you in accomplishing what you were asked to do?'; 
         temp =cell2mat(ind(3));
        fprintf(fid_task_ques,'\n%s \n %s\n\n',ch,(temp));
%         fprintf(fid_only_ans,'\n%s',temp);
       
        ch = 'How hard did you have to work (mentally or physically) to accomplish your level of performance in accomplishing these tasks?';
        temp =cell2mat(ind(4));
        fprintf(fid_task_ques,'\n%s \n %s\n\n',ch,(temp));
%         fprintf(fid_only_ans,'\n%s',temp);
       
        ch = 'How discouraged/ irritated/ stressed/ annoyed did you feel during tasks?';
        temp =cell2mat(ind(5));
        fprintf(fid_task_ques,'\n%s \n %s\n\n',ch,(temp));
%         fprintf(fid_only_ans,'\n%s',temp);
        fprintf(fid_task_ques,'\n--------------------------------------------------------------\n');
        uncheck_all
       close(f_feedback_task);
       imshow('media\images\Thanks.png');
                       

         else 
             set(text_submit,'visible','on');
        end
    end


% For next option
% Text box for question 1
% text_check5 = uicontrol(f_feedback_task,'Style','text','String','Very much','Units','points','fontsize',15,'Position',[685 440,75,30],'visible','on','backgroundcolor',[1 1 1]);
% text box for question 3
% Text box for question 2
% for question 4
% for question 5
clc

uncheck_all


end

