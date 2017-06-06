function SessionWithModulationNeuDecor(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,Trialmodulation,varargin)
% this function is specifically used for analysis sessions with interleved
% modulation trials(e.g. opto trials)
isSessionBstrap = 0;
if nargin > 6
    if ~isempty(varargin{1})
        isSessionBstrap = varargin{1};
    end
end
if ~isSessionBstrap
    BootStrapIter = 1;
    BootStrapRatio = 1;
else
    BootStrapIter = 10;
    BootStrapRatio = 0.9;
    if nargin > 7
        InputPara = varargin{2};
        BootStrapIter = InputPara(1);
        BootStrapRatio = InputPara(2);
    end
end
if nargin > 8
    paraInputs = varargin{3:end};
else
    paraInputs = {};
end
nTrs = length(StimAll);

for nboot = 1 : BootStrapIter
    if isempty(Trialmodulation)
        if nboot == 1
            BootResults = cell(BootStrapIter,1);
        end
        fprintf('No modulation index being input, considering as a pure control session.\n');
        RandInds = CusRandSample(nTrs,round(nTrs*BootStrapRatio));
        TestLoss = TbyTAllROIclassNeuDecor(RawDataAll(RandInds,:,:),StimAll(RandInds),TrialResult(RandInds),AlignFrame,FrameRate,varargin{:});
        BootResults{nboot} = TestLoss;
    else
        if nboot == 1
            optoBootResult = cell(BootStrapIter,1);
            ContBootResult = cell(BootStrapIter,1);
        end
        
        if ~islogical(Trialmodulation)
            Trialmodulation = logical(Trialmodulation); % modulation trials if logical true
        end
        RandInds = CusRandSample(double(Trialmodulation),round(nTrs*BootStrapRatio));
        
        BstrapInds = Trialmodulation(RandInds);
        optoRawData = RawDataAll(RandInds,:,:);
        optoStimAll = StimAll(RandInds);
        optoResult = TrialResult(RandInds);
        % opto trials result
%         if ~isdir('./Opto_trials/')
%             mkdir('./Opto_trials/');
%         end
%         cd('./Opto_trials/');
        OptoDataAll = optoRawData(BstrapInds,:,:);
        OptoFreqAll = optoStimAll(BstrapInds);
                
        optoLoss = TbyTAllROIclassNeuDecor(OptoDataAll,OptoFreqAll,optoResult(BstrapInds),AlignFrame,...
            FrameRate,paraInputs{:});
        optoBootResult{nboot} = optoLoss;
%         cd ..;

%         % control Trials result
%         if ~isdir('./Control_trials/')
%             mkdir('./Control_trials/');
%         end
%         cd('./Control_trials/');
        ContDataAll = optoRawData(~BstrapInds,:,:);
        ContFreqAll = optoStimAll(~BstrapInds);
        ContLoss = TbyTAllROIclassNeuDecor(ContDataAll,ContFreqAll,optoResult(~BstrapInds),AlignFrame,...
            FrameRate,paraInputs{:});
        ContBootResult{nboot} = ContLoss;
%         cd ..;
        save ContModuSessionSave.mat optoBootResult ContBootResult -v7.3
    end
end
if isempty(Trialmodulation)
    save SessionResultSave.mat BootResults BootStrapIter BootStrapRatio -v7.3
else
    save ContModuSessionSave.mat optoBootResult ContBootResult BootStrapIter BootStrapRatio -v7.3
end