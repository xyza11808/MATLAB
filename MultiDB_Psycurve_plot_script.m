% codes for multi DB curve plot
StimDBAll = double(behavResults.Stim_toneIntensity);
StimFreqAll = double(behavResults.Stim_toneFreq);
StimChoiceAll = double(behavResults.Action_choice);
%% using only non-miss trial
NMChoiceInds = StimChoiceAll ~= 2;
NMChoice = StimChoiceAll(NMChoiceInds);
NMDBAll = StimDBAll(NMChoiceInds);
NMFreqAll = StimFreqAll(NMChoiceInds);
NMFreqOctAll = log2(NMFreqAll/min(NMFreqAll)) - 1; % aligned to boundary
%%

FreqTypes = unique(NMFreqAll);
FreqStrs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
OctTypes = unique(NMFreqOctAll);

DBTypes = unique(NMDBAll);
DBStrs = cellstr(num2str(DBTypes(:),'%d db'));
DBTypesNum = length(DBTypes);
DBFitSave = cell(DBTypesNum,1);
DBFreqChoiceAvg = cell(DBTypesNum,2);
LineColor = cool(DBTypesNum);
hl = [];
hf = figure('position',[100 100 380 340]);
hold on
for cDB = 1 : DBTypesNum
    cDBValue = DBTypes(cDB);
    cDBInds = NMDBAll == cDBValue;
    
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
    chl = plot(cTrFitAll.curve(:,1),cTrFitAll.curve(:,2),'Color',LineColor(cDB,:),'linewidth',2);
    plot(cFreqTypes,FreqRChoiceFrac,'o','Color',LineColor(cDB,:),'linewidth',1.4);
    hl = [hl,chl];
end
legend(hl,DBStrs,'Box','off','location','Northwest');
set(gca,'xtick',OctTypes,'xticklabel',FreqStrs,'ylim',[-0.1 1.1],'ytick',0:0.2:1);
set(gca,'FontSize',12);
xlabel('Freq (kHz)');
ylabel('Right choice')
