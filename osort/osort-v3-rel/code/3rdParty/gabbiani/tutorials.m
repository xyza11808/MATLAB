function [ret,x0,str,ts,xts]=tutorials(t,x,u,flag);
%TUTORIALS	is the M-file description of the SIMULINK system named TUTORIALS.
%	The block-diagram can be displayed by typing: TUTORIALS.
%
%	SYS=TUTORIALS(T,X,U,FLAG) returns depending on FLAG certain
%	system values given time point, T, current state vector, X,
%	and input vector, U.
%	FLAG is used to indicate the type of output to be returned in SYS.
%
%	Setting FLAG=1 causes TUTORIALS to return state derivatives, FLAG=2
%	discrete states, FLAG=3 system outputs and FLAG=4 next sample
%	time. For more information and other options see SFUNC.
%
%	Calling TUTORIALS with a FLAG of zero:
%	[SIZES]=TUTORIALS([],[],[],0),  returns a vector, SIZES, which
%	contains the sizes of the state vector and other parameters.
%		SIZES(1) number of states
%		SIZES(2) number of discrete states
%		SIZES(3) number of outputs
%		SIZES(4) number of inputs
%		SIZES(5) number of roots (currently unsupported)
%		SIZES(6) direct feedthrough flag
%		SIZES(7) number of sample times
%
%	For the definition of other parameters in SIZES, see SFUNC.
%	See also, TRIM, LINMOD, LINSIM, EULER, RK23, RK45, ADAMS, GEAR.

% Note: This M-file is only used for saving graphical information;
%       after the model is loaded into memory an internal model
%       representation is used.

% the system will take on the name of this mfile:
sys = mfilename;
new_system(sys)
simver(1.3)
if (0 == (nargin + nargout))
     set_param(sys,'Location',[164,59,538,441])
     open_system(sys)
end;
set_param(sys,'algorithm',     'RK-45')
set_param(sys,'Start time',    '0.0')
set_param(sys,'Stop time',     'tstop')
set_param(sys,'Min step size', 'tstep')
set_param(sys,'Max step size', 'tstep')
set_param(sys,'Relative error','1e-3')
set_param(sys,'Return vars',   '')


%     Subsystem  'Tutorial 1'.

new_system([sys,'/','Tutorial 1'])
set_param([sys,'/','Tutorial 1'],'Location',[79,53,494,440])
open_system([sys,'/','Tutorial 1'])


%     Subsystem  'Tutorial 1/More Info3'.

new_system([sys,'/','Tutorial 1/More Info3'])
set_param([sys,'/','Tutorial 1/More Info3'],'Location',[196,142,577,351])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info3/Watch the system estimate and error respond as the',13,'gain parameter changes during the simulation.']])
set_param([sys,'/',['Tutorial 1/More Info3/Watch the system estimate and error respond as the',13,'gain parameter changes during the simulation.']],...
		'position',[187,125,192,130])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info3/This system estimates a single scalar parameter.',13,'Open the scopes and run the simulation.']])
set_param([sys,'/',['Tutorial 1/More Info3/This system estimates a single scalar parameter.',13,'Open the scopes and run the simulation.']],...
		'position',[180,15,185,20])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info3/The changing value of the gain applied in the ',13,'Product block "Parameter being estimated" is ',13,'the quantity being estimated.']])
set_param([sys,'/',['Tutorial 1/More Info3/The changing value of the gain applied in the ',13,'Product block "Parameter being estimated" is ',13,'the quantity being estimated.']],...
		'position',[185,60,190,65])
set_param([sys,'/','Tutorial 1/More Info3'],...
		'Mask Display','Theoretical PS and AC')


%     Finished composite block 'Tutorial 1/More Info3'.

set_param([sys,'/','Tutorial 1/More Info3'],...
		'hide name',0,...
		'Drop Shadow',4,...
		'position',[273,345,380,369])

add_block('built-in/Note',[sys,'/',['Tutorial 1/4) Compare the numerical result with the ',13,'theoretical prediction for a renewal process.']])
set_param([sys,'/',['Tutorial 1/4) Compare the numerical result with the ',13,'theoretical prediction for a renewal process.']],...
		'position',[129,335,134,340])


%     Subsystem  'Tutorial 1/More Info2'.

new_system([sys,'/','Tutorial 1/More Info2'])
set_param([sys,'/','Tutorial 1/More Info2'],'Location',[196,142,577,351])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info2/Watch the system estimate and error respond as the',13,'gain parameter changes during the simulation.']])
set_param([sys,'/',['Tutorial 1/More Info2/Watch the system estimate and error respond as the',13,'gain parameter changes during the simulation.']],...
		'position',[187,125,192,130])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info2/This system estimates a single scalar parameter.',13,'Open the scopes and run the simulation.']])
set_param([sys,'/',['Tutorial 1/More Info2/This system estimates a single scalar parameter.',13,'Open the scopes and run the simulation.']],...
		'position',[180,15,185,20])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info2/The changing value of the gain applied in the ',13,'Product block "Parameter being estimated" is ',13,'the quantity being estimated.']])
set_param([sys,'/',['Tutorial 1/More Info2/The changing value of the gain applied in the ',13,'Product block "Parameter being estimated" is ',13,'the quantity being estimated.']],...
		'position',[185,60,190,65])
set_param([sys,'/','Tutorial 1/More Info2'],...
		'Mask Display','Theoretical ISI')


%     Finished composite block 'Tutorial 1/More Info2'.

set_param([sys,'/','Tutorial 1/More Info2'],...
		'hide name',0,...
		'Drop Shadow',4,...
		'position',[280,275,367,303])


%     Subsystem  'Tutorial 1/More Info'.

new_system([sys,'/','Tutorial 1/More Info'])
set_param([sys,'/','Tutorial 1/More Info'],'Location',[196,142,577,351])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info/Watch the system estimate and error respond as the',13,'gain parameter changes during the simulation.']])
set_param([sys,'/',['Tutorial 1/More Info/Watch the system estimate and error respond as the',13,'gain parameter changes during the simulation.']],...
		'position',[187,125,192,130])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info/This system estimates a single scalar parameter.',13,'Open the scopes and run the simulation.']])
set_param([sys,'/',['Tutorial 1/More Info/This system estimates a single scalar parameter.',13,'Open the scopes and run the simulation.']],...
		'position',[180,15,185,20])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info/The changing value of the gain applied in the ',13,'Product block "Parameter being estimated" is ',13,'the quantity being estimated.']])
set_param([sys,'/',['Tutorial 1/More Info/The changing value of the gain applied in the ',13,'Product block "Parameter being estimated" is ',13,'the quantity being estimated.']],...
		'position',[185,60,190,65])
set_param([sys,'/','Tutorial 1/More Info'],...
		'Mask Display','Numerical ISI')


%     Finished composite block 'Tutorial 1/More Info'.

set_param([sys,'/','Tutorial 1/More Info'],...
		'hide name',0,...
		'Drop Shadow',4,...
		'position',[280,240,367,268])

add_block('built-in/Note',[sys,'/',['Tutorial 1/2) Compare the numerical result with the',13,'gamma distribution with refractory period']])
set_param([sys,'/',['Tutorial 1/2) Compare the numerical result with the',13,'gamma distribution with refractory period']],...
		'position',[129,270,134,275])

add_block('built-in/Note',[sys,'/',['Tutorial 1/3) Compute the Power Spectrum and',13,' Autocorrelation of the spike train.']])
set_param([sys,'/',['Tutorial 1/3) Compute the Power Spectrum and',13,' Autocorrelation of the spike train.']],...
		'position',[119,305,124,310])

add_block('built-in/Note',[sys,'/','Tutorial 1/1) Compute the Interspike Interval Distribution'])
set_param([sys,'/','Tutorial 1/1) Compute the Interspike Interval Distribution'],...
		'position',[139,245,144,250])


%     Subsystem  'Tutorial 1/More Info1'.

new_system([sys,'/','Tutorial 1/More Info1'])
set_param([sys,'/','Tutorial 1/More Info1'],'Location',[196,142,577,351])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info1/Watch the system estimate and error respond as the',13,'gain parameter changes during the simulation.']])
set_param([sys,'/',['Tutorial 1/More Info1/Watch the system estimate and error respond as the',13,'gain parameter changes during the simulation.']],...
		'position',[187,125,192,130])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info1/This system estimates a single scalar parameter.',13,'Open the scopes and run the simulation.']])
set_param([sys,'/',['Tutorial 1/More Info1/This system estimates a single scalar parameter.',13,'Open the scopes and run the simulation.']],...
		'position',[180,15,185,20])

add_block('built-in/Note',[sys,'/',['Tutorial 1/More Info1/The changing value of the gain applied in the ',13,'Product block "Parameter being estimated" is ',13,'the quantity being estimated.']])
set_param([sys,'/',['Tutorial 1/More Info1/The changing value of the gain applied in the ',13,'Product block "Parameter being estimated" is ',13,'the quantity being estimated.']],...
		'position',[185,60,190,65])
set_param([sys,'/','Tutorial 1/More Info1'],...
		'Mask Display','Numerical PS and AC')


%     Finished composite block 'Tutorial 1/More Info1'.

set_param([sys,'/','Tutorial 1/More Info1'],...
		'hide name',0,...
		'Drop Shadow',4,...
		'position',[273,315,380,339])

add_block('built-in/Note',[sys,'/',['Tutorial 1/To start and stop the simulation, use the "Start//Stop"',13,'selection in the "Simulation" pull-down menu']])
set_param([sys,'/',['Tutorial 1/To start and stop the simulation, use the "Start//Stop"',13,'selection in the "Simulation" pull-down menu']],...
		'position',[174,185,179,190])

add_block('built-in/Note',[sys,'/',['Tutorial 1/Response of an Integrate-and-fire neuron with ',13,'random threshold to a constant current pulse']])
set_param([sys,'/',['Tutorial 1/Response of an Integrate-and-fire neuron with ',13,'random threshold to a constant current pulse']],...
		'position',[171,35,176,40])


%     Subsystem  ['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period'].

new_system([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']])
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],'Location',[90,87,403,270])

add_block('built-in/Demux',[sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/Demux']])
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/Demux']],...
		'outputs','2',...
		'position',[195,66,235,99])

add_block('built-in/S-Function',[sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/I & F  neuron',13,'with rand. thres.',13,'and ref. period']])
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/I & F  neuron',13,'with rand. thres.',13,'and ref. period']],...
		'function name','giandfr',...
		'parameters','dt,thres,n,C,ref')
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/I & F  neuron',13,'with rand. thres.',13,'and ref. period']],...
		'position',[105,61,145,109])

add_block('built-in/Inport',[sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/in_1']])
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/in_1']],...
		'position',[55,75,75,95])

add_block('built-in/Outport',[sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/out_2']])
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/out_2']],...
		'position',[265,105,285,125])

add_block('built-in/Outport',[sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/out_1']])
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period/out_1']],...
		'Port','2',...
		'position',[265,35,285,55])
add_line([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],[150,85;190,85])
add_line([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],[240,75;260,45])
add_line([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],[240,90;260,115])
add_line([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],[80,85;100,85])
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],...
		'Mask Display','Vm \n\n spikes',...
		'Mask Type','I&F g. thres., ref. per.')
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],...
		'Mask Dialogue','Parameters|time step [msec]|mean threshold [mV]|gamma distr. order|Capacitance [nF]|refractory period [msec]')
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],...
		'Mask Translate','dt = @1; thres = @2; n = @3; C = @4; ref = @5; if (ref<dt) disp('' ''); disp(''Warning: refractory period cannot be smaller than time step.''); disp('' ''); end;')
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],...
		'Mask Help','For a detailled description of the model, please type ''help giandfr'' in the main matlab window')
set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],...
		'Mask Entries','tstep\/10\/5\/0.5\/5\/')


%     Finished composite block ['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period'].

set_param([sys,'/',['Tutorial 1/I & F neuron',13,'with rand. thres.',13,'and ref. period']],...
		'position',[160,86,205,139])

add_block('built-in/Scope',[sys,'/','Tutorial 1/Scope'])
set_param([sys,'/','Tutorial 1/Scope'],...
		'Vgain','2.000000',...
		'Hgain','500.000000',...
		'Vmax','4.000000',...
		'Hmax','1000.000000',...
		'Window',[306,137,637,451])
open_system([sys,'/','Tutorial 1/Scope'])
set_param([sys,'/','Tutorial 1/Scope'],...
		'position',[270,70,300,100])

add_block('built-in/To Workspace',[sys,'/','Tutorial 1/To Workspace'])
set_param([sys,'/','Tutorial 1/To Workspace'],...
		'mat-name','spk',...
		'buffer','ceil(tstop/tstep)',...
		'position',[260,142,310,158])

add_block('built-in/Constant',[sys,'/','Tutorial 1/Constant current'])
set_param([sys,'/','Tutorial 1/Constant current'],...
		'Value','i',...
		'Mask Display','',...
		'Mask Type','constant current',...
		'Mask Dialogue','Parameter|constant current value [nA]',...
		'Mask Translate','i = @1;')
set_param([sys,'/','Tutorial 1/Constant current'],...
		'Mask Help','Provides a constant input current',...
		'Mask Entries','0.6\/',...
		'position',[70,102,95,128])

add_block('built-in/Note',[sys,'/','Tutorial 1/Once that the stimulation stopped, you can:'])
set_param([sys,'/','Tutorial 1/Once that the stimulation stopped, you can:'],...
		'position',[134,220,139,225])
add_line([sys,'/','Tutorial 1'],[210,125;225,125;225,150;255,150])
add_line([sys,'/','Tutorial 1'],[210,125;235,125;235,85;265,85])
add_line([sys,'/','Tutorial 1'],[100,115;155,115])
set_param([sys,'/','Tutorial 1'],...
		'Mask Display','                   ')


%     Finished composite block 'Tutorial 1'.

set_param([sys,'/','Tutorial 1'],...
		'position',[50,35,119,84])

drawnow

% Return any arguments.
if (nargin | nargout)
	% Must use feval here to access system in memory
	if (nargin > 3)
		if (flag == 0)
			eval(['[ret,x0,str,ts,xts]=',sys,'(t,x,u,flag);'])
		else
			eval(['ret =', sys,'(t,x,u,flag);'])
		end
	else
		[ret,x0,str,ts,xts] = feval(sys);
	end
else
	drawnow % Flash up the model and execute load callback
end
