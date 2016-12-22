%% Estimate Density  

% Copyright 2015 The MathWorks, Inc.


%% 
% Generate a sample data set from a mixture of two normal distributions. 
rng default  % for reproducibility
x = [randn(30,1); 5+randn(30,1)];  
figure;
hist(x,30)
%% 
% Plot the estimated density. 
[f,xi] = ksdensity(x); 
figure
plot(xi,f);     

%%
% The density estimate shows the bimodality of the sample.   

