function dx = curve_tracking(t, x, vd, rd)

c1 = 20000;
tf = 140;
alpha = 200;

v = x(2);
fb = 0.8 *(2.031 + 0.0622 * v + 0.001807 * v * v);
fg = 20;
m = 200;
s1 = x(1) - rd;
ds1 = v - vd;

s2 = ds1 + c1*s1/(tf-t);
u = fb + fg - m*c1*ds1/(tf-t) - m*c1*s1/(tf-t).^2 - alpha * sign(s2);

dx = [x(2); 1/m * (u-fb-fg)];

end