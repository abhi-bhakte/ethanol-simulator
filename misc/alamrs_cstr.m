function alamrs_cstr
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


global x FF mKf Tjin

% x(1) = Concentration of water
% x(2) = Concentration of Ethanol
% x(3) = Temperature of mixture
% x(4) = Temperature of jacket

x_upper_limit = [54.6e-3 1.8e-3 32+273.15 24+273.15 ];

x_lower_limit = [53.8e-3 1e-3   24+273.15 16+273.15];

FF_upper_limit = 7;
FF_lower_limit = 0;


mKf_upper_limit = 13e3/50;
mKf_lower_limit = 0;

%===========V102============
if FF  > FF_upper_limit
    upper_tone;
else if FF<FF_lower_limit
        lower_tone;
    end
end
%=============================



%===========F101=================
if mKf  > mKf_upper_limit
    upper_tone;
else if mKf<mKf_lower_limit
        lower_tone;
    end
end
%================================


%=============T101=============

%==============================


%=================T103==================
  if x(4)>x_upper_limit(4)
        upper_tone;
    else if x(4)<x_lower_limit(4)
            lower_tone;
        end
    end
%========================================

% 
% 
% 
% for i = 1:4
%     
%     if x(i)>x_upper_limit(i)
%         upper_tone;
%     else if x(i)<x_lower_limit(i)
%             lower_tone;
%         end
%     end
% end
% 

end

