function data = load_data(filename, idx_sheet)
%% Function Description:
% 从excel中提取数据，返回速度和位移向量
% 上行方向，亦庄火车站-->宋家庄，共14站，13段
% [Status,Sheets,Format] = xlsfinfo(file);

%% main
    [~, Sheet, ~] = xlsfinfo(filename);  % 获取表格信息

    V = []; S = [];slope = [];

    if (nargin<2)  % 不指定idx_sheet的情况下，读取所有sheet
        for i = 1:length(Sheet)
            NUM = xlsread(filename, Sheet{i});
            V = [V; NUM(:, 6)];  % 速度
            S = [S; NUM(:, 10)];  % 位置
            slope = [slope; NUM(:, 16)];  % 坡度
        end
        data = [V, S-40665.104, slope];
    else  % 指定idx_sheet的情况下，读取指定的sheet
        NUM = xlsread(filename, Sheet{idx_sheet});
        V = NUM(:, 6);  % 速度
        S = NUM(:, 9);  % 位置
        slope = NUM(:, 16);  % 坡度
        data = [V, S, slope];
    end
%     save DataMat data
end