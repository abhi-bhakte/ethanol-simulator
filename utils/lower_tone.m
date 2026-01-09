function lower_tone
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% [y,fs,n]=wavread('lower_alarm.wav');
[y,fs]=audioread('media\audio\lower_alarm.wav');
sound(y,fs);
% pause(.25);
%sound(y,fs);

end

