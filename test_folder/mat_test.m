% mat_test.m

% Add current folder to Python path
if count(py.sys.path, pwd) == 0
    insert(py.sys.path, int32(0), pwd);
end

% Clear Python cache to reload module
clear classes

% Import Python module
mod = py.importlib.import_module('code_test1');

% Call function to get DataFrame
df = mod.get_dataframe();

% Convert Pandas DataFrame to MATLAB numeric array
data_list = df.values.tolist();   % Convert to nested Python list
rows = int32(length(data_list));
cols = int32(length(data_list{1}));
mat = zeros(rows, cols);

for i = 1:rows
    for j = 1:cols
        mat(i,j) = double(data_list{i}{j});
    end
end

% Display matrix
disp('Data from Python DataFrame:')
disp(mat)

% Plot in MATLAB
figure;
imagesc(mat);
colorbar;
title('Heatmap from Python DatffaFrame');
xlabel('Columns');
ylabel('Rows');
