% batched through all used sessions
cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
sortingcode_string = 'ks2_5';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);


SessIndexCell = readcell(AllSessFolderPathfile,'Range','D:D',...
        'Sheet',1);
MissInds = cellfun(@(x) any(ismissing(x)),SessIndexCell);
SessIndexC = SessIndexCell(~MissInds);
SessIndexAll = cell2mat(SessIndexC(2:end));
[~, Inds, ~] = unique(SessIndexAll); % unique behavior session path index

SessionFolders = SessionFoldersAll(UsedFolderInds);
UniqeBehavPath = SessionFolders(Inds);
NumprocessedNPSess = length(UniqeBehavPath);
%%
ErrosSess = zeros(NumprocessedNPSess,1);
AllbehavSessDatas = cell(NumprocessedNPSess,2);
% ProcessSess = [36,37,38,56,57];
for cfff = 1 : NumprocessedNPSess
% for cff = 1 : length(ProcessSess)
    
%     cfff = ProcessSess(cff);
    
%     ksfolder = fullfile(SessionFolders{cfff},sortingcode_string);
    
%     ksfolder = fullfile(strrep(SessionFolders{cfff},'F:','I:\ksOutput_backup'),sortingcode_string);
    ksfolder = fullfile(strrep(UniqeBehavPath{cfff},'F:','P:'),sortingcode_string);
    cSessFolder = ksfolder;
    fprintf('Processing session %d...\n', cfff);
    try
        cBehavDataFile = fullfile(ksfolder,'BehavSwitchData.mat');
        cBehavDataStrc = load(cBehavDataFile,'SwitchBlockChoices_rightward','H2L_choiceprob_diff');

        AllbehavSessDatas(cfff,:) = {cBehavDataStrc.SwitchBlockChoices_rightward,cBehavDataStrc.H2L_choiceprob_diff};
    end
    
end

%%
AllSessBehav = cat(1,AllbehavSessDatas{:,1});
NumofTotalSwitches = length(AllSessBehav);
IsSwUsed = ones(NumofTotalSwitches,1);
for cSw = 1 : NumofTotalSwitches
    if length(AllSessBehav{cSw}) < 40
        IsSwUsed(cSw) = 0;
    end
    AllSessBehav{cSw}(1) = 1;
end

UsedSwBehav = AllSessBehav(IsSwUsed > 0);

AllSessBehavC = cellfun(@(x) (smooth(x(1:40),5))',UsedSwBehav,'un',0);
AllSessBehavMtx = cell2mat(AllSessBehavC);

%%

TrialIndex = repmat(1:size(AllSessBehavMtx,2),size(AllSessBehavMtx,1),1);

ft = fittype('a*exp(-x/tau)');
startPoints = [1,1];
md = fit(TrialIndex(:),AllSessBehavMtx(:),ft,'StartPoint',startPoints);

syms x
s = solve(md.a*exp(-x/md.tau) == 0.5);
HalfPeakTrial = double(s);


%%
MeanSemPlot(AllSessBehavMtx,[],[],[],[],'Color','k','linewidth',2);
% line([HalfPeakTrial,HalfPeakTrial],[0 1.05],'Color','r','linewidth',1.4,'linestyle','--');
% text(HalfPeakTrial+1,0.7,sprintf('HalfTrialNum = %.2f',HalfPeakTrial));
set(gca,'ylim',[0.2 1.02]);

title(sprintf('N = %d sessions, %d switches',length(AllbehavSessDatas),length(AllSessBehavC)));
xlabel('Trials');
ylabel('Switched Choices');

%%

saveFolder = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas';
saveName = fullfile(saveFolder,'Behav switch summary plot');
saveas(gcf,saveName);
saveas(gcf,saveName,'pdf');
saveas(gcf,saveName,'png');


