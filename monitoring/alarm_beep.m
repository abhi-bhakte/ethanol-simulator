function alarm_beep(acend_index,time_current)


global  alarm_status alarm_var_store
global alarm_upper_limit alarm_lower_limit t_start_exp toc_for_alarm_database_lower toc_for_alarm_database_upper

% var_with_alarms = [Flow_inlet_with_noise mKf_with_noise thetaKin_with_noise-273.15 x_with_noise(4)-273.15 F_with_noise*1.129623 Tout_current_with_noise(3) Tout_current_with_noise(5) Tout_current_with_noise(8) x_with_noise(3)-273.15 x_with_noise(2).*1e3 cstr_level_with_noise ];
for i = 1 :length(acend_index)
    
    p = acend_index(i);
    
%     if var_with_alarms(p) > alarm_upper_limit(p) && alarm_status(p)==0
%         alarm_status(p)=1;
%         upper_tone;
%     else
%         if var_with_alarms(p) < alarm_lower_limit(p) && alarm_status(p) ==0
%             alarm_status(p)=1;
%             lower_tone;
%         end
%     end
%     
    
    
    
    if alarm_var_store(p,time_current) > alarm_upper_limit(p) && alarm_status(p)==0
        alarm_status(p)=1;
        toc_for_alarm_database_upper =toc(t_start_exp);
        upper_tone;
    else
        if alarm_var_store(p,time_current) < alarm_lower_limit(p) && alarm_status(p)==0
            alarm_status(p)=1;
            toc_for_alarm_database_lower = toc(t_start_exp);
            lower_tone;
%             pause(.1);
        end
         

    end
    
end
