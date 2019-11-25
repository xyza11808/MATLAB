function train_test_RNN(p,mypath)

%demo for generating data from a network that performs the towers/detection
%task

N = 1000; %number of neurons
cross_mod_N = N/20; %number of neurons that project from one module to the other (maxiumum is N/2)
g = 1.5; %intermodule recurrent connectivity strength of the teacher network
goff = 0.75; %intermodule recurrent connectivity strength of the teacher network
%p = 0.05; %cross module sparsity of the teacher network

T = 300; %trial duration (in units of tau)
dt = 0.1; %integration timestep (units of tau)
tau = 1; %decay timescale

%1:N/2 is posterior mode, N/2+1:N is anterior mode

post_post = 1:N/2; %posterior module's postsynaptic neural indices.
post_pre = [1:N/2,N/2+1:N/2+cross_mod_N]; %posterior module's presynaptic neural indices (i.e. the neurons that project from posterior -> (posterior,anterior))
ant_post = N/2+1:N; %anterior module's postsynaptic neurla indices. these are also used to define the presynaptic output of the anterior module to the network output
ant_pre = [1:cross_mod_N,N/2+1:N]; %anterior module's presynaptic neural indices (i.e. the neurons that project from anterior -> (posterior,anterior))

%%  Create connectivity matrices

rng(6); %set random seed

uIn_pulse = 2*rand(N,2) - 1; %pulse inputs
uIn_const = 2*rand(N,2) - 1; %constant inputs
uIn_GO = 2*rand(N,3) - 1; %go signal
uOut = 2*rand(N,2) - 1; %teaching network "target input" matrices

uIn_pulse(ant_post,:) = 0; %shut off pulse input into anterior module
uIn_const(ant_post,:) = 0; %shut off detect input into anterior module
uOut(post_post,1) = 0; %shut off output from posterior mode
uOut(ant_post,2) = 0; %shut off hint into anterior mode

%teacher network connectivity
J1 = 1/sqrt(N) * blkdiag(randn(length(post_post)), randn(length(ant_post)));
holes = J1 == 0; %off diags
ConnProb = rand(size(J1)) < p;
weights = randn(size(J1));
J1 = g * J1 + goff/sqrt(N) * holes .* ConnProb .* weights;

%% learning network matrices

J2 = zeros(N); %recurrent connectivity of learned network
w = zeros(2,length(ant_post)); %network output
Pw = eye(length(ant_post)); %inverse covariance of the output
PJ1 = eye(length(post_pre)); %inverse covariance of posterior module
PJ2 = eye(length(ant_pre)); %inverse covariance of anterior module

%% untrained network data

mode = 'untrained';
make_figure = false;
num_trials = 10; % number of trials

[~,~,~,~,~,~,~,Rdata_untrained] = RNN(T,N,post_post,post_pre,ant_post,ant_pre,...
    num_trials,dt,tau,...
    0*uIn_GO,0*uIn_pulse,0*uIn_const,0*uOut,...
    J1,w,J2,[],[],[],mode,make_figure);

%% Train the network

mode = 'train';
num_trials = 100; % number of trials
[J2, w, PJ1, PJ2, Pw] = RNN(T,N,post_post,post_pre,ant_post,ant_pre,...
    num_trials,dt,tau,...
    uIn_GO,uIn_pulse,uIn_const,uOut,...
    J1,w,J2,PJ1,PJ2,Pw,mode,make_figure);

%% test

mode = 'test';
num_trials = 100; % number of trials
[Task_data, Godata, pulsedata, constdata, outputdata, zsdata, R2data] = ...
    RNN(T,N,post_post,post_pre,ant_post,ant_pre,num_trials,dt,tau,...
    uIn_GO,uIn_pulse,uIn_const,uOut,...
    J1,w,J2,[],[],[],mode,make_figure);

%% Compute correlations

if make_figure
    plotRNNcorr(R2data,Task_data,N,post_post,ant_post);
end

save(fullfile(mypath,sprintf('data_and_network_sparse_%g.mat',p)),'-v7.3');

end
