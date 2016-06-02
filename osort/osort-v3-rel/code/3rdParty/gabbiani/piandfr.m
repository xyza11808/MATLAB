function  [sys, x0, str, ts]  = piandfr(t,x,u,flag,dt,thres,C,ref)
%piandfr: S-function that implements an integrate-and-fire neuron
%model with Poisson distributed random threshold (i.e., a Poisson
%spike train generator) and refractory period. 
%The model uses discrete integration time steps. During a simulation
%the time-course of the various variables is computed as follows:
%
%	The membrane voltage is updated using:
%
%	Vm_i+1 = Vm_i + (dt/C) * I_i, if Vm_i < randomthres_i
%	Vm_i+1 = 0, if Vm_i >= randomthres_i or if reftime_i > 0 
%
%	The occurence of a spike is determined from:
%
%	spk_i = 1  if (Vm_i >=  randomthres_i)
%	spk_i = 0  if (Vm_i < randomthres_i)
%
%	The refractory period indicator is updated using:
%
%	reftime_i+1 = n, if Vm_i >= randomthres_i
%	reftime_i+1 = reftime_i - 1 if (reftime_i > 0)
%	reftime_i+1 = 0 otherwise
%	where n = ceil(ref/dt) is the refractory time in units of the
%	          time step (rounded up)
%
%       The random threshold is updated using:
%
%       randomthres_i+1 = random_i, if Vm_i < randomthres_i
%	randomthres_i+1 = random number drawn from a exponential 
%	                  distribution with mean=thres,
%	                  if Vm_i >= randomthres_i
%	
%	The input variable is:
%	
%	I_i = input current at time step i (in nA)
%
%	The output is a two dimensional vector [spk_i, Vm_i].
%	The first component spk_i is equal to 0 if no spike occured or
%	1 if a spike occured). The second component is the membrane
%	voltage Vm (in mV) at time i. 
%
%	The parameters are:
%
%	dt  = sampling step (in msec)
%	thres = mean threshold value (in mV)
%	n = order of the gamma distribution
%	C   = capacitance (in nC)
%	ref = refractory period (in msec)
%
%

if (abs(flag) == 2)    	% Discrete state update
  if ( x(1) >= x(3) )	% threshold reached, next voltage value is reset
    sys(1) = 0;
    sys(2) = max(0,ceil(ref/dt)-1); %sets the refractory period
    sys(3) = exprnd(thres); %updates the threshold
  elseif ( x(2) > 0 )	% in refractory period, wait
    sys(1) = 0;
    sys(2) = x(2) - 1;
    sys(3) = x(3);
  else %integrates the voltage
    sys(1) = x(1) + (dt/C) * u;
    sys(2) = 0;
    sys(3) = x(3);
  end

elseif ( flag == 3 )	%output vector required
  if ( x(1) >= x(3) )	%fire a spike
    sys = [1, x(1)];
  else
    sys = [0, x(1)];
  end

elseif ( flag  == 0 )	% Initialization
  
  % Return system sizes
  sys(1) = 0;	% 0 continuous states
  sys(2) = 3;	% 3 discrete states: membrane voltage, refractory
%		    period indicator and random threshold 
  sys(3) = 2;	% 2 outputs: spike occurence and membrane voltage
  sys(4) = 1;	% 1 input: current
  sys(5) = 0;	% 0 roots
  sys(6) = 0;	% no direct feedthrough
  sys(7) = 1;	% 1 sample time: dt
  
  x0 = [0, 0, exprnd(thres)];	% Initialization of the membrane voltage,
				%refractory time and random threshold
%  disp('the first threshold is: ');
%  disp(x0(1,3));

  ts = [dt, 0];

else 

  sys = [];

end


