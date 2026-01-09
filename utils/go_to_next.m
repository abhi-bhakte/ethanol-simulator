function go_to_next

% clear all
global count_ra qa1 qa2 qa3 qa4 qa5 flag_next_to_go flag_submit_next f_next message_text go_to_scen Calib pts
f_next = figure('Visible','on','Name','Ready for Scenarios',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[330,40,940,750],'Resize','on','color',[1 1 1]);


f_message = figure('Visible','off','Name','Progress Statement',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[330,40,940,750],'Resize','off','color',.9.*[ 1 1 1]);

text_submit  = uicontrol(f_next,'Style','text','foregroundcolor',[1 0 0],'Units','points',...
    'fontsize',14,'Position',[650, 20,270,75],'visible','off','String','Give answer to each question');
flag_submit = 0;
% WindowAPI(f_next, 'Clip', true);
% set(f_next,'CloseRequestFcn',@close_go_to_next);

close_message =  uicontrol(f_next,'Visible','off','Style','text','HorizontalAlignment','left','Units','points','Position',[650,680,200,50], 'fontsize',14,'foregroundcolor',[1 0 0],'String','Give answer to each question and press Submit');

go_to_scen = uicontrol(f_message,'Style','pushbutton','Units','points','Position',[725,20,130,25],'String','run_experiment','fontsize',15,'visible','on','Callback',@go_scen,'visible','on');

message_text = uicontrol(f_message,'Style','text','Units','points',...
    'fontsize',20,'Position',[10, 325,800,175],'visible','on','backgroundcolor',.9*[1 1 1]);%'foregroundcolor',[0 0 0],

ques_text1 = uicontrol(f_next,'Style','text','String','1.Which plant are you going to operate?','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 625,800,50],'visible','on');

ques_text2 = uicontrol(f_next,'Style','text','String','2. What is direction of ethanol-water mixture flow in the plant?','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 500,800,50],'visible','on');

ques_text3 = uicontrol(f_next,'Style','text','String','3. Do we have blocking valves in this plant?','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 400,800,50],'visible','on');

ques_text4 = uicontrol(f_next,'Style','text','String','4. How many variables are configured with alarms?','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 290,800,50],'visible','on');

ques_text5 = uicontrol(f_next,'Style','text','String','5. Have you thoroughly gone through the technical handouts provided to you?','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[10, 195,800,45],'visible','on');

two_opt_1 = uibuttongroup(f_next,'visible','on');
two_opt_2 = uibuttongroup(f_next,'visible','on');
two_opt_3 = uibuttongroup(f_next,'visible','on');

three_opt_1 = uibuttongroup(f_next,'visible','on');
four_opt_1 = uibuttongroup(f_next,'visible','on');

set(two_opt_1,'SelectionChangeFcn',@two_opt_1_callback);
set(two_opt_2,'SelectionChangeFcn',@two_opt_2_callback);
set(two_opt_3,'SelectionChangeFcn',@two_opt_3_callback);
set(three_opt_1,'SelectionChangeFcn',@three_opt_1_callback);
set(four_opt_1,'SelectionChangeFcn',@four_opt_1_callback);


% For first question
task_1_1 = uicontrol(f_next,'parent',three_opt_1,'Style','radiobutton','String','Ethanol','Units','points','Position',[150+25 600,10,10],'visible','on'); 
task_1_2 = uicontrol(f_next,'parent',three_opt_1,'Style','radiobutton','String','Methanol','Units','points','Position',[350+25 600,10,10],'visible','on'); 
task_1_3 = uicontrol(f_next,'parent',three_opt_1,'Style','radiobutton','String','Buteanol','Units','points','Position',[550+25 600,10,10],'visible','on'); 

text_1_1 =  uicontrol(f_next,'Style','text','String','Ethanol','Units','points','fontsize',15,'Position',[170+25 585 55,30],'visible','on');
text_1_2 =  uicontrol(f_next,'Style','text','String','Methanol','Units','points','fontsize',15,'Position',[370+25 585 75,30],'visible','on');
text_1_3 =  uicontrol(f_next,'Style','text','String','Butanol','Units','points','fontsize',15,'Position',[570+25 585 65,30],'visible','on');


% For second question

task_2_1 = uicontrol(f_next,'parent',two_opt_1,'Style','radiobutton','String','From CSTR to Distillation Column','Units','points','Position',[150+25 475,10,10],'visible','on'); 
task_2_2 = uicontrol(f_next,'parent',two_opt_1,'Style','radiobutton','String','From Distillation Column to CSTR','Units','points','Position',[550+25 475,10,10],'visible','on'); 

text_2_1 = uicontrol(f_next,'Style','text','String','From CSTR to Distillation Column','Units','points','fontsize',15,'Position',[170+25 460 250,30],'visible','on');
text_2_2 = uicontrol(f_next,'Style','text','String','From Distillation Column to CSTR','Units','points','fontsize',15,'Position',[570+25 460,250,30],'visible','on');


% For third question 

task_3_1 = uicontrol(f_next,'parent',two_opt_2,'Style','radiobutton','String','Yes','Units','points','Position',[400 405,10,10],'visible','on'); 
task_3_2 = uicontrol(f_next,'parent',two_opt_2,'Style','radiobutton','String','No','Units','points','Position',[400 355,10,10],'visible','on'); 

text_3_1 = uicontrol(f_next,'Style','text','String','Yes','Units','points','fontsize',15,'Position',[415 390 35,30],'visible','on');
text_3_2 = uicontrol(f_next,'Style','text','String','No','Units','points','fontsize',15,'Position',[415 340 35,30],'visible','on');

% For fourth question

task_4_1 = uicontrol(f_next,'parent',four_opt_1,'Style','radiobutton','String','11','Units','points','Position',[200-75 280,10,10],'visible','on'); 
task_4_2 = uicontrol(f_next,'parent',four_opt_1,'Style','radiobutton','String','12','Units','points','Position',[400-75 280,10,10],'visible','on'); 
task_4_3 = uicontrol(f_next,'parent',four_opt_1,'Style','radiobutton','String','13','Units','points','Position',[600-75 280,10,10],'visible','on'); 
task_4_4 = uicontrol(f_next,'parent',four_opt_1,'Style','radiobutton','String','14','Units','points','Position',[800-75 280,10,10],'visible','on'); 

text_4_1 = uicontrol(f_next,'Style','text','String','11','Units','points','fontsize',15,'Position',[140 265 25,30],'visible','on');
text_4_2 = uicontrol(f_next,'Style','text','String','12','Units','points','fontsize',15,'Position',[340 265 25,30],'visible','on');
text_4_3 = uicontrol(f_next,'Style','text','String','13','Units','points','fontsize',15,'Position',[540 265 25,30],'visible','on');
text_4_4 = uicontrol(f_next,'Style','text','String','14','Units','points','fontsize',15,'Position',[740 265 25,30],'visible','on');


% For fifth question

task_5_1 = uicontrol(f_next,'parent',two_opt_3,'Style','radiobutton','String','Yes','Units','points','Position',[400 175,10,10],'visible','on'); 
task_5_2 = uicontrol(f_next,'parent',two_opt_3,'Style','radiobutton','String','No','Units','points','Position',[400 125,10,10],'visible','on'); 

text_5_1 = uicontrol(f_next,'Style','text','String','Yes','Units','points','fontsize',15,'Position',[415 160 35,30],'visible','on');
text_5_2 = uicontrol(f_next,'Style','text','String','No','Units','points','fontsize',15,'Position',[415 110 35,30],'visible','on');

uncheck_all
% Submit Button

next_box = uicontrol(f_next,'Style','pushbutton','Units','points','Position',[725,20,100,25],'String','Submit','fontsize',15,'visible','on','Callback',@submit_next);

run_train_video = uicontrol(f_message,'Style','pushbutton','Units','points','Position',[125,20,100,25],'String','View Video','fontsize',15,'visible','on','Callback',@run_video_call);

function three_opt_1_callback(source,eventdata)
    
        qa1= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        
        if flag==1
            set(text_submit,'visible','off');
        end
        
    end
function two_opt_1_callback(source,eventdata)
    
        qa2= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        
        if flag==1
            set(text_submit,'visible','off');
        end
        
    end
function two_opt_2_callback(source,eventdata)
    
        qa3= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        
        if flag==1
            set(text_submit,'visible','off');
        end
        
    end
function four_opt_1_callback(source,eventdata)
    
        qa4= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        
        if flag==1
            set(text_submit,'visible','off');
        end
        
    end

function two_opt_3_callback(source,eventdata)
    
        qa5= get(eventdata.NewValue,'String');
        [flag,ind] = check_for_next;
        
        if flag==1
            set(text_submit,'visible','off');
        end
        
    end

function [flag,ind] = check_for_next
    flag = 0;
        count_ra = 0;
        ch=[];
        ch1=[];
        ch2=[];
        ch3=[];
        ch4=[];
        
        
        ind=cell(5,1);
        if ~isempty(qa1)
            ind{1} = qa1;
            ch = 1;
        end
           
        if ~isempty(qa2)
            ind{2} = qa2;
            ch1 = 1;
        end
        
        if ~isempty(qa3)
            ind{3} = qa3;
            ch2 = 1;
        end
        
        if ~isempty(qa4)
            ind{4} = qa4;
            ch3 = 1;
        end
        
        
        if ~isempty(qa5)
            ind{5} = qa5;
            ch4 = 1;
        end
        
      
        
        if ~isempty(ch) && ~isempty(ch1) && ~isempty(ch2) && ~isempty(ch3) && ~isempty(ch4) 
            flag = 1;
        else 
            flag = 0;
        end
        
end


    function submit_next(varargin)
        flag_submit_next = 0;
        [flag,ind] = check_for_next;
        
        if flag==1
            flag_submit_next = 1;
          
            if isequal(qa1,'Ethanol')
                count_ra = count_ra + 1;
            end
            
            if isequal(qa2,'From CSTR to Distillation Column')
                count_ra = count_ra + 1;
            end
            
             if isequal(qa3,'Yes')
                count_ra = count_ra + 1;
             end
            
            if isequal(qa4,'11')
                count_ra = count_ra + 1;
            end
            
            if isequal(qa5,'Yes')
                count_ra = count_ra + 1;
            end
            
              close(f_next);
        set(f_message,'visible','on');
        
        if count_ra>=4 && count_ra<=5
                        
                        flag_next_to_go = 1;
        else
            flag_next_to_go = 0;
            
        end
        
        if flag_next_to_go==1
            set(message_text,'String','Press Start Experiment button to start.');
            set(go_to_scen,'String','Start Experiment');
            set(run_train_video,'visible','off');
            
        else 
            set(message_text,'String','Please go through handouts once again.  If you want to see the video again press View Video button. After finishing video press Restart Quiz button in order to give the test again.');
        
           set(go_to_scen,'String','Restart Quiz');
            end
        
        else % if submit button clicked without giving answer to all questions
       set(text_submit,'visible','on');
        end
        
        
        
        
    end




function uncheck_all(varargin)
    for iii = 1:3
            
            eval(sprintf('set(task_1_%d,''Value'',0);',iii));
            
    end
    for iii = 1:2
            
            eval(sprintf('set(task_2_%d,''Value'',0);',iii));
            
    end
        for iii = 1:2
            
            eval(sprintf('set(task_3_%d,''Value'',0);',iii));
            
        end
        for iii = 1:4
            
            eval(sprintf('set(task_4_%d,''Value'',0);',iii));
            
        end
        
        for iii = 1:2
            
            eval(sprintf('set(task_5_%d,''Value'',0);',iii));
            
        end
        
   
        
end

    function go_scen(varargin)
        if flag_next_to_go==1
            close(f_message);
            run_experiment
        else
            close(f_message);
            go_to_next
            
        
        end
    end

    function close_go_to_next(varargin)
       
       if flag_submit_next == 1
             close(f_next);
       else
           set(close_message,'visible','on');
           pause(2)
           set(close_message,'visible','off');
       end
        
    end

    function run_video_call(varargin)
        winopen('media\video\Video_Final.mp4');
    end


end
