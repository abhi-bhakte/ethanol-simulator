% Generate Fault Data for Simulations

% Initialize parameters
num_samples = 1000; % Number of data points to generate
fault_types = {'Type1', 'Type2', 'Type3'}; % Example fault types

% Preallocate data storage
data = struct();
data.samples = zeros(num_samples, length(fault_types));
data.labels = cell(num_samples, 1);

% Generate data
for i = 1:num_samples
    % Randomly select a fault type
    fault_idx = randi(length(fault_types));
    fault_type = fault_types{fault_idx};

    % Simulate data for the selected fault type
    % Replace the following line with actual simulation logic
    data.samples(i, :) = rand(1, length(fault_types));
    data.labels{i} = fault_type;
end

% Save the generated data
output_file = '../data/matlab-data/generated_fault_data.mat';
save(output_file, 'data');

fprintf('Fault data generated and saved to %s\n', output_file);