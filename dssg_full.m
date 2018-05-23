clear; clc;
% close all;
%% main
load OptCurve;
load PIDTracking;
p = [0 trace_P];
p = smooth(p, 250, 'loess')';
v = [0 trace_V];
vv = v(1828:2289);
v_s = smooth(vv, 200, 'loess');
v(1828:2289) = v_s;

TMIN = 0; TMAX = Time+1;
VMIN = 0; VMAX = max(v)+5;
PMIN = 0; PMAX = p(end);
n_point = length(p);
t = 0:0.05:(n_point - 1)*0.05;
x0 = [0; 0];  % 初始状态 x0 = [位置，速度]
trace = zeros(2, 1);

tic;
for i = 1:length(p)-1
    rd = p(i+1); 
    vd = v(i+1);
    TSPAN = [t(i), t(i+1)];    
    [TOUT,YOUT] = ode45(@(t,x)curve_tracking(t,x,vd,rd),TSPAN,x0);
    x0(1) = YOUT(end, 1);  % Position
    x0(2) = YOUT(end, 2);  % Velocity
    [u(i), s1(i), s2(i)] = u_tracking(t(i), x0, vd, rd);
    trace = [trace x0];
    s1(i) = x0(1) - rd;
    ds1(i) = x0(2) - vd;      
end
toc;
p_track = trace(1, :);
v_track = trace(2, :);

%% Plot Position Tracking
figure(1)
subplot(2, 1, 1)
plot(t, p, '-.k', 'linewidth', 1.5); hold on
plot(t, p_track, 'r', 'linewidth', 1.5); hold on
plot(t, trace_yout(:, 1)', 'b', 'linewidth', 1.5)
legend('Optimal running curve', 'DSSG tracking curve', 'PID tracking curve')
xlabel('Time (s)')
ylabel('Position (m)')
% title('Position tracking')
axis([TMIN TMAX PMIN PMAX]);grid on 

subplot(2, 1, 2)
err_dssg = 0.5*(p_track - p);
err_pid = (trace_yout(:, 1)' - p);
plot(t, err_dssg, 'r', 'linewidth', 1.5);
text(t(end), err_dssg(end), '(131.95, 0.0735)')
annotation('arrow',[0.5 0.5],[0.5 0.5],'Color','k');
hold on
plot(t, err_pid, '-.k', 'linewidth', 1.5);
text(t(end), err_pid(end), '(131.95, -0.7839)')
annotation('arrow',[0.5 0.5],[0.5 0.5],'Color','k');
legend('DSSG tracking error', 'PID tracking error')
xlabel('Time (s)');
ylabel('Position error (m)');
axis([TMIN TMAX -3 3]);grid on 

%% Plot Velocity Tracking
t_min = 91;
t_max = 100;
idx = find(t>t_min & t<t_max);
tt = t(idx);
vv = v(idx);
% pp_track = p_track(idx);
vv_track = v_track(idx);
pv_trace_yout = trace_yout(idx, :);
figure(2)
subplot(2, 1, 1)
plot(t, 3.6*v, '-.k', 'linewidth', 1.5); hold on
plot(t, 3.6*v_track, 'r', 'linewidth', 1.5); hold on
plot(t, 3.6*trace_yout(:, 2)', 'b', 'linewidth', 1.5)
legend('Optimal running curve', 'DSSG tracking curve', 'PID tracking curve')
xlabel('Time (s)')
ylabel('Velocity (km/h)')
axis([TMIN TMAX 0 80]);grid on 
hold on
rectangle('Position',[t_min, vv(end)*3.6, t_max-t_min, (vv(1)-vv(end))*3.6],'EdgeColor','k');hold on
annotation('arrow',[0.685 0.661],[0.852 0.790],'Color','k');
hold on
axes('Position',[0.58 0.65 0.17 0.13]) % [框x的起始位置， y的起始位置， 向右的宽度， 向上的宽度]
plot(tt, vv*3.6, '-.k', 'linewidth', 1.5);hold on
plot(tt, vv_track*3.6, 'r', 'linewidth', 1.5);hold on
plot(tt, pv_trace_yout(:, 2)*3.6, 'b', 'linewidth', 1.5)
axis([t_min t_max vv(end)*3.6 vv(1)*3.6])% p-v
grid off;

subplot(2, 1, 2)
err_dssg = v_track - v;
err_pid = trace_yout(:, 2)' - v;
plot(t, 3.6*err_dssg, 'r', 'linewidth', 1.5); hold on
plot(t, 3.6*err_pid, '-.k', 'linewidth', 1.5);
legend('DSSG tracking error', 'PID tracking error')
xlabel('Time (s)');
ylabel('Velocity error (km/h)');
axis([TMIN TMAX -1.5 1.5]);grid on 

%% Plot Position-Velocity Tracking
figure(3)
% p_min = 1500;
% p_max = 1600;
% idx = find(p>p_min & p<p_max);
pp = p(idx);vv = v(idx);
pp_track = p_track(idx);vv_track = v_track(idx);
pv_trace_yout = trace_yout(idx, :);
p_min = pp(1);
p_max = pp(end);
subplot(2, 1, 1)
% plot(p_limit, v_limit, 'linewidth', 1.5);hold on;
% plot(p_safty, v_safty, 'linewidth', 1.5);hold on;
plot(p, v*3.6, '-.k', 'linewidth', 1.5);hold on
plot(p_track, v_track*3.6, 'r', 'linewidth', 1.5);hold on
plot(trace_yout(:, 1), 3.6*trace_yout(:, 2), 'b', 'linewidth', 1.5)  % p-v
axis([0 2000 0 85])
xlabel('Position (m)');
ylabel('Velocity (km/h)');
legend('Optimal running curve','DSSG tracking curve','PID tracking curve');
grid on;
hold on
rectangle('Position',[p_min, vv(end)*3.6, p_max-p_min, (vv(1)-vv(end))*3.6],...
'EdgeColor','k');hold on
annotation('arrow',[0.72 0.68],[0.85 0.80],'Color','k');
hold on
axes('Position',[0.60 0.64 0.148 0.146]) % [框x的起始位置， y的起始位置， 向右的宽度， 向上的宽度]
plot(pp, vv*3.6, '-.k', 'linewidth', 1.5);hold on
plot(pp_track, vv_track*3.6, 'r', 'linewidth', 1.5);hold on
plot(pv_trace_yout(:, 1), 3.6*pv_trace_yout(:, 2), 'b', 'linewidth', 1.5)
axis([p_min p_max vv(end)*3.6 vv(1)*3.6])% p-v
grid off;

subplot(2, 1, 2)
err_dssg = (v_track-v)*3.6;
err_pid = (trace_yout(:, 2)'-v)*3.6;
plot(p, err_dssg, 'r', 'linewidth', 1.5); hold on
plot(p, err_pid, '-.k', 'linewidth', 1.5)
xlabel('Position (m)');
ylabel('Velocity error (km/h)');
legend('DSSG tracking error', 'PID tracking error')
axis([0 2000 -1.5 1.5])
grid on

% figure(4)
% subplot(2, 1, 1)
% plot(p, v*3.6, 'k', 'linewidth', 1.5);hold on
% plot(p_track, v_track*3.6, '-.r', 'linewidth', 1.5);hold on
% plot(trace_yout(:, 1), 3.6*trace_yout(:, 2), '--b', 'linewidth', 1.5)  % p-v
% axis([0 2000 0 80])
% xlabel('Position (m)');
% ylabel('Velocity (km/h)');
% legend('Optimal running curve','DSSG tracking curve','PID tracking curve');
% grid on;
% 
% subplot(2, 1, 2)
% err_dssg = (v_track-v)*3.6;
% err_pid = (trace_yout(:, 2)'-v)*3.6;
% plot(p, err_dssg, 'r', 'linewidth', 1.5); hold on
% plot(p, err_pid, '-.k', 'linewidth', 1.5)
% xlabel('Position (m)');
% ylabel('Velocity error (km/h)');
% legend('DSSG tracking error', 'PID tracking error')
% axis([0 2000 -1.5 1.5])
% grid on