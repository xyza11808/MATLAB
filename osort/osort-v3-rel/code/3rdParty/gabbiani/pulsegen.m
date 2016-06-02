function  [sys, x0, str, ts]  = pulsegen(t,x,u,flag,dt,s,p,w,h)
%pulsegen: S-function that implements a pulse generator with 
%discretized time steps. 
%
%	The pulse output is updated as follows:
%
%	p_i = h if width > 0
%	p_i = 0 otherwise
%
%	The two states variables period and width are updated as follows:
%
%	if t < s-dt then 
%	   period_i+1 = width_i+1 = 0
%	else
%	  if period_i = 0 then 
%	    period_i+1 = np
%	    width_i+1 = nw
%	  else
%	    period_i+1 = period_i - 1
%	    width_i+1 = width_i - 1 
%	  here np = ceil(p/dt) and nw= ceil(w/dt) are the pulse period
%	  and the width in units of the time step.
%
%	The parameters are:
%	
%	s = start time for pulse generation (msec)
%	p = time interval between two pulse starts (msec)
%	w = width of the pulse (msec)
%	h = height of the pulse (nA)
%	
%
%
%

if (abs(flag) == 2)    	% Discrete state update
  if ( t >= s )		% start time for pulse generation reached
    if ( x(1) == 0 )
      sys(1) = ceil(p/dt);
      sys(2) = ceil(w/dt);
    else
      sys(1) = x(1) - 1;
      sys(2) = x(2) - 1;
    end;
  else			% wait for start time
    sys(1) = 0;
    sys(2) = 0;
  end

elseif ( flag == 3 )	%output vector required
  if ( x(2) > 0 )	%output a pulse
    sys = h;
  else
    sys = 0;
  end

elseif ( flag  == 0 )	% Initialization
  

  % Return system sizes
  sys(1) = 0;	% 0 continuous states
  sys(2) = 2;	% 2 discrete states: period and width
  sys(3) = 1;	% 1 output: pulse value
  sys(4) = 0;	% 0 inputs
  sys(5) = 0;	% 0 roots
  sys(6) = 0;	% no direct feedthrough
  sys(7) = 1;	% 1 sample time
  
  x0 = [0, 0];	% Initialization of the period and width states

  ts = [dt, 0];

else 

  sys = [];

end


