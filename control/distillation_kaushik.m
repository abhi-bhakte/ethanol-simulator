function dstate_dis_x = distillation_kaushik(t,state_dis_x)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


% state_dis_x contains 10 states of distillation column
global V1 y MD TU_min Ld Vr Lr MT Ls Vs B MB F zf State_Noise_Matrix error_count


for i  = 1 : length(state_dis_x) % length(state_dis_x) = 10
    % state_dis_x is (mol/mL) /sec
    if i==1
        
        if (state_dis_x(i)>0) && (state_dis_x(i)<.894)
            dstate_dis_x(i) = ((V1*(y(i+1)-state_dis_x(i)))/(MD*TU_min))  ;
        else
            dstate_dis_x(i) = 0;
        end
        
    else if i==2
            
            if (state_dis_x(i)>0) && (state_dis_x(i)<0.894)
                dstate_dis_x(i)=((Ld*state_dis_x(i-1)+Vr*y(i+1)-Lr*state_dis_x(i)-V1*y(i))/(MT*TU_min)) ;
            else
                dstate_dis_x(i) = 0;
            end
            
            
        elseif (i>=3) && (i<=5)
            if (state_dis_x(i)>0) && (state_dis_x(i)<0.894)
                dstate_dis_x(i)=((Lr*state_dis_x(i-1)+Vr*y(i+1)-Lr*state_dis_x(i)-Vr*y(i))/(MT*TU_min)) ;
            else
                dstate_dis_x(i) = 0;
            end
            
            
        elseif (i>=7) && (i<=9)
            if (state_dis_x(i)>0) && (state_dis_x(i)<0.894)
                dstate_dis_x(i)=((Ls*state_dis_x(i-1)+Vs*y(i+1)-Ls*state_dis_x(i)-Vs*y(i))/(MT*TU_min)) ;
            else
                dstate_dis_x(i) = 0;
            end
            
            
        elseif i==length(state_dis_x)  % i  == 10
            if (state_dis_x(i)>0) && (state_dis_x(i)<0.894)
                dstate_dis_x(i)=((Ls*state_dis_x(i-1)-B*state_dis_x(i)-Vs*y(i))/(MB*TU_min)) ;
            else
                dstate_dis_x(i) = 0;
            end
            
            
         %% Feed Tray ( Tray 5th as given in supplementry material while taken as 6th in code here )   
        else
            if (state_dis_x(i)>0) && (state_dis_x(i)<0.894)
                dstate_dis_x(i)=((Lr*state_dis_x(i-1)+Vs*y(i+1)+F*zf-Ls*state_dis_x(i)-Vr*y(i))/(MT*TU_min)) ;
            else
                dstate_dis_x(i) = 0;
            end
        end
        
    end
       
end


    
    dstate_dis_x = dstate_dis_x.';
    

end
