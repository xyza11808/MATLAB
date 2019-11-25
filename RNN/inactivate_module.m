clearvars

mypath = '/mnt/bucket/labs/brody/briandd/RNN/data/original_data';

load(fullfile(mypath,'data_and_network.mat'),...
    'T','N','post_post','post_pre','ant_post','ant_pre',...
    'dt','tau','uIn_GO','uIn_pulse','uIn_const','uOut',...
    'J1','w','J2');

mode = 'inactivate';
make_figure = false;
num_trials = 200; % number of trials
num_percs = 21;
numruns = 50;

percents = linspace(0,0.1,num_percs);
iscorrect_post = NaN(numruns,num_trials,length(percents));
iscorrect_ant = NaN(numruns,num_trials,length(percents));
tasks_post = NaN(numruns,num_trials,length(percents));
tasks_ant = NaN(numruns,num_trials,length(percents));

pc = parcluster('local');
pool = parpool(pc,pc.NumWorkers);

parfor k = 1:numruns

    corr_post = NaN(num_trials,length(percents));
    t_post = NaN(num_trials,length(percents));

    for j = 1:length(percents)

        clc;fprintf('\n percent %g of %g, %g of %g',j,length(percents),k,numruns)

        inactive_vec = randsample(post_post,round(percents(j)*N/2));
        
        [Task_data, ~, ~, ~, outputdata, zsdata] = ...
            RNN(T,N,post_post,post_pre,ant_post,ant_pre,num_trials,dt,tau,...
            uIn_GO,uIn_pulse,uIn_const,uOut,...
            J1,w,J2,[],[],[],mode,make_figure,inactive_vec);
        
        corr_post(:,j) = logical(0.5*(squeeze(sign(sum(outputdata(1,2500:end,:),2))) + 1)) == ...
            logical(0.5*(squeeze(sign(sum(zsdata(1,2500:end,:),2))) + 1));

        t_post(:,j) = Task_data;
        
    end

    iscorrect_post(k,:,:) = corr_post;
    tasks_post(k,:,:) = t_post;
    
end

parfor k = 1:numruns

    corr_ant = NaN(num_trials,length(percents));
    t_ant = NaN(num_trials,length(percents));

    for j = 1:length(percents)

        clc;fprintf('\n percent %g of %g, %g of %g',j,length(percents),k,numruns)

        inactive_vec = randsample(ant_post,round(percents(j)*N/2));
        
        [Task_data, ~, ~, ~, outputdata, zsdata] = ...
            RNN(T,N,post_post,post_pre,ant_post,ant_pre,num_trials,dt,tau,...
            uIn_GO,uIn_pulse,uIn_const,uOut,...
            J1,w,J2,[],[],[],mode,make_figure,inactive_vec);
        
         corr_ant(:,j) = logical(0.5*(squeeze(sign(sum(outputdata(1,2500:end,:),2))) + 1)) == ...
            logical(0.5*(squeeze(sign(sum(zsdata(1,2500:end,:),2))) + 1));

        t_ant(:,j) = Task_data;
        
    end

    iscorrect_ant(k,:,:) = corr_ant;
    tasks_ant(k,:,:) = t_ant;
    
end

delete(pool);

save(fullfile(mypath,'data_inactivation_module.mat'),'iscorrect_post','iscorrect_ant',...
    'tasks_ant','tasks_post','percents','num_trials','numruns');
