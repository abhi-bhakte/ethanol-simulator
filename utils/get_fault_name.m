% =========================================================================
% FUNCTION: get_fault_name
% =========================================================================
% Purpose: Returns the descriptive name for each fault scenario
%
% Input:
%   fault_number - Fault case number (0-12)
%
% Output:
%   fault_name - String describing the fault
%
% =========================================================================

function fault_name = get_fault_name(fault_number)
    fault_names = {
        'Normal Operation';                           % 0
        'Feed Flow Reduction';                        % 1
        'Reaction Rate Change';                       % 2
        'Coolant Flow Reduction';                     % 3
        'Distillation Flow Reduction';                % 4
        'Reflux Valve Set High';                      % 5
        'Reboiler Power Reduction';                   % 6
        'Feed Flow Increase';                         % 7
        'Coolant Flow Increase';                      % 8
        'Distillation Feed Valve Stuck';              % 9
        'Reflux Valve Set Low';                       % 10
        'Feed Flow Leakage';                          % 11
        'Coolant Flow Leakage'                        % 12
    };
    
    if fault_number >= 0 && fault_number <= 12
        fault_name = fault_names{fault_number + 1};
    else
        fault_name = 'Unknown';
    end
end
