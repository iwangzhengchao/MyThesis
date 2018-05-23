function [ftfj] = ft_fj(T, Td, J, Jd)
%% Parameters Description
% T, actual run time
% Td, Expected run time
% J, Jerk
% Jd, The rate of acceleration that passengers can accept
% ftfj, 时间惩罚与舒适度惩罚之积

%% main
% clear; clc;
% load J

h = 0.2;
cj = 1;
alpha = 0.03;

% T = linspace(120, 200, 100);
% Td = 160;
ft = 1 + ((T - Td)/Td).^2 / (alpha.^2);

% figure
% plot(T, ft);

fj = zeros(size(J));
for i = 1:length(J)
    if J(i) > Jd
       fj(i) = power(1 + cj, (J(i) - Jd)/h);
    else
       fj(i) = 1;
    end
end

%% return 
ftfj = ft * mean(fj);
