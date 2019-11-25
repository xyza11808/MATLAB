
cclr
InputStep = 1;
InputLength = 3500/InputStep;
Tau = 10/InputStep;
RNN_Unit_Num = 200;
ReadyPulse = 20/InputStep;
SetPulse = 20/InputStep;
PulseAmp = 0.4;
BaseTime = 100/InputStep;
PriorValue = [0.3,0.4];

A = 3;
Alpha = 2.8;
ProductFun = @(A,alpha,t,ts) A*(exp(t/(ts*alpha)) - 1);
tsTypeNum = 5;
ts_high = linspace(800,1200,tsTypeNum);
ts_low = linspace(400,800,tsTypeNum);
wm = 0.05;

nRepeats = 50;

TrParas = cell(tsTypeNum,2);
for cTs = 1 : tsTypeNum
    LowTs = ts_low(cTs);
    TargetTp = ones(nRepeats,1)*LowTs;
    InputTs_tm = round(LowTs+randn(nRepeats,1)*LowTs*wm);
    TrParas{cTs,1} = [TargetTp,InputTs_tm,ones(nRepeats,1)*PriorValue(1)];
    
    HighTs = ts_high(cTs);
    TargetHighTp = ones(nRepeats,1)*HighTs;
    InputHighTs_tm = round(HighTs+randn(nRepeats,1)*HighTs*wm);
    TrParas{cTs,2} = [TargetHighTp,InputHighTs_tm,ones(nRepeats,1)*PriorValue(2)];
end

AllTrParas = [cell2mat(TrParas(:,1));cell2mat(TrParas(:,2))];
TotalTrNum = size(AllTrParas,1);
ShufInds = Vshuffle(1:TotalTrNum);
PesudoAllTrParas = AllTrParas(ShufInds,:);

AllTrTimeSeqs = cell(TotalTrNum,1);
TargetStartEnd  = zeros(TotalTrNum,2);
for cTr = 1 : TotalTrNum
    cTrParas = PesudoAllTrParas(cTr,:);
    StartInds = BaseTime+ReadyPulse+cTrParas(2)+SetPulse;
    
    cInputs = [zeros(BaseTime,1);PulseAmp*ones(ReadyPulse,1);zeros(cTrParas(2),1);PulseAmp*ones(SetPulse,1);...
        zeros(InputLength-StartInds,1)];
    InputPriors = [zeros(BaseTime,1);cTrParas(3)*ones(InputLength-BaseTime,1)];
    
    
    OutPutTarget = [zeros(StartInds,1);ProductFun(A,Alpha,(1:cTrParas(1))',cTrParas(1));...
        zeros(InputLength-StartInds-cTrParas(1),1)];
    
    AllTrTimeSeqs{cTr} = ([cInputs,InputPriors,OutPutTarget])';
    TargetStartEnd(cTr,:) = [StartInds,cTrParas(1)];
end

%%
InputSize = 2;
OutSize = 1;
InOutSize = [InputSize,OutSize];
NetParas = {[],[],[],[],[]};
[NetParas,xInit,~] = sohnRNNFun(RNN_Unit_Num,'init',[],NetParas,Tau,InOutSize,...
    [],[],[],[],[],[]);

%%
BatchTrSize = 30;
BatchStartInds = 1;
ShufBatchIndex = 1 : TotalTrNum;
LearnRate = 0.4;
TBPTT_k = [50,20];
MaxIter = 1000;
cIter = 1;
Errors = 1;
k = 1;
ErrorAll = [];
while cIter < MaxIter && Errors > 1e-5  
    if (BatchStartInds + BatchTrSize) > TotalTrNum
        BatchInds = ShufBatchIndex(BatchStartInds : TotalTrNum);
        ShufBatchIndex = Vshuffle(ShufBatchIndex);
    else
        BatchInds = ShufBatchIndex(BatchStartInds : (BatchStartInds+BatchTrSize));
    end
    
    BatchInDataCell = cellfun(@(x) x(1:2,:),AllTrTimeSeqs(BatchInds),'UniformOutput',false);
    BatchOutDataCell = cellfun(@(x) x(3,:),AllTrTimeSeqs(BatchInds),'UniformOutput',false);
    
    BatchInData = cat(3,BatchInDataCell{:});
    BatchOutData = cat(3,BatchOutDataCell{:});
    BatchStartEndTime = TargetStartEnd(BatchInds,:);
    
    [NetParas,cError,LearnRate] = sohnRNNFun(RNN_Unit_Num,'TBPTT',xInit,NetParas,Tau,[],...
        BatchInData,BatchOutData,TBPTT_k,BatchStartEndTime(:,1),BatchStartEndTime(:,2),LearnRate);
    ErrorAll(k) = cError;
    k = k + 1;
end

