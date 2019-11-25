clearvars;

load('data_and_network.m','-v7.3');

mode = 'inactivate';
make_figure = true;
num_trials = 200; % number of trials

percents = linspace(0,0.1,21);
per_corr_post = NaN(length(percents),numruns,num_trials,2);
per_corr_ant = NaN(length(percents),numruns,num_trials,2);

for j = 1:length(percents)
    
    for k = 1:numruns
        
        inactive_vec = randsample(post_post,round(percents(j)*N/2));
        
        [~, Task_data_inactivate, ~, ~, ~, outputdata_inactivate, zsdata_inactivate] = ...
            RNN(T,N,post_post,post_pre,ant_post,ant_pre,num_trials,dt,tau,...
            uIn_GO,uIn_pulse,uIn_const,uOut,...
            J1,w,J2,PJ1,PJ2,Pw,mode,make_figure,inactive_vec);
        
        per_corr_post(j,k,:,1) = logical(0.5*(squeeze(sign(sum(outputdata_inactivate(1,2500:end,:),2))) + 1)) == ...
            logical(0.5*(squeeze(sign(sum(zsdata_inactivate(1,2500:end,:),2))) + 1));
        per_corr_post(j,k,:,2) = Task_data_inactivate;
        
        inactive_vec = randsample(ant_post,round(percents(j)*N/2));
        
        [~, Task_data_inactivate, ~, ~, ~, outputdata_inactivate, zsdata_inactivate] = ...
            RNN(T,N,post_post,post_pre,ant_post,ant_pre,num_trials,dt,tau,...
            uIn_GO,uIn_pulse,uIn_const,uOut,...
            J1,w,J2,PJ1,PJ2,Pw,mode,make_figure,inactive_vec);
        
        per_corr_ant(j,k,:,1) = logical(0.5*(squeeze(sign(sum(outputdata_inactivate(1,2500:end,:),2))) + 1)) == ...
            logical(0.5*(squeeze(sign(sum(zsdata_inactivate(1,2500:end,:),2))) + 1));
        per_corr_ant(j,k,:,2) = Task_data_inactivate;
        
    end
    
end

%% Figure

ant = NaN(21,2);
post = NaN(21,2);

for i = 1:21
    for j = 1:2
        ant(i,j) = mean(per_corr_ant(i,logical(per_corr_ant(i,:,2) == j),1),2);
        post(i,j) = mean(per_corr_post(i,logical(per_corr_post(i,:,2) == j),1),2);
    end
end

figure;subplot(211);plot(percents,post);legend('towers','detect');title('posterior module');
subplot(212);plot(percents,ant);legend('towers','detect');title('anterior module');
