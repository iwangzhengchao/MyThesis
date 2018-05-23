clear ; clc;
% close all;
%% main
% pid tracking
load OptCurve;
p = [0 trace_P];
v = [0 trace_V];
SPAN = 200;
v_s = smooth(v(1828:2289), SPAN, 'loess');
v(1828:2289) = v_s;
p = smooth(p, SPAN, 'loess')';
dt = 0.05; 
t = 0:0.05:Time;

% kp = 105;ki = 83.5;kd = 45;  % 最佳参数
kp = 100;ki = 20.5;kd = 10;
u_1 = 0.0;   
x = [0,0,0]';  
trace_tout = [];
trace_yout = [];
for k = 1:length(v)-1   
    rin(k) = v(k);   
    du(k) = kp*x(1) + kd * x(2)+ki * x(3);    
    u(k) = u_1+du(k);     
    if k==1
        [TOUT,YOUT] = ode45(@(t,y)vdp1(t,y,u(k)),[(k-1)*dt k*dt],...
        [0; 0]);
    else
        [TOUT,YOUT] = ode45(@(t,y)vdp1(t,y,u(k)),[(k-1)*dt k*dt],...
        [trace_yout(end, 1); trace_yout(end, 2)]);
    end   
    yout(k) = YOUT(end, 2);  % 记录 v
    trace_tout = [trace_tout; TOUT(end)];
    trace_yout = [trace_yout; YOUT(end, :)];
    clear TOUT YOUT  
    err(k) = rin(k)-yout(k);
    u_1 = u(k); % 保存上一次控制输入     
    if k==1    
        x = [err(k); err(k); err(k)]; 
    elseif k==2
        x = [err(k)-err(k-1); err(k)-2*err(k-1); err(k)];     
    else
        x = [err(k)-err(k-1); err(k)-2*err(k-1)+err(k-2); err(k)]; 
    end                    
end

trace_tout = [0 ;trace_tout];
trace_yout = [0 0; trace_yout];
save PIDTracking trace_yout trace_tout
fprintf('PID tracking completed')

% figure(1);
% subplot(3, 1, 1)
% plot(p, 3.6*v); hold on
% plot(trace_yout(:, 1), 3.6*trace_yout(:, 2), 'r') % p-v 
% xlabel('Position (m)')
% ylabel('Velocity (km/h)')
% legend('Optimal running curve', 'PID tracking curve')
% axis([0 trace_yout(end, 1) 0 80])
% grid on
% subplot(3, 1, 2)
% plot(p, 3.6*(v-trace_yout(:, 2)'), 'r')
% xlabel('Position (m)')
% ylabel('Error (km/h)')
% legend('PID error')
% grid on
% subplot(3, 1, 3)
% plot(p(2:end), u, 'k')
% xlabel('Position (m)')
% ylabel('u')
% legend('u')
% grid on

% figure()
% err = trace_yout(:, 1)'-p;
% plot(t, err, '-.k', 'linewidth', 1.5)
% ylim([-3 3])
% grid on
% 
% figure()
% subplot(2, 1, 1)
% plot(t, v, 'r')
% grid on
% subplot(2, 1, 2)
% plot(t, p, 'k'); hold on
% grid on
figure()
plot(p(2:end), u)