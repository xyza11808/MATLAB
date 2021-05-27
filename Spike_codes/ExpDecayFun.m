function y = ExpDecayFun(x,funparas)
A0 = funparas(1);
tau = funparas(2);
y = A0 * exp(-x/tau);




