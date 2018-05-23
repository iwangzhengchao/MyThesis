function dydt = vdp1(t, y, u)

fb = 0.8 *(2.031 + 0.0622 * y(2) + 0.001807 * y(2) * y(2));
fg = 20;
m = 200;
dydt = [y(2); (u-fb-fg)/m];