%%
clear
clc
SessFracDataSum = {};
SessMaxAUCSum = {};
mk = 1;
ROCfracInds = (0.1:0.05:1)*100;
[RFfn,RFfp,RFfi] = uigetfile('*.txt','please select the RF classification accuracy mat file');
RFpath = fullfile(RFfp,RFfn);
RFid = fopen(RFpath);
tline = fgetl(RFid);
while ischar(tline)
    if isempty(strfind(tline,'Frac_class_compPlot\RFtaskFracClass.mat;'))
        tline = fgetl(RFid);
        continue;
    end
    SessDataPath = strrep(tline,'Frac_class_compPlot\RFtaskFracClass.mat;','rfSelectDataSet.mat');
    SessDataStrc = load(SessDataPath);
    SessAUCPath = strrep(tline,'Frac_class_compPlot\RFtaskFracClass.mat;','Stim_time_Align\ROC_Left2Right_result\ROC_score.mat');
    SessAUCData = load(SessAUCPath);
    
    AUCABS = SessAUCData.ROCarea;
    AUCABS(SessAUCData.ROCRevert == 1) = 1 - AUCABS(SessAUCData.ROCRevert == 1);
    SessFreqtype = unique(SessDataStrc.SelectSArray);
    FreqArray = SessDataStrc.SelectSArray;
    FreqData = SessDataStrc.SelectData;
    FrameRate = SessDataStrc.frame_rate;
    if mod(length(SessFreqtype),2)
        BoundFreq = SessFreqtype(ceil(length(SessFreqtype)/2));
        FreqArray(FreqArray == BoundFreq) = [];
        FreqData(FreqArray == BoundFreq,:,:) = [];
    end 
    %
    savePath = strrep(tline,'Frac_class_compPlot\RFtaskFracClass.mat;','Frac_popuAccuracy');
    if ~isdir(savePath)
        mkdir(savePath);
    end
    cd(savePath);
    TrTypes = FreqArray > 16000;
    ROCABS = ROC_check(FreqData,double(TrTypes),FrameRate,FrameRate,1.5,'Stim_time_Align_select',0);
    PrcAUCValue = prctile(ROCABS,ROCfracInds);
    PopuAccuracy = zeros(length(ROCfracInds),1000);
    FracMaxAUC = zeros(length(ROCfracInds),1);
    ROCFrac = cell(length(ROCfracInds),1);
    for nFrac = 1 : length(ROCfracInds)
        FracThres = PrcAUCValue(nFrac);
        BelowThresInds = ROCABS < FracThres;
        [AllTloss,~] = TbyTAllROIclass(FreqData,TrTypes,ones(length(FreqArray),1),FrameRate,FrameRate,...
        1.5,0,[],BelowThresInds,1,1);
        PopuAccuracy(nFrac,:) = 1 - AllTloss;
        FracMaxAUC(nFrac) = max(ROCABS(BelowThresInds));
        ROCFrac{nFrac} = BelowThresInds;
    end

    save RFFracPopuAccuracyNew.mat AUCABS ROCfracInds PopuAccuracy FracMaxAUC ROCABS -v7.3
    
    SessMaxAUCSum{mk} = FracMaxAUC;
    SessFracDataSum{mk} = PopuAccuracy;
    mk = mk + 1;
    tline = fgetl(RFid);
end
%%
clear
clc
SessFracDataSum = {};
SessMaxAUCSum = {};
mk = 1;
[RFfn,RFfp,RFfi] = uigetfile('*.txt','please select the RF classification accuracy mat file');
RFpath = fullfile(RFfp,RFfn);
RFid = fopen(RFpath);
tline = fgetl(RFid);
while ischar(tline)
    if isempty(strfind(tline,'Frac_class_compPlot\RFtaskFracClass.mat;'))
        tline = fgetl(RFid);
        continue;
    end
    SessDataPath = strrep(tline,'Frac_class_compPlot\RFtaskFracClass.mat;','Frac_popuAccuracy\RFFracPopuAccuracyNew.mat');
    SessDataStrc = load(SessDataPath);
    SessMaxAUCSum{mk} = SessDataStrc.FracMaxAUC;
    SessFracDataSum{mk} = SessDataStrc.PopuAccuracy;
    mk = mk + 1;
    tline = fgetl(RFid);
end
SavePath = uigetdir(pwd,'Please select the data asave path');
cd(SavePath);
save RFFracPopuAccuSaveNew.mat SessMaxAUCSum SessFracDataSum -v7.3
%%
PopuAccuracy = cellfun(@(x) mean(x,2),SessFracDataSum,'UniformOutput',false);
PopuSEM = cellfun(@(x) std(x,[],2),SessFracDataSum,'UniformOutput',false); %/sqrt(size(x,2))
PopuSEMMtx = cell2mat(PopuSEM);
PopuAccuMtx = cell2mat(PopuAccuracy);
PopuMaxAUCSave = cell2mat(SessMaxAUCSum);
nSess = size(PopuAccuMtx,2);
hhf = figure;
hold on
for nn = 1 : nSess
    cSessPopuAccu = PopuAccuMtx(:,nn);
    cSessAUCMax = PopuMaxAUCSave(:,nn);
    plot(cSessAUCMax,cSessPopuAccu,'k-o','linewidth',1.6,'MarkerSize',8);
    plot(cSessAUCMax(end),cSessPopuAccu(end),'o','MarkerSize',8,'MarkerFaceColor','y');
end
set(gca,'xlim',[0.3,1],'ylim',[0.3,1],'xtick',[0.4,0.6,0.8,1],'ytick',[0.4,0.6,0.8,1]);
line([0.3,1],[0.3,1],'Color','k','linewidth',1.8,'linestyle','--');
errorbar(PopuMaxAUCSave(end,:),PopuAccuMtx(end,:),PopuSEMMtx(end,:),'ro','linewidth',1.8)
xlabel('Maxium AUC within neuron subset');
ylabel('Population decoding accuracy');
title('Passive\_population\_VS\_maxAUC');
[h,p] = ttest(PopuMaxAUCSave(end,:),PopuAccuMtx(end,:));
text([0.75,0.75],[0.4,0.5],{sprintf('P = %.5f',p),sprintf('n = %d',nSess)},'FontSize',18);
set(gca,'FOntSize',20);
saveas(hhf,'RF_PopuAccuracy_MaxAUC_compare_plot_errorbar');
saveas(hhf,'RF_PopuAccuracy_MaxAUC_compare_plot_errorbar','png');
saveas(hhf,'RF_PopuAccuracy_MaxAUC_compare_plot_errorbar','pdf');