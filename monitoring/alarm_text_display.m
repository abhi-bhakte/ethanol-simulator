function alarm_text_display(time_current)

global alarm_lower_limit number_var_alarms

global ans_pv_1 ans_pv_2 ans_pv_3 ans_pv_4 ans_pv_5 ans_pv_6 ans_pv_7 ans_pv_8 ans_pv_9 ans_pv_10 ans_pv_11 alarm_upper_limit
global  uni

% var_with_alarms = [Flow_inlet_with_noise mKf_with_noise thetaKin_with_noise-273.15 x_with_noise(4)-273.15 F_with_noise*1.129623 Tout_current_with_noise(3) Tout_current_with_noise(5) Tout_current_with_noise(8) x_with_noise(3)-273.15 x_with_noise(2).*1e3 cstr_level_with_noise ];

global alarm_var_store

% for i = 1:length(alarm_var_store)
%     ch = eval(sprintf(' alarm_var_store{%d}',i));
%  p =  eval(sprintf('global ch'));
%  p
% end


% for i = 1 : number_var_alarms
%     
%     if var_with_alarms(i) > alarm_upper_limit(i) || var_with_alarms(i) < alarm_lower_limit(i)
%         
%         eval(sprintf('set(ans_pv_%d,''foregroundcolor'',[1 0 0],''FontWeight'',''bold'',''FontSize'',14);',i));
%     else
%         
%           eval(sprintf('set(ans_pv_%d,''foregroundcolor'',[33 61 33]./255,''FontWeight'',''bold'',''FontSize'',14);',i'));
%     end
%      
%         
%      ch = sprintf('%.2f%s',var_with_alarms(i),uni{i});
%                   eval(sprintf('set(ans_pv_%d, ''String'',''%s'');',i,ch));
% 
%     
%  drawnow
% end

for i = 1:number_var_alarms

    
    
    if alarm_var_store(i,time_current)> alarm_upper_limit(i) || alarm_var_store(i,time_current) < alarm_lower_limit(i)
        
        eval(sprintf('set(ans_pv_%d,''foregroundcolor'',[1 0 0],''FontWeight'',''bold'',''FontSize'',16);',i));
    else
        
     eval(sprintf('set(ans_pv_%d,''foregroundcolor'',[0 0 0],''FontWeight'',''bold'',''FontSize'',16);',i'));
%      set(ans_pv_1,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_2,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_3,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_4,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_5,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_6,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_7,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_8,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_9,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_10,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
%      set(ans_pv_11,'foregroundcolor',[33 61 33]./255,'FontWeight','bold','FontSize',14);
    end
for i = 1:number_var_alarms   
     ch = sprintf('%.2f%s',alarm_var_store(i,time_current),uni{i});
     eval(sprintf('set(ans_pv_%d, ''String'',''%s'');',i,ch));
end
    
 drawnow
% pause(.05);

end
 