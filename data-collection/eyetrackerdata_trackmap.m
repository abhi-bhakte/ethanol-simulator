function newdata_mat = eyetrackerdata_trackmap (file_name)

data = csvread(file_name);


% Identifying the right data from raw data

valid_data_index = find(data(:,9)==0 |  data(:,9)==3 | data(:,9)==1 | (data(:,9)==4 & data(:,16)==0) |  (data(:,9)==0 & data(:,16)==4));

newdata_mat = data(valid_data_index,[1 2 3 4 8 9 10 11 15 16]);

% 1 - time stamp in seconds
% 2 - time stamp in microseconds
% 3 - left eye gaze in data in horizontal direction
% 4 - left eye gaze in data in vertical direction
% 8 - pupil size of left eye
% 9 - validity code left eye
% 10 - right eye gaze in data in horizontal direction
% 11 - right eye gaze in data in vertical direction
% 15 - pupil size of right eye
% 16 - validity code right eye 

lh = 11; lv = 12;
rh = 13; rv = 14;
id_col = 15;
tolerance = 0; % tolerance in number of pixels

% Removing outliers

new_index = find(newdata_mat(:,1)~=0 & newdata_mat(:,1)<=3600);

newdata_mat = newdata_mat(new_index,:);
[r c] = size(newdata_mat); % here c is 10

number_of_hot_spots = 14;

% Making of two column for left eye (hoziontal and vertical pixels)

newdata_mat(:,lh) = ceil(newdata_mat(:,3).*1920);
newdata_mat(:,lv) = ceil(newdata_mat(:,4).*1080);

% Making of two column for right eye (hoziontal and vertical pixels)
newdata_mat(:,rh) = ceil(newdata_mat(:,7).*1920);
newdata_mat(:,rv) = ceil(newdata_mat(:,8).*1080);




% Defining hot spots

hot_spot = struct('Identifier','F101','Id',1,'Position',[435 489;86 123]);    % position is written in form of [x_min x_max ; y_min y_max]
hot_spot(2) = struct('Identifier','F102','Id',2,'Position',[298 350;265 304]);
hot_spot(3) = struct('Identifier','T101','Id',3,'Position',[391 441;261 302]);
hot_spot(4) = struct('Identifier','T102','Id',4,'Position',[763 809; 317 351]);
hot_spot(5) = struct('Identifier','T103','Id',5,'Position',[642 692;157 193]);
hot_spot(6) = struct('Identifier','T104','Id',6,'Position',[1112 1115;453 483]);
hot_spot(7) = struct('Identifier','T105','Id',7,'Position',[1341 1388;315 359]);
hot_spot(8) = struct('Identifier','T106','Id',8,'Position',[1100 1152;247 287]);
hot_spot(9) = struct('Identifier','F105','Id',9,'Position',[1044 1096;353 393]);
hot_spot(10) = struct('Identifier','C101','Id',10,'Position',[585 633;417 454]);
hot_spot(11) = struct('Identifier','L101','Id',11,'Position',[771 820;189 226]);
hot_spot(12) = struct('Identifier','TrendPanel','Id',12,'Position',[126 545;448 690]);
hot_spot(13) = struct('Identifier','AlarmSummary','Id',13,'Position',[102 1740;711 1038]);
hot_spot(14) = struct('Identifier','Start','Id',14,'Position',[933 1131;597 637]);


% hot_spot(1:number_of_hot_spots).Position(:,:) =    hot_spot(1:number_of_hot_spots).Position(:,:) + tolerance;
for i = 1:number_of_hot_spots
    hot_spot(i).Position(:,:) = hot_spot(i).Position(:,:) + tolerance;
end

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

excel_file_name = ['data\excel-outputs\eye_track_process' file_name];
xlswrite(excel_file_name,newdata_mat);




end
