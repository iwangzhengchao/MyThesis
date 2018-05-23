function [a, F] = TrainModel(p, v, ctrl_signal, slope)
%% Parameter Description
% p, Current position; unit:
% v, Current speed; unit: 
% m, mass of train; unit:
% slope, matrix of slope, size(slope) = (m, 3)
% Control signals; 
%   0, coasting;
%   1, 100% traction;
%   2, 60% traction;
%   3, 30% traction;
%   4, braking;
%   5, cruise.
% clear; clc;
% p = 0; v=0; ctrl_signal=1; slope=[0 3000 0];

m = 200;  % 列车质量 unit：t
g = 9.8;
gamma = 0.06;
v = v * 3.6;
%% 根据当前控制信号，确定牵引系数和制动系数
if ctrl_signal == 0
    mu_f = 0; mu_b = 0;
elseif ctrl_signal == 1
    mu_f = 0.8; mu_b = 0;
elseif ctrl_signal == 2
    mu_f = 0.6; mu_b = 0;
elseif ctrl_signal == 3
    mu_f = 0.3; mu_b = 0;
elseif ctrl_signal == 4
    mu_f = 0; mu_b = 1;
else 
    mu_f = 1.0; mu_b = 0;
end

%% 根据当前位置，确定当前坡度角
for i = 1: size(slope, 1)
    if p >= slope(i, 1) && p <= slope(i, 2)
        theta = atan(slope(i, 3));    
    end
end
%% 牵引力
if (v <= 51.5)
    F_max = 206;
else
    F_max = -0.002032 * v * v * v+0.4928 * v * v - 42.12 * v + 1343;
end
F = mu_f * F_max;
%% 制动力
if (v <= 77)
    B_max = 166;
else
    B_max = 0.134 * v * v - 25.07 * v + 1300;
end
B = mu_b * B_max;
%% 基本阻力
fb = 2.031 + 0.0622 * v + 0.001807 * v * v;
fb = 0.8 * fb;
%% 附加阻力
% fg = m * g * cos(theta);  % theta,坡度角 ？？？
fg = 20;
% fg = 0;
%% main

a = (F - B - fb - fg)/(m * (1 + gamma));

if ctrl_signal == 5
    a = 0;
    F = B + fb + fg;
end



