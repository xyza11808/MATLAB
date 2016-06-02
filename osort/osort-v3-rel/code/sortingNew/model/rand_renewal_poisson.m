function interspk_interval = rand_renewal_poisson (firing_rate, dead_time)
%   interspike_interval = rand_renewal_poisson (firing_rate, dead_time)
%RAND_POISSON generate a random variable which satisfis renewal poisson process;
%   the distribution is p(t) = lamda*exp(-lamda*(t-t0)), t>0
%                       where lamda is the firing_rate, t0 is the dead_time
%Input:
%	firing_rate   -   neuron firing rate, spikes/sec
%	dead_time     -   absolute refractory period, second
%Output:
%	interspk_interval      -     interspike interval, second
%See also:

%Hanzhang Lu
%Date: 03/03/1999

r = exprnd(1/firing_rate);
interspk_interval = r+dead_time;