% Test script to verify API-based Fault Prediction
% Run this from the project root directory
% IMPORTANT: Make sure API server is running first!
% Start server with: cd explaination_module && python api_server.py

fprintf('Testing API-based Fault Prediction...\n');
fprintf('=========================================\n\n');

% Test with dummy process variables (11 values)
test_vars = [759.6335297, 141.203, 23.9737, 29.4825, 754.802, 78.199, 80.76478, 84.444, 30.935, 1464.473, 1.4589];
% F101_FeedFlow_Lhr
% F102_CoolantFlow_Lhr
% T101_CoolantTemp_C
% T102_JacketTemp_C
% F105_DistillFlow_Lhr
% T106_Tray3Temp_C
% T105_Tray5Temp_C
% T104_Tray8Temp_C
% T103_CSTRTemp_C
% C101_EthanolConc_molL (scaled by 1e6)
% L101_CSTRLevel_m (scaled by 1e1)

fprintf('Input variables:\n');
for i = 1:length(test_vars)
    fprintf('  Var %d: %.2f\n', i, test_vars(i));
end
fprintf('\n');

% Add utils to path
addpath('utils');

% Test API health first
fprintf('Checking API server health...\n');
try
    health = webread('http://127.0.0.1:5000/health');
    fprintf('  Status: %s\n', health.status);
    fprintf('  Model loaded: %d\n', health.model_loaded);
    fprintf('  Number of classes: %d\n\n', health.num_classes);
catch
    fprintf('  *** WARNING: Cannot reach API server! ***\n');
    fprintf('  Start the server with: cd explaination_module && python api_server.py\n\n');
end

% Call prediction
fprintf('Calling predict_fault_api...\n');
[fault_label, probabilities, confidence, explanation] = predict_fault_api(test_vars);

fprintf('\nResults:\n');
fprintf('  Predicted Fault: %d\n', fault_label);
fprintf('  Confidence: %.4f\n', confidence);
if ~isempty(probabilities)
    fprintf('  Probabilities: ');
    fprintf('%.4f ', probabilities);
    fprintf('\n');
else
    fprintf('  Probabilities: Empty (error occurred)\n');
end

if fault_label == -1
    fprintf('\n*** PREDICTION FAILED - Check error messages above ***\n');
    fprintf('Make sure API server is running:\n');
    fprintf('  cd explaination_module\n');
    fprintf('  python api_server.py\n');
else
    fault_name = get_fault_name(fault_label);
    fprintf('\n  Fault Name: %s\n', fault_name);
    fprintf('\n*** SUCCESS ***\n');
end
