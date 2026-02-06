% =========================================================================
% FUNCTION: main_file_kaushik_parameters
% =========================================================================
% Purpose: Runs the core simulation loop for the ethanol plant experiment.
%          Initializes process parameters, fault logic, noise models, and
%          streams real-time values to the GUI and alarm system.
%
% Inputs:
%   task_no       - Current task number (identifies which scenario is running)
%   fault_no_list - Array of fault scenario numbers for all tasks
%   fault_no      - Fault number for the current task
%
% Outputs:
%   None (updates global state, GUI elements, and logs)
%
% =========================================================================

function main_file_kaushik_parameters(task_no, fault_no_list, fault_no)

% -------------------------------------------------------------------------
% SECTION 1: PATH SETUP
% -------------------------------------------------------------------------
addpath('monitoring');
addpath('utils');
addpath('control');

% -------------------------------------------------------------------------
% SECTION 2: GLOBAL VARIABLE DECLARATIONS
% -------------------------------------------------------------------------
% clear alarm_var_store tag_for_plot
global ans_pv_1 ans_pv_2 ans_pv_3 ans_pv_4 ans_pv_5 ans_pv_6 ans_pv_7 ans_pv_8 ans_pv_9 ans_pv_10 ans_pv_11 varTrend tic_start x_temp1
global no_of_tasks es_flag task_complete_flag sequence_task
global intro_file leftEyeAll rightEyeAll timeStampAll
global f f2 V102 V301 V401 V201 f_ref f2_ref
global Start_Simu ans_11 ans_12 ans_13 ans_14
global slider_reflux slider_coolant slider_feed slider_flow_dist % sliders showing position of valve from 0 to 1 for flow control
global X_cstr_state Ts
global control_stat_reflux control_stat_feed control_stat_dist control_stat_cooling % showing state of controlling used
global cstr_level fid_click
global x curr_time
global FF k10 mKf R Qreb E1 Hr1 rho Cp kw AR VR mK CPK H1 H2 c1 c2 MT MD MB fault_time
global Ql F Tf zf Tbf Vs Hf Cf qf Vr V1 Ld Lr Ls D B TIMEUNITS_PER_HOUR
global TU_min k1 y
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
global time_track_for_experiment time_track_count t_start_exp
global flag_flow_distill flag_for_reflux
global time_for_process_var index_for_scenario
global slider_var_store  % V102 V301 V201 V401 temp_flag
global fault_prediction_text fault_prediction_axes
global fault_prediction_history time_prediction_history

% -------------------------------------------------------------------------
% SECTION 3: ALARM CONFIGURATION AND LABELS
% -------------------------------------------------------------------------
tag_for_plot = 1; % Default to F101 plot at startup
index_for_scenario = 0;
temp_flag = 0;  % for scenario 10
count_dist = 0;  % for scenario 4 (feed flow reduction to distillation)
number_var_alarms = 11;
alarm_var_tag_name = {'F101', 'F102', 'T101', 'T102', 'F105', 'T106', 'T105', 'T104', 'T103', 'C101', 'L101'};
alarm_upper_limit = [0.95*1e3 200 40 35 0.95*(0.6482/0.7)*1.129623*1e3 80.4 89.5 100.5 33 ((1/18) - 0.0540)*1e3*1e3 (0.1858*1e3)/(1e2)];
alarm_lower_limit = [0.55*1e3 80 0 15.2 0.55*(0.6482/0.7)*1.129623*1e3 78.5 86.5 98.5 29.5 ((1/18) - 0.0546)*1e3*1e3 0];

intro_file = fopen('data\text-logs\Introduction.txt', 'at+');

description_of_alarms = {'Feed Flow Rate', 'Cooling Water Flow Rate', 'Cooling Water Temperature', 'Jacket Temperature', 'Flow rate to Distillation', 'Temperature of 3rd Tray', 'Temperature of 5th Tray', 'Temperature of 8th Tray', 'Temperature inside CSTR', 'Concentration of Ethanol', 'Level of CSTR'};
s_deg = sprintf(' %cC', char(176));
uni = {' L/hr'; ' L/hr'; s_deg; s_deg; ' L/hr'; s_deg; s_deg; s_deg; s_deg; ' mol/L'; ' m'};

% -------------------------------------------------------------------------
% SECTION 4: TIMING, FLAGS, AND CONSTANTS
% -------------------------------------------------------------------------
number_of_samples_per_sec = 145; % calculated by running a loop at (avg basis)
speedx = 80; % scaling for world clock (max ~145x)
cA0 = 1/18;
err_ind_feed = 0;
err_ind_cool = 0;
err_ind_reflux = 0;
err_ind_dist  = 0;

% Update here if adding new process variables in GUI
alarm_status = zeros(1, number_var_alarms);
flag_for_alarm = zeros(1, number_var_alarms);
date_vec = zeros(number_var_alarms, 6);
time_vec = zeros(number_var_alarms, 20);

set(Start_Simu, 'UserData', 1);
error_count = 1;

N = 180; % for 3 minutes
Ts = 1;  % Process sampling time for ode15s (process running time)

volm = 0.2; % l
cstr_feed_valve = FF / 7;

R = 0.9; % Reflux fraction

time_duration_seconds = 150; % four minutes durations
count_ref = 0;


% -------------------------------------------------------------------------
% SECTION 5: INITIAL STATES FOR WHOLE SETUP
% -------------------------------------------------------------------------
%============INITIAL CONDITIONS by kaushkik=====================
x_initial = [0.054189182040791 0.001366373514770 3.037294916114016e+02 3.025542614394507e+02 1 0.894000003246616 0.730388652781846 0.574718575473013 0.363664773653394 0.091480578882567 0.024177207681576 0.005194979500616 9.571081707482047e-04 -1.982433505631396e-06]';

x = x_initial; % x is used for differential equation
cstr_x_initial = x_initial(1:4)';
distill_x_initial = x_initial(5:end)';

X_cstr_state = cstr_x_initial';
X_distill_state = distill_x_initial';


distill_bottom_flow_rate = 0.625;
distill_up_flow_rate = 0.025;

x1 = x; % For tic to toc loop
cstr_vol_ss = 133.33; % Cstr level at steady state in ml
cstr_total_height = 0.1858; % Actual height of cstr tank in cm at vol 200 ml

cstr_level = (cstr_total_height / 1.5); % cstr height at vol 133.33ml

% -------------------------------------------------------------------------
% SECTION 6: NOISE MODELS
% -------------------------------------------------------------------------
% 0.01   = Original noise levels (very small, plots look noiseless)
% 0.05  = 5x amplification (subtle noise visible)
% 0.10  = 10x amplification (recommended for realistic 1-2% sensor noise)
% 0.20  = 20x amplification (strong noise for challenging scenarios)
noise_amplitude_factor = 0.2; 

% Calculate noise amplitude for each alarm variable
noise_amplitude = (alarm_upper_limit - alarm_lower_limit)

% State noise based on alarm limits for known process variables
% State mapping: 1=cA, 2=cB(C101), 3=theta(T103), 4=thetaK(T102), 5-14=distillation
for i = 1:length(x_initial)
    if i == 2  % cB → C101 (alarm index 10)
        State_Noise_Matrix(i, 1:(N + 1)) = noise_amplitude_factor * noise_amplitude(10) * 1e-6 * rand(1, N + 1);
    elseif i == 3  % theta → T103 (alarm index 9)
        State_Noise_Matrix(i, 1:(N + 1)) = noise_amplitude_factor * noise_amplitude(9) * rand(1, N + 1);
    elseif i == 4  % thetaK → T102 (alarm index 4)
        State_Noise_Matrix(i, 1:(N + 1)) = noise_amplitude_factor * noise_amplitude(4) * rand(1, N + 1);
    else  % Other states - use default noise
        State_Noise_Matrix(i, 1:(N + 1)) = noise_amplitude_factor * 0.05 .* sqrt(1e-7) * rand(1, N + 1);
    end
end

cstr_level_noise(1:N + 1) = noise_amplitude_factor * noise_amplitude(11) * 1e-1  * rand(1, N + 1);
FF_noise(1:N + 1) = noise_amplitude_factor * noise_amplitude(1) * 1e-3 * rand(1, N + 1);
mKf_noise(1:N + 1) = noise_amplitude_factor * noise_amplitude(2) * rand(1, N + 1);
F_noise(1:N + 1) = noise_amplitude_factor * noise_amplitude(5) * (1e-3 / 1.129623) * rand(1, N + 1);
thetaKin_noise(1:N + 1) = noise_amplitude_factor * noise_amplitude(3) * rand(1, N + 1);


% Sensor noise in temperature noise
% Apply specific noise for known tray temperatures (T106, T105, T104) based on alarm limits
% For other trays, use default uniform noise
for i = 1:length(distill_x_initial) - 1
    if i == 3  % T106 - tray 3 (alarm index 6)
        output_error_matrix(i, 1:(N + 1)) = noise_amplitude_factor * noise_amplitude(6)  * rand(1, N + 1);
    elseif i == 5  % T105 - tray 5 (alarm index 7)
        output_error_matrix(i, 1:(N + 1)) = noise_amplitude_factor * noise_amplitude(7) *  rand(1, N + 1);
    elseif i == 8  % T104 - tray 8 (alarm index 8)
        output_error_matrix(i, 1:(N + 1)) = noise_amplitude_factor * noise_amplitude(8) *  rand(1, N + 1);
    else  % Other trays - use default uniform noise
        output_error_matrix(i, 1:(N + 1)) = noise_amplitude_factor * 0.05 .* sqrt(1e-1) * rand(1, N + 1);
    end
end

% -------------------------------------------------------------------------
% SECTION 7: INPUTS AND PROCESS PARAMETERS
% -------------------------------------------------------------------------

% Rate constant of Reaction A->B
k10 = 5.187e11;

% Coolant Mass flow rate (g/h)
cool_jacket_valve = mKf / (6.5e3 / 50);

% Reboiler power
Qreb = 800;

% Heat transfer coefficient between jacket and reactor
kw = 4032e3; % J/hr-m^2-K

% -------------------------------------------------------------------------
% SECTION 8: PROCESS PARAMETERS
% -------------------------------------------------------------------------

% Arrehnius law parameters
% Reaction A->B
% Activation energy (K )
E1 = -8930.3; 

% J/mol  % Heat of reaction A->B (delH1)
Hr1 = -11e3; 


% Density of reactor fluid (g/mL)
rho = 0.9942; 

% Heat capacity of reactor fluid (J/g-K)
Cp = 3.01;

% Heat transfer coefficient between jacket and reactor (J/hr-m^2-K)
kw = 4032e3;

% Surface area for cooling (m^2)
AR = 0.215 / 50;

% Volume of the CSTR (mL)
VR = 200;

% Coolant Mass (g)
mK = 5e3 / 50; 

% Coolant Heat Capacity (J/g-K)
CPK = 4.186;


% Value of H1 and H2
% Heat of vapourization of pure B (Ethanol) (J/mole)---delHva
H1 = 33.99e3; 
% Heat of vapourization of pure A (Water) (J/mole)-----delHvb
H2 = 40.656e3; 

% Specific Heat pure B (Ethanol) (J/mole K)
c1 = 0.1309e3; 
% Specific Heat pure A (Water) (J/mole K)
c2 = 0.0754e3; 

% Molar hold-up on Tray (mole)
MT = 1.0; 
% Molar hold-up in Reflux Drum (mole)
MD = 0.5;
% Molar hold-up in Rebioler (mole)
MB = 325; 

% Murphy Tray Efficeincy of each tray--------eta_T
Eff = 0.7; 

% Heat loss from the reboiler of distillation column (watt=J/s) ----Q_loss
Ql = 250; 

% -------------------------------------------------------------------------
% SECTION 9: INITIAL VALUES (STARTUP SETTINGS)
% -------------------------------------------------------------------------
% These are not initial values for states
es_flag
% Feed temperature (K)
theta0 = 28 + 273.15; 

% Coolant inlet Temperature (K)
thetaKin = 20 + 273.15;

% -------------------------------------------------------------------------
% SECTION 10: MAIN SIMULATION LOOP
% -------------------------------------------------------------------------
tic_start = tic;
i = 1; % this i is used for storing per second (world clock) values.
% for ol = 50002:50002+N
while toc(tic_start) < time_duration_seconds % for defining how much long a scenario

    if es_flag ~= 1 || task_complete_flag ~= 1
        set(curr_time, 'visible', 'on', 'String', datestr(now), 'backgroundcolor', [127 127 127] ./ 255, 'foregroundcolor', [0 0 0]);

        % i = ol - 50001;

        Flow_inlet = V102.flowin * V102.valvepos;
        mKf = V301.flowin * V301.valvepos;

        % converting to 2 decimal points (changed to percentage value)
        set(ans_11, 'String', sprintf('%d', round(V102.valvepos * 100)));
        set(ans_12, 'String', sprintf('%d', round(V301.valvepos * 100)));
        set(ans_13, 'String', sprintf('%d', round(V401.valvepos * 100)));
        set(ans_14, 'String', sprintf('%d', round(V201.valvepos * 100)));
        set(slider_feed, 'Value', V102.valvepos);
        set(slider_coolant, 'Value', V301.valvepos);
        set(slider_flow_dist, 'Value', V201.valvepos);
        set(slider_reflux, 'Value', V401.valvepos);
    end
    
    % ---------------------------------------------------------------------
    % Fault injection logic
    % ---------------------------------------------------------------------
    
    switch fault_no
        
        case 1
            % Fault 1: Feed flow reduction
            % After the specified fault time, the maximum possible feed flow (V102.flowin)
            % is reduced to 0.8 to simulate a supply limitation or partial blockage.
            % The actual flow to the reactor is then determined by the valve position.
            if toc(tic_start) > fault_time(1)
                V102.flowin = 0.8;
                Flow_inlet = (V102.flowin * V102.valvepos);
            end

        case 2
            if toc(tic_start) > fault_time(2)
                k10 = 2e9;
            end

        case 3
            % Fault 3: Coolant flow reduction
            % After the specified fault time, the maximum possible coolant flow (V301.flowin)
            % is reduced to 130 to simulate reduced cooling capacity (e.g., pump limitation or partial blockage).
            % The actual coolant flow is then determined by the valve position.
            if toc(tic_start) > fault_time(3)
                V301.flowin = 130;
                mKf = (V301.flowin * V301.valvepos);
            end

        case 4
            % Fault 4: Feed flow reduction to distillation column
            % After the specified fault time, the valve position (V201.valvepos) is set to 0.5 ONCE, reducing the feed flow to the distillation column by 50%.
            % This simulates a partial blockage or valve malfunction in the feed line to the column (not a leak).
            % The flag 'count_dist' ensures the fault is applied only once, so the controller can later recover the valve position if enabled.
            % No additional subtraction or leakage is applied in the flow calculation; the reduction is purely via valve position.
            if toc(tic_start) > fault_time(4)
                if count_dist == 0
                    V201.valvepos = 0.5;  % Apply fault: reduce valve position to 50%
                    count_dist = 1;
                end
            end

        case 5
            % Fault 5: Reflux valve malfunction
            % After the specified fault time, the reflux valve (V401.valvepos) is set to 0.75 ONCE, simulating a malfunction (e.g., actuator or control error) that causes the valve to move to an unintended position.
            % The flag 'count_ref' ensures the fault is applied only once, so the controller can later recover the valve position if enabled.
            if toc(tic_start) > fault_time(5)
                if count_ref == 0
                    V401.valvepos = 0.75;
                    count_ref = 1;
                end
            end

        case 6
            if toc(tic_start) > fault_time(6)
                Qreb = 300;
            end

        case 7
            % Fault 7: Feed flow increase
            % After the specified fault time, the maximum possible feed flow (V102.flowin)
            % is increased to 2.1 to simulate excessive reactant feed (e.g., valve stuck open or operator error).
            % The actual flow to the reactor is then determined by the valve position.
            if toc(tic_start) > fault_time(7)
                V102.flowin = 2.1;
                Flow_inlet = (V102.flowin * V102.valvepos);
            end

        case 8
            % Fault 8: Coolant flow increase
            % After the specified fault time, the maximum possible coolant flow (V301.flowin)
            % is increased to 480 to simulate excessive cooling (e.g., valve stuck open or operator error).
            % The actual coolant flow is then determined by the valve position.
            if toc(tic_start) > fault_time(8)
                V301.flowin = 480;
                mKf = (V301.flowin * V301.valvepos);
            end

        case 9
            % if i > fault_time(fault_no_list(9)) && flag_flow_distill == 0 && control_stat_dist == 2
            if toc(tic_start) > fault_time(9)
                V201.valvepos = 0.25;
            end

        case 10
            % Fault 10: Reflux valve malfunction
            % After the specified fault time, the reflux valve (V401.valvepos) is set to 0.4 ONCE, simulating a malfunction (e.g., actuator or control error) that causes the valve to move to an unintended position.
            % The flag 'temp_flag' ensures the fault is applied only once, so the controller can later recover the valve position if enabled.
            if toc(tic_start) > fault_time(10)
                if temp_flag == 0
                    V401.valvepos = 0.4;
                    temp_flag = 1;
                end
            end
      
        case 11
            % Fault 11: Feed flow leakage
            % After the specified fault time, a fixed amount (0.2 units) is subtracted from the feed flow to the reactor.
            % This simulates a leak in the feed line, causing a loss of material regardless of valve position.
            if toc(tic_start) > fault_time(11)
                Flow_inlet = (V102.flowin * V102.valvepos) - 0.2;
            end

        case 12
            % Fault 12: Coolant flow leakage
            % After the specified fault time, a fixed amount (100 units) is subtracted from the coolant flow.
            % This simulates a leak in the coolant line, causing a loss of coolant regardless of valve position.
            if toc(tic_start) > fault_time(12)
                mKf = (V301.flowin * V301.valvepos) - 100;
            end

%         case 13 
%             if i > 50
%                 thetaKin = 12 + 273.15;
%             end
    end
    
    FF = Flow_inlet / volm; % This is .7(l/h) / 200ml to get FF

    F101_store(i) = Flow_inlet + FF_noise(i);
    F102_store(i) = mKf + mKf_noise(i);
    T101_store(i) = thetaKin + thetaKin_noise(i);
    
    % ---------------------------------------------------------------------
    % State extraction (total 14 states)
    % ---------------------------------------------------------------------
    % Concentration of A in the reactor (mol/mL)
    cA = x(1);
    
    % Concentration of B in the reactor (mol/mL)
    cB = x(2);
    % Temperature of reactor fluid (deg K)
    theta = x(3);
    
    % Temperature of cooling fluid (deg K)
    thetaK = x(4);

    % ---------------------------------------------------------------------
    % Controller updates
    % ---------------------------------------------------------------------

    if es_flag ~= 1 || task_complete_flag ~= 1
        V201.flowin = FF * VR * (cA + cB) * (1 / 60);
        V201.flowfinal = V201.flowin * V201.valvepos;

        % Feed flow to distillation column (F):
        % Under normal operation, F = V201.flowfinal.
        % If Case 4 fault is active, V201.valvepos is set to 0.5 (see above), so F is automatically reduced.
        % No additional subtraction or leakage is applied here; the reduction is purely via valve position.
        F = V201.flowfinal;
        if F < 0
            F = 0;
        end

        F105_store(i) = F + F_noise(i);

        R_des = V401.flowin * V401.valvepos;
        R = (V401.flowin - R_des) / R_des;
    end

    Tf = x(3) - 273.15; % Distillation column feed temperature (deg C)
    
    %%
    
    zf = cB / (cA + cB); % Mole fraction of B in distillation column feed-------xF
    % See Tbf in degree celsius
    
    %% ------------------------ CHECK---------------------
    
    %===================Temperature polynomial==========================
    pt = 1e+004 .* [-0.5309 2.6189 -5.5894 6.7753 -5.1579 2.5764 -0.8544 0.1849 -0.0253 0.0100];
    %====================================================================
    % model_based_FDI_ethanol_water_new.m also in
    % pt is a polynomial function
    Tbf = polyval(pt, zf); % Bubble point temperature of distillation column feed (deg C)
    
    
    %%
    %Molar flow rate of vapour phase in stripping section (mol/min)-----Vs
    
    Vs = ((Qreb - Ql) * 60) / ((H1 * x(14)) + (H2 * (1 - x(14))));
    
    Hf = zf * H1 + (1 - zf) * H2; % Heat of vaporization of distillation column feed (J/mole)
    Cf = zf * c1 + (1 - zf) * c2; % Specific Heat of distillation column feed (J/mole)
    qf = 1 + ((Cf * (Tbf - Tf)) / Hf); % distillation column feed quality (dimensionless)
    Vr = Vs + F * (1 - qf); % Molar Flow rate of vapor phase in rectifying section (mol/min)
    
    Td = 30.5;
    TDb = polyval(pt, x(5)); % Bubble point temperature of Distillate (deg C)
    Hd = x(5) * H1 + (1 - x(5)) * H2; % Heat of vaporization of distillate (J/mole)
    Cd = x(5) * c1 + (1 - x(5)) * c2; % Specific heat of Distillate (J/mole)
    qd = 1 + ((Cd * (TDb - Td)) / Hd); % Distillate Quality
    V1 = Vr / (1 - R * (1 - qd)); % Molar flow rate of vapour phase from tray 1 (mol/min)
    %%
    
    %   V1=Vr; %---------by putting qd  =  1 in previous equation
    % Molar flow rate of vapour phase from tray 1 - top tray (mol/min)
    %qd is distillate quality
    
    Ld = R * V1;
    % Molar flow rate of Liq phase flow rate to column (mol/min)
    
    Lr = qd * Ld;
    %  Lr = Ld;
    % Molar flow rate of vapour phase in rectifying section (mol/min)
    
    Ls = Lr + F * qf;
    % Molar flow rate of vapour phase in stripping section (mol/min)
    
    D = Vr - Lr;
    if D < 0
        D = 0;
    end
    % Molar flow rate of Top product (mol/min)
    
    B = F - D;
    if B < 0
        B = 0;
    end
    %     B = .625;
    %     D = .025;
    % Molar flow rate of bottom product (mol/min)
    %----------------------CHECK--------------------
    k1 = k10 * exp(E1 / (x(3))); % theta = x(3)
    % Arrhenious Equation of Rate Constant
    %% CSTR state equation by ODE15S
    TIMEUNITS_PER_HOUR = 3600;
    TU_min = 60;
    t_run = 1;
    time_c = 1;
    cstr_x_initial1 = cstr_x_initial;
    distill_x_initial1 = distill_x_initial;
    tStart = tic;
    while toc(tStart) < t_run
        % speedx is used for speeding up the process
        for k_speed = 1:speedx
            [~, cstr_state1] = ode15s(@cstr_kaushik, [(time_c - 1) * Ts time_c * Ts], cstr_x_initial1);

            X_cstr_state1(1:4, time_c + 1) = cstr_state1(end, :)';

            cstr_x_initial1 = cstr_state1(end, :)';
            x1(1:4) = cstr_state1(end, :)';
            
            
            
            
            pe12 = 1e+004 .* [-0.3118 1.5082 -3.1538 3.7380 -2.7695 1.3368 -0.4263 0.0897 -0.0123 0.0011 0.0000];
            y = func_x_y_ethanol_water(pe12, Eff, x1(5:end)); % 10 by 1s

            [~, distill_state1] = ode15s(@distillation_kaushik, [(time_c - 1) * Ts time_c * Ts], distill_x_initial1);

            X_distill_state1(1:10, time_c + 1) = distill_state1(end, :)';
            distill_x_initial1 = distill_state1(end, :)';
            x1(5:14) = distill_state1(end, :)';
            time_c = time_c + 1;
        end
        pause(t_run - toc(tStart));
    end
    
 
    X_cstr_state(1:4, i + 1) = X_cstr_state1(1:4, time_c - 1);

    cstr_x_initial = cstr_state1(end, :)';
    x(1:4) = cstr_state1(end, :)';
   
    X_distill_state(1:10, i + 1) = X_distill_state1(1:10, time_c - 1);
    distill_x_initial = distill_state1(end, :)';
    x(5:end) = distill_state1(end, :)';
    
    T103_store(i) = X_cstr_state(3, i + 1) + State_Noise_Matrix(3, i);
    T102_store(i) = X_cstr_state(4, i + 1) + State_Noise_Matrix(4, i);
    C101_store(i) = X_cstr_state(2, i + 1) + State_Noise_Matrix(2, i);
      
    
    
    
    %% Output equations of Distillation Column
    
      
    Tout(:, i) = polyval(pt, x(6:end)); % Dimension is 9 by 1 with noise
    
    T106_store(i) = Tout(3, i) + output_error_matrix(3, error_count);
    T105_store(i) = Tout(5, i) + output_error_matrix(5, error_count);
    T104_store(i) = Tout(8, i) + output_error_matrix(8, error_count);
    
    error_count = error_count + 1;
    L101_store(i) = cstr_level + cstr_level_noise(i);
    if es_flag ~= 1 || task_complete_flag ~= 1
        alarm_var_store(1:number_var_alarms, i) = [F101_store(i) * 1e3 F102_store(i) T101_store(i) - 273.15 T102_store(i) - 273.15 F105_store(i) * 1.129623 * 1e3 T106_store(i) T105_store(i) T104_store(i) T103_store(i) - 273.15 C101_store(i) .* 1e6 L101_store(i) .* 1e1]';
        temp_valveposition = sprintf('%.2f', V401.valvepos);
        slider_var_store(1:4, i) = [V102.valvepos V301.valvepos V201.valvepos str2num(temp_valveposition)]';

        time_temp = toc(t_start_exp);
        time_for_process_var(i, 1:2) = [floor(time_temp) time_temp - floor(time_temp)];
        index_for_scenario = i;
        
        % AI Fault Prediction - Call API endpoint
        try
            process_vars = alarm_var_store(1:number_var_alarms, i)';
            [predicted_fault, probabilities, confidence, explanation] = predict_fault_api(process_vars);
            
            % Store prediction history
            fault_prediction_history(end+1) = predicted_fault;
            time_prediction_history(end+1) = time_temp;
            
            % Display in MATLAB command window
            if predicted_fault == 0
                % Normal operation - show centered green text only
                normal_text = sprintf('\n\n\n\n\n    PROCESS NORMAL');
                set(fault_prediction_text, 'String', normal_text);
                set(fault_prediction_text, 'ForegroundColor', [0 0.6 0]); % Green color
                set(fault_prediction_text, 'FontSize', 16);
                set(fault_prediction_text, 'HorizontalAlignment', 'center');
                fprintf('[Time: %.2fs] AI Prediction: Normal Operation | Confidence: %.3f\n', ...
                        time_temp, confidence);
            else
                % Fault detected - show fault name and top 3 variables with human-readable names
                fault_name = get_fault_name(predicted_fault);
                
                % Mapping of variable codes to human-readable names
                var_names = containers.Map(...
                    {'F101_FeedFlow_Lhr', 'F102_CoolantFlow_Lhr', 'T101_CoolantTemp_C', ...
                     'T102_JacketTemp_C', 'T103_CSTRTemp_C', 'C101_EthanolConc_molL', ...
                     'L101_CSTRLevel_m', 'F105_DistillFlow_Lhr', 'T106_Tray3Temp_C', ...
                     'T105_Tray5Temp_C', 'T104_Tray8Temp_C'}, ...
                    {'Reactor Feed Flow (F101)', 'Reactor Coolant Flow (F102)', 'Reactor Coolant Temperature (T101)', ...
                     'Reactor Jacket Temperature (T102)', 'Reactor Temperature (T103)', 'Reactor Concentration (C101)', ...
                     'Reactor Level (L101)', 'Distillation Feed Flow (F105)', 'Tray 3 Temperature (T106)', ...
                     'Tray 5 Temperature (T105)', 'Tray 8 Temperature (T104)'});
                
                % Build formatted text with fault name only
                fault_text = sprintf('%s\n', fault_name);
                fault_text = sprintf('%s═══════════════════════════\n', fault_text);
                
                if isfield(explanation, 'top_features') && ~isempty(explanation.top_features)
                    top_3 = explanation.top_features(1:min(3, length(explanation.top_features)));
                    for j = 1:length(top_3)
                        feature_code = top_3(j).feature;
                        % Get human-readable name, fallback to original if not in map
                        if isKey(var_names, feature_code)
                            feature_name = var_names(feature_code);
                        else
                            feature_name = feature_code;
                        end
                        fault_text = sprintf('%s\n%d. %s', fault_text, j, feature_name);
                    end
                end
                
                set(fault_prediction_text, 'String', fault_text);
                set(fault_prediction_text, 'ForegroundColor', [0.545 0.271 0.075]); % Brown color
                set(fault_prediction_text, 'FontSize', 12);
                fprintf('[Time: %.2fs] AI Prediction: %s | Confidence: %.3f\n', ...
                        time_temp, fault_name, confidence);
            end
        catch ME
            % If prediction fails, just continue without crashing
            warning('Fault prediction failed: %s', ME.message);
        end
    end
    [status, hi_lo] = check_alarm_limit(i);

    if es_flag ~= 1 || task_complete_flag ~= 1
        if i > 2 && tag_for_plot ~= 0
            plot_trend(i * Ts)
        end
    end
    %% Alarm timing database manage
    
    %% Displaying Measured variables values
    if es_flag ~= 1 || task_complete_flag ~= 1
        alarm_text_display(i)
    end
    %% Demo for using valve
    
  
    alarm_timing_database(i, task_no, fault_no);
    
    %=======================Controller for Input feed valve====================
    if Flow_inlet ~= V102.setpoint
        if control_stat_feed == 0
            er_feed(err_ind_feed + 1) = ((1 / (V102.flowin)) * (V102.setpoint - Flow_inlet));
            V102 = autocontrol(V102, er_feed);
            if Flow_inlet == V102.setpoint
                err_ind_feed = 0;
            else
                err_ind_feed = err_ind_feed + 1;
            end
        end
    end
    %    ==========================================================================
    
    
    %=======================Controller for Coolant Valve=======================
    if mKf ~= 130
        if control_stat_cooling == 0
            er_cool(err_ind_cool + 1) = ((1 / (V301.flowin)) * (V301.setpoint - mKf));
            V301 = autocontrol(V301, er_cool);
            if mKf == V301.setpoint
                err_ind_cool = 0;
            else
                err_ind_cool = err_ind_cool + 1;
            end
        end
    end
    
    
    
    %============================Controller for Reflux Valve===================
    
    if R_des ~= 1
        if control_stat_reflux == 0
            er_reflux(err_ind_reflux + 1) = ((1 / (V401.flowin)) * (1 - R_des)); % 1 is taken as set point for R_des
            V401 = autocontrol(V401, er_reflux);

            if R_des == 1
                err_ind_reflux = 0;
            else
                err_ind_reflux = err_ind_reflux + 1;
            end
        end
    end
    %========================Controller between CSTR and distillaton column ===========================
    
    if F ~= V201.setpoint
        if control_stat_dist == 0
            V201.valvepos = V201.valvepos + (0.25 * ((1 / (V201.flowin)) * (V201.setpoint - F)));
            if V201.valvepos > 1
                V201.valvepos = 1;
            end
            V201.flowout = V201.valvepos * V201.flowin;
            V201.flowfinal = V201.flowout;
            set(slider_flow_dist, 'Value', V201.valvepos);
        end
    end
    
     
    %====================liquid level check=========================
    if V201.valvepos ~= 1 % Checking for liquid level in tank
        % 1.129623 factor is added to show value in lt/hr
        change_in_vol = (V201.flowin - V201.flowfinal) * 1.129623; % in lt/hr
        change_in_vol_per_sec = (change_in_vol) * (Ts / 3600); % change in vol per second
        cstr_level = cstr_level + (change_in_vol_per_sec) * (cstr_total_height / 0.2);
    end
    
    
    %================ For checking Stop ===================================
    if es_flag ~= 1 || task_complete_flag ~= 1
        if i > 20
            check_for_stop(i, task_no, fault_no_list, fault_no)
        end
    end
    %======================================================================
    if es_flag == 1 || task_complete_flag == 1
        close(f)
        close(f2);
        task_no = task_no + 1;
        if task_no <= no_of_tasks
            fault_no = fault_no_list(task_no);
        end
        making_ready_for(task_no, fault_no_list, fault_no)
        break;
    end


% if any(get(f,'Position')~=f_ref)
%         set(f,'Position',f_ref);
%     end
%     
%     if any(get(f2,'Position')~=f2_ref)
%         set(f2,'Position',f2_ref);
%     end


    i = i + 1;
    
end
% TrackStop
if es_flag ~= 1 || task_complete_flag ~= 1
    task_complete_flag = 1;
    time_track_count = time_track_count + 1;
    time_track_for_experiment(time_track_count) = toc(t_start_exp);

    fprintf(intro_file, 'Automatic Shutdown \n');
    set(ans_29, 'visible', 'on', 'fontweight', 'bold', 'String', 'Automatic ShutDown!!!');
    set(esd_box, 'visible', 'off');
    te = toc(t_start_exp);
    fprintf(fid_click, '%d     %.6f  %.2f   %.2f    %d   %s %.2f \n', floor(te), (te - floor(te)), 0, 0, 0, 'Automatic_Shutdown', 0);
    pause(1);
    close(f);
    close(f2);

    [a_c, b_c, c_c, d_c, e_c, f_c, g_c] = textread('data\text-logs\Mouse_click.txt', '%s %s %s %s %s %s %s', 'whitespace', ' ', 'bufsize', 10000);
    ty = time_start_first;
    ty([12 15 18]) = '_';
    global id_num;
    if ~isempty(a_c) && ~isempty(b_c) && ~isempty(c_c) && ~isempty(d_c) && ~isempty(e_c) && ~isempty(f_c) && ~isempty(g_c)
        eval(sprintf('xlswrite(''data\\excel-outputs\\Mouse_click_%s_%s.xlsx'',[a_c b_c c_c d_c e_c f_c g_c],%d);', id_num, ty, task_no));
    end

    fclose(fid_click);
    %-------------------------------alarm timing0----------------------
    [a_a, b_a, c_a] = textread('data\text-logs\alarm_timing.txt', '%s %s %s', 'whitespace', ' ', 'bufsize', 10000);
    ty = time_start_first;
    ty([12 15 18]) = '_';
    if ~isempty(a_a) && ~isempty(b_a) && ~isempty(c_a)
        eval(sprintf('xlswrite(''data\\excel-outputs\\Alarm_timing_%s_%s.xlsx'',[a_a b_a c_a],%d);', id_num, ty, task_no));
    end

    %% Writing to process data
    process_var_store = [time_for_process_var(1:index_for_scenario, :) alarm_var_store(1:number_var_alarms, 1:index_for_scenario)' slider_var_store(1:4, 1:index_for_scenario)'];
    ty = time_start_first;
    ty([12 15 18]) = '_';
    eval(sprintf('xlswrite(''data/excel-outputs/Process_data_%s_%s.xlsx'',process_var_store,%d);', id_num, ty, task_no));

    [a_c, b_c, c_c, d_c, e_c, f_c] = textread('data\text-logs\task_no.txt', '%s %s %s %s %s %s', 'whitespace', ' ', 'bufsize', 10000);
    ty = time_start_first;
    ty([12 15 18]) = '_';
    if ~isempty(a_c) && ~isempty(b_c) && ~isempty(c_c) && ~isempty(d_c) && ~isempty(e_c) && ~isempty(f_c)
        eval(sprintf('xlswrite(''data\\excel-outputs\\Mouse_move_%s_%s.xlsx'',[a_c b_c c_c d_c e_c f_c],%d);', id_num, ty, task_no));
    end
    fclose(fid_mouse_move);
    pause(1);

    time_track_count = time_track_count + 1;
    time_track_for_experiment(time_track_count) = toc(t_start_exp);

    task_no = task_no + 1;
    if task_no <= no_of_tasks
        fault_no = fault_no_list(task_no);
    end
    making_ready_for(task_no, fault_no_list, fault_no)

    % feedback_form_case1();
end
end

