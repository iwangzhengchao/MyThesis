clear; clc;
% close all;
% load dataMat
% data = load_data('E:\Thesis\分站处理数据_删减版.xlsx');
% v = data(:, 1);
% p = data(:, 2);
% slope = data(:, 3);
% plot(p, v); hold on;
% plot(p, slope);
%% Line parameter
speed_lim =[0 200 200 300 300 800 800 1200 1200 1500 1500 1700 1700 1980;
    60 60 70 70 80 80 70 70 80 80 70 70 65 65];  % 亦庄桥---旧宫 
% speed_lim =[0, 400, 400, 1400, 1400, 1700;
%     60, 60, 80, 80, 60, 60];
% speed_lim =[0, 300, 300, 800, 800, 1000, 1000, 1300, 1300, 2000, 2000, 2400;
%     50, 50, 80, 80, 70, 70, 50, 50, 65, 65, 50, 50];
% speed_lim =[0, 200, 200, 550, 550, 900, 900, 1500, 1500, 1950, 1950, 2200, 2200, 2600, 2600, 3000;
%             60, 60,  80, 80, 70, 70, 80, 80, 70, 70, 50, 50, 80, 80, 70, 70];

%% Convert speed limit curve to safe operation curve
p_limit = speed_lim(1, :);
v_limit = speed_lim(2, :);
L = 80;
[p_safty, v_safty] = trans2safty_line(p_limit, v_limit, L);

%% 确定惰行点范围
coast1 = []; coast2 = [];
v_safty_end = v_safty(2:2:end);
X.trace_P=[];
X.trace_E=[];
X.trace_A=[];
X.trace_F=[];
X.trace_V=[];
for i = 2: length(v_safty_end)-1
    if v_safty_end(i)>v_safty_end(i-1) && v_safty_end(i)>v_safty_end(i+1)
        coast1 = [coast1 i];
    elseif v_safty_end(i)<v_safty_end(i-1) && v_safty_end(i)>v_safty_end(i+1)
        coast2 = [coast2 i];
    end    
end
coast_section = sort([coast1 coast2]);  % coast记录惰行点所在区间的编号
temp = unique(p_safty);
posi_coast = zeros(length(coast_section), 3); % posi_coast矩阵将用于遗传算法种群的生成

for i = 1: length(coast_section)
    posi_coast(i, 1) = temp(coast_section(i)+i-1); % posi_coast的每一行代表一个惰行点存在的范围
    posi_coast(i, 2) = temp(coast_section(i)+i); 
    posi_coast(i, 3) = v_safty_end(coast_section(i));
end

%% ga
NIND = 10;               
MAXGEN = 100; 
NVAR = size(posi_coast, 1);               
PRECI = 20;
GGAP=1;             
% Build field descriptor
FieldD = [rep(PRECI, [1,NVAR]); posi_coast(:, 1:2)'; rep([1;0;1;1],[1,NVAR])];
Chrom = crtbp(NIND, NVAR * PRECI); 
coast_posi = bs2rv(Chrom, FieldD);
              
trace = zeros(MAXGEN, 1); 

gen = 0;  
slope = [0 3000 0];
ObjV = zeros(NIND, 1);
for i = 1:size(Chrom, 1)
    [ObjV(i), ~, ~, ~, ~, ~, ~] = ...
        ObjFun2(coast_posi(i,:), coast_section, v_safty, p_safty, slope);
end
ObjVSel = zeros(NIND*GGAP, 1);

tic;
while gen <= MAXGEN  
    FitnV = ranking(ObjV);                             
    SelCh = select('sus', Chrom, FitnV, GGAP);  % 选择
    SelCh = recombin('xovsp', SelCh, 0.9);  % 交叉
    SelCh = mut(SelCh);  % 变异
    b = bs2rv(SelCh, FieldD);
    for i = 1:size(Chrom, 1)
        [ObjVSel(i),time(i), X(i).trace_P, X(i).trace_V, X(i).trace_A,...
            X(i).trace_E, X(i).trace_F] = ...
            ObjFun2(b(i,:), coast_section, v_safty, p_safty, slope);
    end
    [Chrom, ObjV] = reins(Chrom, SelCh, 1, 1, ObjV, ObjVSel);
    gen = gen+1;
    [trace(gen, 1), idx] = min(ObjV);  % 性能跟踪   
end
toc;
Time = time(idx);  % 存储最优解
trace_P = X(idx).trace_P;
trace_E = X(idx).trace_E;
trace_V = X(idx).trace_V;
trace_A = X(idx).trace_A;
trace_F = X(idx).trace_F;
save OptCurve trace_P trace_V Time  % 保存数据

%% plot 
%%%***************** 绘制进化过程 *****************
% figure
% plot(1./trace(:,1)); grid on;
% xlabel('Evolutionary Generations');
% ylabel('Fitness Value');
% legend('Optimal individual fitness of each generation');

%%%***************** 绘制含有惰行区间标注的v-p图像 *****************
% figure()
% plot(p_limit, v_limit, 'r', 'linewidth', 1.5);hold on;
% plot(p_safty, v_safty, '--b', 'linewidth', 1.5);hold on;
% plot(trace_P, trace_V*3.6, 'k', 'linewidth', 2.0);hold on;
% % 标注惰行区间
% for i = 1:size(posi_coast, 1)
%     plot([posi_coast(i, 1) posi_coast(i, 1)], [0, posi_coast(i, 3)], ':b');hold on;    
%     plot([posi_coast(i, 2) posi_coast(i, 2)], [0, posi_coast(i, 3)], ':b');hold on;       
% end
% xlabel('Position (m)');
% ylabel('Velocity (km/h)');
% axis([0, p_safty(end), 0, 85]);

%%%***************** 利用插值法绘制v-p图像 *****************
% figure()
% plot(p_limit, v_limit, 'r', 'linewidth', 1.5);hold on;
% plot(p_safty, v_safty, '--b', 'linewidth', 1.5);hold on;
% xlabel('Position (m)');
% ylabel('Velocity (km/h)');
% axis([0, p_safty(end), 0, 85]);
% grid on
%%标注惰行区间
% for i = 1:size(posi_coast, 1)
%     plot([posi_coast(i, 1) posi_coast(i, 1)], [0, posi_coast(i, 3)], ':b');hold on;    
%     plot([posi_coast(i, 2) posi_coast(i, 2)], [0, posi_coast(i, 3)], ':b');hold on;       
% end
%%插值法平滑曲线
% xx = 0: 50: p_safty(end)+1;
% yy = interp1(trace_P, trace_V, xx,'PCHIP');
% xx = [xx p_safty(end)];
% yy = [yy 0];
% plot(xx, yy*3.6, 'k', 'linewidth', 2.0);
% legend('Limited speed curve', 'Warning speed curve',...
%     'Optimized running reference curve')
%%绘制能耗、牵引力、加速度随位置变化曲线
% yy_A = interp1(trace_P, trace_A, xx,'PCHIP');yy_A = [yy_A yy_A(end)];
% yy_F = interp1(trace_P, trace_F, xx,'PCHIP');yy_F = [yy_F yy_A(end)];
% yy_E = interp1(trace_P, trace_E, xx,'PCHIP');yy_E = [yy_E yy_E(end)];
% xx = [xx p_safty(end)];
% figure()
% subplot(3, 1, 1)
% plot(xx, yy_E*1000);grid on
% ylabel('Energy consumption (J)');
% legend('Energy consumption-time curve')
% subplot(3, 1, 2)
% plot(xx, yy_F);grid on
% ylim([0, 200])
% ylabel('Traction (KN)')
% legend('Traction-time curve')
% subplot(3, 1, 3)
% plot(xx, yy_A);grid on
% xlabel('Position (m)')
% ylabel('Acceleration (m/s^2)')
% legend('Acceleration-time curve')

%%%***************** 绘制V-P和E-T图像（不使用插值）*****************
figure()
subplot(2, 1, 1) % V-P
plot(p_limit, v_limit, 'r', 'linewidth', 1.5);hold on;
plot(p_safty, v_safty, '--b', 'linewidth', 1.5);hold on;
plot(trace_P, 3.6*trace_V, 'k', 'linewidth', 1.5)
legend('Limited speed curve', 'Warning speed curve', 'Optimized running curve')
xlabel('Pisotion (m)')
ylabel('Velocity (km/h)')
axis([0 2000 0 85])
grid on
subplot(2, 1, 2) % E-T
plot(trace_P, trace_E, 'linewidth', 1.5)
legend('Energy consumption curve')
xlabel('Pisotion (m)')
ylabel('Energy (J)')
grid on

% clear ;
% run('debug1610.m')


