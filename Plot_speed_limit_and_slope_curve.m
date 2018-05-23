clear; clc;

idx_sheet = 4;  % please modify the idx_sheet

data = load_data('E:\Thesis\分站处理数据_删减版.xlsx', idx_sheet);
v = data(:, 1);
s = data(:, 2);
slope_ = slope_fun(s);
len_train = 120;

speed_lim = [0,133, 133, 1853, 1853, 2272;
    51, 51, 75, 75, 50, 50];
safty_speed = [speed_lim(1, :);speed_lim(2, :)-2];
plot(speed_lim(1, :), speed_lim(2, :));hold on;
plot(safty_speed(1, :), safty_speed(2, :));hold on;
plot(s, slope_);

function slope_ = slope_fun(s)
    for i=1:length(s)
        if s(i)>0 && s(i)<169.7
            slope_ = 0;
        elseif  s(i)>169.7 && s(i)<838.2
            slope_(i) = 1;
        elseif  s(i)>838.2 && s(i)<1269
            slope_(i) = 5;
        elseif  s(i)>1269 && s(i)<1659
            slope_(i) = -3;
        elseif  s(i)>1659 && s(i)<1938
            slope_(i) = -8;
        else
            slope_(i) = 0;
        end
    end
end
