
% using a model to fit the constantly changed boundaries
B_t = f(t);
dB_dt = sign(Stim_t(t-1) - B_t(t-1))*PredError(t-1);

% for each trial, we define a rightward prob value
% according to the distance between current stimuli and internal boundary
% position
% all Stimulus value was in octave form
