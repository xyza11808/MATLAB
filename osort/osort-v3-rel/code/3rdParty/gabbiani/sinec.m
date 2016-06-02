function  [sys, x0, str, ts]  = sinec(t,x,u,flag,dt,a,f,p,o)
%sinec: S-function that implements a discretized sine-wave  current
%
%	The current output is updated as follows:
%
%	I_i = a*sin[2*pi*(f*10e-3*t + p)] + o
%
%	The factor 10e-3 handles the conversion between Hz and kHz,
%	since the time units are msec. Multiplication by 2*pi converts
%	to radians
%
%	The parameters are:
%	
%	a = amplitude of the sine wave component (nA)
%	f = frequency (Hz)
%	p = phase (percent of the sine period, from 0 to 1)
%	o = current offset (nA)
%
%
%

if (abs(flag) == 2)    	% Discrete state update nothing to do
  sys = [];

elseif ( flag == 3 )	%output vector required
  sys=a*sin(2*pi*(f*1e-3*t+p))+o;
  
elseif ( flag  == 0 )	% Initialization
  

  % Return system sizes
  sys(1) = 0;	% 0 continuous states
  sys(2) = 0;	% 0 discrete states
  sys(3) = 1;	% 1 output: current value
  sys(4) = 0;	% 0 inputs
  sys(5) = 0;	% 0 roots
  sys(6) = 0;	% no direct feedthrough
  sys(7) = 1;	% 1 sample time
  
  x0 = [];	% Initialization of the width state

  ts = [dt, 0];

else 

  sys = [];

end


