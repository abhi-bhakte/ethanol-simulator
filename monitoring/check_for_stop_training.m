function check_for_stop_training(current_time_index,task_training_no)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global varTrend trendPanel f f2 fid fid_alarm_timing fid_click esd_box fid_mouse_move


global Ts ans_29  time_start_first count_completed alarm_upper_limit alarm_lower_limit alarm_var_store number_var_alarms

% current_time_index = current_time/Ts;
% critic_with_noise is for flow rate from cstr to distillation column

N = 20; % number of past indexs needs to be checked in order to identify variable within its limits


flag = zeros(number_var_alarms,1);




for k = 1:number_var_alarms
if all(alarm_var_store(k,current_time_index:-1:current_time_index-N)<alarm_upper_limit(k)) && all(alarm_var_store(k,current_time_index:-1:current_time_index-N)>alarm_lower_limit(k))
    flag(k) = 1;
end



if all(flag==1)
% TrackStop   
% fprintf(fid,'STOP TIME = %s \n',datestr(clock,'dd-mm-yyyy HH:MM:SS FFF')); 
% 
    count_completed = count_completed + 1;
%     
%     [y,fs] = wavread('scenario_completed_message.wav');
%     sound(y,fs);
    set(ans_29,'visible','on','fontweight','bold','String','Task Completed!!!');
    set(esd_box,'visible','off');
%     
    pause(4)
%     [a_a b_a c_a f_a] = textread('alarm_timing.txt','%s %s %s %s','whitespace',' ','bufsize',10000);
%         ty = time_start_first;
%        ty([12 15 18]) = '_'; 
%        if ~isempty(a_a) && ~isempty(b_a) && ~isempty(c_a) && ~isempty(f_a)
%        eval(sprintf('xlswrite(''Alarm_timing_%s.xlsx'',[a_a b_a c_a f_a],%d);',ty,fault_no));
%        
%        [a_c b_c c_c d_c e_c f_c] = textread('Mouse_click.txt','%s %s %s %s %s %s','whitespace',' ','bufsize',10000);
%         ty = time_start_first;
%        ty([12 15 18]) = '_'; 
%        if ~isempty(a_c) && ~isempty(b_c) && ~isempty(c_c) && ~isempty(d_c) && ~isempty(e_c) && ~isempty(f_c)
%        eval(sprintf('xlswrite(''Mouse_click_%s.xlsx'',[a_c b_c c_c d_c e_c f_c],%d);',ty,fault_no));
%                 
%        end
%                
%        end
        close(f)
        close (f2)
%          fclose(fid_mouse_move);
%         fclose(fid);
%        
%         fprintf('\n==========================================================================================');
% 
%         fclose(fid_click);
       


%         feedback_per_task(task_no,fault_no_list,fault_no);
    task_training_no = task_training_no + 1;
    making_ready_for(task_training_no);
    
end
    
    
    
    
    

end

