function ReOmtRespComp(RawDataAll,AnsT,TimeScale,WinBin,TypeInds,Frate,varargin)
% this function is used for comparation of the response between Normal
% correct trials and reward omit trials and try to whetehr there are any
% differences between two different conditions

[Trialnum,ROINum,FrameNum] = size(RawDataAll);
if Trialnum ~= length(AnsT)
    error('Matrix index inconsistant, please check your input.');
end

if length(TimeScale) ~= 2 
    error('The input TimeScale must be a two elements vector.');
end
AnsT = double(AnsT);
CorrLNorInds = TypeInds.CLNorInds;
CorrLOmtInds = TypeInds.CLOmtInds;
CorrRNorInds = TypeInds.CRNorInds;
CorrROmtInds = TypeInds.CROmtInds;
% SelectInds = logical(CorrLNorInds + CorrLOmtInds + CorrRNorInds + CorrROmtInds);
% SelectAnsT = AnsT()
FrameScale = round(TimeScale * Frate);  % Normally the first element should be negtive number indicates time before answer time
FrameAnsT = round((AnsT/1000) * Frate);
MinAnsT = unique(FrameAnsT);
MinAnsTV = MinAnsT(2);
if (MinAnsTV + FrameScale(1)) < 1
    FrameScale(1) = 1 - MinAnsTV;
end
if (max(FrameAnsT) + FrameScale(2)) > FrameNum
    FrameScale(2) = FrameNum - max(FrameAnsT)-1;
end

SelectRange = zeros(Trialnum,ROINum,diff(FrameScale)+1);  % miss trial should be all zeros values
for nTr = 1 : Trialnum
    if FrameAnsT(nTr)
        SelectRange(nTr,:,:) = RawDataAll(nTr,:,(FrameAnsT(nTr) + FrameScale(1)):(FrameAnsT(nTr) + FrameScale(2)));
    end
end

if WinBin > 1  % frame input
    FrameBin = WinBin; 
    TimeBin = FrameBin/Frate;
else    % time input
    FrameBin = round(WinBin * Frate);
    TimeBin = WinBin;
end
isBeforePlot = 0;
if TimeScale(1) < 0
    BeforeInds = floor(abs(TimeScale(1))/TimeBin);
    isBeforePlot = 1;
end
%%
BinNum = ceil(diff(FrameScale)/FrameBin);
CorrLNorDSum = zeros(ROINum,BinNum,3); % three columns for mean, std, number
CorrLOmtDSum = zeros(ROINum,BinNum,3); 
LeftSigInds = zeros(ROINum,BinNum); % p value storage

CorrRNorDSum = zeros(ROINum,BinNum,3); % three columns for mean, std, number
CorrROmtDSum = zeros(ROINum,BinNum,3); 
RightSigInds = zeros(ROINum,BinNum);
for nROI = 1 : ROINum
    CorrLNorData = squeeze(SelectRange(CorrLNorInds,nROI,:));
    CorrLOmtData = squeeze(SelectRange(CorrLOmtInds,nROI,:));
    
    CorrRNorData = squeeze(SelectRange(CorrRNorInds,nROI,:));
    CorrROmtData = squeeze(SelectRange(CorrROmtInds,nROI,:)); 
    
    for nBin = 1 : BinNum
        cWinBase = 1 + FrameBin * (nBin - 1);
        CorrLNorcBinData = CorrLNorData(:,cWinBase:min((cWinBase+FrameBin),size(SelectRange,3)));
        CorrLOmtcBinData = CorrLOmtData(:,cWinBase:min((cWinBase+FrameBin),size(SelectRange,3)));
        CorrLNorDSum(nROI,nBin,:) = [mean(CorrLNorcBinData(:)),std(CorrLNorcBinData(:)),size(CorrLNorcBinData,1)];
        CorrLOmtDSum(nROI,nBin,:) = [mean(CorrLOmtcBinData(:)),std(CorrLOmtcBinData(:)),size(CorrLOmtcBinData,1)];
        [~,p] = ttest2(CorrLNorcBinData(:),CorrLOmtcBinData(:));
        LeftSigInds(nROI,nBin) = p;
        
        CorrRNorcBinData = CorrRNorData(:,cWinBase:min((cWinBase+FrameBin),size(SelectRange,3)));
        CorrROmtcBinData = CorrROmtData(:,cWinBase:min((cWinBase+FrameBin),size(SelectRange,3)));
        CorrRNorDSum(nROI,nBin,:) = [mean(CorrRNorcBinData(:)),std(CorrRNorcBinData(:)),size(CorrRNorcBinData,1)];
        CorrROmtDSum(nROI,nBin,:) = [mean(CorrROmtcBinData(:)),std(CorrROmtcBinData(:)),size(CorrROmtcBinData,1)];
        [~,p] = ttest2(CorrRNorcBinData(:),CorrROmtcBinData(:));
        RightSigInds(nROI,nBin) = p;
    end
end

%%
if ~isdir('./ReOmit_WinBin_comp/')
    mkdir('./ReOmit_WinBin_comp/');
end
cd('./ReOmit_WinBin_comp/');

save WinDataSummary.mat CorrLNorDSum CorrLOmtDSum LeftSigInds CorrRNorDSum CorrROmtDSum RightSigInds -v7.3

for nnROI = 1 : ROINum
    
    hh_ROI = figure('position',[90 200 1720 700],'Paperpositionmode','auto');
    subplot(1,2,1)  % Left correct trials 
    hold on
    cLNorData = squeeze(CorrLNorDSum(nnROI,:,1));
    cLOmtData = squeeze(CorrLOmtDSum(nnROI,:,1));
    cLNorSem = squeeze(CorrLNorDSum(nnROI,:,2))/sqrt(CorrLNorDSum(nnROI,1,3));
    cLOmtSem = squeeze(CorrLOmtDSum(nnROI,:,2))/sqrt(CorrLOmtDSum(nnROI,1,3));
    cSigInds =  double(LeftSigInds(nnROI,:) < 0.01);
    cSigInds(cSigInds < 1) = nan;
    cline1 = plot(cLNorData,'b','LineWidth',1.8,'LineStyle','--');  % control pot
    cline2 = plot(cLOmtData,'b','LineWidth',1.8);
    errorbar(1:BinNum,cLNorData,cLNorSem,'bo','LineWidth',1.4);
    errorbar(1:BinNum,cLOmtData,cLOmtSem,'bo','LineWidth',1.4);
    ylimValue = get(gca,'ylim');
    plot(cSigInds.*(1:BinNum),(0.95*ylimValue(2))*ones(BinNum,1),'k*');
    if isBeforePlot
        line([BeforeInds,BeforeInds],[0 0.8*ylimValue(2)],'color',[.8 .8 .8],'LineWidth',1.8);
    end
    xlabel('BinNum');
    ylabel('mean \DeltaF/F_0 (%)');
    title('Left Correct trials');
    set(gca,'FontSize',20);
    legend([cline1,cline2],{'Left_Nor','Left_Omit'},'FontSize',10);
    hold off
    box off
    
    subplot(1,2,2)  % Right correct trials 
    hold on
    cRNorData = squeeze(CorrRNorDSum(nnROI,:,1));
    cROmtData = squeeze(CorrROmtDSum(nnROI,:,1));
    cRNorSem = squeeze(CorrRNorDSum(nnROI,:,2))/sqrt(CorrRNorDSum(nnROI,1,3));
    cROmtSem = squeeze(CorrROmtDSum(nnROI,:,2))/sqrt(CorrROmtDSum(nnROI,1,3));
    cSigInds =  double(RightSigInds(nnROI,:) < 0.01);
    cSigInds(cSigInds < 1) = nan;
    cLine3 = plot(cRNorData,'r','LineWidth',1.8,'LineStyle','--');
    cLine4 = plot(cROmtData,'r','LineWidth',1.8);
    errorbar(1:BinNum,cRNorData,cRNorSem,'ro','LineWidth',1.4);
    errorbar(1:BinNum,cROmtData,cROmtSem,'ro','LineWidth',1.4);
    ylimValue = get(gca,'ylim');
    plot(cSigInds.*(1:BinNum),(0.95*ylimValue(2))*ones(BinNum,1),'k*');
    if isBeforePlot
        line([BeforeInds,BeforeInds],[0 0.8*ylimValue(2)],'color',[.8 .8 .8],'LineWidth',1.8);
    end
    xlabel('BinNum');
    ylabel('mean \DeltaF/F_0 (%)');
    title('Right Correct trials');
    set(gca,'FontSize',20);
    legend([cLine3,cLine4],{'Right_Nor','Right_Omit'},'FontSize',10);
    
    hold off
    box off
    
    suptitle(sprintf('ROI%d compare plot',nnROI));
    saveas(hh_ROI,sprintf('ROI%d Reomt plot',nnROI),'png');
    saveas(hh_ROI,sprintf('ROI%d Reomt plot',nnROI),'fig');
    close(hh_ROI);
end

cd ..;