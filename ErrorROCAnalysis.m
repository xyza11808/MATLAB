clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
% load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');

%%
fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
nSess = 1;
SessErrorNumSum = {};
CategROCAll = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ff);
        continue;
    end
    
    clearvars behavResults
    load(fullfile(tline,'CSessionData.mat'),'behavResults');
    cSessTrChoice = double(behavResults.Action_choice);
    NMChoiceInds = cSessTrChoice ~= 2;
    NMChoice = cSessTrChoice(NMChoiceInds);
    cSessTrTypes = double(behavResults.Trial_Type(NMChoiceInds));
    
    cSessOutcomes = double(cSessTrTypes(:) == NMChoice(:));
    
    TrpeErrorRate = 1 - [mean(cSessOutcomes(cSessTrTypes == 0)),mean(cSessOutcomes(cSessTrTypes == 1))];
    TypeErrorNum = TrpeErrorRate .* [sum(cSessTrTypes == 0),sum(cSessTrTypes == 1)];
    SessErrorNumSum{nSess,1} = TrpeErrorRate;
    SessErrorNumSum{nSess,2} = TypeErrorNum;
    
    %
    RespDataPath = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewLog_fit_test_new','NewCurveFitsave.mat');
    CategROIInds = load(RespDataPath,'IsCategROI');
    
    DataForCal = load(fullfile(tline,'CSessionData.mat'),'smooth_data','start_frame','frame_rate');
    ROIROC = TypeRespROC(DataForCal.smooth_data,behavResults,logical(CategROIInds.IsCategROI),[0,1],...
        DataForCal.start_frame,DataForCal.frame_rate);
    CategROCAll{nSess} = ROIROC;
    
    %
    tline = fgetl(ff);
    nSess = nSess + 1;
    
end
cd('E:\DataToGo\data_for_xu\CorrErroROC');
save CategROCSave.mat SessErrorNumSum CategROCAll -v7.3
%%
UsedSessInds = cellfun(@(x) ~isempty(x),CategROCAll);
UsedROCData = CategROCAll(UsedSessInds);
CorrROCAllCell = cellfun(@(x) x.CorrROCAll,UsedROCData,'UniformOutput',false);
ErroROCAllCell = cellfun(@(x) x.ErroROCAll,UsedROCData,'UniformOutput',false);
CorrROCAll = cell2mat(CorrROCAllCell');
ErroROCAll = cell2mat(ErroROCAllCell');
CorrROCSig = CorrROCAll(:,1);
CorrROCSig(CorrROCAll(:,2) == 1) = 1 - CorrROCSig(CorrROCAll(:,2) == 1);
ErroROCSig = ErroROCAll(:,1);
ErroROCSig(ErroROCAll(:,2) == 1) = 1 - ErroROCSig(ErroROCAll(:,2) == 1);
CorrSigInds = CorrROCSig >= CorrROCAll(:,3);
ErroSigInds = ErroROCSig >= ErroROCAll(:,3);

CorrPreferAll = (CorrROCAll(:,1) - 0.5) * 2;
ErroPreferAll = (ErroROCAll(:,1) - 0.5) * 2;

%%
hhf = figure('position',[100 100 450 360]);
hold on
hl1 = plot(CorrPreferAll(CorrSigInds & ErroSigInds),ErroPreferAll(CorrSigInds & ErroSigInds),'o','MarkerSize',6,...
    'MarkerFaceColor','r','MarkerEdgeColor','none');
hl2 = plot(CorrPreferAll(CorrSigInds & ~ErroSigInds),ErroPreferAll(CorrSigInds & ~ErroSigInds),'o','MarkerSize',6,...
    'MarkerFaceColor',[1 0.7 0.2],'MarkerEdgeColor','none');
hl3 = plot(CorrPreferAll(~CorrSigInds & ErroSigInds),ErroPreferAll(~CorrSigInds & ErroSigInds),'o','MarkerSize',6,...
    'MarkerFaceColor','c','MarkerEdgeColor','none');
hl4 = plot(CorrPreferAll(~CorrSigInds & ~ErroSigInds),ErroPreferAll(~CorrSigInds & ~ErroSigInds),'o','MarkerSize',6,...
    'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
set(gca,'xlim',[-1 1],'ylim',[-1 1]);
line([0 0],[-1 1],'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
line([-1 1],[0 0],'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('Correct Prefer.');
ylabel('Error Prefer.');
set(gca,'FontSize',14)

SignSame = sign(CorrPreferAll) == sign(ErroPreferAll);
title(sprintf('Same %.3f, Diff %.3f',mean(SignSame),1 - mean(SignSame)));
legend([hl1,hl2,hl4],{'Both','Corr','Neith'},'location','north','box','on');
saveas(hhf,'CategROI ROC CorrErro Calculation');
saveas(hhf,'CategROI ROC CorrErro Calculation','png');
