function [status,hi_lo] = check_alarm_limit(time_current)

global flag_for_alarm alarm_status tic_start 
global date_vec time_vec
global alarm_text alarm_upper_limit alarm_lower_limit  number_var_alarms alarm_var_store x_temp5
global task_no_current  % Track current task number for conditional display

x_temp5 = toc(tic_start); 
status = zeros(number_var_alarms,1);

for i = 1:number_var_alarms
    hi_lo(i,:) = ['NN NN'];
end

for i = 1: number_var_alarms
    
    if alarm_var_store(i,time_current) > alarm_upper_limit(i)
        status(i) = 1; % i.e. above threshold

        hi_lo(i,:) = 'PV HI';
        
    else if alarm_var_store(i,time_current) < alarm_lower_limit(i)
            status(i) = 1;

            hi_lo(i,:) = 'PV LO';
        
        else
            flag_for_alarm(i)=0;
            status(i) = 0;
            alarm_status(i) = 0;
        end
    
    end
end

 for p = 1 : number_var_alarms
        
        if status(p) == 1 && flag_for_alarm(p)==0 % presence of alarm and we need it in alarm table
            flag_for_alarm(p) = 1;  % use flag very carefully
            %time_vec(p,1:20) = datestr(now)
            date_vec(p,:) = datevec(now);
            
        end
    end
    
    ob = find(status(:)==1);
    date_vec;
    get_date = date_vec(ob,:);
    [get_date, acend_index] = ascend_alarms(get_date,ob);
    hi_lo = hi_lo(acend_index,:);
    
    % Always show actual alarm data in table
    for u = 1:length(acend_index)
        set(alarm_text{u,1},'String',datestr(get_date(u,:)),'foregroundcolor',[0 0 0],'fontangle','normal','fontweight','bold');
        [get_loc,res] = get_location(acend_index(u));
        set(alarm_text{u,2},'String',get_loc,'foregroundcolor',[0 0 0],'fontangle','normal','fontweight','bold');
        set(alarm_text{u,3},'String',hi_lo(u,:),'foregroundcolor',[0 0 0],'fontangle','normal','fontweight','bold');
        set(alarm_text{u,4},'String',res,'foregroundcolor',[0 0 0],'fontangle','normal','fontweight','bold');
    end
    cvv = .9.*[1 1 1];
    for  u = length(acend_index)+1 : 10
        set(alarm_text{u,1},'String','A','foregroundcolor',cvv,'fontangle','normal','fontweight','bold');
        set(alarm_text{u,2},'String','A','foregroundcolor',cvv,'fontangle','normal','fontweight','bold');
        set(alarm_text{u,3},'String','A','foregroundcolor',cvv,'fontangle','normal','fontweight','bold');
        set(alarm_text{u,4},'String','A','foregroundcolor',cvv,'fontangle','normal','fontweight','bold');
    end

    alarm_beep(acend_index,time_current); 
end
