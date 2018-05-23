clear; clc;
%% Function Description
% 绘制限速曲线以及坡度曲线

%% 线路信息
line = [0 137 210 366 952 1008 1325 1369 1460 2014 2210 2269 2322 2366];
slope = [0 1 3 2 1 0 2 11 22 19 15 5 -1];
%% 计算 altitude
for i=1:length(line)-1
   if i==1
       trace(i) = 0;
   else
       trace(i) = (line(i+1)-line(i))*slope(i)/1000;
   end
end
for i=1:length(trace)
   altitude(i) = sum(trace(:,1:i));
end
%% 绘制双纵坐标图
altitude = [0 altitude];
x = [0 137 137 2269 2269 2366 2366];
y = [48 48 80 80 48 48 0];

[AX,H1,H2] = plotyy(line, altitude, x, y,'plot');
set(AX(1),'XColor','k','YColor','b');
set(AX(2),'XColor','k','YColor','m');
set(AX(1),'ylim',[0,90],'yTick',(0:10:90));  
set(AX(2),'ylim',[0,90],'yTick',(0:10:90));  
set(AX(1),'xlim',[0,2500],'xTick',(0:500:2500))  
set(AX(2),'xlim',[0,2500],'xTick',(0:500:2500)) 
HH1=get(AX(1),'Ylabel');
set(HH1,'String','Speed（km/h）','color','b');
HH2=get(AX(2),'Ylabel');
set(HH2,'String','Altitude（m）','color','m');
set(H1,'LineStyle','-','linewidth', 2,'color','m');
set(H2,'LineStyle','-.','linewidth', 2,'color','b');
legend([H1,H2],{'Slope Curve';'Speed Limit Curve'});
xlabel('Distance（m）');
