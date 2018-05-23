function [ObjV, time, trace_P, trace_V, trace_A, trace_E, trace_F] = ObjFun2...
    (coast_posi, coast_section, v_safty, p_safty, slope)
% clear; clc;
% load dataMat
% slope = [0 3000 0];
%% Parameter Description
% posi, 各个惰行点位置，unit: m
% ObjV, 目标函数值， 1 / (E * ftfj)

% Control signals; 
%   0, coasting;
%   1, 100% traction;
%   2, 60% traction;
%   3, 30% traction;
%   4, braking;
%   5, cruise.

v_safty = v_safty / 3.6;

p = 0; v = 0; E = 0; T = 0;

trace_V = [];
trace_A = [];
trace_P = [];
trace_E = [];
trace_F = [];
        
delta_t = 0.05;
v_safty_end = v_safty(2:2:end);
run_coast = 0; run_NOcoast = 0;

for i = 1: size(v_safty_end, 2)
    if i == size(v_safty_end, 2)
        p_end = p;
        v_end = v;
        T_end = T;
        E_end = E;
%         E_end = E;
    end 
    
    trace_v = []; trace_p = []; trace_a = [];
    trace_e = []; trace_f = [];
    
    if (any(coast_section == i)== false)  % 非惰行区间  加速-巡航
        k = 1;
        while v < v_safty_end(i) && p  < p_safty(2*i)  % 加速
            [a, F] = TrainModel(p, v, 1, slope);
            delta_s = v * delta_t + 0.5 * a * delta_t^2;
            E = E + F * delta_s;
            p = p + delta_s;
            v = v + a * delta_t;
            T = T + delta_t;
            trace_a(k) = a;
            trace_v(k) = v;
            trace_p(k) = p;
            trace_e(k) = E;
            trace_f(k) = F;
            k = k + 1;       
        end
        
        while p  < p_safty(2*i)  % 巡航
            [a, F] = TrainModel(p, v, 5, slope);  % 此处满足 a==0
            delta_s = v * delta_t + 0.5 * a * delta_t^2;
            E = E + F * delta_s;
            p = p + delta_s;
            v = v + a * delta_t;
            T = T + delta_t;
            trace_a(k) = a;
            trace_v(k) = v;
            trace_p(k) = p;
            trace_e(k) = E;
            trace_f(k) = F;            
            k = k + 1;
        end
        trace_V = [trace_V trace_v];
        trace_A = [trace_A trace_a];
        trace_P = [trace_P trace_p];
        trace_E = [trace_E trace_e];
        trace_F = [trace_F trace_f];
        run_NOcoast = run_NOcoast + 1;
        clear trace_v trace_a trace_p trace_e trace_f
               
    else  % 惰行区间  加速-惰行
        k = 1;
        while v < v_safty_end(i) && p  < coast_posi(1, i-run_NOcoast)  % 加速
            [a, F] = TrainModel(p, v, 1, slope);
            delta_s = v * delta_t + 0.5 * a * delta_t^2;
            E = E + F * delta_s;
            p = p + delta_s;
            v = v + a * delta_t;
            T = T + delta_t;
            trace_a(k) = a;
            trace_v(k) = v;
            trace_p(k) = p;
            trace_e(k) = E;
            trace_f(k) = F;
            k = k + 1; 
        end
        
        while p < p_safty(2*i)  % 惰行
            [a, F] = TrainModel(p, v, 0, slope);  % 此处满足 F==0
            delta_s = v * delta_t + 0.5 * a * delta_t^2;
            E = E + F * delta_s;
            p = p + delta_s;
            v = v + a * delta_t;
            T = T + delta_t;
            trace_a(k) = a;
            trace_v(k) = v;
            trace_p(k) = p;
            trace_e(k) = E;
            trace_f(k) = F;
            k = k + 1;
        end
        
        if v > v_safty_end(i+1)  % 大于下一个区间的限速，制动
            while v > v_safty_end(i+1) && p  <  p_safty(2*i+1) % 制动
                [a, F] = TrainModel(p, v, 4, slope);
                delta_s = v * delta_t + 0.5 * a * delta_t^2;
                E = E + F * delta_s;
                p = p + delta_s;
                v = v + a * delta_t;
                T = T + delta_t;
                trace_a(k) = a;
                trace_v(k) = v;
                trace_p(k) = p;
                trace_e(k) = E;
                trace_f(k) = F;
                k = k + 1;
            end
            
            if v < v_safty_end(i+1) % 巡航
                [a, F] = TrainModel(p, v, 5, slope);  % 此处满足 a==0
                delta_s = v * delta_t + 0.5 * a * delta_t^2;
                E = E + F * delta_s;
                p = p + delta_s;
                v = v + a * delta_t;
                T = T + delta_t;
                trace_a(k) = a;
                trace_v(k) = v;
                trace_p(k) = p;
                trace_e(k) = E;
                trace_f(k) = F;            
                k = k + 1;                
            end
            
            
        else  % 加速
            while v < v_safty_end(i+1) && p  <  p_safty(2*i+1) % 加速
                [a, F] = TrainModel(p, v, 1, slope);
                delta_s = v * delta_t + 0.5 * a * delta_t^2;
                E = E + F * delta_s;
                p = p + delta_s;
                v = v + a * delta_t;
                T = T + delta_t;
                trace_a(k) = a;
                trace_v(k) = v;
                trace_p(k) = p;
                trace_e(k) = E;
                trace_f(k) = F;
                k = k + 1;
            end
            
            if v > v_safty_end(i+1)  % 巡航
                [a, F] = TrainModel(p, v, 5, slope);  % 此处满足 a==0
                delta_s = v * delta_t + 0.5 * a * delta_t^2;
                E = E + F * delta_s;
                p = p + delta_s;
                v = v + a * delta_t;
                T = T + delta_t;
                trace_a(k) = a;
                trace_v(k) = v;
                trace_p(k) = p;
                trace_e(k) = E;
                trace_f(k) = F;            
                k = k + 1;  
            end                         
        end
        trace_V = [trace_V trace_v];
        trace_A = [trace_A trace_a];
        trace_P = [trace_P trace_p];
        trace_E = [trace_E trace_e];
        trace_F = [trace_F trace_f];
        run_coast = run_coast + 1;
        clear trace_v trace_a trace_p trace_e trace_f    
    end  
end

%% 求解交叉点
p_in = p_end;
v_in = v_end;
delta_t2 = 0.01;
k = 1;
while(p_in < p_safty(end))  % 惰行
    [a, F] = TrainModel(p_in, v_in, 0, slope);  % 此处满足 F==0
    delta_s = v_in * delta_t2 + 0.5 * a * delta_t2^2;
    p_in = p_in + delta_s;
    v_in = v_in + a * delta_t2;
    trace_v_in(k) = v_in;
    trace_p_in(k) = p_in;
    k = k + 1;   
end
% plot(trace_p_in, trace_v_in * 3.6); hold on;
vb = v_safty_end(end);
pb = p_safty(end-1);
k = 1;
while(vb > 0.0)  % 制动
    [a, F] = TrainModel(pb, vb, 4, slope);
    delta_s = vb * delta_t2 + 0.5 * a * delta_t2^2;
    pb = pb + delta_s;
    vb = vb + a * delta_t2;
    trace_vb(k) = vb;
    trace_pb(k) = pb;
    k = k + 1;     
end
delta_p = p_safty(end) - trace_pb(end);
trace_pb_2 = trace_pb + delta_p;

trace_v_out = trace_vb;
trace_p_out = trace_pb_2;
%% 寻找交叉点（即制动点）
% for i = 1:length(trace_v_in)
%     for j = 1:length(trace_v_out)
%         if abs(trace_v_in(i) - trace_v_out(j)) < 0.1
%             if abs(trace_p_in(i) - trace_p_out(j)) < 0.1
%                 v_brake = trace_v_out(j)+0.15;  % v_brake 交叉点速度
%             end
%         end        
%     end
% end
X1 = trace_p_in;
Y1 = trace_v_in;
X2 = trace_p_out;
Y2 = trace_v_out;
P = intersections(X1,Y1,X2,Y2);
v_brake = P(2);
%% 计算最后一个区间的轨迹
p = p_end;
v = v_end;
k = 1;
E = E_end;
T = 0;
while(v > v_brake)  % 惰行
    [a, F] = TrainModel(p, v, 0, slope);  % 此处满足 F==0
    delta_s = v * delta_t + 0.5 * a * delta_t^2;

    p = p + delta_s;
    v = v + a * delta_t;
    T = T + delta_t;
    trace_a(k) = a;
    trace_v(k) = v;
    trace_p(k) = p;
    trace_e(k) = E;
    trace_f(k) = F;
    k = k + 1;  
end

while(v >= 0.0)  % 制动
    [a, F] = TrainModel(p, v, 4, slope);
    delta_s = v * delta_t + 0.5 * a * delta_t^2;

    p = p + delta_s;
    v = v + a * delta_t;
    T = T + delta_t;
    trace_a(k) = a;
    trace_v(k) = v;
    trace_p(k) = p;
    trace_e(k) = E;
    trace_f(k) = F;
    k = k + 1;  
end

%% 
idx = floor(T_end/delta_t);
trace_V = [trace_V(1:idx) trace_v];
trace_A = [trace_A(1:idx) trace_a];
trace_P = [trace_P(1:idx) trace_p];
trace_E = [trace_E(1:idx) trace_e];
trace_F = [trace_F(1:idx) trace_f];

time = T_end + T;
energy = trace_E(end);

A = trace_A(1:4:end);
P = trace_P(1:4:end);

Jerk = zeros(1, size(A, 2)-1);
for i = 1:size(A, 2)-1
   Jerk(i) = abs((A(i+1) - A(i)) / (0.05*4)); 
end

% figure
% scatter(P(2:end), Jerk); hold on;
% for i = 2 :length(Jerk)
%    plot([P(i), P(i)], [0, Jerk(i)], '-'); hold on; 
% end



ftfj = ft_fj(time, 132, Jerk, 3);

% T, actual run time
% Td, Expected run time
% J, Jerk
% Jd, The rate of acceleration that passengers can accept
% ftfj, 时间惩罚与舒适度惩罚之积

ObjV = E * ftfj;
% ObjV =  E ;
% [ftfj] = ft_fj(T, Td, J, Jd)
% T, actual run time
% Td, Expected run time
% J, Jerk
% Jd, The rate of acceleration that passengers can accept
% ftfj, 时间惩罚与舒适度惩罚之积


% plot(trace_P, trace_V*3.6, 'k', 'linewidth', 2.0); hold on;
% plot(trace_p, trace_v * 3.6, 'k', 'linewidth', 2.0); hold on;
% plot(trace_p_out, trace_v_out * 3.6)



