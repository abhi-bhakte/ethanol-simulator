function [get_date,acend_index] = ascend_alarms(get_date,ob)
global time_vec
r  =size(get_date,1);
c = size(get_date,2);

% converting time into seconds
temp(1:r,1) = 3600.*get_date(1:r,4) + 60.*get_date(1:r,5)+ get_date(1:r,6);

[~,inde] = sort(temp,'ascend');
acend_index = ob(inde);
get_date = get_date(inde,:);

end