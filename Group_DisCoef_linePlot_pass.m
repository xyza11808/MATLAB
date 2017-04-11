% scripts for groupwised plot of passive data of coefficient against paired
% distance
clear
clc
% real paired distance (um)
[Passfn,Passfp,Passfi] = uigetfile('CoefDisSave.mat','Please select your passive coefficient vs paired distance data');
if ~Passfi
    return;
else
    cPath = fullfile(Passfp,Passfn);
    PassDataStrc = load(cPath);
    cd(Passfp);
    PairedDis = (PassDataStrc.ROIEucDis)';
    PairedNC = PassDataStrc.PairedNoiseCoef;
    PairedSC = PassDataStrc.ReshapedVectorCoef;
    
    PairedDisMtx = squareform(PairedDis);
    PairedNCMtx = squareform(PairedNC);
    PairedSCMtx = squareform(PairedSC);
end

%% load ROI group index data from task session
[fn,fp,fi] = uigetfile('RespGroupNCData.mat','Please select your Groupwised signal correlation data');
if ~fi
    return;
else
    RespgroupIndsPath = fullfile(fp,fn);
    GroupIndexStrc = load(RespgroupIndsPath);
    LeftROIindex = GroupIndexStrc.LeftSigROIAUCIndex;
    RightROIindex = GroupIndexStrc.RightSigROIAUCIndex;
end

%% substract the group wised data
nLeftROIs = length(LeftROIindex);
LeftCoefMask = logical(tril(ones(nLeftROIs),-1));
if ~isempty(LeftROIindex)
    LeftDisMtx = PairedDisMtx(LeftROIindex,LeftROIindex);
    LeftDisVector = LeftDisMtx(LeftCoefMask);
    LeftNCMtx = PairedNCMtx(LeftROIindex,LeftROIindex);
    LeftNCVector = LeftNCMtx(LeftCoefMask);
    LeftSCMtx = PairedSCMtx(LeftROIindex,LeftROIindex);
    LeftSCVector = LeftSCMtx(LeftCoefMask);
end

nRightROIs = length(RightROIindex);
RightCoefMask = logical(tril(ones(nRightROIs),-1));
if ~isempty(RightROIindex)
    RightDisMtx = PairedDisMtx(RightROIindex,RightROIindex);
    RightDisVector = RightDisMtx(RightCoefMask);
    RightNCMtx = PairedNCMtx(RightROIindex,RightROIindex);
    RightNCVector = RightNCMtx(RightCoefMask);
    RightSCMtx = PairedSCMtx(RightROIindex,RightROIindex);
    RightSCVector = RightSCMtx(RightCoefMask);
end

LRDisMtx = PairedDisMtx(LeftROIindex,RightROIindex);
LRDisNCMtx = PairedNCMtx(LeftROIindex,RightROIindex);
LRDisSCMtx = PairedSCMtx(LeftROIindex,RightROIindex);
LRDisVector = LRDisMtx(:);
LRNCVector = LRDisNCMtx(:);
LRSCVector = LRDisSCMtx(:);
save PassNCDisGrWiseSave.mat PassDataStrc LeftROIindex RightROIindex 
%% organized into distance binned data format
DisMaxRange = max([max(LeftDisVector),max(RightDisVector),max(LRDisVector)]);
DisBinRange = 0:50:DisMaxRange;
DisBinRange = [DisBinRange,DisMaxRange];
nBins = length(DisBinRange) - 1;
nBinCenters = zeros(nBins,1);
LeftBinNCdata = zeros(nBins,3);
LeftBinSCdata = zeros(nBins,3);
RightBinNCdata = zeros(nBins,3);
RightBinSCdata = zeros(nBins,3);
LRBinNCdata = zeros(nBins,3);
LRBinSCdata = zeros(nBins,3);

for nBin = 1 : nBins
    cBinScale = [DisBinRange(nBin),DisBinRange(nBin+1)];
    nBinCenters(nBin) = round(mean(cBinScale));
    if nBin ~= nBins
        LeftBinInds = (LeftDisVector >= DisBinRange(nBin)) & (LeftDisVector < DisBinRange(nBin+1));
        RightBinInds = (RightDisVector >= DisBinRange(nBin)) & (RightDisVector < DisBinRange(nBin+1));
        LRBinInds = (LRDisVector >= DisBinRange(nBin)) & (LRDisVector < DisBinRange(nBin+1));
    else
        LeftBinInds = (LeftDisVector >= DisBinRange(nBin)) & (LeftDisVector <= DisBinRange(nBin+1));
        RightBinInds = (RightDisVector >= DisBinRange(nBin)) & (RightDisVector <= DisBinRange(nBin+1));
        LRBinInds = (LRDisVector >= DisBinRange(nBin)) & (LRDisVector <= DisBinRange(nBin+1));
    end
    
    % left selective data
     cBinNCdataAll = LeftNCVector(LeftBinInds);
     cBinSCdataAll = LeftSCVector(LeftBinInds);
     if ~isempty(cBinNCdataAll)
         LeftBinNCdata(nBin,:) = [mean(cBinNCdataAll),std(cBinNCdataAll)/sqrt(length(cBinNCdataAll)),length(cBinNCdataAll)];
     end
     if ~isempty(cBinSCdataAll)
          LeftBinSCdata(nBin,:) = [mean(cBinSCdataAll),std(cBinSCdataAll)/sqrt(length(cBinSCdataAll)),length(cBinSCdataAll)];
     end
     
     % right selective data
     cBinNCdataAll = RightNCVector(RightBinInds);
     cBinSCdataAll = RightSCVector(RightBinInds);
      if ~isempty(cBinNCdataAll)
          RightBinNCdata(nBin,:) = [mean(cBinNCdataAll),std(cBinNCdataAll)/sqrt(length(cBinNCdataAll)),length(cBinNCdataAll)];
      end
      if ~isempty(cBinSCdataAll)
          RightBinSCdata(nBin,:) = [mean(cBinSCdataAll),std(cBinSCdataAll)/sqrt(length(cBinSCdataAll)),length(cBinSCdataAll)];
      end
      
      % LR selective data
      cBinNCdataAll = LRNCVector(LRBinInds);
      cBinSCdataAll = LRSCVector(LRBinInds);
    
      if ~isempty(cBinNCdataAll)
          LRBinNCdata(nBin,:) = [mean(cBinNCdataAll),std(cBinNCdataAll)/sqrt(length(cBinNCdataAll)),length(cBinNCdataAll)];
      end
      if ~isempty(cBinSCdataAll)
          LRBinSCdata(nBin,:) = [mean(cBinSCdataAll),std(cBinSCdataAll)/sqrt(length(cBinSCdataAll)),length(cBinSCdataAll)];
      end
end

%% plot the final results
cd ..;
if ~isdir('./GroupCoef_DisBin/')
    mkdir('./GroupCoef_DisBin/');
end
cd('./GroupCoef_DisBin/');
FontSizeText = 10;
ShiftStep = 5;
h_groupSC = figure('position',[50 200 1000 800]);
hold on
h1 = errorbar(nBinCenters,LeftBinSCdata(:,1),LeftBinSCdata(:,2),'-o','Color','b','MarkerFaceColor','b','LineWidth',1.4);
h3 = errorbar(nBinCenters,RightBinSCdata(:,1),RightBinSCdata(:,2),'-o','Color','r','MarkerFaceColor','r','LineWidth',1.4);
h5 = errorbar(nBinCenters,LRBinSCdata(:,1),LRBinSCdata(:,2),'-o','Color','k','MarkerFaceColor','k','LineWidth',1.4);
xlabel('Pair Distance (um)');
ylabel('Correlation Value');
title('Signal correlation vs paired distance');
set(gca,'FontSize',18);
MaxRespData = max([LeftBinSCdata(:,1),RightBinSCdata(:,1),LRBinSCdata(:,1)],[],2);
yscales = get(gca,'ylim');
BinMaxDiff = yscales(2) - MaxRespData;
text(nBinCenters+ShiftStep,MaxRespData+(0.3*BinMaxDiff),cellstr(num2str(LeftBinSCdata(:,3))),'Color','b','FontSize',FontSizeText);
text(nBinCenters+ShiftStep,MaxRespData+(0.5*BinMaxDiff),cellstr(num2str(RightBinSCdata(:,3))),'Color','r','FontSize',FontSizeText);
text(nBinCenters+ShiftStep,MaxRespData+(0.7*BinMaxDiff),cellstr(num2str(LRBinSCdata(:,3))),'Color','k','FontSize',FontSizeText);
legend([h1,h3,h5],{'LeftSC','RightSC','LRSC'},'Fontsize',12);
saveas(h_groupSC,'SC Group Dis Coef Plot');
saveas(h_groupSC,'SC Group Dis Coef Plot','png');
close(h_groupSC);

h_groupNC = figure('position',[2200 200 1000 800]);
hold on
h2 = errorbar(nBinCenters,LeftBinNCdata(:,1),LeftBinNCdata(:,2),'-o','Color','b','MarkerFaceColor','b','LineWidth',1.4);
h4 = errorbar(nBinCenters,RightBinNCdata(:,1),RightBinNCdata(:,2),'-o','Color','r','MarkerFaceColor','r','LineWidth',1.4);
h6 = errorbar(nBinCenters,LRBinNCdata(:,1),LRBinNCdata(:,2),'-o','Color','k','MarkerFaceColor','k','LineWidth',1.4);
xlabel('Pair Distance (um)');
ylabel('Correlation Value');
title('Noise correlation vs paired distance');
set(gca,'FontSize',18);
MaxRespData = max([LeftBinNCdata(:,1),RightBinNCdata(:,1),LRBinNCdata(:,1)],[],2);
yscales = get(gca,'ylim');
BinMaxDiff = yscales(2) - MaxRespData;
text(nBinCenters+ShiftStep,MaxRespData+(0.3*BinMaxDiff),cellstr(num2str(LeftBinNCdata(:,3))),'Color','b','FontSize',FontSizeText);
text(nBinCenters+ShiftStep,MaxRespData+(0.5*BinMaxDiff),cellstr(num2str(RightBinNCdata(:,3))),'Color','r','FontSize',FontSizeText);
text(nBinCenters+ShiftStep,MaxRespData+(0.7*BinMaxDiff),cellstr(num2str(LRBinNCdata(:,3))),'Color','k','FontSize',FontSizeText);
legend([h2,h4,h6],{'LeftNC','RightNC','LRNC'},'Fontsize',12);
saveas(h_groupNC,'NC Group Dis Coef Plot');
saveas(h_groupNC,'NC Group Dis Coef Plot','png');
close(h_groupNC);

save GroupDisCoefLinesave.mat nBinCenters LeftBinNCdata RightBinNCdata LRBinNCdata LeftBinSCdata RightBinSCdata LRBinSCdata -v7.3
% save GroupDisCoefStrc.mat LeftGroupDataStrc RightGroupDataStrc LRGroupDataStrc -v7.3

cd ..;
