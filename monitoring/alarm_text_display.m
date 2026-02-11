function alarm_text_display(time_current)

global alarm_lower_limit number_var_alarms

global ans_pv_1 ans_pv_2 ans_pv_3 ans_pv_4 ans_pv_5 ans_pv_6 ans_pv_7 ans_pv_8 ans_pv_9 ans_pv_10 ans_pv_11 alarm_upper_limit
global  uni

global alarm_var_store

for i = 1:number_var_alarms
    % Check if value exceeds alarm limits
    if alarm_var_store(i,time_current) > alarm_upper_limit(i) || alarm_var_store(i,time_current) < alarm_lower_limit(i)
        % Alarm condition: display in red
        eval(sprintf('set(ans_pv_%d,''foregroundcolor'',[1 0 0],''FontWeight'',''bold'',''FontSize'',16);',i));
    else
        % Normal condition: display in black
        eval(sprintf('set(ans_pv_%d,''foregroundcolor'',[0 0 0],''FontWeight'',''bold'',''FontSize'',16);',i));
    end
    
    % Display the actual process variable value with units
    ch = sprintf('%.2f%s',alarm_var_store(i,time_current),uni{i});
    eval(sprintf('set(ans_pv_%d, ''String'',''%s'');',i,ch));
end

drawnow
 