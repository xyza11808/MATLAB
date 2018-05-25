
cd('H:\data\behavior\2p_data\behaviro_data\batch52\Data\anm01\data');
files = dir('H:\data\behavior\2p_data\behaviro_data\batch52\Data\anm01\data\*.mat');
nfiles = length(files);
nfDatasAll = zeros(nfiles,4);
UsedFiles = ones(nfiles,1);
for cf = 1 : nfiles
    load(files(cf).name);
    TrChoiceAll = double(behavResults.Action_choice(:));
    if length(TrChoiceAll) < 120
        UsedFiles(cf) = 0;
        continue;
    end
    TrTypesAll = double(behavResults.Trial_Type(:));
    NMInds = TrChoiceAll ~= 2;
    NMChoice_All = TrChoiceAll(NMInds);
    NMTrTypes = TrTypesAll(NMInds);
    TrOutcomes = double(NMChoice_All == NMTrTypes);
    ErrorInds = TrOutcomes == 0;
    CorrInds = ~ErrorInds;
    NMNextChoiceAll = [NMChoice_All(2:end);nan];

    ErrorInds_Choice = NMChoice_All(ErrorInds);
    ErrorInds_NextChoice = NMNextChoiceAll(ErrorInds);

    CorrInds_Choice = NMChoice_All(CorrInds);
    CorrInds_NextChoice = NMNextChoiceAll(CorrInds);

    if isnan(ErrorInds_NextChoice(end))
        ErrorInds_NextChoice(end) = [];
        ErrorInds_Choice(end) = [];
    else
        CorrInds_Choice(end) = [];
        CorrInds_NextChoice(end) = [];
    end

    %
    L_Error_Next_RProb = mean(ErrorInds_NextChoice(ErrorInds_Choice == 0));
    R_Error_Next_RProb = mean(ErrorInds_NextChoice(ErrorInds_Choice == 1));

    L_Corr_Next_RProb = mean(CorrInds_NextChoice(CorrInds_Choice == 0));
    R_Corr_Next_RProb = mean(CorrInds_NextChoice(CorrInds_Choice == 1));
    
    nfDatasAll(cf,:) = [L_Error_Next_RProb,R_Error_Next_RProb,L_Corr_Next_RProb,R_Corr_Next_RProb];
end

%%
UsedDatasAll = nfDatasAll(logical(UsedFiles),:);
figure;
hold on
plot([1,2],(UsedDatasAll(:,1:2))','Color',[.7 .7 .7])
plot([3,4],(UsedDatasAll(:,3:4))','Color',[.7 .7 .7])
set(gca,'xlim',[0.5 4.5],'xtick',1:4,'xticklabel',{'LENR','RENR','LCNR','RCNR'})
ylabel('Right prob.')
