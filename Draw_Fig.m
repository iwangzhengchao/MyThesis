load dataMat125
figure(1)
subplot(2, 1, 1)
plot(p_limit, v_limit, 'r', 'linewidth', 1.5);hold on;
plot(p_safty, v_safty, '--b', 'linewidth', 1.5);hold on;
plot(trace_P, 3.6*trace_V, 'k', 'linewidth', 1.5)
legend('Limited speed curve', 'Warning speed curve', 'Optimized running curve')
xlabel('Pisotion (m)')
ylabel('Velocity (km/h)')
title('Plan time = 125s')
axis([0 2000 0 85])
grid on
subplot(2, 1, 2)
plot(trace_P, trace_E, 'k', 'linewidth', 1.5)
legend('Energy consumption curve')
xlabel('Pisotion (m)')
ylabel('Energy (J)')
grid on
clear; clc;

load dataMat132
figure(2)
subplot(2, 1, 1)
plot(p_limit, v_limit, 'r', 'linewidth', 1.5);hold on;
plot(p_safty, v_safty, '--b', 'linewidth', 1.5);hold on;
plot(trace_P, 3.6*trace_V, 'k', 'linewidth', 1.5)
legend('Limited speed curve', 'Warning speed curve', 'Optimized running curve')
xlabel('Pisotion (m)')
ylabel('Velocity (km/h)')
axis([0 2000 0 85])
title('Plan time = 132s')
grid on
subplot(2, 1, 2)
plot(trace_P, trace_E, 'k', 'linewidth', 1.5)
legend('Energy consumption curve')
xlabel('Pisotion (m)')
ylabel('Energy (J)')
grid on
clear; clc;

load dataMat150
figure(3)
subplot(2, 1, 1)
plot(p_limit, v_limit, 'r', 'linewidth', 1.5);hold on;
plot(p_safty, v_safty, '--b', 'linewidth', 1.5);hold on;
plot(trace_P, 3.6*trace_V, 'k', 'linewidth', 1.5)
legend('Limited speed curve', 'Warning speed curve', 'Optimized running curve')
xlabel('Pisotion (m)')
ylabel('Velocity (km/h)')
axis([0 2000 0 85])
title('Plan time = 150s')
grid on
subplot(2, 1, 2)
plot(trace_P, trace_E, 'k', 'linewidth', 1.5)
legend('Energy consumption curve')
xlabel('Pisotion (m)')
ylabel('Energy (J)')
grid on
