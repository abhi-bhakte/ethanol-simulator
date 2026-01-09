function upper_tone
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% [y,fs,n]=wavread('Upper_alarm.wav');
[y,fs]=audioread('media\audio\Upper_alarm.wav');
y = y(1:13416);
sound(y,fs);
% pause(.25);
%sound(y,fs);

end

