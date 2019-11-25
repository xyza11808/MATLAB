function inactivate(p,mypath)

S = load(fullfile(mypath,sprintf('data_and_network_sparse_%g.mat',p)),...
    'T','N','post_post','post_pre','ant_post','ant_pre',...
    'dt','tau','uIn_GO','uIn_pulse','uIn_const','uOut',...
    'J1','w','J2','p');

T = S.T;
N = S.N;
post_post = S.post_post;
post_pre = S.post_pre;
ant_post = S.ant_post;
ant_pre = S.ant_pre;
dt = S.dt;
tau = S.tau;
uIn_GO = S.uIn_GO;
uIn_pulse = S.uIn_pulse;
uIn_const = S.uIn_const;
uOut = S.uOut;
J1 = S.J1;
w = S.w;
J2 = S.J2;
p = S.p;

clear S

mode = 'inactivate';
make_figure = false;
num_trials = 200; % number of trials
num_percs = 21;
numruns = 50;

percents = linspace(0,0.1,num_percs);
iscorrect = NaN(numruns,num_trials,length(percents));
tasks = NaN(numruns,num_trials,length(percents));

pc = parcluster('local');
pool = parpool(pc,pc.NumWorkers);

parfor k = 1:numruns

    corrtemp = NaN(num_trials,length(percents));
    ttemp = NaN(num_trials,length(percents));

    for j = 1:length(percents)

        clc;fprintf('\n percent %g of %g, %g of %g',j,length(percents),k,numruns)

        inactive_vec = randsample(post_post,round(percents(j)*N));
        
        [Task_data, ~, ~, ~, outputdata, zsdata] = ...
            RNN(T,N,post_post,post_pre,ant_post,ant_pre,num_trials,dt,tau,...
            uIn_GO,uIn_pulse,uIn_const,uOut,...
            J1,w,J2,[],[],[],mode,make_figure,inactive_vec);
        
        corrtemp(:,j) = logical(0.5*(squeeze(sign(sum(outputdata(1,2500:end,:),2))) + 1)) == ...
            logical(0.5*(squeeze(sign(sum(zsdata(1,2500:end,:),2))) + 1));

        ttemp(:,j) = Task_data;
        
    end

    iscorrect(k,:,:) = corrtemp;
    tasks(k,:,:) = ttemp;
    
end

delete(pool);

save(fullfile(mypath,sprintf('data_inactivation_sparse_%g.mat',p)),'iscorrect',...
    'tasks','percents','num_trials','numruns');

end
