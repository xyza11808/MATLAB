% cell type part
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');

%%
[fn,fp,fi] = uigetfile('*.txt','Please select the session data path');
if ~fi
    return;
end

%%
fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
cSess = 1;
IndexDataAll = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
        continue;
    end
    SpikeDataPath = [tline,'\Tunning_fun_plot_New1s'];
    cd(SpikeDataPath);
    load('TunningDataSave.mat');
    
    nROIs = size(CorrTunningFun,2);
    cd('./Curve fitting plots/');
    CategFitMD = load('NewCurveFitsave.mat','LogCoefFit');
    
    CategInds = BoundTunROIindex{cSess,6};
%     TuningInds = BoundTunROIindex{cSess,7};
%     TuningIndex = find(TuningInds);
%     BoundTunROIIndex = BoundTunROIindex{cSess,1};
%     OtherTunROIIndex = TuningIndex(~(BoundTunROIindex{cSess,2}));
%     RestROIs = ~(CategInds | TuningInds);
    TaskIndexAll = zeros(nROIs,1);
    PassIndexAll = zeros(nROIs,1);
    for ROInum = 1 : nROIs
        
        if CategInds(ROInum)
            cSigFitMD = CategFitMD.LogCoefFit{ROInum};
            FitBoundary = cSigFitMD.b3;
            
            cROITunData = CorrTunningFun(:,ROInum);
            NorTundata = cROITunData(:);%/mean(cROITunData);
            OctaveData = TaskFreqOctave(:);
            LeftInds = OctaveData < FitBoundary;
            LeftMean = max(mean(NorTundata(LeftInds)),0.1);
            RightMean = max(mean(NorTundata(~LeftInds)),0.1);
            TaskIndex = abs(LeftMean - RightMean)/(LeftMean + RightMean);
            TaskIndexAll(ROInum) = TaskIndex;
            
            PassFreqConsidered = ~(abs(PassFreqOctave) > 1);
            PassTundata = PassTunningfun(PassFreqConsidered,ROInum);
            PassOctave = PassFreqOctave(PassFreqConsidered);
            PassLeftInds = PassOctave < FitBoundary;
            PassLMean = max(mean(PassTundata(PassLeftInds)),0.1);
            PassRMean = max(mean(PassTundata(~PassLeftInds)),0.1);
            PassIndexAll(ROInum) = abs(PassLMean - PassRMean)/(PassLMean + PassRMean);
        end
    end
    IndexDataAll{cSess,1} = TaskIndexAll;
    IndexDataAll{cSess,2} = PassIndexAll;
    IndexDataAll{cSess,3} = CategInds;
    
    save CategIndexSave.mat TaskIndexAll PassIndexAll CategInds -v7.3
    tline = fgetl(ff);
    cSess = cSess + 1;
end

%%
TaskCategDataCell = cellfun(@(x,y) x(y),IndexDataAll(:,1),IndexDataAll(:,3),'uniformoutput',false);
PassCategDataCell = cellfun(@(x,y) x(y),IndexDataAll(:,2),IndexDataAll(:,3),'uniformoutput',false);
TaskCategDataMtx = cell2mat(TaskCategDataCell);
PassCategDataMtx = cell2mat(PassCategDataCell);
%%
[~,p] = ttest(TaskCategDataMtx,PassCategDataMtx);
hhf = figure('position',[100 100 420 350]);
hold on
plot(TaskCategDataMtx,PassCategDataMtx,'ro','linewidth',1.6);
line([0 1],[0 1],'Color',[.5 .5 .5],'linewidth',2,'linestyle','--');
xlabel('Task');
ylabel('Passive');
set(gca,'xlim',[0 1.1],'ylim',[0 1.1],'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
title({sprintf('Task %.4f-%.4f, Pass %.4f-%.4f',mean(TaskCategDataMtx),std(TaskCategDataMtx),...
    mean(PassCategDataMtx),std(PassCategDataMtx));sprintf('p = %.3e',p)});
set(gca,'FontSize',14);
