Stims = linspace(-0.5,0.5,6);
StimCorr = [0.9,0.85,0.7,0.75,0.85,0.95];
TotalTrNum = 240;
TypeTrNum = [40,40,40,40,40,40];
TrType_ChoiceAll = cell(numel(Stims),3);
for cStim = 1 : numel(Stims)
    cTrType = double(Stims(cStim) > 0);
    cAllTypes = zeros(TypeTrNum(cStim),1);
    nCorrTypeNum = round(StimCorr(cStim) * TypeTrNum(cStim));
    if cTrType
        SampleIndex = randsample(TypeTrNum(cStim),nCorrTypeNum);
        cAllTypes(SampleIndex) = 1;
    else
        SampleIndex = randsample(TypeTrNum(cStim), TypeTrNum(cStim) - nCorrTypeNum);
        cAllTypes(SampleIndex) = 1;
    end
    
    TrType_ChoiceAll{cStim,1} = cTrType + zeros(TypeTrNum(cStim),1);
    TrType_ChoiceAll{cStim,2} = cAllTypes;
    TrType_ChoiceAll{cStim,3} = repmat(Stims(cStim),TypeTrNum(cStim),1);
end

Simulate_trTypes = cell2mat(TrType_ChoiceAll(:,1));
Simulate_ActChoice = cell2mat(TrType_ChoiceAll(:,2));
Simulate_TrCoheren = cell2mat(TrType_ChoiceAll(:,3));

[ShufStimCohn,shufIndex] = Vshuffle(Simulate_TrCoheren);
ShufSimulate_trTypes = Simulate_trTypes(shufIndex);
ShufSimulate_ActChoice = Simulate_ActChoice(shufIndex);
%%
DDMFitFun = @(ddm) ddm_call_fun(Simulate_TrCoheren,Simulate_ActChoice,ddm);
dd_x0 = [0,0.1,5,0.5,0.5];
options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-8,'MaxIter',1e6,'TolX',1e-6);
[x,fval,exitflag,output] = fminsearch(DDMFitFun,dd_x0,options);


