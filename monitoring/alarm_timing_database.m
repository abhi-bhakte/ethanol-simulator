function  alarm_timing_database(inde,task_no,fault_no)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

global fid_alarm_timing  number_var_alarms t_start_exp toc_for_alarm_database_upper toc_for_alarm_database_lower
global alarm_upper_limit alarm_lower_limit alarm_var_tag_name
global alarm_var_store

fid_alarm_timing = fopen('data\text-logs\alarm_timing.txt','at+');

if inde > 1
    
       
    for m = 1:size(alarm_var_store,1)
        
    var((2*m)-1 :2*m) = alarm_var_store(m,inde:-1:inde-1);
    end
    
    for k = 1:number_var_alarms
        
        temp = var(2*k - 1  : 2*k);
        
        
        % stat(1) is for recent
        if temp(1)>alarm_upper_limit(k)
            stat(1) = 1;
        else if temp(1)<alarm_lower_limit(k)
                stat(1) = -1;
            else
                stat(1) = 0;
            end
            
        end
        
        % stat(2) is for previous sample
        if temp(2)>alarm_upper_limit(k)
            stat(2) = 1;
        else if temp(2)<alarm_lower_limit(k)
                stat(2) = -1;
            else
                stat(2) = 0;
            end
        end
        
        if stat(1)==1 && stat(2)==0
            te = toc_for_alarm_database_upper;
            temp_text = [alarm_var_tag_name{k} '_high'];
         fprintf(fid_alarm_timing,'%d     %.6f  %s \n',floor(te),(te-floor(te)),temp_text);
%             fprintf(fid_alarm_timing,'1 %s %s\n',alarm_var_tag_name{k},datestr(now));
        else if stat(1)==1 && stat(2)==-1
                 te = toc_for_alarm_database_upper;
                 temp_text = [alarm_var_tag_name{k} '_high'];
         fprintf(fid_alarm_timing,'%d     %.6f  %s \n',floor(te),(te-floor(te)),temp_text);
%                 fprintf(fid_alarm_timing,'1 %s %s\n',alarm_var_tag_name{k},datestr(now));
            else if stat(1)==-1 && stat(2)==0
                
                     te =toc_for_alarm_database_lower;
%          fprintf(fid_alarm_timing,'%d     %.6f  2 %s \n',floor(te),(te-floor(te)),alarm_var_tag_name{k});
                 temp_text = [alarm_var_tag_name{k} '_low'];
                 fprintf(fid_alarm_timing,'%d     %.6f %s \n',floor(te),(te-floor(te)),temp_text);
%                     fprintf(fid_alarm_timing,'2 %s %s\n',alarm_var_tag_name{k},datestr(now));
                else if stat(1)==-1 && stat(2)==1
                         te = toc_for_alarm_database_lower;
                          temp_text = [alarm_var_tag_name{k} '_low'];
         fprintf(fid_alarm_timing,'%d     %.6f %s \n',floor(te),(te-floor(te)),temp_text);
%                         fprintf(fid_alarm_timing,'2 %s %s\n',alarm_var_tag_name{k},datestr(now));
                    else if stat(1)==0 && (stat(2)==1 || stat(2)==-1)
                             te = toc(t_start_exp);
                          temp_text = [alarm_var_tag_name{k} '_cleared'];
                            fprintf(fid_alarm_timing,'%d     %.6f %s \n',floor(te),(te-floor(te)),temp_text);
                    end
                    end
                end
            end
           
        end
  
    end
end

fclose(fid_alarm_timing);
end

