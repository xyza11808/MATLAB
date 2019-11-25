function  varargout = RNN(T,N,post_post,post_pre,ant_post,ant_pre,...
    num_trials,dt,tau,...
    uIn_GO,uIn_pulse,uIn_const,uOut,...
    J1,w,J2,PJ1,PJ2,Pw,mode,make_figure,varargin)

%for plotting
if make_figure
    
    fh = figure('Color','w', 'menubar', 'none', 'NumberTitle','off','ToolBar','none','name', 'RNN!',...
        'Position', [100, 100, 500, 1500]);
    nplt = 10;
    
    %axes handles
    ah1 = axes(fh,'LineWidth',2,'FontSize',12,'Position',[0.1 0.05 0.8 0.30],'xlim',[-10 T+10],'ylim',[-1.1,1.1]);
    ah2 = axes(fh,'LineWidth',2,'FontSize',12,'Position',[0.1 0.40 0.8 0.25],'xlim',[-10 T+10],'ylim',[-1.1,1.1],...
        'XColor','w');
    ah3 = axes(fh,'LineWidth',2,'FontSize',12,'Position',[0.1 0.70 0.8 0.25],'xlim',[-10 T+10],'ylim',[-1.1,(nplt * 2) - 1 + 0.1],...
        'XColor','w');
    
    xlabel(ah1,'time (tau)');
    title(ah3,'neurons');
    title(ah2,'pulses and visual cue');
    title(ah1,'output');
    
    %line handles for input and target output
    lh_Lpulse = line(ah2,'Color','b','LineWidth',1,'Marker','none','LineStyle','-');
    lh_Lconst = line(ah2,'Color','b','LineWidth',2,'Marker','none','LineStyle',':');
    
    lh_Rpulse = line(ah2,'Color','r','LineWidth',1,'Marker','none','LineStyle','-');
    lh_Rconst = line(ah2,'Color','r','LineWidth',2,'Marker','none','LineStyle',':');
    
    %line handles for output targets and generated output
    for i = 1:3
        lh_go(i) = line(ah1,'Color','k','LineWidth',1,'Marker','none','LineStyle','-');
    end
    lh_z(1) = line(ah1,'Color','r','LineWidth',2,'Marker','none','LineStyle','-');
    lh_z(2) = line(ah1,'Color','r','LineWidth',2,'Marker','none','LineStyle','-');
    lh_out(1) = line(ah1,'Color','k','LineWidth',1,'Marker','none','LineStyle','-');
    lh_out(2) = line(ah1,'Color','g','LineWidth',1,'Marker','none','LineStyle','-');
    
    %neuron line handles
    for i = 1:nplt
        lh_r1(i) = line(ah3,'Color','k','LineWidth',1,'Marker','none','LineStyle','-');
        lh_r2(i) = line(ah3,'Color','r','LineWidth',2,'Marker','none','LineStyle','-');
    end
    
end

%% Initialize state variables and emptry arrays for storing activity

t = 0:dt:T; %time indices for a trial

H1 = 0.1 * randn(N,1); %state of teacher network
H2 = H1; %state of learning network
R1 = zeros(N, length(t)); %for saving data
R2 = zeros(N, length(t));
Tar = zeros(N, length(t));
zt = zeros(2, length(t));

%% For collecting data, only when not training

if ~strcmp(mode,'train')
    if ~strcmp(mode,'inactivate')
        R1data = nan(N, length(t), num_trials); %N is number of nodes, t is time, num_trials is number of trials
        R2data = nan(N, length(t), num_trials); %N is number of nodes, t is time, num_trials is number of trials
    end
    Task_data = nan(num_trials,1);
    Go = nan(3,length(t),num_trials);
    pulses = nan(2,length(t),num_trials);
    consts = nan(2,length(t),num_trials);
    outputs = nan(2,length(t),num_trials);
    zs = nan(2,length(t),num_trials);
end

%% which neurons to inactivate

if strcmp(mode,'inactivate')
    inactive_vec = varargin{1};
end

%%  loop over trials

for trial = 1:num_trials
    
    %create input and output for current trial
    make_external_inputs;
    
    %multiply all the inputs by their input vectors
    pulse = uIn_pulse*[fin_Lpulse;fin_Rpulse]; %pulses
    const = uIn_const*[fin_Lconst;fin_Rconst];% detect
    go = uIn_GO*fin_GO; % go cue
    output = uOut*fOut;     %decision output
    
    for tt = 1:length(t)     % loop over length of trial
        
        %common external input to both networks
        Common_ext = go(:,tt) + const(:,tt);
        
        %teacher recurrent input
        R1(:, tt) = tanh(H1);
        
        Tar(:, tt) = J1*R1(:, tt) + output(:, tt); %internal targets for RLS
        JR1 = Tar(:, tt) + Common_ext + (Task == 1) * pulse(:,tt);  %NOTE A KEY FEATURE HERE: PULSE IS GATED OFF FOR DETECT TASK
        
        %learner recurrent input
        R2(:, tt) = tanh(H2);
        
        %shut off neurons to study inactivation
        if strcmp(mode,'inactivate')
            R2(inactive_vec,tt) = 0;
        end
        
        JR2 = J2*R2(:, tt) + Common_ext + pulse(:,tt);
        
        %readout from the anterior module
        zt(:,tt) = w*R2(ant_post,tt);
     
        %decay both networks
        H2 = (-H2 + JR2)*dt/tau + H2;
        H1 = (-H1 + JR1)*dt/tau + H1;
        
        %RLS
        if strcmp(mode,'train') && mod(tt,9) == 0
            RLS;
        end
        
    end
    
    %update lines in figure
    if make_figure
        
        %plot neural activity
        pltvec = [1:5,N/2+1:N/2+5];
        for i = 1:length(lh_r1)
            set(lh_r1(i),'XData',t,'YData',R1(pltvec(i), :)+2*(i-1));
            set(lh_r2(i),'XData',t,'YData',R2(pltvec(i), :)+2*(i-1));
        end
        
        %plot pulses and constant input
        set(lh_Lpulse,'XData',t,'YData',1*fin_Lpulse);
        set(lh_Lconst,'XData',t,'YData',1*fin_Lconst);
        set(lh_Rpulse,'XData',t,'YData',-1*fin_Rpulse);
        set(lh_Rconst,'XData',t,'YData',-1*fin_Rconst);
        
        %plot output and targets
        for i = 1:3
            set(lh_go(i),'XData',t,'YData',fin_GO(i,:));
        end
        set(lh_z(1),'XData',t,'YData',zt(1,:));
        set(lh_z(2),'XData',t,'YData',zt(2,:));
        set(lh_out(1),'XData',t,'YData',fOut(1,:));
        set(lh_out(2),'XData',t,'YData',fOut(2,:));
        
        drawnow;
        
    end
    
    clc; fprintf('\n mode %s, trial %g', mode, trial);
    
    %save some data
    if ~strcmp(mode,'train')
        %matrix of neurons over time for this trials is R2
        if ~strcmp(mode,'inactivate')
            R2data(:,:,trial) = R2;
            R1data(:,:,trial) = R1;
         end
        Task_data(trial) = Task;
        Go(:,:,trial) = fin_GO;
        pulses(:,:,trial) = [fin_Lpulse;fin_Rpulse];
        consts(:,:,trial) = [fin_Lconst;fin_Rconst];
        outputs(:,:,trial) = fOut;
        zs(:,:,trial) = zt;
    end
    
end

%% Subfunctions

    function  make_external_inputs
        
        bDur = 250; %I'm actually not quite sure what this is
        pDur = 100; %duration of pulse (units of dt)
        inBin = 10; % number of possible pulses on each side
        outDur = 200; %duration of output (units of dt)        
        outStart = 1+(inBin-1)*bDur+2*pDur; % index when you start to answer
        offSet = -0.5; % constant input for nosepoke
        
        counter = 3/inBin; %also not sure, but sets the scale of the intergral
        scale = 0.25;
        
        Task = randi([1 2]);
        
        % Go signal   
        fin_GO = 1.5 * [linspace(0,1,length(t)).^8;linspace(0,1,length(t)).^4;linspace(0,1,length(t)).^2];
        %fin_GO = zeros(1, length(t));
        %fin_GO(outStart:outStart+pDur) = scale;
        
        % Choose L or R trial for pulses     
        if randi(2) == 1
            pLeft_pulse = 0.70;
        else
            pLeft_pulse = 0.30;
        end
        
        pRight_pulse = 1 - pLeft_pulse;
        
        % Pulses       
        fin_Lpulse = zeros(1, length(t));
        fin_Rpulse = zeros(1, length(t));
        
        for ii = 1:inBin %loop over number of pulses
            
            if rand < pLeft_pulse
                fin_Lpulse(1+(ii-1)*bDur:1+(ii-1)*bDur+pDur) = scale;
            end
            
            if rand < pRight_pulse
                fin_Rpulse(1+(ii-1)*bDur:1+(ii-1)*bDur+pDur) = scale;
            end
            
        end
        
        % Make relevant inputs and outputs, depending on the task
        
        fOut = zeros(2, length(t));
                
        if Task == 1  %towers task
            
            fin_GO(2:3,:) = zeros(2,length(t));
            fin_GO(1,:) = offSet +  fin_GO(1,:);
            
            %fin_GO(2:3,:) = zeros(2,length(t));
            %fin_GO(1,:) = -0.5; fin_GO(1,outStart:outStart+pDur) = 0.5;
                        
            fin_Rconst = zeros(1, length(t));
            fin_Lconst = zeros(1, length(t));
            
            %integral of pulses
            for ttt = 2:length(t)
                fOut(2,ttt) = fOut(2,ttt-1) + counter*(fin_Lpulse(ttt-1) - fin_Rpulse(ttt-1))*dt/(2*tau);
            end
            
            %output is threshold of pulse integral
            if (sum(fin_Lpulse) - sum(fin_Rpulse)) > 0
                fOut(1,outStart+bDur:outStart+outDur+bDur) =  + sin(pi*(0:outDur)./outDur);
            else
                fOut(1,outStart+bDur:outStart+outDur+bDur) =  - sin(pi*(0:outDur)./outDur);
            end
            
        elseif Task == 2 %detect task
            
            %choose L or R trial
            if randi(2) == 1
                pLeft_detect = 0.70;
            else
                pLeft_detect = 0.30;
            end
            
            if rand < pLeft_detect
                fin_Lconst = scale * ones(1, length(t));
                fin_Rconst = zeros(1, length(t));
                fOut(1,outStart+bDur:outStart+outDur+bDur) =  + sin(pi*(0:outDur)./outDur);
            else
                fin_Lconst = zeros(1, length(t));
                fin_Rconst = scale * ones(1, length(t));
                fOut(1,outStart+bDur:outStart+outDur+bDur) =  - sin(pi*(0:outDur)./outDur);
            end
            
            fin_GO(2:3,:) = zeros(2,length(t));
            fin_GO(1,:) = offSet +  fin_GO(1,:);
            %fin_GO(1,:) = -0.5; fin_GO(1,outStart:outStart+pDur) = scale;
            
        end
        
    end

    function RLS
          
        %train connections from posterior to itself and anterior
        err2 = J2(post_post,post_pre)*R2(post_pre, tt) - Tar(post_post, tt);     
        k = PJ1*R2(post_pre, tt);
        rPr = R2(post_pre, tt)'*k;
        c = 1.0/(1.0 + rPr);
        PJ1 = PJ1 - c*(k*k');
        J2(post_post,post_pre) = J2(post_post,post_pre) - c*err2*k';
        
        %train connections from anterior to itself and posterior
        err2 = J2(ant_post,ant_pre)*R2(ant_pre,tt) - Tar(ant_post, tt);    
        k = PJ2*R2(ant_pre, tt);
        rPr = R2(ant_pre, tt)'*k;
        c = 1.0/(1.0 + rPr);
        PJ2 = PJ2 - c*(k*k');
        J2(ant_post,ant_pre) = J2(ant_post,ant_pre) - c*err2*k';   
        
        %network readout 
        err1 = zt(:,tt) - fOut(:,tt);
        k = Pw*R2(ant_post, tt); %wchange
        rPr = R2(ant_post, tt)'*k;
        c = 1.0/(1.0 + rPr);
        Pw = Pw - c*(k*k');
        w = w - c*err1*k';
        
    end

if make_figure; close(fh); end

if strcmp(mode,'train');
    varargout{1} = J2; %projection to factors
    varargout{2} = w; %output
    varargout{3} = PJ1; %inverse covariance of v
    varargout{4} = PJ2; %inverse covariance of v
    varargout{5} = Pw;
else
    varargout{1} = Task_data;
    varargout{2} = Go;
    varargout{3} = pulses;
    varargout{4} = consts;
    varargout{5} = outputs;
    varargout{6} = zs;
    if ~strcmp(mode,'inactivate')
        varargout{7} = R2data;
        varargout{8} = R1data;
    end
end

end
