function plot_trend(current_time)

global   varTrend trendPanel closeTrendbh es_flag task_complete_flag
global  uni s_deg alarm_var_tag_name
global t_run tag_for_plot
t_run2 = t_run;
global alarm_lower_limit alarm_upper_limit number_var_alarms alarm_var_store
global  Ts
current_time_index = fix(current_time/Ts);
if es_flag ~= 1 || task_complete_flag ~= 1  
set(trendPanel,'visible','on');
set(closeTrendbh,'visible','on');
N = 10; % number of past index



% trend_var_name = {'(Flow_inlet_store_with_noise(current_time_index:-1:current_time_index-(N-1))*1e3)',
%     'mKf_store_with_noise(current_time_index:-1:current_time_index-(N-1))',
%     '(thetaKin_store_with_noise(current_time_index:-1:current_time_index-(N-1)) -273.15)',
%     '(X_cstr_state_with_noise(4,current_time_index:-1:current_time_index-(N-1))-273.15)',
%     '(critic_with_noise(current_time_index:-1:current_time_index-(N-1)))*1.129623*1e3',
%     'Tout(3,current_time_index:-1:current_time_index-(N-1))',
%     'Tout(5,current_time_index:-1:current_time_index-(N-1))',
%     'Tout(8,current_time_index:-1:current_time_index-(N-1))',
%     '(X_cstr_state_with_noise(3,current_time_index:-1:current_time_index-(N-1))-273.15)',
%     '(X_cstr_state_with_noise(2,current_time_index:-1:current_time_index-(N-1)).*1e3*1e3)',
%     '(cstr_level_store_with_noise(current_time_index:-1:current_time_index-(N-1)))*1e1'
%     };
%
% current_value_name = {'(Flow_inlet_store_with_noise(current_time_index))*1e3',
%     '(mKf_store_with_noise(current_time_index))',
%     'thetaKin_store_with_noise(current_time_index)-273.15',
%     'X_cstr_state_with_noise(4,current_time_index)-273.15',
%     'critic_with_noise(current_time_index)*1.129623*1e3',
%     'Tout(3,current_time_index)',
%     'Tout(5,current_time_index)',
%     'Tout(8,current_time_index)',
%     'X_cstr_state_with_noise(3,current_time_index)-273.15',
%     'X_cstr_state_with_noise(2,current_time_index).*1e3*1e3',
%     'cstr_level_store_with_noise(current_time_index)*1e1'};



% alarm_var_tag_name = {'F101','F102','T101','T102','F105','T106','T105','T104','T103','C101','L101'};




% temp = current_time:-Ts:0;

% for real time;
temp = current_time_index*t_run2 : -t_run2:0;


if current_time_index*t_run2 >= N*t_run2
    temp = temp(1:N);
    
    
    %         refreshdata(varTrend);
    %
    %         eval(sprintf('plot(varTrend,temp,%s,''--*'')',cell2mat(trend_var_name(tag_for_plot))));hold(varTrend,'on');
    %         plot(varTrend,[current_time_index*t_run2 temp(end)],[alarm_upper_limit(tag_for_plot) alarm_upper_limit(tag_for_plot)],'r--'); hold(varTrend,'on');
    %         plot(varTrend,[current_time_index*t_run2 temp(end)],[alarm_lower_limit(tag_for_plot) alarm_lower_limit(tag_for_plot)],'r--');hold(varTrend,'on');
    %         set(varTrend,'XLim',[temp(end) temp(1)]);
    %         text(temp(end)+t_run2,alarm_lower_limit(tag_for_plot)+.1*(alarm_upper_limit(tag_for_plot)-alarm_lower_limit(tag_for_plot)),'Low Alarm Limit','fontweight','bold','fontsize',8,'Color',[1 0 0],'Parent',varTrend);hold(varTrend,'on');
    %         text(temp(end)+t_run2,alarm_upper_limit(tag_for_plot)-.1*(alarm_upper_limit(tag_for_plot)-alarm_lower_limit(tag_for_plot)),'High Alarm Limit','fontweight','bold','fontsize',8,'Color',[1 0 0],'Parent',varTrend);hold(varTrend,'on');
    %         temp_val = eval(sprintf('%s'),cell2mat(current_value_name(tag_for_plot)));
    %         temp_val = sprintf('%.2f',(temp_val));
    %         t_text = cell2mat(alarm_var_tag_name(tag_for_plot));
    %         t_text2 =   cell2mat(uni(tag_for_plot));
    %         ch_val = [t_text '='  num2str(temp_val) ' ' t_text2];
    %         text(.35,1.05,ch_val,'Units','normalized','fontweight','bold','fontsize',12,'Color',[0 0 0],'Parent',varTrend);
    %         hold(varTrend,'on');
    %         set(varTrend,'Units','points');
    %         drawnow
    
    plot(varTrend,temp,alarm_var_store(tag_for_plot,current_time_index:-1:current_time_index-(N-1)),'k--*'); hold(varTrend,'on');
      set(varTrend,'xtick',[],'Color',[127 127 127]./255);
      set(varTrend,'box','off');
      set(varTrend,'YAxislocation','right');
%       set(varTrend,'Color',[1 1 1]);
    plot(varTrend,[current_time_index*t_run2 temp(end)],[alarm_upper_limit(tag_for_plot) alarm_upper_limit(tag_for_plot)],'r--'); hold(varTrend,'on');
%   set(varTrend,'xtick',[]);
    plot(varTrend,[current_time_index*t_run2 temp(end)],[alarm_lower_limit(tag_for_plot) alarm_lower_limit(tag_for_plot)],'r--');hold(varTrend,'on');
    set(varTrend,'XLim',[temp(end) temp(1)]);
%     set(varTrend,'xtick',[]);
    text(temp(1)+t_run2,alarm_lower_limit(tag_for_plot)+.1*(alarm_upper_limit(tag_for_plot)-alarm_lower_limit(tag_for_plot)),'Lower Limit','fontweight','bold','fontsize',8,'Color',[1 0 0],'Parent',varTrend);hold(varTrend,'on');

    text(temp(1)+t_run2,alarm_upper_limit(tag_for_plot)-.1*(alarm_upper_limit(tag_for_plot)-alarm_lower_limit(tag_for_plot)),'Upper Limit','fontweight','bold','fontsize',8,'Color',[1 0 0],'Parent',varTrend);hold(varTrend,'on');
 
    ch  = sprintf('%.2f%s',alarm_var_store(tag_for_plot,current_time_index));
    t_text = cell2mat(alarm_var_tag_name(tag_for_plot));
    t_text2 =   cell2mat(uni(tag_for_plot));
    ch_val = [t_text '='  ch ' ' t_text2];
    
    text(.35,1.05,ch_val,'Units','normalized','fontweight','bold','fontsize',12,'Color',[0 0 0],'Parent',varTrend);hold(varTrend,'on');
%     set(gca,'xtick',[]);
    set(varTrend,'Units','points');
    drawnow
       
else
    
    %         temp_time = [-N*Ts:Ts:Ts*current_time_index ];
    %         temp_time = temp_time(length(temp_time):-1:(length(temp_time)-(N-1)));
    %
    
    %% for real time
    temp_time = [-N*t_run2 : t_run2 : current_time_index*t_run2];
    temp_time = temp_time(length(temp_time):-1:(length(temp_time)-(N-1)));
    
    
    temp_store = alarm_var_store(tag_for_plot,1:current_time_index);
    temp_store = [(ones((N-current_time_index),1)*alarm_var_store(tag_for_plot,current_time_index))' temp_store];
%     plot(varTrend,temp_time,temp_store);hold(varTrend,'on');set(gcf,'Color',[1 1 1])
    
    plot(varTrend,temp_time,temp_store,'k--*'); hold(varTrend,'on');
    set(varTrend,'xtick',[],'Color',[127 127 127]./255);
    set(varTrend,'box','off');
     set(varTrend,'YAxislocation','right');
    
    
    plot(varTrend,[temp_time(1) temp_time(end)],[alarm_upper_limit(tag_for_plot) alarm_upper_limit(tag_for_plot)],'r--');hold(varTrend,'on');
    plot(varTrend,[temp_time(1) temp_time(end)],[alarm_lower_limit(tag_for_plot) alarm_lower_limit(tag_for_plot)],'r--'); hold(varTrend,'on');
    set(varTrend,'XLim',[temp_time(end) temp_time(1)]);
    text(temp_time(1)+t_run2,alarm_lower_limit(tag_for_plot)+.1*(alarm_upper_limit(tag_for_plot)-alarm_lower_limit(tag_for_plot)),'Lower Limit','fontweight','bold','fontsize',8,'Color',[1 0 0],'Parent',varTrend);hold(varTrend,'on');
    text(temp_time(1)+t_run2,alarm_upper_limit(tag_for_plot)-.1*(alarm_upper_limit(tag_for_plot)-alarm_lower_limit(tag_for_plot)),'Upper Limit','fontweight','bold','fontsize',8,'Color',[1 0 0],'Parent',varTrend);hold(varTrend,'on');
    ch  = sprintf('%.2f%s',alarm_var_store(tag_for_plot,current_time_index));
    t_text = cell2mat(alarm_var_tag_name(tag_for_plot));
    t_text2 =   cell2mat(uni(tag_for_plot));
    ch_val = [t_text '='  ch ' ' t_text2];
    
    text(.35,1.05,ch_val,'Units','normalized','fontweight','bold','fontsize',12,'Color',[0 0 0],'Parent',varTrend);hold(varTrend,'on');
    set(varTrend,'Units','points');
    drawnow
  
end
end
if es_flag ~= 1
hold(varTrend,'off');
drawnow
end
end
