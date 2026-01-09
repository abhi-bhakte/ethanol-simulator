clear;
clc


file_name_gaze = 'gaze_processed_08-Aug-2014_17_43_40';
file_mouse_click = 'Mouse_click_08-Aug-2014_17_43_40';
gaze_data = xlsread(file_name_gaze);
task_1_gaze_data_index = find(gaze_data(:,1) >= 382 & gaze_data(:,1) <= 482);

left_pupil = gaze_data(task_1_gaze_data_index,5);

for i = 10:length(left_pupil)
    if left_pupil(i) == -1
        left_pupil(i) = left_pupil(i-1);
    end
end

% left_pupil_ma(1:10)= left_pupil(1:10);
% for i = 11:length(left_pupil)
%     left_pupil_ma(i) = sum(left_pupil((i-10):i))/3;
% end
left_pupil_ma = left_pupil;

left_pupil_ma = left_pupil_ma - mean(left_pupil_ma);

click_data = xlsread(file_mouse_click,4);




figure(1)
time = gaze_data(task_1_gaze_data_index,1)+gaze_data(task_1_gaze_data_index,2)*1.e-6;
plot(time(10:end),left_pupil_ma(10:end)');
xlabel('time');
ylabel('Pupil dilation');
hold on;
stem((click_data(:,1)+click_data(:,2)),ones(length(click_data(:,1))),'r');


