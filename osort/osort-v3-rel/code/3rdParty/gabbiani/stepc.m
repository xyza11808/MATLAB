function  [sys, x0, str, ts]  = stepc(t,x,u,flag,dt,s,w,h)
%stepc: S-function that implements a step current pulse with 
%discretized time steps. 
%
%	The pulse output is updated as follows:
%
%	p_i = h if width_i > 0
%	p_i = 0 otherwise
%
%	The state variable width is updated as follows:
%
%	if t < s-dt then 
%	   width_i+1 = -1
%	else
%	  if width_i = -1 then 
%	    width_i+1 = nw
%	  else
%	    if width_i > 0 then
%	      width_i = width_i - 1
%	    else width_i = 0
%	  here nw= ceil(w/dt) is the width in units of the time step.
%
%	The parameters are:
%	
%	s = start time for pulse generation (msec)
%	w = width of the pulse (msec)
%	h = height of the pulse (nA)
%	
%
%
%

if (abs(flag) == 2)    	% Discrete state update
  if ( t >= s )		% start time for pulse generation reached
    if ( x(1) == -1 )
      sys(1) = ceil(w/dt);
    else
      if ( x(1) > 0 )
        sys(1) = x(1) - 1;
      else 
        sys(1) = 0;
      end
    end
  else			% wait for start time
    sys(1) = -1;
  end

elseif ( flag == 3 )	%output vector required
  if ( x(1) > 0 )	%pulse on
    sys = h;
  else
    sys = 0;
  end

elseif ( flag  == 0 )	% Initialization
  

  % Return system sizes
  sys(1) = 0;	% 0 continuous states
  sys(2) = 1;	% 1 discrete states: width of the step
  sys(3) = 1;	% 1 output: pulse value
  sys(4) = 0;	% 0 inputs
  sys(5) = 0;	% 0 roots
  sys(6) = 0;	% no direct feedthrough
  sys(7) = 1;	% 1 sample time
  
  x0 = -1;	% Initialization of the width state

  ts = [dt, 0];

else 

  sys = [];

end


