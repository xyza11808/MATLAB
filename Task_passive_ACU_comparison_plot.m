% new scripts for comparison plot of 2afc and RF auc values, both plot the
% significant values and non-significant values
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select data path saved file');
if ~fi
    return;
end
[Passfn,Passfp,~] = uigetfile('*.txt','Please select Passive session AUC data');

%%
fPath = fullfile(fp,fn);
fids = fopen(fPath);
tline = fgetl(fids);
Passfid = fopen(fullfile(Passfp,Passfn));
Passline = fgetl(Passfid);

m = 1;
% AfcAUCPath = {};
% AFCdataAll = {};
% AFCaucRealValue = [];
% AFCaucIsrevert = [];
% AFCaucShufThres = [];
% RFAUCPath = {};
% RFdataAll = {};
% RFaucRealValue = [];

SessDataExist = [];

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fids);
        Passline = fgetl(Passfid);
        continue;
    end
    TaskDataPath = fullfile(tline,'Stim_time_Align','ROC_Left2Right_result','ROC_score.mat');
    PassDataPath = fullfile(Passline,'Stim_time_Align','ROC_Left2Right_result','ROC_score.mat');
    if ~exist(TaskDataPath,'file') || ~exist(PassDataPath,'file')
        IsSessDataExist = 0;
    else
        IsSessDataExist = 1;
    end
    SessDataExist(m) = IsSessDataExist;
%     c2afcPath = fullfile(afcfp,afcfn);
%     AfcAUCPath{m} = c2afcPath;
%     AfcAUCdataStrc = load(c2afcPath);
%     AFCdataAll{m} = AfcAUCdataStrc;
%     cAFCauc = AfcAUCdataStrc.ROCarea;
%     ROInum = length(cAFCauc);
%     cAFCaucABS = cAFCauc;
%     cAFCaucABS(AfcAUCdataStrc.ROCRevert == 1) = 1 - cAFCaucABS(AfcAUCdataStrc.ROCRevert == 1);
%     AFCaucRealValue = [AFCaucRealValue;cAFCaucABS(:)];
%     AFCaucIsrevert = [AFCaucIsrevert;AfcAUCdataStrc.ROCRevert(:)];
%     AFCaucShufThres = [AFCaucShufThres;AfcAUCdataStrc.ROCShufflearea(:)];
%     
%     
%     cRFpath = fullfile(RFfp,RFfn);
%     RFAUCPath{m} = cRFpath;
%     RFaucDataStrc = load(cRFpath);
%     RFdataAll{m} = RFaucDataStrc;
%     cRFAUCdata = RFaucDataStrc.ROCdataRF(:);
%     if length(cRFAUCdata) > ROInum
%         cRFAUCdata = cRFAUCdata(1:ROInum);
%     end
%     RFaucRealValue = [RFaucRealValue;cRFAUCdata];
    
    m = m + 1;
    tline = fgetl(fids);
    Passline = fgetl(Passfid);
end

%% write the used data path

savePath = uigetdir(pwd,'Please select a path for current data saving');
cd(savePath);
fFormat = '%s;\r\n';
fid = fopen('Task_pass_AUCData_path.txt','w');
fprintf(fid,'Task data path used:\r\n');
for nnd = 1 : m
    fprintf(fid,fFormat,AfcAUCPath{nnd});
end
fprintf(fid,'\r\n  \r\n  \r\n');
for nnn = 1 : m
    fprintf(fid,fFormat,RFAUCPath{nnn});
end
fclose(fid);
save TaskPassSaveData.mat AfcAUCPath AFCdataAll AFCaucRealValue AFCaucIsrevert AFCaucShufThres RFAUCPath RFdataAll RFaucRealValue -v7.3

%%
TaskAUCSigInds = AFCaucRealValue > AFCaucShufThres;
[~,pSig] = ttest(AFCaucRealValue(TaskAUCSigInds),RFaucRealValue(TaskAUCSigInds));
[~,pAll] = ttest(AFCaucRealValue,RFaucRealValue);
hf = figure;
hold on

scatter(AFCaucRealValue(~TaskAUCSigInds),RFaucRealValue(~TaskAUCSigInds),50,'o','linewidth',1,...
    'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',[.7 .7 .7]);
scatter(AFCaucRealValue(TaskAUCSigInds),RFaucRealValue(TaskAUCSigInds),50,'ko','linewidth',1.5,'MarkerEdgeColor','k');
set(gca,'xlim',[0 1],'ylim',[0 1],'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
line([0.5,0.5],[0 1],'color',[.6 .6 .6],'LineWidth',1.6,'lineStyle','--');
line([0 1],[0.5,0.5],'color',[.6 .6 .6],'LineWidth',1.6,'lineStyle','--');
line([0 1],[0 1],'color',[.6 .6 .6],'LineWidth',1.6,'lineStyle','--');
xlabel('Task AUC');
ylabel('Passive AUC');
title({sprintf('pSig = %.3e',pSig),sprintf('pAll = %.3e',pAll)});
set(gca,'FontSize',20);
text(0.7,0.2,sprintf('n = %d,%d',sum(TaskAUCSigInds),numel(AFCaucRealValue)));
saveas(hf,'TaskPassive_AUC_compPlot');
saveas(hf,'TaskPassive_AUC_compPlot','png');
saveas(hf,'TaskPassive_AUC_compPlot','pdf');
close(hf);
save CtestSave.mat pAll pSig -v7.3
