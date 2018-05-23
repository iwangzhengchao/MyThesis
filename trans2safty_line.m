function [p_safty, v_safty] = trans2safty_line(p_limit, v_limit, L)
%% parameters:
% p_limit, 限速曲线的横坐标
% v_limit, 限速曲线的纵坐标
% L，列车长度
% posi, 安全运行曲线的横坐标
% v_safty，安全运行曲线的纵坐标

%% trans2safty_line

p_safty = zeros(size(p_limit));
v = v_limit(2:2:end);

for i = 1: length(v)-1
   if i == 1  % 第一个区间
       if v(i) < v(i+1)
           p_safty(2*i-1) = p_limit(2*i-1);
           p_safty(2*i) = p_limit(2*i) + L;
       else
           p_safty(2*i-1) = p_limit(2*i-1);
           p_safty(2*i) = p_limit(2*i) - L;
       end
    
   else  %% 中间区间（不包含第一个和最后一个区间）
       if v(i)>v(i-1) && v(i)>v(i+1)  %% 低高低
           p_safty(2*i-1) = p_limit(2*i-1) + L;
           p_safty(2*i) = p_limit(2*i) - L;
       elseif v(i)>v(i-1) && v(i)<v(i+1)  %% 连续上升
           p_safty(2*i-1) = p_limit(2*i-1) + L;
           p_safty(2*i) = p_limit(2*i) + L;
       elseif v(i)<v(i-1) && v(i)>v(i+1)  % 连续下降
           p_safty(2*i-1) = p_limit(2*i-1);
           p_safty(2*i) = p_limit(2*i) - L;
       elseif v(i)<v(i-1) && v(i)<v(i+1)  %% 高低高
           p_safty(2*i-1) = p_limit(2*i-1);
           p_safty(2*i) = p_limit(2*i) + L;
       end
              
   end
    
end

% 最后一个区间
i = length(v);
if v(i) < v(i-1)  % 高低
   p_safty(2*i-1) = p_limit(2*i-1);
   p_safty(2*i) = p_limit(2*i);
else  % 低高
   p_safty(2*i-1) = p_limit(2*i-1) + L;
   p_safty(2*i) = p_limit(2*i);
end

v_safty = v_limit - 2;

end