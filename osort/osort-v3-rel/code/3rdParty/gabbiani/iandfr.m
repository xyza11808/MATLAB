function  [sys, x0, str, ts]  = iandfr(t,x,u,flag,dt,thres,C,ref)
%iandfr: S-function that implements an integrate-and-fire neuron with
%refractory period. The model uses discrete integration time steps. 
%During a simulation the time course of the various variables is
%computed as follows: 
%
%	The membrane voltage is updated using:
%
%	Vm_i+1 = Vm_i + (dt/C) * I_i if Vm_i < thres
%	Vm_i+1 = 0 if Vm_i >= thres or if reftime_i > 0
%
%	The occurence of a spike is determined from:
%
%	spk_i = 1  if Vm_i >=  thres
%	spk_i = 0  if Vm_i < thres
%
%	The state variable reftime is updated as follows:
%
%	reftime_i+1 = n if Vm_i >= thres
%	reftime_i+1 = reftime_i - 1 if reftime_i > 0
%	reftime_i+1 = 0 otherwise
%	where n = ceil(ref/dt) is the refractory time in units of the
%	          time step (rounded up)
%
%	The input variable is:
%
%	I_i = input current at time step i
%
%
%	The output is a two dimensional vector [spk_i, Vm_i].
%	The first component spk_i is equal to 0 if no spike occured or
%	1 if a spike occured. The second component is the membrane
%	voltage Vm (in mV) at time i. 
%
%	The parameters are:
%	
%	dt  = sampling step (in msec)
%	C   = capacitance (in nF)
%	ref = refractory period (in msec)
%
%

if (abs(flag) == 2)    	% Discrete state update
  if ( x(1) >= thres )	% threshold reached, next voltage value is reset
    sys(1) = 0;
    sys(2) = max(ceil(ref/dt)-1,0); %sets the refractory period
  elseif ( x(2) > 0 )	% in refractory period, wait
    sys(1) = 0;
    sys(2) = x(2) - 1;
  else %integrates the voltage
    sys(1) = x(1) + (dt/C) * u;
    sys(2) = 0;
  end

elseif ( flag == 3 )	%output vector required
  if ( x(1) >= thres )	%fire a spike
    sys = [1, x(1)];
  else
    sys = [0, x(1)];
  end

elseif ( flag  == 0 )	% Initialization
  
  nstates = 1;

  % Return system sizes
  sys(1) = 0;	% 0 continuous states
  sys(2) = 2;	% 2 discrete states: membrane voltage and refractory
		%   period indicator
  sys(3) = 2;	% 2 outputs: spike occurence and membrane voltage
  sys(4) = 1;	% 1 input: current
  sys(5) = 0;	% 0 roots
  sys(6) = 0;	% no direct feedthrough
  sys(7) = 1;	% 1 sample time
  
  x0 = [0, 0];	% Initialization of the membrane voltage and
		% refractory time

  ts = [dt, 0];

else 

  sys = [];

end


