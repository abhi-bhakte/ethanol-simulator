% function newdata_mat = eyetrackerdata_trackmap (file_name)
function newdata_mat = eyetrackerdata_trackmap ()
% data = csvread(file_name);

file_name = 'gazedata_25-Jul-2014_10_27_56.xlsx';
data = xlsread(file_name);
% Identifying the right data from raw data

valid_data_index = find(data(:,15)==0 |  data(:,15)==3 | data(:,15)==1 | (data(:,15)==4 & data(:,28)==0) |  (data(:,15)==0 & data(:,28)==4));

newdata_mat = data(valid_data_index,[1 2 9 10 14 15 22 23 27 28]);

% 1 - time stamp in seconds
% 2 - time stamp in microseconds
% 9 - left eye gaze in data in horizontal direction
% 10 - left eye gaze in data in vertical direction
% 14 - pupil size of left eye
% 15 - validity code left eye
% 22 - right eye gaze in data in horizontal direction
% 23 - right eye gaze in data in vertical direction
% 27 - pupil size of right eye
% 28 - validity code right eye 

lh = 11; lv = 12;
rh = 13; rv = 14;
id_col = 15;
% tolerance = [-75 75;-75 75]; % tolerance in number of pixels

% Removing outliers

new_index = find(newdata_mat(:,1)<=3600);

newdata_mat = newdata_mat(new_index,:);
[r c] = size(newdata_mat); % here c is 10

number_of_hot_spots = 14;

% Making of two column for left eye (hoziontal and vertical pixels)

newdata_mat(:,lh) = ceil(newdata_mat(:,3)*1920);
newdata_mat(:,lv) = ceil(newdata_mat(:,4)*1080);

% Making of two column for right eye (hoziontal and vertical pixels)
newdata_mat(:,rh) = ceil(newdata_mat(:,7)*1920);
newdata_mat(:,rv) = ceil(newdata_mat(:,8)*1080);




% Defining hot spots

hot_spot = struct('Identifier','F101','Id',1,'Position',[427 619;73 135]);    % position is written in form of [x_min x_max ; y_min y_max]
hot_spot(2) = struct('Identifier','F102','Id',2,'Position',[259 375;223 317]);
hot_spot(3) = struct('Identifier','T101','Id',3,'Position',[385 507;223 317]);
hot_spot(4) = struct('Identifier','T102','Id',4,'Position',[757 915;297 389]);
hot_spot(5) = struct('Identifier','T103','Id',5,'Position',[629 741;115 219]);
hot_spot(6) = struct('Identifier','T104','Id',6,'Position',[1091 1227;427 521]);
hot_spot(7) = struct('Identifier','T105','Id',7,'Position',[1315 1447;281 413]);
hot_spot(8) = struct('Identifier','T106','Id',8,'Position',[1047 1215;195 299]);
hot_spot(9) = struct('Identifier','F105','Id',9,'Position',[1019 1173;315 411]);
hot_spot(10) = struct('Identifier','C101','Id',10,'Position',[543 715;397 489]);
hot_spot(11) = struct('Identifier','L101','Id',11,'Position',[759 859;137 251]);
hot_spot(12) = struct('Identifier','TrendPanel','Id',12,'Position',[126 545;448 690]);
hot_spot(13) = struct('Identifier','AlarmSummary','Id',13,'Position',[102 1740;711 1038]);
hot_spot(14) = struct('Identifier','Start','Id',14,'Position',[889 1185;565 691]);


% hot_spot(1:number_of_hot_spots).Position(:,:) =    hot_spot(1:number_of_hot_spots).Position(:,:) + tolerance;
% for i = 1:number_of_hot_spots-3
%     hot_spot(i).Position(:,:) = hot_spot(i).Position(:,:) + tolerance;
% end

for i = 1 : r
    flag_left = 0;
    flag_right = 0;
    for k = 1:number_of_hot_spots
    
        if newdata_mat(i,lh)>=hot_spot(k).Position(1,1) & newdata_mat(i,lh)<=hot_spot(k).Position(1,2) & newdata_mat(i,lv)>=hot_spot(k).Position(2,1) & newdata_mat(i,lv)<=hot_spot(k).Position(2,2)
            flag_left = k;
        end
        
        if newdata_mat(i,rh)>=hot_spot(k).Position(1,1) & newdata_mat(i,rh)<=hot_spot(k).Position(1,2) & newdata_mat(i,rv)>=hot_spot(k).Position(2,1) & newdata_mat(i,rv)<=hot_spot(k).Position(2,2)
            flag_right = k;
        end
        
        if flag_left==0 & flag_right==0
            newdata_mat(i,id_col) = 0;
        else if flag_left==0 & flag_right==1
                newdata_mat(i,id_col) = flag_right;
            else if flag_left==1 & flag_right==0
                    newdata_mat(i,id_col) = flag_left;
                else
                    newdata_mat(i,id_col) = flag_left;
                end
            end
        end
    
    end
    

end




excel_file_name = ['data\excel-outputs\eye_track_process_' file_name];
xlswrite(excel_file_name,newdata_mat);




end
