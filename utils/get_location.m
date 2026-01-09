function [get_tag,res] = get_location(numb)

global alarm_var_tag_name number_var_alarms description_of_alarms

for i=1:number_var_alarms
    if numb == i
        get_tag = alarm_var_tag_name{numb};
        res = description_of_alarms{numb};
    end
end


end
