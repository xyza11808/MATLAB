% new scripts for comparison plot of 2afc and RF auc values, both plot the
% significant values and non-significant values
clear
clc

m = 0;
AfcAUCPath = {};
AFCdataAll = {};
AFCaucRealValue = [];
AFCaucIsrevert = [];
AFCaucShufThres = [];
RFAUCPath = {};
RFdataAll = {};
RFaucRealValue = [];
% RFaucIsrevert = [];
% RFaucShufThres = [];
addChar = 'y';

while ~strcmpi(addChar,'n')
    m = m + 1;
    % load 2afc task auc value data file
    [afcfn,afcfp,afcfi] = uigetfile('ROC_score.mat','Please select your 2afc AUC analysis data');
    if ~afcfi
        return;
    end
    c2afcPath = fullfile(afcfp,afcfn);
    AfcAUCPath{m} = c2afcPath;
    AfcAUCdataStrc = load(c2afcPath);
    AFCdataAll{m} = AfcAUCdataStrc;
    cAFCauc = AfcAUCdataStrc.ROCarea;
    ROInum = length(cAFCauc);
    cAFCaucABS = cAFCauc;
    cAFCaucABS(AfcAUCdataStrc.ROCRevert == 1) = 1 - cAFCaucABS(AfcAUCdataStrc.ROCRevert == 1);
    AFCaucRealValue = [AFCaucRealValue;cAFCaucABS(:)];
    AFCaucIsrevert = [AFCaucIsrevert;AfcAUCdataStrc.ROCRevert(:)];
    AFCaucShufThres = [AFCaucShufThres;AfcAUCdataStrc.ROCShufflearea(:)];
    
    [RFfn,RFfp,RFfi] = uigetfile('ROIrocsave.mat','Please select your RF AUC analysis data');
    if ~RFfi
        return;
    end
    cRFpath = fullfile(RFfp,RFfn);
    RFAUCPath{m} = cRFpath;
    RFaucDataStrc = load(cRFpath);
    RFdataAll{m} = RFaucDataStrc;
    cRFAUCdata = RFaucDataStrc.ROCdataRF(:);
    if length(cRFAUCdata) > ROInum
        cRFAUCdata = cRFAUCdata(1:ROInum);
    end
    RFaucRealValue = [RFaucRealValue;cRFAUCdata];
    
    addChar = input('Would you like to add another session data?\n','s');
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
