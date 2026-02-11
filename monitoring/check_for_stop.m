function check_for_stop(current_time_index,task_no,fault_no_list,fault_no)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global f f2 fid fid_click esd_box fid_mouse_move  time_track_count time_track_for_experiment t_start_exp index_for_scenario time_for_process_var slider_var_store
global trackerId timeStampAll leftEyeAll rightEyeAll 

global Ts ans_29  time_start_first count_completed alarm_upper_limit alarm_lower_limit alarm_var_store number_var_alarms
global no_of_tasks task_complete_flag es_flag

current_time_index ;
% critic_with_noise is for flow rate from cstr to distillation column

N = 10; % number of past indexs needs to be checked in order to identify variable within its limits


flag = zeros(number_var_alarms,1);




for k = 1:number_var_alarms
if all(alarm_var_store(k,current_time_index:-1:current_time_index-N) < alarm_upper_limit(k)) && all(alarm_var_store(k,current_time_index:-1:current_time_index-N) > alarm_lower_limit(k))
    flag(k) = 1;
end
end

if all(flag == 1)
    task_complete_flag = 1;
    es_flag = 1;
% TrackStop   
time_track_count = time_track_count+1;
time_track_for_experiment(time_track_count) = toc(t_start_exp);
% fprintf(fid,'STOP TIME = %s \n',datestr(clock,'dd-mm-yyyy HH:MM:SS FFF')); 
% fprintf(fid,'Scenario Completed. \n');
    count_completed = count_completed + 1;
     set(ans_29,'visible','on','fontweight','bold','String','Scenario Completed!!!');
    [y,fs] = audioread('media\audio\scenario_completed_message.wav');
    sound(y,fs);
   
    set(esd_box,'visible','off');
     te = toc(t_start_exp);
    fprintf(fid_click,'%d     %.6f  %.2f   %.2f    %d   %s %.2f \n',floor(te),(te-floor(te)),0,0,0,'Scenario_Completed',0000);
    pause(1)
    
%  [a_a b_a c_a ] = textread('alarm_timing.txt','%s %s %s','whitespace',' ','bufsize',10000);
%         ty = time_start_first;
%         ty([12 15 18]) = '_';
%         if ~isempty(a_a) && ~isempty(b_a) && ~isempty(c_a) 
%             eval(sprintf('xlswrite(''Alarm_timing_%s.xlsx'',[a_a b_a c_a],%d);',ty,task_no));
%             
%         end
       
        [a_c b_c c_c d_c e_c f_c g_c] = textread('data\text-logs\Mouse_click.txt','%s %s %s %s %s %s %s','whitespace',' ','bufsize',10000);
        ty = time_start_first;
        ty([12 15 18]) = '_';
        global id_num;
        if ~isempty(a_c) && ~isempty(b_c) && ~isempty(c_c) && ~isempty(d_c) && ~isempty(e_c) && ~isempty(f_c) && ~isempty(g_c)
            eval(sprintf('xlswrite(''data\\excel-outputs\\Mouse_click_%s_%s.xlsx'',[a_c b_c c_c d_c e_c f_c g_c],%d);',id_num,ty,task_no));
        end
        
        fclose(fid_click);
 %-------------------alarm timing---------------------------------
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
        fclose(fid_mouse_move);
        
        pause(0.5);
        clc
        time_track_count = time_track_count+1;  % for start of feeedback form 
        time_track_for_experiment(time_track_count) = toc(t_start_exp);

end


end

    
    
    
    
    


