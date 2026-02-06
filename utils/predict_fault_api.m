% =========================================================================
% FUNCTION: predict_fault_api
% =========================================================================
% Purpose: Calls REST API endpoint to predict fault from process variables.
%          Uses HTTP requests instead of Python integration.
%
% Inputs:
%   process_vars - Array of 11 process variables in order:
%                  [F101, F102, T101, T102, F105, T106, T105, T104, T103, C101, L101]
%   api_url      - (Optional) API URL. Default: 'http://127.0.0.1:5000/predict'
%
% Outputs:
%   fault_label   - Predicted fault number (0 = normal, 1-12 = fault case)
%   probabilities - Array of probabilities for each class
%   confidence    - Confidence score (max probability)
%   explanation   - Struct with feature attributions and top features
%
% Example:
%   vars = [700, 150, 20, 25, 500, 79, 88, 99, 30, 54000, 1.2];
%   [label, probs, conf, explanation] = predict_fault_api(vars);
%
% =========================================================================

function [fault_label, probabilities, confidence, explanation] = predict_fault_api(process_vars, api_url)
    % Default API endpoint
    if nargin < 2
        api_url = 'http://127.0.0.1:5000/predict';
    end
    
    % Validate input
    if length(process_vars) ~= 11
        error('Expected 11 process variables, got %d', length(process_vars));
    end
    
    % Initialize explanation as empty struct (in case of error)
    explanation = struct();
    
    try
        % Prepare JSON data
        data = struct('features', process_vars(:)');  % Ensure row vector
        json_data = jsonencode(data);
        
        % Configure HTTP options
        options = weboptions(...
            'MediaType', 'application/json', ...
            'ContentType', 'json', ...
            'Timeout', 30, ...
            'RequestMethod', 'post');
        
        % Make API request
        response = webwrite(api_url, data, options);
        
        % Parse response
        fault_label = response.fault_label;
        probabilities = response.probabilities;
        confidence = response.confidence;
        
        % Extract explanation if available
        if isfield(response, 'explanation')
            explanation = response.explanation;
        end
        
        if ~strcmp(response.status, 'success')
            warning('API returned non-success status: %s', response.status);
        end
        
    catch ME
        % Handle errors gracefully
        if contains(ME.identifier, 'MATLAB:webservices')
            fprintf('[API ERROR] Cannot connect to API server at %s\n', api_url);
            fprintf('            Make sure the API server is running:\n');
            fprintf('            >> cd explaination_module\n');
            fprintf('            >> python api_server.py\n');
        else
            fprintf('[API ERROR] %s\n', ME.message);
        end
        
        % Return error values
        fault_label = -1;
        probabilities = [];
        confidence = 0;
        explanation = struct();
    end
end
