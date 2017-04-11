function reward_train_model()
    numTrial = 100;
    para = struct; % store all parameters which once set won't change
    netStr = struct; % store network structure info, 

    preStimTime = 200; % ms % phase1 pre-stimulus time 200 ms
    stimTime = 1000; %ms % stimulus lasts for 1000 ms
    ITI = 500;%ms % inter trial intervel 500 ms
    trialTime = preStimTime + stimTime + ITI; % total time for one trial
    tStep = 1; %ms/step %time step
    numStep = round(trialTime/tStep);
    t = (1:numStep) * tStep; % for plotting the figure
    IdTime = 300; %ms % reset current to decision layer in the first 300 ms in the inter trial interval 
    resWin = 25;%ms % response time window, last 25 ms during stimulus presentation
    
    tIdxPreStim = 1:round(preStimTime/tStep);
    tIdxStim = round(preStimTime/tStep)+1:round((preStimTime+stimTime)/tStep);
    tIdxITI = round((preStimTime+stimTime)/tStep)+1:numStep;
    tIdxId = round((preStimTime+stimTime)/tStep)+1:round((preStimTime+stimTime+IdTime)/tStep);
    tIdxResWin = round((trialTime-resWin)/tStep):numStep;
    
    numStim = 6;% 6 types of octave for stimuli
    idxBound = round(numStim/2); % the bound to decide low/high
    facStim = log2(32/8)/(numStim-1); % a factor to convert idxStim to stimOct
    
    numNodeS = 64; % number of units in sensory layer
    numNodeA = numNodeS; % number of units in sensory layer
    numNodeD = 2; % 2 competing neurons in decision layer
    numNode = numNodeS + numNodeA + numNodeD;
    idxS = 1:numNodeS; % index for sensory nodes
    idxA = numNodeS+1:numNodeS+numNodeA; % index for association nodes
    idxD = numNodeS+numNodeA+1:numNode; % index for decision nodes
    
    nodeSta = zeros(numNode,numStep); % nodes' state the opening faction of NMDA receptor
    gMat = zeros(numNode,numNode); % g(conductance) matrix for all units in the network
    cMat = zeros(numNode,numNode); % synapse strength between all nodes in the network
    In = zeros(numNode,numStep); % noise current for each node, notice there's extra 0 for 3rd row
    Ir = zeros(numNode,numStep); % recurrent input for each node, notice there's extra 0 for 3rd row
    %TODO: initialize currents for different nodes and time
    I = zeros(numNode,numStep); % total input current for each node, notice there's extra 0 for 3rd row
    Id = zeros(numNode,numStep); %nA % corollary discharge current
    Id(idxD,tIdxId) = -0.08; % presented during first 300 ms in the inter trial interval
    Is = zeros(numNode,numStep); %nA % stimuli induced current
    Insg = zeros(numNode,numStep); %nA, non-selective gating current to decision layer during stimulus
    Insg(idxD,tIdxStim) = 0.01; %nA, non-selective gating current  
    
    frHist = zeros(numNode,numStep); % firing rate history of all nodes
    resHist = zeros(2,numTrial); % 1st row: stimuli type; 2nd row: responses    
    
    facNode = log2(32/8)/(numNodeS-1); % a factor to convert idxUnit to stimulus octave
    sigma = 2.5*log(32/8)*46/360*128/numNode; % octave, s.d. for stimulus induced response
    
    %% Initialize all variables
    [gMat,cMat] = var_initialize(numNodeS,numNodeA,numNodeD,facNode,sigma);% g(conductance) matrix for all units in the network; % c: synapse strength between all nodes in the network
    
    for idxTr = 1:numTrial
        idxStim = randi(numStim,1); % stimulus to show for this trial
        fprintf('Trial %d\n',idxTr);% show the progress 
        conMat = gMat .* cMat; % the sythenized connected strength between synapses
        Is = intilize_Is(Is,idxS,idxStim,sigma,facNode,facStim,tIdxStim); % stimulus induced current input to sensory nodes
        for idxStep = 2:numStep
            Ir(:,idxStep) = transpose(nodeSta(:,idxStep-1)'*conMat);
            In(:,idxStep) = update_network_In(In(:,idxStep-1),idxS,idxA,idxD,tStep);
            I(:,idxStep) = Ir(:,idxStep) + In(:,idxStep) + Id(:,idxStep) + Is(:,idxStep) + Insg(:,idxStep); % last three terms not added to all nodes in each step.
            frHist(:,idxStep) = r_I_curve(I(:,idxStep));
            nodeSta(:,idxStep) = update_network_s(nodeSta(:,idxStep-1),tStep,frHist(:,idxStep-1));
        end    
        % Respond or not
        resHist(1,idxTr) = idxStim;
        [resHist(2,idxTr),testHist(1,idxTr),testHist(2,idxTr)] = decide_response(frHist,idxStim,idxBound,tIdxResWin,idxD);
        cMat = update_syn_plasticity(resHist,idxTr,idxStim,cMat,frHist,tIdxStim,idxS,idxA,idxD);
        
        % add the last state to the first step in the next trial
        nodeSta(:,1) = nodeSta(:,idxStep);
        In(:,1) = In(:,idxStep);
        Ir(:,1) = Ir(:,idxStep);
        frHist(:,1) = frHist(:,idxStep);
        
    end
        
    
    %% Plot results
    figure;
    % plot responses versus time
    subplot(4,2,1);
    scatter(1:length(resHist(2,:)),resHist(2,:),'.');
    xlabel('Trial Index');
    ylabel('Response');
    title('Responses across trials');
    
    subplot(4,2,2);
    scatter(1:length(resHist(1,:)),resHist(1,:),'.');
    xlabel('Trial Index');
    ylabel('stimuli typr');
    title('Responses across trials');
    % plot firing rate in the sensory layer
    subplot(4,2,[3,4]);
    plot(t,frHist(1,:));
    title('Firing rate of 1st unit in sensory population');
    ylabel('Firing Rate (Hz)');
    
    subplot(4,2,[5,6]);
    plot(t,frHist(idxA(1),:));
    title('Firing rate of 1st unit in association population');
    ylabel('Firing Rate (Hz)');
    
    subplot(4,2,7);
    plot(t,frHist(idxD(1),:));
    title('Firing rate of D1');
    ylabel('Firing Rate (Hz)');
    
    subplot(4,2,8);
    plot(t,frHist(idxD(2),:));
    title('Firing rate of D2');
    ylabel('Firing Rate (Hz)'); 

end

function [response,fr1,fr2] = decide_response(frHist,idxStim,idxBound,tIdxResWin,idxD)
    % the network use this function to decide what response to give
    resThre = 20; %Hz, response threshold
    if idxStim < idxBound
        isLow = 1; % the stimulus is closer to the low frequency
    elseif idxStim == idxBound
        isLow = 1;
    else
        isLow = 0;
    end
    fr1 = mean(frHist(idxD(1),tIdxResWin));
    fr2 = mean(frHist(idxD(2),tIdxResWin));
    %fprintf('fr1: %6.2f and fr2 is: %6.2f\n',fr1,fr2);
    %fprintf('Difference between fr1 and fr2 is: %6.2f\n',fr1-fr2);
    if fr1>resThre
        isD1on = 1;
    else
        isD1on = 0;
    end
    
    if fr2>resThre
        isD2on = 1;
    else
        isD2on = 0;
    end
    
    if (isD1on&&isD2on) || ((~isD1on)&&(~isD2on))
        response = nan; % invalid trial
    elseif (isD1on&&isLow) || (isD2on&&(~isLow))
        response = 1; % valid correct trial
    else
        response = 0; % valid incorrect trial
    end
    
end

function diffMat = calc_diffMat(numChan1,numChan2,facUnit,sigma)
    % calculate the difference between different channels
    diffMat = zeros(numChan1,numChan2);% measure the exponent between different channels
    for i=1:numChan1
        for j=1:numChan2
            diffMat(i,j) = -((i-j)*facUnit).^2./(2*sigma^2);
        end
    end
end

function [gMat,cMat] = var_initialize(numNodeS,numNodeA,numNodeD,facUnit,sigma)

% TODO: Devide it into 2 functions?
% initialize the coupling between all connected nodes
% row: index of pre nodes; 
% col: index of post nodes

numNode = numNodeS + numNodeA + numNodeD;
gMat = zeros(numNode,numNode); % g(conductance) matrix for all units in the network
cMat = zeros(numNode,numNode); % synapse strength between all nodes in the network

diffMat = calc_diffMat(numNodeS,numNodeS,facUnit,sigma);
Jmat = [1.43,-0.5,-10,-0.4,0.3725,4*-0.1137];% J_pos, J_neg for S; J_pos, J_neg for A; J_same, J_diff for D
% 4.5 is a good factor to time on the last J.
idxS = 1:numNodeS;
idxA = numNodeS+1:numNodeS+numNodeA;
idxD = numNodeS+numNodeA+1:numNodeS+numNodeA+numNodeD;
gMat(idxS,idxS) = Jmat(2) + Jmat(1)*exp(diffMat);
gMat(idxA,idxA) = Jmat(4) + Jmat(3)*exp(diffMat);
gMat(idxD,idxD) = [Jmat(5),Jmat(6);Jmat(6),Jmat(5)];

gMat(idxS,idxA) = 1; % nA
gMat(idxA,idxD) = 0.03;
gMat(idxD,idxA) = 0.01;

cMat(idxS,idxS) = 1;
cMat(idxA,idxA) = 1;
cMat(idxD,idxD) = 1;

cMat(idxS,idxA) = exp(diffMat);
cMat(idxD,idxA) = 0.25+0.5*rand(length(idxD),length(idxA));
cMat(idxA,idxD) = 0.25+0.5*rand(length(idxA),length(idxD));

end

function cMat = update_syn_plasticity(resHist,idxTr,idxStim,cMat,frHist,tIdxStim,idxS,idxA,idxD)
q = 0.00003;% learning rate
resLast = resHist(2,idxTr); % the last response

if ~isnan(resLast)
    idxNotNan = find(~isnan(resHist(2,1:idxTr)));
    idxGivenStim = idxNotNan(resHist(1,idxNotNan)==idxStim);
    if isempty(idxGivenStim)
        resMean = 0;
    else
        resMean = mean(resHist(2,idxGivenStim));
    end
    
    frMean = mean(frHist(:,tIdxStim),2);
    cMatTemp = cMat + q*(resLast-resMean)*(frMean*frMean');% learning vis plasticity
    % only below connections have plasticity
    
    
    cMat(idxS,idxA) = cMatTemp(idxS,idxA);
    cMat(idxA,idxD) = cMatTemp(idxA,idxD);
    cMat(idxD,idxA) = cMatTemp(idxD,idxA);
    idx = (cMat > 1); % c is bounded between 0 and 1
    cMat(idx) = 1;
    idx = (cMat < 0);
    cMat(idx) = 0;
end

end

function Is = intilize_Is(Is,idxS,idxStim,sigma,facNode,facStim,tIdxStim)
    g_s = 0.1; %nA 
    IsArr = g_s * exp(-1*((1:length(idxS))*facNode-idxStim*facStim).^2/(2*sigma^2));
    Is(idxS,tIdxStim) = repmat(IsArr',1,length(tIdxStim));
end

function updated_In = update_network_In(In_1step,idxS,idxA,idxD,tStep)
% TODO: remove tStep (change it to a global variable?)
% noise currrent update function
I0 = [0.3297,0.31,0.3297];%nA% each for S,A,D
I0Arr = [I0(1)*ones(length(idxS),1);I0(2)*ones(length(idxA),1);I0(3)*ones(length(idxD),1)];
tau_n = 2; % ms
sigma_n = 0.009; %nA
updated_In = In_1step + tStep/tau_n*(sqrt(tau_n)*sigma_n*randn(size(I0Arr))+I0Arr-In_1step);

end

function nodeSta_updated = update_network_s(nodeSta_1step,tStep,frHist_1step)
% update s(the fraction of opening NMDAR) for each time step
% TODO: use struct or what to use S, A, D only in the argument list
gama = 0.641; % the factor in s updating equation.
tau_s = 60; %ms
nodeSta_updated = nodeSta_1step + tStep*(-nodeSta_1step/tau_s + (1-nodeSta_1step).*gama.*frHist_1step);
idx = (nodeSta_updated > 1);
nodeSta_updated(idx) = 1;
idx = (nodeSta_updated < 0);
nodeSta_updated(idx) = 0;
end

function r = r_I_curve(I)
% the input output function of r-I curve
a = 270;%Hz/mA
b = 108;%Hz
d = 0.154;%second
r = (a*I-b)./(1-exp(-d*(a*I-b)));
idx = (r < 0);
r(idx) = 0;
idx = (isnan(r));% when I = 0.4, the limit of r-I curve is 1
r(idx) = 1;

end

