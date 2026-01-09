function eye_track_automatic(task_no,fault_no_list,fault_no)

clc
t =  'TX300-010103300552.local.';
% TX300-010103300552.local.
ConnectTo(t);

disp('You need to focus in black window and try to locate two white balls as shown in handouts.');
disp('This step will take 15 seconds.');

TrackStatus
pause(10)
EndTrackStatus
clc

commandwindow
% fprintf('\n Close the Tobii Toolbox v1.1 window.\n');
disp('==============================================================');
disp('Please avoid closing any window.');
disp('For calibration you need to trace the blue dot which appears on a black background when you press Enter');
n = 9;
disp('Press Enter key to start the calibration...');
pause
Calibrate(n)

ClearPlot


% Now start track Start by TrackStart function

clc
disp('Please don''t close any window during experiment');
disp('Now you are ready to go for scenarios.');
disp('Press any key to continue...');
pause

% TrackStart(0,'eye_track_data');
%  setDesktopVisibility('off')
% gui_changed_color(task_no,fault_no_list,fault_no);
making_ready_for(task_no,fault_no_list,fault_no);
end

