
CNOfilePath = 'R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\CNO matfile';
BehavConlPath = 'R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\control for CNO matfile';
salinePath = 'R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\saline control matfile';

%%
cd(CNOfilePath);
CNPmatfileAll = dir('*.mat');
CNODataStrc = struct('fname','','TrStimFreq',[],'TrType',[],'TrChoice',[],'TrIsProb',[]);
CNOCurveData = cell(length(CNPmatfileAll),2);
psyCurveFit = cell(length(CNPmatfileAll),1);
for cf = 1 : length(CNPmatfileAll)
    cfName = CNPmatfileAll(cf).name;
    cfData = load(cfName);
    [behavResults,behavSettings] = behav_cell2struct(cfData.SessionResults,cfData.SessionSettings);
    CNODataStrc(cf).fname = cfName(1:end-3);
    NMInds = behavResults.Action_choice ~= 2;
    
    
    NMChoice = double(behavResults.Action_choice(NMInds));
    NMfreqsAll = double(behavResults.Stim_toneFreq(NMInds));
    NMIsProb = double(behavResults.Trial_isProbeTrial(NMInds));
    NMTrTypes = double(behavResults.Trial_Type(NMInds));
    
    CNODataStrc(cf).TrStimFreq = NMfreqsAll;
    CNODataStrc(cf).TrType = NMTrTypes;
    CNODataStrc(cf).TrChoice = NMChoice;
    CNODataStrc(cf).TrIsProb = NMIsProb;
    
    NMOctAlls = log2(NMfreqsAll/14000);
    ffitData = FitPsycheCurveWH_nx(NMOctAlls(:),NMChoice(:));
    psyCurveFit{cf} = ffitData;
    
    FreqTypes = unique(NMfreqsAll);
    CNOCurveData{cf,1} = FreqTypes;
    nFreqs = length(FreqTypes);
    FreqChoiceFrac = zeros(nFreqs,1);
    for ccc = 1 : nFreqs
        cffreq = FreqTypes(ccc);
        cfreqInds = NMfreqsAll == cffreq;
        FreqChoiceFrac(ccc) = mean(NMChoice(cfreqInds));
    end
    CNOCurveData{cf,2} = FreqChoiceFrac;
end
%%
CNODataFreqMtx = cell2mat(CNOCurveData(:,1));
CNODataOctaveMtx = log2(CNODataFreqMtx/14000);
CNODataChoiceMtx = cell2mat(CNOCurveData(:,2)');
hf = figure;
plot(CNODataOctaveMtx',CNODataChoiceMtx,'k-o')
