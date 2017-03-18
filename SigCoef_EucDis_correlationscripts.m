%%
clear
clc

%% loading Paired corrcoef data
[Coeffn,Coeffp,Coeffi] = uigetfile('SignalCorrSave.mat','Please select the signal correlation savage data');
if ~Coeffi
    return;
else
    SigCoefDataStrc = load(fullfile(Coeffp,Coeffn));
    cd(Coeffp);
    PairedSigCoefp = squareform(SigCoefDataStrc.PairedSCpvalue);
    PairedSigCoef = squareform(SigCoefDataStrc.PairedROISigcorr);
end

%%
% loading ROIinfo data file
[ROIinfofn,ROIinfofp,ROIinfofi] = uigetfile('*.mat','Please select the ROI position info saving file for current session');
if ~ROIinfofi
    return
else
    PosInfoData = load(fullfile(ROIinfofp,ROIinfofn));
    ROIposCell = cellfun(@mean,PosInfoData.ROIinfoBU.ROIpos,'UniformOutput',false);
    ROIposMatrix = cell2mat(ROIposCell');
    nROIs = length(PosInfoData.ROIinfoBU.ROImask);
end

%%
MatrixmaskRaw = ones(size(PairedSigCoef));
Matrixmask = logical(tril(MatrixmaskRaw,-1));

ReshapedVectorCoef = PairedSigCoef(Matrixmask);
ReshapedVectorCoefP = PairedSigCoefp(Matrixmask);

ROIEucDis = pdist(ROIposMatrix); 
ROIRealDis = ROIEucDis * (325/256);  % convert into real distance in macrometer form
ROIEucDis = ROIRealDis;
%%
[lmmd,hfSCDis] = lmFunCalPlot(ROIEucDis,ReshapedVectorCoef);
[hSC_dis,pSC_dis] = corrcoef(ROIEucDis,ReshapedVectorCoef);
text(-45,0.8,sprintf('p = %.3f',pSC_dis(1,2)),'FontSize',16);
set(gca,'ytick',[-1 0 1]);
xlabel('Paired\_distance');
ylabel('Signal\_correlation');

%%
% calculate the binned data inds
MaxDis = max(ROIRealDis);
BinsizeBound = 0:50:MaxDis;  % distance bin, 50umm step
BinsizeBound = [BinsizeBound, MaxDis]; % add the maxium distance value
BinNumber = length(BinsizeBound) - 1;
BinInds = cell(BinNumber,1);
BinCenter = zeros(BinNumber,1);
for nBin = 1 : BinNumber
    LowBinValue = BinsizeBound(nBin);
    HighBinValue = BinsizeBound(nBin+1);
    BinCenter(nBin) = (LowBinValue+HighBinValue)/2;
    if nBin == BinNumber
        cInds = find(ROIRealDis >= LowBinValue & ROIRealDis <= HighBinValue);
    else
        cInds = find(ROIRealDis >= LowBinValue & ROIRealDis < HighBinValue);
    end
    BinInds{nBin} = cInds;
end

% y=tiedrank(X);
% z=ceil((GroupNumber*y)/length(X));

%%
[NCoeffn,NCoeffp,NCoeffi] = uigetfile('ROIModified_coefSaveMean.mat','Please select the noise correlation data saving file');
if ~NCoeffi
    return;
else
    NCdataStrc = load(fullfile(NCoeffp,NCoeffn));
    PairedNoiseCoef = NCdataStrc.PairedROIcorr;
    PairedNoiseCoefp = NCdataStrc.PairedNCpvalue;
end
%%

[~,hfNCDis] = lmFunCalPlot(ROIEucDis,PairedNoiseCoef);
[hNC_dis,pNC_dis] = corrcoef(ROIEucDis,PairedNoiseCoef);
text(-45,0.8,sprintf('p = %.3f',pNC_dis(1,2)),'FontSize',16);
set(gca,'ytick',[-1 0 1]);
xlabel('Paired\_distance');
ylabel('Noise\_correlation');

%
[~,hfNCSC] = lmFunCalPlot(ReshapedVectorCoef,PairedNoiseCoef);
[hNC_SC,pNC_SC] = corrcoef(ReshapedVectorCoef,PairedNoiseCoef);
text(-1.25,0.8,sprintf('p = %.3f',pNC_SC(1,2)),'FontSize',16);
set(gca,'ytick',[-1 0 1]);
xlabel('Signal\_correlation');
ylabel('Noise\_correlation');

%%
cd ..;
if ~isdir('Correlation_distance_coefPlot')
    mkdir('Correlation_distance_coefPlot');
end
cd('Correlation_distance_coefPlot');

save CoefDisSave.mat ReshapedVectorCoef PairedNoiseCoef ROIEucDis pSC_dis pNC_dis pNC_SC -v7.3
saveas(hfSCDis,'SC_Dis_correlation_plot');
saveas(hfSCDis,'SC_Dis_correlation_plot','png');
saveas(hfNCDis,'NC_Dis_correlation_plot');
saveas(hfNCDis,'NC_Dis_correlation_plot','png');
saveas(hfNCSC,'NC_SC_correlation_plot');
saveas(hfNCSC,'NC_SC_correlation_plot','png');
close(hfSCDis);
close(hfNCDis);
close(hfNCSC);
cd ..;

%%
% binned data set for SC and NC
% cd ..;
SCDataAll = ReshapedVectorCoef;
NCDataAll = PairedNoiseCoef;
SCBinDataCell = cell(BinNumber,1);
SCBinMeanSem = zeros(BinNumber,3);
NCBinDataCell = cell(BinNumber,1);
NCBinMeanSem = zeros(BinNumber,3);
for nnm = 1 : BinNumber
    cBinInds = BinInds{nnm};
    SCBinDataCell{nnm} = SCDataAll(cBinInds);
    NCBinDataCell{nnm} = NCDataAll(cBinInds);
    SCBinMeanSem(nnm,:) = [mean(SCBinDataCell{nnm}),std(SCBinDataCell{nnm})/sqrt(length(SCBinDataCell{nnm})),length(SCBinDataCell{nnm})];
    NCBinMeanSem(nnm,:) = [mean(NCBinDataCell{nnm}),std(NCBinDataCell{nnm})/sqrt(length(NCBinDataCell{nnm})),length(NCBinDataCell{nnm})];
end

if ~isdir('./CorrCoefDis_Plot/')
    mkdir('./CorrCoefDis_Plot/');
end
cd('./CorrCoefDis_Plot/');

hscnc = figure('position',[600 400 1050 700]);
hold on
SCLine = errorbar(BinCenter,SCBinMeanSem(:,1),SCBinMeanSem(:,2),'-o','Color','r','MarkerFaceColor','r');
NCLine = errorbar(BinCenter,NCBinMeanSem(:,1),NCBinMeanSem(:,2),'-o','Color','k','MarkerFaceColor','k');
xlabel('Pair Distance (um)');
ylabel('Correlation Value');
title('Noise and signal correlation vs paired distance');
set(gca,'FontSize',18);
legend([SCLine,NCLine],{'Signal correlation','Noise correlation'},'FontSize',14);
saveas(hscnc,'SCNC_dis_binned_coef_value');
saveas(hscnc,'SCNC_dis_binned_coef_value','png');
close(hscnc);
save binnedCoefDataSave.mat SCBinDataCell NCBinDataCell SCBinMeanSem NCBinMeanSem BinCenter BinsizeBound SCDataAll NCDataAll ROIRealDis -v7.3
cd ..;
% pwd

%%
% binned data set using group wised dataset for SC and NC
% cd ..;

% load groupwised ROIinfo
[fn,fp,fi] = uigetfile('RespGroupNCData.mat','Please select your Groupwised signal correlation data');
if ~fi
    return;
else
    RespgroupIndsPath = fullfile(fp,fn);
    GroupIndexStrc = load(RespgroupIndsPath);
    LeftROIindex = GroupIndexStrc.LeftSigROIAUCIndex;
    RightROIindex = GroupIndexStrc.RightSigROIAUCIndex;
    
%     nROIs = length(ROIinfoData(1).ROImask);
    % ROIindexAll = 1 : nROIs;
%     ROIinputIndex = zeros(nROIs,1);
%     ROIinputIndex(LeftROIindex) = -1; 
%     ROIinputIndex(RightROIindex) = 1;
end

SCDataAll = ReshapedVectorCoef;
NCDataAll = PairedNoiseCoef;
SCBinDataCell = cell(BinNumber,1);
SCBinMeanSem = zeros(BinNumber,3);
NCBinDataCell = cell(BinNumber,1);
NCBinMeanSem = zeros(BinNumber,3);
for nnm = 1 : BinNumber
    cBinInds = BinInds{nnm};
    SCBinDataCell{nnm} = SCDataAll(cBinInds);
    NCBinDataCell{nnm} = NCDataAll(cBinInds);
    SCBinMeanSem(nnm,:) = [mean(SCBinDataCell{nnm}),std(SCBinDataCell{nnm})/sqrt(length(SCBinDataCell{nnm})),length(SCBinDataCell{nnm})];
    NCBinMeanSem(nnm,:) = [mean(NCBinDataCell{nnm}),std(NCBinDataCell{nnm})/sqrt(length(NCBinDataCell{nnm})),length(NCBinDataCell{nnm})];
end

if ~isdir('./CorrCoefDis_Plot/')
    mkdir('./CorrCoefDis_Plot/');
end
cd('./CorrCoefDis_Plot/');

hscnc = figure('position',[600 400 1050 700]);
hold on
SCLine = errorbar(BinCenter,SCBinMeanSem(:,1),SCBinMeanSem(:,2),'-o','Color','r','MarkerFaceColor','r');
NCLine = errorbar(BinCenter,NCBinMeanSem(:,1),NCBinMeanSem(:,2),'-o','Color','k','MarkerFaceColor','k');
xlabel('Pair Distance (um)');
ylabel('Correlation Value');
title('Noise and signal correlation vs paired distance');
set(gca,'FontSize',18);
legend([SCLine,NCLine],{'Signal correlation','Noise correlation'},'FontSize',14);
saveas(hscnc,'SCNC_dis_binned_coef_value');
saveas(hscnc,'SCNC_dis_binned_coef_value','png');
close(hscnc);
save binnedCoefDataSave.mat SCBinDataCell NCBinDataCell SCBinMeanSem NCBinMeanSem BinCenter BinsizeBound SCDataAll NCDataAll ROIRealDis -v7.3
cd ..;
pwd