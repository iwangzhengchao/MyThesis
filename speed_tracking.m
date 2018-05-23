clear; clc;

load line;
delta_t = 0.05;
trace_P = [0 trace_P];
trace_V = [0 trace_V];

n_point = length(trace_P);

t = 0:0.05:delta_t * (n_point-1);
figure
plot(t, trace_V);
figure
plot(trace_P, trace_V);
