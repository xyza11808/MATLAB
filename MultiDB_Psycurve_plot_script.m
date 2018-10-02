
clear
clc
%% codes for multi DB curve plot
StimDBAll = double(behavResults.Stim_toneIntensity); 
StimFreqAll = double(behavResults.Stim_toneFreq);
StimChoiceAll = double(behavResults.Action_choice);
% using only non-miss trial
NMChoiceInds = StimChoiceAll ~= 2;
NMChoice = StimChoiceAll(NMChoiceInds);
NMDBAll = StimDBAll(NMChoiceInds);
NMFreqAll = StimFreqAll(NMChoiceInds);
NMFreqOctAll = log2(NMFreqAll/min(NMFreqAll)) - 1; % aligned to boundary
%

FreqTypes = unique(NMFreqAll);
FreqStrs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
OctTypes = unique(NMFreqOctAll);

DBTypes = unique(NMDBAll);
DBStrs = cellstr(num2str(DBTypes(:),'%d db'));
DBTypesNum = length(DBTypes);
DBTypeTrNum = zeros(DBTypesNum,1);
DBTypeMissRate = zeros(DBTypesNum,1);
DBFitSave = cell(DBTypesNum,1);
DBFreqChoiceAvg = cell(DBTypesNum,2);
LineColor = cool(DBTypesNum);
linehandleStrs = cell(DBTypesNum,1);
hl = [];
hf = figure('position',[100 100 380 340]);
hold on
for cDB = 1 : DBTypesNum
    cDBValue = DBTypes(cDB);
    cDBInds = NMDBAll == cDBValue;
    DBTypeTrNum(cDB) = sum(cDBInds);
    
    % calculate the miss rate
    DBTypeMissRate(cDB) = mean(StimChoiceAll(StimDBAll == cDBValue) == 2);
    
    % calculate the psychometric curve
    cDBFreqOcts = NMFreqOctAll(cDBInds);
    cDBChoice = NMChoice(cDBInds);
    
    cTrFitAll = FitPsycheCurveWH_nx(cDBFreqOcts,cDBChoice);
    DBFitSave{cDB} = cTrFitAll;
    
    cFreqTypes = unique(cDBFreqOcts);
    cFreqTypeNum = numel(cFreqTypes);
    FreqRChoiceFrac = zeros(cFreqTypeNum,1);
    for cf = 1 : cFreqTypeNum
        FreqRChoiceFrac(cf) = mean(cDBChoice(cDBFreqOcts == cFreqTypes(cf)));
    end
    chl = plot(cTrFitAll.curve(:,1),cTrFitAll.curve(:,2),'Color',LineColor(cDB,:),'linewidth',3);
    plot(cFreqTypes,FreqRChoiceFrac,'o','Color',LineColor(cDB,:),'linewidth',2.4);
    hl = [hl,chl];
    linehandleStrs{cDB} = sprintf('%s,%d Trs, %.2fMR',DBStrs{cDB},DBTypeTrNum(cDB),...
        DBTypeMissRate(cDB)*100);
end
legend(hl,linehandleStrs,'Box','off','location','Northwest');
set(gca,'xtick',OctTypes,'xticklabel',FreqStrs,'ylim',[-0.1 1.1],'ytick',0:0.2:1);
set(gca,'FontSize',12);
xlabel('Freq (kHz)');
ylabel('Right choice')

%% add sopports for type miss rate plot and frequency type plot
TrChoiceAll = double(behavResults.Action_choice(:));
TrTypeAll = double(behavResults.Trial_Type(:));
TrFreqAll = double(behavResults.Stim_toneFreq(:));
MissInds = double(TrChoiceAll == 2);
TrNums = length(MissInds);
% plot the trial type miss rate data
LeftMissRate = double(TrTypeAll == 0 & logical(MissInds));
RightMissRate = double(TrTypeAll == 1 & logical(MissInds));
hf = figure('position',[100 100 380 300]);
hold on
plot(1:TrNums,smooth(LeftMissRate,15),'b','linewidth',3);
plot(1:TrNums,smooth(RightMissRate,15),'r','linewidth',3);
xlabel('# Trials');
ylabel('Miss rate');
set(gca,'FontSize',14);
title('trial type miss rate plot');

% plot miss rate according to frequency type
FreqTypes = unique(TrFreqAll);
NumFreqs = numel(FreqTypes);
ColorTypes = jet(NumFreqs);
Headers = [];
HeaderStr = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));

hFreqf = figure('position',[500 100 380 300]);
hold on
for cf = 1 : NumFreqs
    cfInds = TrFreqAll == FreqTypes(cf);
    cFreqMissRate = double(cfInds & logical(MissInds));
    hl = plot(1:TrNums,smooth(cFreqMissRate,15),'Color',ColorTypes(cf,:),...
        'Linewidth',2.6);
    Headers = [Headers,hl];
end
legend(Headers,HeaderStr,'location','Northwest','Boxoff');

xlabel('# Trials');
ylabel('Miss rate');
set(gca,'FontSize',14);
title('Frequency type miss rate plot');


