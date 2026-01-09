% N is the number of samples
% Ts is sampling period



%%
function main_file_kaushik_parameters_training(task_training_no)

% Add monitoring functions to path
addpath('monitoring');
addpath('utils');

%% Defining global variables

% clear all
clear alarm_var_store tag_for_plot
global f f2 V102 V301 V401 V201
global Start_Simu ans_11 ans_12 ans_13 ans_14  
global slider_reflux slider_coolant slider_feed slider_flow_dist % sliders showing position of valve from 0 to 1 for flow control
global X_cstr_state Ts
global control_stat_reflux control_stat_feed control_stat_dist control_stat_cooling % showing state of controlling used
global cstr_level 
global x curr_time
global FF k10 mKf R Qreb E1 Hr1 rho Cp kw AR VR mK CPK H1 H2 c1 c2 MT MD MB fault_time
global  Ql F Tf zf Tbf Vs Hf Cf qf Vr V1 Ld Lr Ls D B TIMEUNITS_PER_HOUR
global TU_min  k1 y
global cstr_feed_valve
global cool_jacket_valve
global distill_bottom_flow_rate  % stripping section
global distill_up_flow_rate      % rectifying section
global error_count
global output_error_matrix
global Tout
global thetaKin 
global flag_for_alarm
global alarm_status
global cA0
global t_run
global speedx
global time_vec date_vec
global ans_29 esd_box fid time_start_first fid_mouse_move 
global Flow_inlet 
global auto_matic_shutdown tag_for_plot
global alarm_lower_limit alarm_upper_limit
global alarm_var_tag_name
global number_var_alarms description_of_alarms
global uni s_deg alarm_var_store

tag_for_plot = 0;
number_var_alarms = 11;
alarm_var_tag_name = {'F101','F102','T101','T102','F105','T106','T105','T104','T103','C101','L101'};
alarm_upper_limit = [ .95*1e3 200 40 32.5 .95*(.6482/.7)*1.129623*1e3 80.4 89.5 100.5 33 ((1/18)- 0.0540)*1e3*1e3 (.1858*1e3)/(1e2)];
alarm_lower_limit = [ .55*1e3 35 0 15.2 .55*(.6482/.7)*1.129623*1e3 78.5 86.5 98.5 29.5 ((1/18)- 0.0546)*1e3*1e3 0 ];
description_of_alarms = {'Feed Flow Rate','Cooling Water Flow Rate','Cooling Water Temperature','Jacket Temperature','Flow rate to Distillation','Temperature of 3rd Tray','Temperature of 5th Tray','Temperature of 8th Tray','Temperature inside CSTR','Concentration of Ethanol','Level of CSTR'};
s_deg = sprintf(' %cC', char(176));
uni = {' lt/hr'; ' lt/hr'; s_deg ; s_deg; ' lt/hr'; s_deg; s_deg; s_deg; s_deg; ' mol/Lt'; ' m'};

number_of_samples_per_sec = 145; % calculated by running a loop at  (taken on an average basis)
speedx = 60; % kept for changing number of samples in 1 second world clock, we can go upto 145x(max)
cA0 = 1/18;
err_ind_feed = 0;
err_ind_cool = 0;
err_ind_reflux = 0;
err_ind_dist  = 0;
tag_for_plot = 0;

%% Here change should be done if we add any other process variables in gui
alarm_status = zeros(1,10);
flag_for_alarm = zeros(1,11);

date_vec = zeros(10,6);
time_vec = zeros(10,20);

%%
set(Start_Simu,'UserData',1);
error_count = 1;

N=600; % for 10 minutes
Ts=1; % Process sampling time for ode15s (process running time)
%Flow_inlet = .7; % l/h
% assuming valve to be linear operating....

% fault_no = fault_no_list(task_no)
% fault_no = 7;

volm = .2;       % l
%FF = Flow_inlet/volm; % This is .7(l/h) / 200ml to get FF
cstr_feed_valve = FF/7;


%R = u(4,1); % 0.9;
R = .9;
% Reflux fraction---------------------------R

time_duration_seconds = 420; % Since this is for training tasks
count_ref = 0;
%% Defining Initial States for whole setup
%============INITIAL CONDITIONS by kaushkik=====================
x_initial = [ 0.054189182040791 0.001366373514770 3.037294916114016e+02  3.025542614394507e+02 1 0.894000003246616 0.730388652781846 0.574718575473013 0.363664773653394 0.091480578882567 0.024177207681576 0.005194979500616 9.571081707482047e-04 -1.982433505631396e-06 ]';

x = x_initial; % x is used for differential equation
cstr_x_initial  = x_initial(1:4)';
distill_x_initial = x_initial(5:end)';

X_cstr_state = cstr_x_initial';
X_distill_state = distill_x_initial';


distill_bottom_flow_rate = .625;
distill_up_flow_rate = .025;

x1 = x; % For tic to toc loop
cstr_vol_ss = 133.33; % Cstr level at steady state in ml
cstr_total_height = .1858; % Actual height of cstr tank in cm at vol 200 ml

cstr_level =( cstr_total_height/1.5); % cstr height at vol 133.33ml

for i = 1:length(x_initial)
    if i==3 || i==4
        State_Noise_Matrix(i,1:(N+1))= 0.5.*sqrt(1e-1)*rand(1,N+1);
    else
        State_Noise_Matrix(i,1:(N+1))= .05.*sqrt(1e-8)*rand(1,N+1);
    end
end

cstr_level_noise(1:N+1) = 0.1.*sqrt(1e-2)*rand(1,N+1);
FF_noise(1:N+1) = 0.1.*sqrt(1e-5)*rand(1,N+1);
mKf_noise(1:N+1) = 0.5.*sqrt(1e-1)*rand(1,N+1);
F_noise(1:N+1) = 0.1.*sqrt(1e-2)*rand(1,N+1);
thetaKin_noise(1:N+1) = 0.5.*sqrt(1e-1)*rand(1,N+1);


%===================================================================================================================================
% Sensor noise in temperature noise
for i = 1:length(distill_x_initial)-1
    
    output_error_matrix(i,1:(N+1)) =0.5.*sqrt(1e-1)*rand(1,N+1); % Adding of uniform noise not gaussian noise
end

%====================================================================================================================================

%%  Input(5) - defined by u


%k10 = u(2,1); % 1.287e12; % hr^-1-----------------k10
k10 = 5.187e11;
% Rate constant of Reaction A->B

% Coolant Mass flow rate (g/h)

cool_jacket_valve = mKf /(6.5e3/50);

Qreb = 800;
% Reboiler power---------------------------------Qreb

% Heat transfer coefficient between jacket and reactor---------U
kw   =  4032e3; % J/hr-m^2-K

%% Process Parameters

% Arrehnius law parameters
% Reaction A->B
E1   =  -8930.3; % K  % Activation energy -----------E1'
Hr1   =  -11e3; % J/mol  % Heat of reaction A->B (delH1)----------delH1


% Density of reactor fluid
rho  =  0.9942; % g/mL

% Heat capacity of reactor fluid--------------cp
Cp   =  3.01; % J/g-K

% Heat transfer coefficient between jacket and reactor---------U
kw   =  4032e3; % J/hr-m^2-K

% Surface area for cooling---------------------------------A
AR   =  0.215/50; % m^2

% Volume of the CSTR----------------------V
VR   =  200; % mL

% Coolant Mass----------------------------Mj
mK   =  5e3/50; % g

% Coolant Heat Capacity----------------------cpj
CPK  =  4.186; % J/g-K


% Value of H1 and H2
H1=33.99e3;    % Heat of vapourization of pure B (Ethanol) (J/mole)---delHva
H2=40.656e3;   % Heat of vapourization of pure A (Water) (J/mole)-----delHvb

c1=0.1309e3;  % Specific Heat pure B (Ethanol) (J/mole K)----------Cp,a
c2=0.0754e3;  % Specific Heat pure A (Water) (J/mole K)-------------Cp,b

MT=1.0;      % Molar hold-up on Tray (mole)------------Mt
MD=0.5;      % Molar hold-up in Reflux Drum (mole)-------Md
MB=325;      % Molar hold-up in Rebioler (mole)----------Mb

Eff=0.7;     % Murphy Tray Efficeincy of each tray--------eta_T

Ql=250;   % Heat loss from the reboiler of distillation column (watt=J/s) ----Q_loss

%%  Initial values of parameters for startup
% These are not initial values for states

% Feed temperature  %----------Tf
theta0 =  28 + 273.15; % K

% Coolant inlet Temperature (K) -------------Tji
thetaKin = 20 + 273.15; % K

%% Simulation of Process
fault_no = 0; % For dummy tasks we don't need any fault to be introduced
% Need to change N 
tic_start = tic;
i = 1; % this i is used for storing per second (world clock) values.
% for ol = 50002:50002+N
    while toc(tic_start) < time_duration_seconds % for 10 minutes 
    set(curr_time,'visible','on','String',datestr(now),'backgroundcolor',[1 1 1],'foregroundcolor',[.8 .6 .3]);
    
%     i = ol-50001;
    
    %%====================================================================
    
    Flow_inlet = V102.flowin * V102.valvepos;
    
    mKf = V301.flowin * V301.valvepos;
    
    % converting to 2 decimal points
    
    set(ans_11,'String',sprintf('%.2f',V102.valvepos));
    set(ans_12,'String',sprintf('%.2f',V301.valvepos));
    set(ans_13,'String',sprintf('%.2f',V401.valvepos));
    set(ans_14,'String',sprintf('%.2f',V201.valvepos));
    set(slider_feed,'Value',V102.valvepos);
    set(slider_coolant,'Value',V301.valvepos);
    set(slider_flow_dist,'Value',V201.valvepos);
    set(slider_reflux,'Value',V401.valvepos);
    
    
    %% Selecting which fault needs to be introduced
    
    switch(fault_no)
        
        case 1
            if  i>fault_time(fault_no_list(1))
                Flow_inlet = (V102.flowin * V102.valvepos) - .2;
                if Flow_inlet<0
                    Flow_inlet =0;
                end
            end
        case 2
            if i>fault_time(fault_no_list(2))
               k10 = 2e9;
            end
        case 3
            
            if  i>fault_time(fault_no_list(3))
               mKf = (V301.flowin * V301.valvepos) - 100;
                if mKf<0
                    mKf =0;
                end
            end
        case 4
            if i>fault_time(fault_no_list(4))
                 F = V201.flowin * V201.valvepos-.5;
                if F<0
                    F = 0;
                end
               
            end
        case 5
            if i>fault_time(fault_no_list(5))
                if count_ref == 0
                    V401.valvepos = .35;
                    count_ref = 1;
                end
            end
        case 6
            if i>fault_time(fault_no_list(6))
                Qreb =  300;
            end
%         case 7
%             if i>55 &&  flag_temp_control==0
%                 thetaKin = 12+ 273.15;
%                 set(slider_for_temp,'Value',12/100);
%             else if i>38 && flag_temp_control==1
%                     thetaKin = (100*get( slider_for_temp,'Value') + 273.15);
%                 else
%                     thetaKin = 20 + 273.15;
%                 end
%             end
    end
    
    FF = Flow_inlet/volm; % This is .7(l/h) / 200ml to get FF

   
     

     F101_store(i) = Flow_inlet + FF_noise(i);
     
    
    F102_store(i) = mKf + mKf_noise(i);
    
    T101_store(i) = thetaKin + thetaKin_noise(i);
    
    %%  There are total 4+10=14 states in whole system
    % Concentration of A in the reactor (mol/mL)---------CA
    cA = x(1);
    
    % Concentration of B in the reactor (mol/mL)----------CB
    cB = x(2);
    % Temperature of reactor fluid (deg K)----------------Tr
    theta = x(3);
    
    % Temperature of cooling fluid (deg K)----------------Tj
    thetaK = x(4);
  
    %% Changes made for adding controller
    V201.flowin = FF*VR*(cA+cB)*(1/60);
    V201.flowfinal = V201.flowin*V201.valvepos;
    
    F = V201.flowfinal;
%     critic(i) = F;
%     
%     F_with_noise = V201.flowfinal + F_noise(i);
%     critic_with_noise(i) = critic(i) + F_noise(i);
    F105_store(i) = F + F_noise(i);
    
    
%     disp('-------');
    
    R_des = V401.flowin* V401.valvepos;
    R = ((V401.flowin-R_des)/R_des);
    
%     disp('-------');    
    
    
    Tf = x(3)-273.15; % Distillation column feed temperature (deg C)
    
    %%
    
    zf=cB/(cA+cB); %Mole fraction of B in distillation column feed-------xF
    % See Tbf in degree celsius
    
    %% ------------------------ CHECK---------------------
    
    %===================Temperature polynomial==========================
    pt = 1e+004.*[-.5309 2.6189 -5.5894 6.7753 -5.1579 2.5764 -.8544 .1849 -.0253 .0100];
    %====================================================================
    % model_based_FDI_ethanol_water_new.m also in
    % pt is a polynomial function
    Tbf=polyval(pt,zf); % Bubble point temperature of distillation column feed (in deg C)-------pt=f(t-->x) & Tbf = TFB
    
    
    %%
    %Molar flow rate of vapour phase in stripping section (mol/min)-----Vs
    
    Vs=((Qreb-Ql)*60)/((H1*x(14))+(H2*(1-x(14))));
    
    Hf=zf*H1+(1-zf)*H2; % Heat of vaporization of distillation column feed (J/mole)----Hf=del(Hf)  zF = xF
    
    Cf=zf*c1+(1-zf)*c2; % Specific Heat of distillation column feed (J/mole)-------Cf
    
    qf=1+((Cf*(Tbf-Tf))/Hf); % distillation column feed quality (dimensionless)-----Qf
    
    Vr = Vs + F*(1-qf); % Molar Flow rate of vapor phase in rectifying section of column (mol/min)----Vr
    
    Td = 30.5;
    TDb=polyval(pt,x(5));  % Bubble point temperature of Distillate(deg C)
    
    Hd=x(5)*H1+(1-x(5))*H2;  % Heat of vaporization of distillate(J/mole)---del HD
    
    Cd=x(5)*c1+(1-x(5))*c2;  % Specific heat of Distillate (J/mole)------CD
    
    qd=1+((Cd*(TDb-Td))/Hd); % Distillate Quality -------QD
    
    V1 = Vr/(1 - R*(1-qd));   % Molar flow rate of vapour phase from tray 1 - top tray (mol/min)
    %%
    
    %   V1=Vr; %---------by putting qd  =  1 in previous equation
    % Molar flow rate of vapour phase from tray 1 - top tray (mol/min)
    %qd is distillate quality
    
    Ld=R*V1;
    % Molar flow rate of Liq phase flow rate to column (mol/min)
    
    Lr=qd*Ld;
    %  Lr = Ld;
    % Molar flow rate of vapour phase in rectifying section (mol/min)
    
    Ls=Lr+F*qf;
    % Molar flow rate of vapour phase in stripping section (mol/min)
    
    D=Vr-Lr;
    if D<0
        D=0;
    end
    % Molar flow rate of Top product (mol/min)
    
    B=F-D;
    if B<0
        B = 0;
    end
    %     B = .625;
    %     D = .025;
    % Molar flow rate of bottom product (mol/min)
    %----------------------CHECK--------------------
    k1=k10*exp(E1/(x(3))); % theta = x(3)
    % Arrhenious Equation of Rate Constant
    %% CSTR state equation by ODE15S
    
    TIMEUNITS_PER_HOUR =3600;
    TU_min=60;
    t_run = 1;
    time_c = 1;
    cstr_x_initial1 = cstr_x_initial;
    distill_x_initial1 = distill_x_initial;
    tStart = tic;
    while toc (tStart) <t_run
        % speedx is used for speeding up the process
        for k_speed = 1:speedx
            [~,cstr_state1] = ode15s (@cstr_kaushik ,[(time_c-1)*Ts time_c*Ts], cstr_x_initial1);
            
            X_cstr_state1(1:4,time_c+1) = cstr_state1(end,:)';
            
            cstr_x_initial1 = cstr_state1(end,:)';
            x1(1:4) = cstr_state1(end,:)';
            
            
            
            
            pe12 = 1e+004.*[-.3118 1.5082 -3.1538 3.7380 -2.7695 1.3368 -.4263 .0897 -.0123 .0011 0.0000];
            y = func_x_y_ethanol_water(pe12,Eff,x1(5:end));  % 10 by 1s
            
            [~,distill_state1] = ode15s (@distillation_kaushik ,[(time_c-1)*Ts time_c*Ts], distill_x_initial1);
            
            X_distill_state1(1:10,time_c+1) = distill_state1(end,:)';
            distill_x_initial1 = distill_state1(end,:)';
            x1(5:14) = distill_state1(end,:)';
            time_c = time_c + 1;
             end
            pause(t_run-toc(tStart))
%        
    end
    
 
    X_cstr_state(1:4,i+1) = X_cstr_state1(1:4,time_c-1);

    cstr_x_initial = cstr_state1(end,:)';
    x(1:4) = cstr_state1(end,:)';
   
    X_distill_state(1:10,i+1) = X_distill_state1(1:10,time_c-1);
    distill_x_initial = distill_state1(end,:)';
    x(5:end) = distill_state1(end,:)';
    
    T103_store(i) = X_cstr_state(3,i+1) + State_Noise_Matrix(3,i);
     T102_store(i) = X_cstr_state(4,i+1) + State_Noise_Matrix(4,i);
      C101_store(i) = X_cstr_state(2,i+1) + State_Noise_Matrix(2,i);
      
    
    
    
    %% Output equations of Distillation Column
    
    
    Tout(:,i) = polyval(pt,x(6:end));  % Dimesion is 9 by 1   with noise
    
    T106_store(i) = Tout(3,i) + output_error_matrix(3,error_count);
    
    T105_store(i) = Tout(5,i) + output_error_matrix(5,error_count);
    T104_store(i) = Tout(8,i) + output_error_matrix(8,error_count);
    
    error_count = error_count + 1;
     L101_store(i) = cstr_level + cstr_level_noise(i);
    alarm_var_store(1:number_var_alarms,i) = [F101_store(i)*1e3 F102_store(i) T101_store(i)-273.15 T102_store(i)-273.15 F105_store(i)*1.129623*1e3 T106_store(i) T105_store(i) T104_store(i) T103_store(i)-273.15 C101_store(i).*1e6 L101_store(i).*1e1]';
    
    
    [status,hi_lo] = check_alarm_limit(i);
    
    
    if i>1 & tag_for_plot~=0
        plot_trend_training(i*Ts)
    end
    
    %% Alarm timing database manage
    alarm_timing_database(i,task_training_no,0); % Using 0 as fault_no for training
    %% Displaying Measured variables values
    
    alarm_text_display(i);
    
    %% Demo for using valve
    
    
    
    %=======================Controller for Input feed valve====================
    if Flow_inlet~=V102.setpoint   
        if control_stat_feed==0
           er_feed(err_ind_feed +1) = (((1/(V102.flowin))*(V102.setpoint - Flow_inlet)));
           V102 = autocontrol(V102,er_feed);
           if Flow_inlet==V102.setpoint
                err_ind_feed = 0;
            else
                err_ind_feed = err_ind_feed + 1;
            end
        end
        

    end
    %    ==========================================================================
    
    
    %=======================Controller for Coolant Valve=======================
    if mKf ~= 130
      
        if control_stat_cooling==0
        er_cool(err_ind_cool +1) = (((1/(V301.flowin))*(V301.setpoint - mKf)));
           V301 = autocontrol(V301,er_cool);
            if mKf==V301.setpoint
                err_ind_cool = 0;
            else
                err_ind_cool = err_ind_cool + 1;
            end  
        end
    end
    
    
    
    %============================Controller for Reflux Valve===================
    
    if R_des~=1
        if control_stat_reflux==0
            er_reflux(err_ind_reflux + 1) = (((1/(V401.flowin))*(1 - R_des))); % 1 is taken as set point for R_des
            V401 = autocontrol(V401,er_reflux);

             if R_des==1
                err_ind_reflux = 0;
             else
                 err_ind_reflux = err_ind_reflux + 1;
             end
            
          end
        
    end
   
    
    %========================Controller between CSTR and distillaton column ===========================
    
    if F~= V201.setpoint
        
        if control_stat_dist==0
            V201.valvepos = V201.valvepos + (.25*(((1/(V201.flowin))*(V201.setpoint - F))));
            if V201.valvepos > 1
                V201.valvepos = 1;
            end
            V201.flowout = V201.valvepos * V201.flowin;
            V201.flowfinal = V201.flowout;
            set(slider_flow_dist,'Value',V201.valvepos);
        end
    end
    
     
    %====================liquid level check=========================
    if V201.valvepos~=1 % Checking for liquid level in tank
        % 1.129623 factor is added to show value in lt/hr
        change_in_vol = (V201.flowin - V201.flowfinal)*1.129623; % in lt/hr
        change_in_vol_per_sec = (change_in_vol)*(Ts/3600); % change in vol per second
        cstr_level = cstr_level + (change_in_vol_per_sec)*(cstr_total_height/.2);
    end
    
    
    %================ For checking Stop ===================================
    if i>450
        check_for_stop_training(i,task_training_no);
    end
    %======================================================================
    
    i = i+1;
    
end
% TrackStop
% fprintf(fid,'STOP TIME = %s \n',datestr(clock,'dd-mm-yyyy HH:MM:SS FFF'));
% fclose(fid_mouse_move);
auto_matic_shutdown = auto_matic_shutdown + 1;
set(ans_29,'visible','on','fontweight','bold','String','Automatic ShutDown!!!');
set(esd_box,'visible','off');

pause(4)

% [a_a b_a c_a f_a] = textread('alarm_timing.txt','%s %s %s %s','whitespace',' ','bufsize',10000);
% ty = time_start_first;
% ty([12 15 18]) = '_';
% if ~isempty(a_a) && ~isempty(b_a) && ~isempty(c_a) && ~isempty(f_a)
%     eval(sprintf('xlswrite(''Alarm_timing_%s.xlsx'',[a_a b_a c_a f_a],%d);',ty,fault_no_lo));
% end
% [a_c b_c c_c d_c e_c f_c] = textread('Mouse_click.txt','%s %s %s %s %s %s','whitespace',' ','bufsize',10000);
% ty = time_start_first;
% ty([12 15 18]) = '_';
% if ~isempty(a_c) && ~isempty(b_c) && ~isempty(c_c) && ~isempty(d_c) && ~isempty(e_c) && ~isempty(f_c)
%     eval(sprintf('xlswrite(''Mouse_click_%s.xlsx'',[a_c b_c c_c d_c e_c f_c],%d);',ty,fault_no_lo));
% end
close(f)
close (f2)
% fclose(fid);
% fprintf('\n==========================================================================================');
% feedback_per_task(task_no,fault_no_list,fault_no);
task_training_no = task_training_no + 1;
        making_ready_for(task_training_no);
end
