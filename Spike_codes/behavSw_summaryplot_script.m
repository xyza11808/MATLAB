% batched through all used sessions
cclr

% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
sortingcode_string = 'ks2_5';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',3);
% SessionFolders = SessionFoldersC(2:end);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);


SessIndexCell = readcell(AllSessFolderPathfile,'Range','D:D',...
        'Sheet',3);
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
    ksfolder = fullfile(strrep(UniqeBehavPath{cfff},'F:','E:\NPCCGs'),sortingcode_string);
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
UsedAfterTrNum = 40;
AllSessBehavFill = cellfun(@(x) [x;nan(UsedAfterTrNum-numel(x),1)],AllSessBehav,'un',0);
AllSessBehavC = cellfun(@(x) (x(1:UsedAfterTrNum))',AllSessBehavFill,'un',0);
% for cSw = 1 : NumofTotalSwitches
%     if length(AllSessBehav{cSw}) < 40
%         IsSwUsed(cSw) = 0;
%     end
%     AllSessBehav{cSw}(1) = 1;
% end
% 
% UsedSwBehav = AllSessBehav(IsSwUsed > 0);
% 
% AllSessBehavC = cellfun(@(x) (smooth(x(1:40),5))',UsedSwBehav,'un',0);
AllSessBehavMtx = cell2mat(AllSessBehavC);
AllSessBehavMtx(:,1) = 1;
% AllSessBehavMtx= AllSessBehavMtxAll(:,2:end);
%%
nanInds = ~isnan(AllSessBehavMtx);
TrialIndex = repmat(1:size(AllSessBehavMtx,2),size(AllSessBehavMtx,1),1);

ft = fittype('a*(1-exp(-x/tau))');
startPoints = [1,1];
md = fit(TrialIndex(nanInds),1-AllSessBehavMtx(nanInds),ft,'StartPoint',startPoints);

syms x
s = solve(md.a*(1-exp(-x/md.tau)) == 0.5);
HalfPeakTrial = double(s);


%%
nTrs = 1:40;
MeanSemPlot(1-AllSessBehavMtx,nTrs-1,[],[],[],'Color','k','linewidth',1.6);
% line([HalfPeakTrial,HalfPeakTrial],[0 1.05],'Color','r','linewidth',1.4,'linestyle','--');
% text(HalfPeakTrial+1,0.7,sprintf('HalfTrialNum = %.2f',HalfPeakTrial));
fircurve = md.a*(1-exp(-nTrs/md.tau));
plot(nTrs-1,fircurve,'--','Color','m','linewidth',1.4);
title(sprintf('N = %d sessions, %d switches',length(AllbehavSessDatas),length(AllSessBehavC)));
line([HalfPeakTrial HalfPeakTrial],[0 1],'Color','k','linestyle','--','linewidth',1.2);
line([.5 .5],[0 1],'Color','b','linestyle','--','linewidth',1.2);
text(HalfPeakTrial,0.8,num2str(HalfPeakTrial,'%.2f'));
set(gca,'ylim',[0 1],'ytick',[0 0.5 1]);

xlabel('Trials');
ylabel({'Reverse trial'; 'performance'});

%%

% saveFolder = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas';
saveFolder = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas';
saveName = fullfile(saveFolder,'Behav switch summary plot');
saveas(gcf,saveName);
print(gcf,saveName,'-dpdf','-bestfit');
print(gcf,saveName,'-dpng','-r350');


