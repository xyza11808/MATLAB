function RandPTROCSelectivity(AlignedData,FreqType,AlignPoint,Framerate,varargin)
%this function will be used for multiple frequency ROC analysis and tyr to
%check ROI's discrimination ability based on ROC result

if nargin > 4
    ModuIndex=varargin{1}; %if any modulation exists, plot the difference for two types
else
    ModuIndex=[];
end

if nargin>5
    TimeWin=varargin{2};
end
if ~exist('TimeWin','var') || isempty(TimeWin) 
    TimeWin=1.5;
end

FreqTypes=unique(FreqType);
TypeNum=length(FreqTypes);
DataForROC=cell(TypeNum,2);
FrameWin=floor(TimeWin*Framerate);
nROIs=size(AlignedData,2);

if ~isdir('./RandROC_plot/')
    mkdir('./RandROC_plot/');
end
cd('./RandROC_plot/');

if isempty(ModuIndex)
    for nType=1:TypeNum
        TypeInds = FreqType == FreqTypes(nType);
        CurrentData = AlignedData(TypeInds,:,:);
        CurrentDataBase = CurrentData(:,:,1:AlignPoint);
        CurrentDataResp = CurrentData(:,:,(AlignPoint+1):(AlignPoint+FrameWin));
        DataForROC(nType,1)={reshape(permute(CurrentDataBase,[2 3 1]),nROIs,[])};
        DataForROC(nType,2)={reshape(permute(CurrentDataResp,[2 3 1]),nROIs,[])};
    end
    clearvars CurrentData CurrentDataBase CurrentDataResp
    
    if ~isdir('./Rand ROI ROC plot/')
        mkdir('./Rand ROI ROC plot/');
    end
    cd('./Rand ROI ROC plot/');
    
    ResultStrc = FreqROCplot(DataForROC,[],nROIs,FreqTypes);
    cd ..;
    
    SortAUC = sort(ResultStrc.AUCPrefer);
    h_ROI = figure;
    scatter(1:nROIs,SortAUC,30,'MarkerEdgeColor','r','LineWidth',0.9);
    line([1,nROIs+1],[0.5 0.5],'LineStyle','-.','LineWidth',1.5,'color',[.8 .8 .8]);
    xlabel('# ROIs');
    ylabel('PreferFreq AUC');
    title('Session ROI Prefer AUC ')
    saveas(h_ROI,'Popu ROC distribution plot.png');
    saveas(h_ROI,'Popu ROC distribution plot.fig');
    close(h_ROI);
    ModuDataForROC = {};
%     cd ..;
else
    ModuDataForROC = cell(TypeNum,2);
    ControlData = AlignedData(~ModuIndex,:,:);
    ControlFreq = FreqType(~ModuIndex);
    for nType=1:TypeNum
        TypeInds = ControlFreq == FreqTypes(nType);
        CurrentData = ControlData(TypeInds,:,:);
        CurrentDataBase = CurrentData(:,:,1:AlignPoint);
        CurrentDataResp = CurrentData(:,:,(AlignPoint+1):(AlignPoint+FrameWin));
        DataForROC(nType,1)={reshape(permute(CurrentDataBase,[2 3 1]),nROIs,[])};
        DataForROC(nType,2)={reshape(permute(CurrentDataResp,[2 3 1]),nROIs,[])};
    end
    clearvars ControlData ControlFreq CurrentData CurrentDataBase CurrentDataResp
    
    ModuData = AlignedData(ModuIndex,:,:);
    ModuFreq = FreqType(ModuIndex);
    for nType=1:TypeNum
        TypeInds = ModuFreq == FreqTypes(nType);
        CurrentData = ModuData(TypeInds,:,:);
        CurrentDataBase = CurrentData(:,:,1:AlignPoint);
        CurrentDataResp = CurrentData(:,:,(AlignPoint+1):(AlignPoint+FrameWin));
        ModuDataForROC(nType,1)={reshape(permute(CurrentDataBase,[2 3 1]),nROIs,[])};
        ModuDataForROC(nType,2)={reshape(permute(CurrentDataResp,[2 3 1]),nROIs,[])};
    end
    clearvars CurrentData CurrentDataBase CurrentDataResp
    
    if ~isdir('./Rand ROI ROC plot/')
        mkdir('./Rand ROI ROC plot/');
    end
    cd('./Rand ROI ROC plot/');
    ResultStrc = FreqROCplot(DataForROC,ModuDataForROC,nROIs,FreqTypes);
    cd ..;
    
    [SortAUC,inds] = sort(ResultStrc.AUCPrefer);
    h_ROI = figure;
    scatter(1:nROIs,SortAUC,30,'MarkerEdgeColor','r','LineWidth',0.9);
    hold on;
    scatter(1:nROIs,ResultStrc.ModuAUCPrefer(inds),30,'MarkerEdgeColor','b','LineWidth',0.9);
    line([1,nROIs+1],[0.5 0.5],'LineStyle','-.','LineWidth',1.5,'color',[.8 .8 .8]);
    legend('ControlROC','ModuROC','Location','northwest');
    legend('boxoff');
    xlabel('# ROIs');
    ylabel('PreferFreq AUC');
    title('Session ROI Prefer AUC ')
    saveas(h_ROI,'Popu ROC distribution plot.png');
    saveas(h_ROI,'Popu ROC distribution plot.fig');
    close(h_ROI);
end

save RandROCsave.mat ResultStrc ModuDataForROC DataForROC -v7.3
cd ..;


%%
% inner function

function ResultStruc = FreqROCplot(CellDataControl,CellDataModu,nROI,FreqTypes)
% when there is no modulation data, just set input CellDataModu as []

nTypes = size(CellDataControl,1);
AUCvalue = zeros(nROI,nTypes);
AUCPrefer = zeros(nROI,1);
AUCPshuffle = zeros(nROI,1);
DataMeanDisp = ones(nROI,nTypes);   %if resp mean lower than base, this value will be 0, other wise is 1
PairedAUCPF = zeros(nROI,nTypes);
for n = 1:nROI
    h_plot  = figure('position',[100 110 1700 960],'PaperPositionMode','auto');
%     cROIcellbase = cell(nfrq,1);
    cROIcellResp = cell(nTypes,1);
    for nfrq = 1:nTypes
        CDataBase = CellDataControl{nfrq,1};
        CDataResp = CellDataControl{nfrq,2};
        baseDataroc = CDataBase(n,:);
        RespDataroc = CDataResp(n,:);
%         cROIcellbase(nfrq) = {baseDataroc};
        cROIcellResp(nfrq) = {RespDataroc};
        baseFORroc = [baseDataroc(:),zeros(length(baseDataroc),1)];
        respFORroc = [RespDataroc(:),ones(length(RespDataroc),1)];
        subplot(2,nTypes,nfrq);
        [ROCstruc,LabelMeanStruc] = rocOnlineHout([baseFORroc;respFORroc]);
        title(sprintf('Freq = %d AUC = %0.4f',FreqTypes(nfrq),ROCstruc.AUC));
        AUCvalue(n,nfrq) = ROCstruc.AUC;
        if LabelMeanStruc.LType1value(2) > LabelMeanStruc.LType2value(2)
            DataMeanDisp(n,nfrq) = 0;
        end
    end
    [~,MaxInds] = max(AUCvalue(n,:));
    logicalinds = true(1,nTypes);
    logicalinds(MaxInds) = false;
    PreferData = cROIcellResp{MaxInds};
    NonPreferDataCell = cROIcellResp(logicalinds);
    NonPreferData=[];
    for m=1:(nTypes-1)
        NonPreferData=[NonPreferData;reshape(NonPreferDataCell{m},[],1)]; %#ok<AGROW>
    end
    PDataFORroc = [PreferData(:),ones(length(PreferData),1)];
    NPDataFORroc = [NonPreferData(:),zeros(numel(NonPreferData),1)];
%     subplot(2,nfrq,(nTypes*1.5):(nTypes*1.5+1));
    subplot(2,nTypes,nTypes+2:nTypes+3)
    SIndexData = [PDataFORroc;NPDataFORroc];
    [rocres,~] = rocOnlineHout(SIndexData);
    title(sprintf('PF = %d, AUC = %0.4f',FreqTypes(MaxInds),rocres.AUC));
    AUCPrefer(n) = rocres.AUC;
    
    %paired frequency ROC to performance psychometrical curve
    for nPair = 1:(nTypes/2)
        cPairedInds = [nPair,nTypes-nPair+1];
        PairedAUCValue = mean(AUCvalue(n,cPairedInds));
        PairedAUCPF(n,cPairedInds) = PairedAUCValue;
    end
    cROICorr = PairedAUCPF(n,:);
    cROICorr(1:(nTypes/2)) = 1 - cROICorr(1:(nTypes/2));
    subplot(2,nTypes,(nTypes*2-2):(nTypes*2-1));
    plot(cROICorr,'ro','MarkerSize',8,'LineWidth',1.2);
    xlabel('Frequency(Oct)');
    ylabel('Rightward Choice');
    title('Performance based on AUC');
    
    suptitle(sprintf('ROI%d, PreferFreq = %d',n,FreqTypes(MaxInds)));
    saveas(h_plot,sprintf('ROC plot for ROI%d.png',n));
    saveas(h_plot,sprintf('ROC plot for ROI%d.fig',n));
    close(h_plot);
    
    OrderLabel = SIndexData(:,2);
    Sorder = Vshuffle(OrderLabel);
    SIndexData(:,2) = Sorder;
    [Srocres,~] = rocOnlineFoff(SIndexData);
    AUCPshuffle(n) = Srocres;
    
end

ResultStruc.AUCvalueAll = AUCvalue;
ResultStruc.AUCPrefer = AUCPrefer;
ResultStruc.DataMeanDispAll = DataMeanDisp;
ResultStruc.AUCPShuffle = AUCPshuffle;
ResultStruc.ModuAUCvalueAll = [];
ResultStruc.ModuAUCPrefer = [];
ResultStruc.ModuDataMeanDispAll = [];

if ~isempty(CellDataModu)
    if ~isdir('./Rand ROI ModuROC plot/')
        mkdir('./Rand ROI ModuROC plot/');
    end
    cd('./Rand ROI ModuROC plot/');
    
    ModuAUCvalue = zeros(nROI,nTypes);
    ModuAUCPrefer = zeros(nROI,1);
    ModuDataMeanDisp = ones(nROI,nTypes);   %if resp mean lower than base, this value will be 0, other wise is 1
    PairedAUCPFModu = zeros(nROI,nTypes);
    for n = 1:nROI
        h_plot  = figure('position',[100 110 1700 960],'PaperPositionMode','auto');
    %     cROIcellbase = cell(nfrq,1);
        cROIcellResp = cell(nTypes,1);
        for nfrq = 1:nTypes
            CDataBase = CellDataModu{nfrq,1};
            CDataResp = CellDataModu{nfrq,2};
            baseDataroc = CDataBase(n,:);
            RespDataroc = CDataResp(n,:);
    %         cROIcellbase(nfrq) = {baseDataroc};
            cROIcellResp(nfrq) = {RespDataroc};
            baseFORroc = [baseDataroc(:),zeros(length(baseDataroc),1)];
            respFORroc = [RespDataroc(:),ones(length(RespDataroc),1)];
            subplot(2,nTypes,nfrq);
            [ROCstruc,LabelMeanStruc] = rocOnlineHout([baseFORroc;respFORroc]);
            title(sprintf('Freq = %d AUC = %0.4f',FreqTypes(nfrq),ROCstruc.AUC));
            ModuAUCvalue(n,nfrq) = ROCstruc.AUC;
            if LabelMeanStruc.LType1value(2) > LabelMeanStruc.LType2value(2)
                ModuDataMeanDisp(n,nfrq) = 0;
            end
        end
        [~,MaxInds] = max(AUCvalue(n,:));
        logicalinds = true(1,nTypes);
        logicalinds(MaxInds) = false;
        PreferData = cROIcellResp{MaxInds};
        NonPreferDataCell = cROIcellResp(logicalinds);
        NonPreferData=[];
        for m=1:(nTypes-1)
            NonPreferData=[NonPreferData;reshape(NonPreferDataCell{m},[],1)]; %#ok<AGROW>
        end
        PDataFORroc = [PreferData(:),ones(length(PreferData),1)];
        NPDataFORroc = [NonPreferData(:),zeros(numel(NonPreferData),1)];
%         subplot(2,nTypes,(nTypes*1.5):(nTypes*1.5+1));
        subplot(2,nTypes,nTypes+2:nTypes+3)
        [rocres,~] = rocOnlineHout([PDataFORroc;NPDataFORroc]);
        title(sprintf('PF = %d, AUC = %0.4f',FreqTypes(MaxInds),rocres.AUC));
        ModuAUCPrefer(n) = rocres.AUC;
        
         %paired frequency ROC to performance psychometrical curve
        for nPair = 1:(nTypes/2)
            cPairedInds = [nPair,nTypes-nPair+1];
            PairedAUCValue = mean(ModuAUCvalue(n,cPairedInds));
            PairedAUCPFModu(n,cPairedInds) = PairedAUCValue;
        end
        cROICorr = PairedAUCPFModu(n,:);
        cROICorr(1:(nTypes/2)) = 1 - cROICorr(1:(nTypes/2));
        subplot(2,nTypes,(nTypes*2-2):(nTypes*2-1));
        plot(cROICorr,'ko','MarkerSize',8,'LineWidth',1.2);
        xlabel('Frequency(Oct)');
        ylabel('Rightward Choice');
        title('Performance based on AUC');

        suptitle(sprintf('Modu, ROI%d, PreferFreq = %d',n,FreqTypes(MaxInds)));
        saveas(h_plot,sprintf('Modu ROC plot for ROI%d.png',n));
        saveas(h_plot,sprintf('Modu ROC plot for ROI%d.fig',n));
        close(h_plot);
    end
    cd ..;
    ResultStruc.ModuAUCvalueAll = ModuAUCvalue;
    ResultStruc.ModuAUCPrefer = ModuAUCPrefer;
    ResultStruc.ModuDataMeanDispAll = ModuDataMeanDisp;
end


% function TrialTypeCom(ControlData,ModuData,FreqTypes,nROI)
% %this functin will be just used for trial type distinguish test
% %%
% if ~isdir('./Trial_Slectivity/')
%     mkdir('./Trial_Slectivity/');
% end
% cd('./Trial_Slectivity/');
% 
% % ROInum=length(ControlData);
% TrialSelectAUC=zeros(nROI,2);
% 
% for n=1:nROI
%     h_ROI=figure('position',[200 200 1400 800]);
%     CondataROIL=[];
%     ModudataROIL=[];
%     for FreqType=1:FreqTypes/2
%         CCondata=ControlData{FreqType,1};
%         CCondata=CCondata(n,:);
%         CondataROIL=[CondataROIL,CCondata];
%         
%         CModudata=ModuData{FreqType,1};
%         CModudata=CModudata(n,:);
%         ModudataROIL=[ModudataROIL,CModudata];
%     end
%     
%     CondataROIR=[];
%     ModudataROIR=[];
%     for FreqType=(FreqTypes/2+1):FreqTypes
%         CCondata=ControlData{FreqType,1};
%         CCondata=CCondata(n,:);
%         CondataROIR=[CondataROIR,CCondata];
%         
%         CModudata=ModuData{FreqType,1};
%         CModudata=CModudata(n,:);
%         ModudataROIR=[ModudataROIR,CModudata];
%     end
%     
%     subplot(1,2,2)
%     LeftMODforROC=[ModudataROIL(:),zeros(numel(ModudataROIL),1)];
%     RightMODforROC=[ModudataROIR(:),ones(numel(ModudataROIR),1)];
%     [ROCout,~]=rocOnlineHout([LeftMODforROC;RightMODforROC]);
%     TrialSelectAUC(n,2)=ROCout.AUC;
%     title(sprintf('Modu, AUC=%0.4f',ROCout.AUC));
%     
%     subplot(1,2,1)
%     LeftCONforROC=[CondataROIL(:),zeros(numel(CondataROIL),1)];
%     RightCONforROC=[CondataROIR(:),ones(numel(CondataROIR),1)];
%     [ROCout,~]=rocOnlineHout([LeftCONforROC;RightCONforROC]);
%     TrialSelectAUC(n,1)=ROCout.AUC;
%     title(sprintf('Modu, AUC=%0.4f',ROCout.AUC));
%     suptitle(sprintf('ROI%d',n));
%     
%     saveas(h_ROI,sprintf('LR Selectivity AUC ROI%d.png',n));
%     saveas(h_ROI,sprintf('LR Selectivity AUC ROI%d.fig',n));
%     close(h_ROI);
% end
% save TrialSelectiveAUC.mat TrialSelectAUC -v7.3
% cd ..