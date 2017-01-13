function SessionModuOptionErrorCal(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,Trialmodulation,varargin)
% this function is specifically used for analysis sessions with interleved
% modulation trials(e.g. opto trials)

if isempty(Trialmodulation)
    fprintf('No modulation index being input, considering as a pure control session.\n');
    TbyTAllROIclassInputParse(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,varargin{:},'isErCal',1,'TrOutcomeOp',0);
else
    if ~islogical(Trialmodulation)
        Trialmodulation = logical(Trialmodulation); % modulation trials if logical true
    end
    
    % opto trials result
    if ~isdir('./Opto_trials/')
        mkdir('./Opto_trials/');
    end
    cd('./Opto_trials/');
    TbyTAllROIclassInputParse(RawDataAll(Trialmodulation,:,:),StimAll(Trialmodulation),TrialResult(Trialmodulation),AlignFrame,...
        FrameRate,varargin{:},'isErCal',1,'TrOutcomeOp',0);
    cd ..;
    
    % control Trials result
    if ~isdir('./Control_trials/')
        mkdir('./Control_trials/');
    end
    cd('./Control_trials/');
    TbyTAllROIclassInputParse(RawDataAll(~Trialmodulation,:,:),StimAll(~Trialmodulation),TrialResult(~Trialmodulation),AlignFrame,...
        FrameRate,varargin{:},'isErCal',1,'TrOutcomeOp',0);
    cd ..;
    
end