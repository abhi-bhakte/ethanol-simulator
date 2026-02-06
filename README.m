%==========================================================================
%                    SINGLE SCREEN ETHANOL SIMULATOR
%==========================================================================
%
% OVERVIEW:
% --------
% This is a MATLAB-based process control simulator that combines a 
% Continuous Stirred Tank Reactor (CSTR) with an ethanol-water distillation 
% column system. The simulator is designed for human factors research, 
% operator training, and behavioral analysis in process control environments.
%
%==========================================================================
% SYSTEM ARCHITECTURE
%==========================================================================
%
% Core Process Models:
%   • CSTR Reactor: Chemical reaction A→B (Cyclopentadiene → Cyclopentenol)
%   • Distillation Column: 10-tray ethanol-water separation system
%   • Integrated Control System: 4 control valves with automatic/manual modes
%
%==========================================================================
% FILE STRUCTURE AND DOCUMENTATION
%==========================================================================
%
%--------------------------------------------------------------------------
% 1. MAIN SIMULATION FILES
%--------------------------------------------------------------------------
%
% Core Execution Files:
% ~~~~~~~~~~~~~~~~~~~~
%   start_experiment.m              - Primary entry point for experiments
%     → Initializes experiment parameters and participant ID
%     → Sets up fault scenarios and timing
%     → Manages eye tracking calibration (when enabled)
%     → Launches main simulation interface
%
%   main_file_kaushik_parameters.m  - Main simulation engine
%     → Orchestrates entire simulation process
%     → Implements fault injection scenarios (12 different fault types)
%     → Manages real-time data collection and logging
%     → Controls automatic/manual valve operations
%     → Handles simulation timing and speed control
%
% Process Model Functions:
% ~~~~~~~~~~~~~~~~~~~~~~~
%   cstr_kaushik.m                  - CSTR reactor differential equations
%     → Implements 4-state reactor model
%     → States: Concentration A, Concentration B, Reactor temp, Jacket temp
%     → Based on van der Vusse reaction kinetics
%
%   distillation_kaushik.m          - Distillation column differential equations
%     → Implements 10-state column model (mole fractions per tray)
%     → Includes feed tray and reboiler dynamics
%     → Uses Murphy tray efficiency model
%
%   func_x_y_ethanol_water.m        - Vapor-liquid equilibrium calculations
%     → Calculates vapor compositions from liquid compositions
%     → Uses polynomial correlation for ethanol-water system
%     → Applies Murphy tray efficiency corrections
%

%
%--------------------------------------------------------------------------
% 2. USER INTERFACE FILES
%--------------------------------------------------------------------------
%
% Main GUI Components:
% ~~~~~~~~~~~~~~~~~~~
%   gui_changed_color.m             - Primary graphical interface (1074 lines)
%     → Creates schematic display of process
%     → Implements interactive control panels
%     → Manages alarm displays and trending
%     → Handles mouse/keyboard interactions
%
%   gui_changed_color_training.m    - Training mode interface
%     → Simplified version for operator training
%     → Reduced complexity for learning purposes
%
% Support Functions:
% ~~~~~~~~~~~~~~~~~
%   making_ready_for.m              - Prepares simulation for next task/scenario
%   making_ready_for1.m             - Alternative preparation function
%   go_to_next.m                    - Transitions between experiment phases
%   ClearPlot.m                     - Resets plotting displays
%

%
%--------------------------------------------------------------------------
% 3. ALARM AND MONITORING SYSTEM
%--------------------------------------------------------------------------
%
% Alarm Management:
% ~~~~~~~~~~~~~~~~
%   monitoring\check_alarm_limit.m      - Monitors 11 process variables against limits
%     → Variables: F101, F102, T101, T102, F105, T106, T105, T104, T103, C101, L101
%     → Implements high/low alarm logic
%     → Manages alarm status and timing
%
%   monitoring\alarm_text_display.m     - Updates alarm summary panel
%   monitoring\alarm_beep.m             - Handles audio alarm notifications
%   alamrs_cstr.m                   - CSTR-specific alarm functions
%   monitoring\ascend_alarms.m          - Sorts alarms by priority/timing
%
% Data Collection:
% ~~~~~~~~~~~~~~~
%   monitoring\alarm_timing_database.m  - Logs alarm timing data
%   monitoring\alarm_timing_database1.m - Alternative alarm timing logger
%   get_location.m                  - Maps alarm IDs to process locations
%

%
%--------------------------------------------------------------------------
% 4. CONTROL SYSTEM FILES
%--------------------------------------------------------------------------
%
% Valve and Control Functions:
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   monitoring\check_for_stop.m         - Monitors emergency stop conditions
%   monitoring\check_for_stop_training.m - Training mode stop conditions
%
% Navigation and Flow Control:
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   name_for_trend.m                - Manages trending displays
%   name_uicontrol.m                - UI control naming functions
%   name_uicontrol_summary.m        - Summary panel controls
%
%--------------------------------------------------------------------------
% 5. DATA COLLECTION AND LOGGING
%--------------------------------------------------------------------------
%
% Eye Tracking Integration:
% ~~~~~~~~~~~~~~~~~~~~~~~~
%   eye_track_automatic.m           - Automated eye tracking data collection
%   eye_track_automatic1.m          - Alternative eye tracking implementation
%   eyetrackerdata_trackmap.m       - Eye tracking data processing
%   eyetrackerdata_trackmap_new_toolbox.m - Updated eye tracking tools
%   eyetracker.exe                  - Eye tracking executable
%   EyeTrackingSample.asv           - Eye tracking sample code
%   SetCalibParams.asv              - Eye tracker calibration parameters
%
% Mouse and Interaction Logging:
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   mouse_click_processing.m        - Processes mouse click data
%
% Feedback and Assessment:
% ~~~~~~~~~~~~~~~~~~~~~~~
%   feedback_form.m                 - Post-experiment questionnaire
%   feedback_form_case1.m           - Case-specific feedback form
%   feedback_form_combined.m        - Combined feedback assessment
%   feedback_form_gui.asv           - GUI-based feedback interface
%   feedback_per_task.m             - Task-specific feedback collection
%   feed_back.m                     - General feedback functions
%

%
%--------------------------------------------------------------------------
% 6. EXPERIMENTAL CONTROL FILES
%--------------------------------------------------------------------------
%
% Training and Execution:
% ~~~~~~~~~~~~~~~~~~~~~~
%   start_training_tasks.m          - Initiates training scenarios
%   run_training.m                  - Executes training sequence
%   run_experiment.m                - Runs experimental trials
%   start_experiment1.m             - Alternative experiment launcher
%
% Utility Functions:
% ~~~~~~~~~~~~~~~~~
%   setDesktopVisibility.m          - Controls desktop visibility during experiments
%   lower_tone.m                    - Audio feedback functions
%   get_location.m                  - Location mapping utilities
%   df.m                            - Data formatting functions
%
%--------------------------------------------------------------------------
% 7. DATA FILES AND OUTPUTS
%--------------------------------------------------------------------------
%
% Text-Based Data Files:
% ~~~~~~~~~~~~~~~~~~~~~
%   Introduction.txt                - Experiment session log with timestamps
%   feedback_for_tasks.txt          - Task-specific feedback responses
%   alarm_timing.txt                - Real-time alarm timing data
%   Mouse_click.txt                 - Mouse interaction log
%   task_no_2.txt, task_no_3.txt, task_no_5.txt - Task-specific data files
%
% Excel Data Outputs:
% ~~~~~~~~~~~~~~~~~~
% The simulator generates timestamped Excel files for each experimental session:
%
%   Alarm Timing Data:
%     Alarm_timing_case4_[timestamp].xlsx    - Alarm response timing analysis
%
%   Mouse Interaction Data:
%     Mouse_click_case4_[timestamp].xlsx     - Click locations and timing
%     Mouse_move_case4_[timestamp].xlsx      - Mouse movement trajectories
%
%   Process Data:
%     Process_data_case4_[timestamp].xlsx    - Complete process variable history
%
% MATLAB Data Files:
% ~~~~~~~~~~~~~~~~~
%   data\matlab-data\ch17b037_info_expD.mat - Experimental configuration data
%   data\matlab-data\flight_data.mat - Reference or comparison data
%
% Multimedia Files:
% ~~~~~~~~~~~~~~~~
%   Lower_alarm.wav                 - Alarm audio notification
%   scenario_completed_audio.mp3    - Task completion sound
%   scenario_completed_message.wav  - Audio message file
%   Final_video_cognitive.mp4       - Training or reference video
%   Thanks.jpg, Thanks - Copy.jpg   - Thank you display images
%   image.gif, image - Copy.gif     - GUI graphics
%   reflux_added_third_pos.jpg      - Process diagram image
%
% Eye Tracking Data:
% ~~~~~~~~~~~~~~~~~
%   gazedata/                       - Directory containing eye tracking data files
%   eye_track_data_02-Jul-2014_10_22_58  - Historical eye tracking session
%   eye_track_data_02-Jul-2014_10_36_26  - Historical eye tracking session
%

%
%--------------------------------------------------------------------------
% 8. DEVELOPMENT AND TESTING FILES
%--------------------------------------------------------------------------
%
% Development Files:
% ~~~~~~~~~~~~~~~~~
%   *.asv files                     - MATLAB auto-save backup versions
%   development\backup-files\delete_after_test.m - Test cleanup utilities
%   development\backup-files\delete_afetr_test.m - Test cleanup utilities  
%   development\backup-files\deleteafterexecute.m - Execution cleanup functions
%   DataCollect1.asv                - Data collection development file
%   punitji.m                       - Developer-specific utility file
%
% Temporary Files:
% ~~~~~~~~~~~~~~~
%   ~$[filename].xlsx               - Excel temporary lock files (when files open)
%
%==========================================================================
% PROCESS VARIABLES MONITORED
%==========================================================================
%
% CSTR Variables:
% ~~~~~~~~~~~~~~
%   1. F101 - Feed Flow Rate (L/hr)
%   2. F102 - Cooling Water Flow Rate (L/hr)
%   3. T101 - Cooling Water Temperature (°C)
%   4. T102 - Jacket Temperature (°C)
%   5. T103 - Temperature inside CSTR (°C)
%   6. C101 - Concentration of Ethanol (mol/L)
%   7. L101 - Level of CSTR (m)
%
% Distillation Variables:
% ~~~~~~~~~~~~~~~~~~~~~~
%   8. F105 - Flow rate to Distillation (L/hr)
%   9. T106 - Temperature of 3rd Tray (°C)
%  10. T105 - Temperature of 5th Tray (°C)
%  11. T104 - Temperature of 8th Tray (°C)
%
%==========================================================================
% FAULT SCENARIOS
%==========================================================================
%
% The simulator implements 12 different fault scenarios for training and research:
%
%   1. Feed flow reduction             - Reduced maximum possible feed to CSTR (simulates supply limitation or partial blockage by lowering V102.flowin after fault time)
%   2. Reaction rate change            - Modified reaction kinetics
%   3. Coolant flow reduction          - Reduced maximum possible coolant flow (simulates reduced cooling capacity by lowering V301.flowin after fault time)
%   4. Distillation flow reduction     - Reduced feed to distillation (after fault time, the distillation feed valve V201.valvepos is set to 0.5 ONCE, reducing flow by 50%; simulates partial blockage or valve malfunction, not a leak)
%   5. Reflux valve set high           - After fault time, the reflux valve (V401.valvepos) is set to 0.75 ONCE, simulating a malfunction (e.g., actuator or control error) that causes the valve to move to a high unintended position; controller can recover if enabled
%   6. Reboiler power reduction        - Reduced heating duty
%   7. Feed flow increase              - Excessive reactant feed (after fault time, the maximum possible feed flow V102.flowin is increased to 2.1 to simulate a stuck valve or operator error; actual flow is determined by valve position)
%   8. Coolant flow increase           - Excessive cooling (after fault time, the maximum possible coolant flow V301.flowin is increased to 480 to simulate a stuck valve or operator error; actual flow is determined by valve position)
%   9. Distillation  feed valve stuck  - Fixed distillation feed valve
%  10. Reflux valve set low            - After fault time, the reflux valve (V401.valvepos) is set to 0.4 ONCE, simulating a malfunction (e.g., actuator or control error) that causes the valve to move to a low unintended position; controller can recover if enabled
%  11. Feed flow leakage               - After fault time, a fixed amount is subtracted from the feed flow to simulate a leak in the feed line (loss of material regardless of valve position)
%  12. Coolant flow leakage            - After fault time, a fixed amount is subtracted from the coolant flow to simulate a leak in the coolant line (loss of coolant regardless of valve position)


%
%==========================================================================
% CONTROL SYSTEM
%==========================================================================
%
% Valve Control Objects:
% ~~~~~~~~~~~~~~~~~~~~~
%   V102 - Feed valve (Flow control)
%   V301 - Coolant valve (Temperature control)
%   V401 - Reflux valve (Composition control)
%   V201 - Distillation feed valve (Level control)
%
% Control Modes:
% ~~~~~~~~~~~~~
%   Automatic - PID control with setpoint tracking
%   Manual    - Direct operator manipulation
%   Emergency - Safety shutdown procedures
%
%==========================================================================
% INSTALLATION AND REQUIREMENTS
%==========================================================================
%
% MATLAB Requirements:
% ~~~~~~~~~~~~~~~~~~~
%   • MATLAB R2016b or later
%   • Signal Processing Toolbox
%   • Control System Toolbox
%
% Hardware Requirements (Optional):
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   • Eye tracker for gaze analysis
%   • Audio capability for alarm notifications
%   • Dual monitor setup recommended for operator interface
%
% Setup Instructions:
% ~~~~~~~~~~~~~~~~~~
%   1. Ensure all .m files are in MATLAB path
%   2. Verify audio files (.wav, .mp3) are accessible
%   3. Check image files (.jpg, .gif) are available for GUI
%   4. For eye tracking: Configure eyetracker.exe and calibration parameters
%
%==========================================================================
% USAGE
%==========================================================================
%
% Basic Operation:
% ~~~~~~~~~~~~~~~
%   1. Run start_experiment.m to begin a session
%   2. Enter participant ID when prompted
%   3. Complete eye tracker calibration (if enabled)
%   4. Operate process using GUI controls
%   5. Respond to alarms and fault conditions
%   6. Complete post-experiment feedback forms
%
% Training Mode:
% ~~~~~~~~~~~~~
%   1. Run start_training_tasks.m for training scenarios
%   2. Use simplified interface for learning
%   3. Practice fault diagnosis and response
%
% Data Analysis:
% ~~~~~~~~~~~~~
%   • Excel files contain timestamped experimental data
%   • Use MATLAB analysis scripts for behavioral metrics
%   • Eye tracking data available in gazedata/ directory
%
%==========================================================================
% RESEARCH APPLICATIONS
%==========================================================================
%
% This simulator supports research in:
%   • Human factors in process control
%   • Operator training effectiveness
%   • Alarm management system design
%   • Fault diagnosis performance
%   • Human-machine interface evaluation
%   • Cognitive workload assessment
%   • Eye tracking and attention analysis
%
%==========================================================================
% FILE NAMING CONVENTIONS
%==========================================================================
%
%   Main execution:    [function_name].m
%   GUI components:    gui_[description].m
%   Alarm functions:   alarm_[function].m
%   Data outputs:      [DataType]_case4_[DD-MMM-YYYY_HH_MM_SS].xlsx
%   Backup files:      [filename].asv
%   Utility functions: [descriptive_name].m
%
%==========================================================================
% DATA EXPORT FORMAT
%==========================================================================
%
% All experimental data is automatically exported in timestamped files:
%   • Excel format for quantitative analysis
%   • Text format for configuration logs
%   • MATLAB format for session parameters
%   • Audio/Video format for multimedia feedback
%
%==========================================================================
%
% This README provides a comprehensive overview of all 246 files in the 
% simulator package. Each file serves a specific purpose in the integrated 
% process control simulation and human factors research platform.
%
%==========================================================================