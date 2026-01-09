function feedback_form_combined
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

clc;

global count
global question_list f_feedback fid_feed edit_box
f_feedback = figure('Visible','on','Name','Final Feedback Form',...
    'Menubar','none','Toolbar','none', 'Units', 'points','NumberTitle','off',...
    'Position',[330,170,630,515],'Resize','off','color',[1 1 1]);  %400,250,550,515


ques_text = uicontrol(f_feedback,'Style','text','String','AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA','foregroundcolor',[0 0 0],'Units','points',...
    'fontsize',15,'Position',[20, 325,520,60],'visible','off');

fid_feed = fopen('data\text-logs\feedback_gui.txt','at+');
fprintf(fid_feed,'\n-------------------------------------------------------------------------------------------');
fprintf(fid_feed,'\n--------------------------Feedback form for whole experiment-------------------------------');




%% objective answer check

buttonColor = [ 1 1 1];

%% uibuttongroup(radio button) for 5 question 
check_button = uibuttongroup(f_feedback,'visible','off');
set(check_button,'SelectionChangeFcn',@status_check_box);


check1 = uicontrol(f_feedback,'Style','radiobutton','parent',check_button,'Units','points','Position',[75 225,10,10],'visible','on','HandleVisibility','off','String','Not at all');
check2 = uicontrol(f_feedback,'Style','radiobutton','parent',check_button,'Units','points','Position',[155+50 225,10,10],'visible','on','HandleVisibility','off','String','Not at all');
check3 = uicontrol(f_feedback,'Style','radiobutton','parent',check_button,'Units','points','Position',[225+90 225,10,10],'visible','on','HandleVisibility','off','String','Not at all');
check4 = uicontrol(f_feedback,'Style','radiobutton','parent',check_button,'Units','points','Position',[315+130 225,10,10],'visible','on','HandleVisibility','off','String','Not at all');
check5 = uicontrol(f_feedback,'Style','radiobutton','parent',check_button,'Units','points','Position',[285+170 225,10,10],'visible','off','HandleVisibility','off','String','Not at all');

%% Objective text

text1 = uicontrol(f_feedback,'Style','text','String','AAAAAAAAAAAAAAAA','Units','points','fontsize',15,'Position',[45 250,85,35],'visible','off');
text2 = uicontrol(f_feedback,'Style','text','String','AAAAAAAAAAAAAAAA','Units','points','fontsize',15,'Position',[175 250,85,35],'visible','off');
text3 = uicontrol(f_feedback,'Style','text','String','AAAAAAAAAAAAAAAA','Units','points','fontsize',15,'Position',[285 250,85,35],'visible','off');
text4 = uicontrol(f_feedback,'Style','text','String','AAAAAAAAAAAAAAAA','Units','points','fontsize',15,'Position',[400 250,95,35],'visible','off');
text5 = uicontrol(f_feedback,'Style','text','String','AAAAAAAAAAAAAAAA','Units','points','fontsize',15,'Position',[500 250,100,35],'visible','off');

%% For Yes No check
yn_button = uibuttongroup(f_feedback,'visible','off');
set(yn_button,'SelectionChangeFcn',@status_yn_box);
yn1 = uicontrol(f_feedback,'Style','radiobutton','parent',yn_button,'String','Yes','Units','points','Position',[250 250,10,10],'visible','on','HandleVisibility','off');
yn2 = uicontrol(f_feedback,'Style','radiobutton','parent',yn_button,'String','No','Units','points','Position',[250 200,10,10],'visible','on','HandleVisibility','off');

yntext1 = uicontrol(f_feedback,'Style','text','String','Yes','Units','points','fontsize',15,'Position',[270 250,45,15],'visible','off');
yntext2 = uicontrol(f_feedback,'Style','text','String','No','Units','points','fontsize',15,'Position',[270 200,45,15],'visible','off');


clc;

%% For next question

next_box = uicontrol(f_feedback,'Style','pushbutton','Units','points','Position',[305+100,75,70,20],'String','Next','fontsize',12,'FontWeight','bold','visible','off','Callback',@nextboxcall);


start_box = uicontrol(f_feedback,'Style','pushbutton','String','Start','Units','points','fontsize',12,'Position',[225 250,75,30],'visible','on','Callback',@nextboxcall);

submit_button = uicontrol(f_feedback,'Style','pushbutton','String','Submit','Units','points','Position',[305+100,75,70,20],'fontsize',12,'FontWeight','bold','visible','off','Callback',@submitboxcall);

edit_box = uicontrol(f_feedback,'Style','edit','Units','points','Position',[25 250 475 25],'visible','off','Min',2,'Max',5);

question_list= {'1. Have you learnt about CSTR process previously in your curriculum?',...
                '2. Rate yourself on the process knowledge of CSTR process.',...
                '3. Have you learnt about Distillation Column process previously in your curriculum?',...
                '4. Rate yourself on the process knowledge of Distillation column.',...
                '5. Have you come across this type of Simulator before for controlling a process plant?',...
                '6. How much was alarm summary panel helpful for you in diagnosis of abnormal plant?',...
                '7. How much was alarm summary panel helpful for you to locate the disturbed variables?',...
                '8. Rate the amount of information provided to you during whole experiment.',...
                '9. How much relevant was the information on schematic display in diagnosis of plant.',...
                '10. How much relevant was the information on alarm summary panel in diagnosis of plant.',...
                '11. Give Comments on improvement of this setup. You can also share views by which diagnosis can be done more swiftly and correctly.'...
                };
                %                 'How much confident do you feel now regarding controlling of such disturbed plant?'...
%                 'Write order of prefrence depending upon usefulness you experienced during this whole experiment  1. Alarm Summary 2. Process Variable Trend 3. Apriori Process Knowledge. for example write 132'...

%%
% First question

count = 0;

%==========================================================================
%==========================================================================

    function make_check_box_off
        set(check_button,'visible','off');
        for iii = 1:1:5
           % eval(sprintf('set(check%d,''visible'',''off'');',iii));
            eval(sprintf('set(text%d,''visible'',''off'');',iii));
        end
        
        
    end



    function make_check_box_on
       set(check_button,'visible','on');
        for iii = 1:1:5
%             eval(sprintf('set(check%d,''visible'',''on'');',iii));
            eval(sprintf('set(text%d,''visible'',''on'');',iii));
        end
    end

    function make_yn_off
        set(yn_button,'visible','off');
        for iii = 1:2
            eval(sprintf('set(yntext%d,''visible'',''off'');',iii));
%             eval(sprintf('set(yn%d,''visible'',''off'');',iii));
            
        end
    end


    function make_yn_on
        set(yn_button,'visible','on');
        for iii = 1:2
            eval(sprintf('set(yntext%d,''visible'',''on'');',iii));
%             eval(sprintf('set(yn%d,''visible'',''on'');',iii));
            
        end
    end


    function status_check_box(source,eventdata)
        set(next_box,'Enable','on');
        
        %     source
        %     eventdata
        %      disp(  get(eventdata.NewValue,'String'));
        ch = get(eventdata.NewValue,'String');
        fprintf(fid_feed,'\n %s \n',ch);
    end

    function status_yn_box(source,eventdata)
        set(next_box,'Enable','on');
        
        ch = get(eventdata.NewValue,'String');
        fprintf(fid_feed,'\n %s \n',ch);
        %  disp(  get(eventdata.NewValue,'String'));
        
    end

    function uncheck_all(varargin)
    for iii = 1:5
            
            eval(sprintf('set(check%d,''Value'',0);',iii));
            
    end
        for iii = 1:2
            
            eval(sprintf('set(yn%d,''Value'',0);',iii));
            
        end
    end
        

    function submitboxcall(varargin)
        
        count = count + 1;
        ch = get(edit_box,'String');
        set(edit_box,'visible','off');
        fprintf(fid_feed,'\n%s',ch);
        set(ques_text,'visible','off');
        make_check_box_off
        set(submit_button,'visible','off');
        b = axes('Parent',f_feedback,'HandleVisibility','callback','NextPlot','replacechildren', 'Units','points', 'Position',[-380 -30 1387 528]);
        imshow('Thanks.jpg','Parent',b);
    fclose(fid_feed);
    pause(2)
    close(f_feedback);
    
    end

    

    function nextboxcall(varargin)
        
         count = count + 1;
        
         
    if count==1
         uncheck_all
        fprintf(fid_feed,'\n--------------------------------------Question 1 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(1)));
          set(next_box,'Enable','inactive');
           set(next_box,'Userdata',0);
            set(next_box,'visible','on');
           set(ques_text,'visible','on','position',[20, 425,520,60]);
           set(start_box,'visible','off');
           make_check_box_off
         make_yn_on;
        set(ques_text,'String',question_list(count));
        set(yn1,'position',[250 440,10,10]);
        set(yn2,'position',[250 400,10,10]);
        set(yntext1,'Position',[270 440,45,15]);
        set(yntext2,'Position',[270 400,45,15]);
        fprintf(fid_feed,'\n--------------------------------------Question 2 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(2)));
        make_check_box_on
       set(ques_text,'String',question_list(2),'position',[20 320 520 60]); 
               set(text1,'String','Poor');
             set(text2,'String','Moderate');
             set(text3,'String','Good');
             set(text4,'String','Excellent');
             set(text5,'visible','off','String','Outstanding');
             
             set(check1,'String','Poor');
             set(check2,'String','Moderate');
             set(check3,'String','Good');
             set(check4,'String','Excellent');
             set(check5,'String','Outstanding');
    end
         
         if count==2
            uncheck_all
            
            set(next_box,'Enable','inactive');
        
        fprintf(fid_feed,'\n--------------------------------------Question 2 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
             make_check_box_on
             make_yn_off
             set(ques_text,'String',question_list(count));
             set(text1,'String','Poor');
             set(text2,'String','Moderate');
             set(text3,'String','Good');
             set(text4,'String','Excellent');
             set(text5,'visible','off','String','Outstanding');
             
             set(check1,'String','Poor');
             set(check2,'String','Moderate');
             set(check3,'String','Good');
             set(check4,'String','Excellent');
             set(check5,'String','Outstanding');
              
         end
         
         
         
         if count==3
            uncheck_all
             fprintf(fid_feed,'\n--------------------------------------Question 3 --------------------------------------\n');
             fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
             set(next_box,'Enable','inactive');
             make_check_box_off
             make_yn_on
             set(ques_text,'String',question_list(count));
         end
        
         if count==4
             uncheck_all
              fprintf(fid_feed,'\n--------------------------------------Question 4 --------------------------------------\n');
             fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
        
             set(next_box,'Enable','inactive');
             make_check_box_on
             make_yn_off
             set(ques_text,'String',question_list(count));
            set(text1,'String','Poor');
             set(text2,'String','Moderate');
             set(text3,'String','Good');
             set(text4,'String','Excellent');
             set(text5,'visible','off','String','Outstanding');
             
             set(check1,'String','Poor');
             set(check2,'String','Moderate');
             set(check3,'String','Good');
             set(check4,'String','Excellent');
             set(check5,'String','Outstanding');
              
         end
         
         
         if count==5   
             uncheck_all
              fprintf(fid_feed,'\n--------------------------------------Question 5 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
             set(next_box,'Enable','inactive');
             make_check_box_off
             make_yn_on
             set(ques_text,'String',question_list(count));
         end
         
         if count==6
             uncheck_all
             fprintf(fid_feed,'\n--------------------------------------Question 6 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
             set(next_box,'Enable','inactive');
             make_check_box_on
             make_yn_off
             set(ques_text,'String',question_list(count));
             set(text1,'String','Not at all');
             set(text2,'String','A little bit');
             set(text3,'String','Average');
             set(text4,'String','Fairly good');
             set(text5,'visible','off','String','Very much');
             
             set(check1,'String','Not at all');
             set(check2,'String','A little bit');
             set(check3,'String','Average');
             set(check4,'String','Fairly good');
             set(check5,'String','Very much');
              
         end
         
         if count==7
             uncheck_all
              fprintf(fid_feed,'\n--------------------------------------Question 7 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
             set(next_box,'Enable','inactive');
             make_check_box_on
             make_yn_off
             set(ques_text,'String',question_list(count));
             set(text1,'String','Not at all');
             set(text2,'String','A little bit');
             set(text3,'String','Moderate');
             set(text4,'String','Fairly good');
             set(text5,'visible','off','String','Very much');
             
             set(check1,'String','Not at all');
             set(check2,'String','A little bit');
             set(check3,'String','Average');
             set(check4,'String','Fairly good');
             set(check5,'String','Very much');
              
             
             
         end
         
         if count==8
              uncheck_all
              fprintf(fid_feed,'\n--------------------------------------Question 8 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
             set(next_box,'Enable','inactive');
         make_check_box_on
             make_yn_off
             set(ques_text,'String',question_list(count));
             set(text1,'String','No information');
             set(text2,'String','Very little');
             set(text3,'String','Moderate');
             set(text4,'String','Overwhelming');
             set(text5,'visible','off','String','Overwhelming');
             
             set(check1,'String','No information');
             set(check2,'String','Very little');
             set(check3,'String','Moderate');
             set(check4,'String','Overwhelming');
             set(check5,'String','Overwhelming');
              
         end
         
         if count==9
             uncheck_all
              fprintf(fid_feed,'\n--------------------------------------Question 9 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
             set(next_box,'Enable','inactive');
              make_check_box_on
             make_yn_off
             set(ques_text,'String',question_list(count));
          set(text1,'String','Not at all');
             set(text2,'String','Very little');
             set(text3,'String','Average');
             set(text4,'String','Fairly relevant');
             set(text5,'visible','off','String','Very much');
             
             
             
             
             set(check1,'String','Not at all');
             set(check2,'String','Very little');
             set(check3,'String','Average');
             set(check4,'String','Fairly relevant');
             set(check5,'String','Very much');
              
         end
         
          if count==10
               uncheck_all
               fprintf(fid_feed,'\n--------------------------------------Question 10 --------------------------------------\n');
        fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
              set(next_box,'Enable','inactive');
              make_check_box_on
             make_yn_off
             set(ques_text,'String',question_list(count));
          set(text1,'String','Not at all');
             set(text2,'String','Very little');
             set(text3,'String','Average');
             set(text4,'String','Fairly relevant');
             set(text5,'visible','off','String','Very much');
             
             set(check1,'String','Not at all');
             set(check2,'String','Very little');
             set(check3,'String','Average');
             set(check4,'String','Fairly relevant');
             set(check5,'String','Very much');
          end
         
%           if count==11
%                uncheck_all
%                fprintf(fid_feed,'\n--------------------------------------Question 11 --------------------------------------\n');
%         fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
%               set(next_box,'Enable','inactive');
%               make_check_box_on
%              make_yn_off
%               
%              set(ques_text,'String',question_list(count));
%           set(text1,'String','Not at all');
%              set(text2,'String','Very little');
%              set(text3,'String','Average');
%              set(text4,'String','Above Average');
%              set(text5,'visible','off','String','Very much');
%              
%              set(check1,'String','Not at all');
%              set(check2,'String','Very little');
%              set(check3,'String','Average');
%              set(check4,'String','Fairly relevant');
%              set(check5,'String','Very much');
%             
%              
%              
%              
%              
%           end
         
%          if count==12
%              uncheck_all
%               fprintf(fid_feed,'\n--------------------------------------Question 12 --------------------------------------\n');
%         fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
%               make_check_box_off
%             set(edit_box,'visible','on');
%             set(ques_text,'String',question_list(count));
%           end
         
          
          
          if count==11
              uncheck_all
      ch = get(edit_box,'String');
      fprintf(fid_feed,'\n %s',ch);
       fprintf(fid_feed,'\n--------------------------------------Question 11 --------------------------------------\n');
               fprintf(fid_feed,'\n %s ',cell2mat(question_list(count)));
              make_check_box_off
               make_yn_off
               set(edit_box,'visible','on');
		set(edit_box,'String','                      ');
              set(next_box,'visible','off');
             set(submit_button,'visible','on');
             set(ques_text,'String',question_list(count));
          end
        
 end 
end

