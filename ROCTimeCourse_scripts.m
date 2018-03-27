

m = 1;
SessDataSummary = struct('SessDate','','ROCData',[],'xtime',[],'AlignBin',[],'ROISeq',[]);
tline = fgetl(Taskfid);

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(Taskfid);
        continue;
    end
    cd(tline);
    Anminfo = SessInfoExtraction(tline);
    TimeROCDataPath = fullfile(tline,'TimeFunROC_Plot','LR_ROC_timeFunSP','timeBinROCResult.mat');
    TimeROCDataStrc = load(TimeROCDataPath);
    if ~isfield(TimeROCDataStrc,'AlignBin')
        SessFrameStrc = load(fullfile(tline,'CSessionData.mat'),'frame_rate');
        SessFrame = SessFrameStrc.frame_rate;
        AlignTime = TimeROCDataStrc.alignpoint/SessFrame;
        AlignBinNum = find(TimeROCDataStrc.PXtickTime > AlignTime,1,'first') - 0.5;
    else
        AlignBinNum = TimeROCDataStrc.AlignBin;
        SessFrame = TimeROCDataStrc.FrameRate;
    end

    ROITemporalROC = TimeROCDataStrc.BINNEDROCResultLR;
    %
    [MaxROCValue,maxInds] = max(ROITemporalROC,[],2);
    [~,ROIseq] = sort(maxInds);
    hROCf = figure('position',[100 100 420 350]);
    imagesc(TimeROCDataStrc.PXtickTime,1:length(ROIseq),ROITemporalROC(ROIseq,:),[0.5 1]);
    line([AlignBinNum AlignBinNum],[0.5 length(ROIseq)+0.5],'Color',[.7 .7 .7],'linewidth',1.8);
    set(gca,'box','off','ylim',[0.5 length(ROIseq)+0.5],'xlim',[0 max(TimeROCDataStrc.PXtickTime)]);
    title(sprintf('Session Date:%s',Anminfo.SessionDate));
    xlabel('Time (s)');
    ylabel('# ROIs');
    set(gca,'FontSize',14);
    saveas(hROCf,'TimeCourse ROC sorted plot');
    saveas(hROCf,'TimeCourse ROC sorted plot','png');
    close(hROCf);
    
    SessDataSummary(m).SessDate = Anminfo.SessionDate;
    SessDataSummary(m).ROCData = ROITemporalROC;
    SessDataSummary(m).xtime = TimeROCDataStrc.PXtickTime;
    SessDataSummary(m).AlignBin = AlignBinNum;
    SessDataSummary(m).ROISeq = ROIseq;
    
    tline = fgetl(Taskfid);
end