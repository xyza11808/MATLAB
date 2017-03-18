% this script is used for calculate the groupwised noise and signcal
% correlation data and then plot it against paired distance
clear
clc

% loading ROIinfo data file
[ROIinfofn,ROIinfofp,ROIinfofi] = uigetfile('*.mat','Please select the ROI position info saving file for current session');
if ~ROIinfofi
    return
else
    PosInfoData = load(fullfile(ROIinfofp,ROIinfofn));
    cd(ROIinfofp);
    ROIposCell = cellfun(@mean,PosInfoData.ROIinfoBU.ROIpos,'UniformOutput',false);
    ROIposMatrix = cell2mat(ROIposCell');
    nROIs = length(PosInfoData.ROIinfoBU.ROImask);
end
ROIEucDis = pdist(ROIposMatrix); 
ROIRealDis = ROIEucDis * (325/256);  % convert into real distance in macrometer form
ROIEucDis = ROIRealDis;
DisMatrix = squareform(ROIEucDis);

%% loading Paired signal correlation coefficient
[Coeffn,Coeffp,Coeffi] = uigetfile('SignalCorrSave.mat','Please select the signal correlation savage data');
if ~Coeffi
    return;
else
    SigCoefDataStrc = load(fullfile(Coeffp,Coeffn));
    cd(Coeffp);
    PairedSigCoefp = squareform(SigCoefDataStrc.PairedSCpvalue);
    PairedSigCoef = squareform(SigCoefDataStrc.PairedROISigcorr);
end
SCmatrixData = PairedSigCoef;

%% loading paired noise correlation coefficient 
[NCoeffn,NCoeffp,NCoeffi] = uigetfile('ROIModified_coefSaveMean.mat','Please select the noise correlation data saving file');
if ~NCoeffi
    return;
else
    NCdataStrc = load(fullfile(NCoeffp,NCoeffn));
    PairedNoiseCoef = NCdataStrc.PairedROIcorr;
    PairedNoiseCoefp = NCdataStrc.PairedNCpvalue;
end
NCmatrixData = squareform(PairedNoiseCoef);

%% loading group index for ROIs within current session
[fn,fp,fi] = uigetfile('RespGroupNCData.mat','Please select your Groupwised signal correlation data');
if ~fi
    return;
else
    RespgroupIndsPath = fullfile(fp,fn);
    GroupIndexStrc = load(RespgroupIndsPath);
    LeftROIindex = GroupIndexStrc.LeftSigROIAUCIndex;
    RightROIindex = GroupIndexStrc.RightSigROIAUCIndex;
end
LeftGroupDataStrc = struct('ROIindex',LeftROIindex,'ROISCcoef',SCmatrixData(LeftROIindex,LeftROIindex),...
    'ROINCcoef',NCmatrixData(LeftROIindex,LeftROIindex),'ROIdis',DisMatrix(LeftROIindex,LeftROIindex));
RightGroupDataStrc = struct('ROIindex',RightROIindex,'ROISCcoef',SCmatrixData(RightROIindex,RightROIindex),...
    'ROINCcoef',NCmatrixData(RightROIindex,RightROIindex),'ROIdis',DisMatrix(RightROIindex,RightROIindex));
LRGroupDataStrc = struct('ROIindex',{{LeftROIindex,RightROIindex}},'ROISCcoef',SCmatrixData(LeftROIindex,RightROIindex),...
    'ROINCcoef',NCmatrixData(LeftROIindex,RightROIindex),'ROIdis',DisMatrix(LeftROIindex,RightROIindex));

%%
% calculate the left bin data based on distance
nLeftROIs = length(LeftROIindex);
LeftCoefMask = logical(tril(ones(nLeftROIs),-1));
if ~isempty(LeftROIindex)
    LeftROIDisAll = LeftGroupDataStrc.ROIdis(LeftCoefMask);
    LeftROISCcoefAll = LeftGroupDataStrc.ROISCcoef(LeftCoefMask);
    LeftROINCcoefAll = LeftGroupDataStrc.ROINCcoef(LeftCoefMask);
end
%
nRightROIs = length(RightROIindex);
RightCoefMask = logical(tril(ones(nRightROIs),-1));
if ~isempty(RightROIindex)
    RightROIDisAll = RightGroupDataStrc.ROIdis(RightCoefMask);
    RightROISCcoefAll = RightGroupDataStrc.ROISCcoef(RightCoefMask);
    RightROINCcoefAll = RightGroupDataStrc.ROINCcoef(RightCoefMask);
end 
%
LRROIDisAll = LRGroupDataStrc.ROIdis(:);
LRROISCcoefAll = LRGroupDataStrc.ROISCcoef(:);
LRROINCcoefAll = LRGroupDataStrc.ROINCcoef(:);
%
DisMaxRange = max([max(LeftROIDisAll),max(RightROIDisAll),max(LRROIDisAll)]);
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
        LeftBinInds = (LeftROIDisAll >= DisBinRange(nBin)) & (LeftROIDisAll < DisBinRange(nBin+1));
        RightBinInds = (RightROIDisAll >= DisBinRange(nBin)) & (RightROIDisAll < DisBinRange(nBin+1));
        LRBinInds = (LRROIDisAll >= DisBinRange(nBin)) & (LRROIDisAll < DisBinRange(nBin+1));
    else
        LeftBinInds = (LeftROIDisAll >= DisBinRange(nBin)) & (LeftROIDisAll <= DisBinRange(nBin+1));
        RightBinInds = (RightROIDisAll >= DisBinRange(nBin)) & (RightROIDisAll <= DisBinRange(nBin+1));
        LRBinInds = (LRROIDisAll >= DisBinRange(nBin)) & (LRROIDisAll <= DisBinRange(nBin+1));
    end
    % left selective data
    cBinNCdataAll = LeftROINCcoefAll(LeftBinInds);
    cBinSCdataAll = LeftROISCcoefAll(LeftBinInds);
    
    if ~isempty(cBinNCdataAll)
        LeftBinNCdata(nBin,:) = [mean(cBinNCdataAll),std(cBinNCdataAll)/sqrt(length(cBinNCdataAll)),length(cBinNCdataAll)];
%     else
%         LeftBinNCdata{nBin} = [0,0,0];
    end
    if ~isempty(cBinSCdataAll)
        LeftBinSCdata(nBin,:) = [mean(cBinSCdataAll),std(cBinSCdataAll)/sqrt(length(cBinSCdataAll)),length(cBinSCdataAll)];
%     else
%         LeftBinSCdata{nBin} = [0,0,0];
    end
    % right selective data
    cBinNCdataAll = RightROINCcoefAll(RightBinInds);
    cBinSCdataAll = RightROISCcoefAll(RightBinInds);
    
    if ~isempty(cBinNCdataAll)
        RightBinNCdata(nBin,:) = [mean(cBinNCdataAll),std(cBinNCdataAll)/sqrt(length(cBinNCdataAll)),length(cBinNCdataAll)];
%     else
%         RightBinNCdata{nBin} = [0,0,0];
    end
    if ~isempty(cBinSCdataAll)
        RightBinSCdata(nBin,:) = [mean(cBinSCdataAll),std(cBinSCdataAll)/sqrt(length(cBinSCdataAll)),length(cBinSCdataAll)];
%     else
%         RightBinSCdata{nBin} = [0,0,0];
    end
    % left-vs-right selective data
    cBinNCdataAll = LRROINCcoefAll(LRBinInds);
    cBinSCdataAll = LRROISCcoefAll(LRBinInds);
    
    if ~isempty(cBinNCdataAll)
        LRBinNCdata(nBin,:) = [mean(cBinNCdataAll),std(cBinNCdataAll)/sqrt(length(cBinNCdataAll)),length(cBinNCdataAll)];
%     else
%         LRBinNCdata{nBin} = [0,0,0];
    end
    if ~isempty(cBinSCdataAll)
        LRBinSCdata(nBin,:) = [mean(cBinSCdataAll),std(cBinSCdataAll)/sqrt(length(cBinSCdataAll)),length(cBinSCdataAll)];
%     else
%         LRBinSCdata{nBin} = [0,0,0];
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
save GroupDisCoefStrc.mat LeftGroupDataStrc RightGroupDataStrc LRGroupDataStrc -v7.3

cd ..;

%% summarize multisession data together
clear
clc

addchar = 'y';
m = 1;
DataSum = {};
DataPath = {};
AllBinCenters = {};
AllNCdata = {};
AllSCdata = {};
% LeftDataSumStrc = struct('LeftBinNC',[],'LeftBinSC',[]);
% RightDataSumStrc = struct('RightBinNC',[],'RightBinSC',[]);
% LRDataSumStrc = struct('LRBinNC',[],'LRBinSC',[]);
NCdataSumStrc = struct('LeftBinData',[],'RightBinData',[],'LRBinData',[]);
SCdataSumStrc = struct('LeftBinData',[],'RightBinData',[],'LRBinData',[]);

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('GroupDisCoefLinesave.mat','Please select your Groupwised coef-dis plot data');
    if fi
        cpath = fullfile(fp,fn);
        DataPath{m} = cpath;
        cDataStrc = load(cpath);
        DataSum{m} = cDataStrc;
        
        cBincenters = cDataStrc.nBinCenters;
        AllBinCenters{m} = cBincenters;
        NCdataSumStrc(m).LeftBinData = cDataStrc.LeftBinNCdata;
        NCdataSumStrc(m).RightBinData = cDataStrc.RightBinNCdata;
        NCdataSumStrc(m).LRBinData = cDataStrc.LRBinNCdata;
        SCdataSumStrc(m).LeftBinData = cDataStrc.LeftBinSCdata;
        SCdataSumStrc(m).RightBinData = cDataStrc.RightBinSCdata;
        SCdataSumStrc(m).LRBinData = cDataStrc.LRBinSCdata;
        
        AllNCdata{m} = [cDataStrc.LeftBinNCdata(:,1),cDataStrc.RightBinNCdata(:,1),cDataStrc.LRBinNCdata(:,1)]; % Left, right and LR data, n by 3 matrix
        AllSCdata{m} = [cDataStrc.LeftBinSCdata(:,1),cDataStrc.RightBinSCdata(:,1),cDataStrc.LRBinSCdata(:,1)]; % Left, right and LR data, n by 3 matrix
        m = m + 1;
    end
    
    addchar = input('Would you like to add another session data?\n','s');
end
%%
cSavePath = uigetdir(pwd,'Please select a dir to save current analysis result');
cd(cSavePath);
fid = fopen('Group_DisCoef_line_path.txt','w');
fForm = '%s;\r\n';
fprintf(fid,'The datapath used within current analysis:\r\n');
for njnj = 1 : (m - 1)
    fprintf(fid,fForm,DataPath{njnj});
end
fclose(fid);
save cSummarySave.mat DataSum AllBinCenters AllNCdata AllSCdata -v7.3

%% data save path selection and data save
if ~exist('m','var')
    m = length(AllBinCenters);
end
nBinAll = cellfun(@length,AllBinCenters);
[MaxBinAll,maxInds] = max(nBinAll);
UseBinCenter = AllBinCenters{maxInds};
[AgnNCdataL,AgnNCdataR,AgnNCdataLR,AgnSCdataL,AgnSCdataR,AgnSCdataLR] = ...
    cellfun(@(x,y) BinAlignFun(MaxBinAll,x,y),AllNCdata,AllSCdata,'UniformOutput',false);

AgnNCdataLMtx = (cell2mat(AgnNCdataL))';
AgnNCdataRMtx = (cell2mat(AgnNCdataR))';
AgnNCdataLRMtx = (cell2mat(AgnNCdataLR))';
h_NCf = figure('position',[50 200 1000 800]);
hold on
h1 = errorbar(UseBinCenter,mean(AgnNCdataLMtx),(std(AgnNCdataLMtx)/sqrt(size(AgnNCdataLMtx,1))),'-o','Color','b','MarkerFaceColor','b','LineWidth',1.4);
h2 = errorbar(UseBinCenter,mean(AgnNCdataRMtx),(std(AgnNCdataRMtx)/sqrt(size(AgnNCdataRMtx,1))),'-o','Color','r','MarkerFaceColor','r','LineWidth',1.4);
h3 = errorbar(UseBinCenter,mean(AgnNCdataLRMtx),(std(AgnNCdataLRMtx)/sqrt(size(AgnNCdataLRMtx,1))),'-o','Color','k','MarkerFaceColor','k','LineWidth',1.4);
xlabel('Pair Distance (um)');
ylabel('Correlation Value');
title({'Noise correlation vs paired distance',sprintf('n = %d',m - 1)});
set(gca,'FontSize',18);
legend([h1,h2,h3],{'LeftNC','RightNC','LRNC'},'FontSize',12);
saveas(h_NCf,'Summary Groupwised DisNC line plot');
saveas(h_NCf,'Summary Groupwised DisNC line plot','png');
close(h_NCf);

AgnSCdataLMtx = (cell2mat(AgnSCdataL))';
AgnSCdataRMtx = (cell2mat(AgnSCdataR))';
AgnSCdataLRMtx = (cell2mat(AgnSCdataLR))';
h_SCf = figure('position',[50 200 1000 800]);
hold on
h1 = errorbar(UseBinCenter,mean(AgnSCdataLMtx),(std(AgnSCdataLMtx)/sqrt(size(AgnSCdataLMtx,1))),'-o','Color','b','MarkerFaceColor','b','LineWidth',1.4);
h2 = errorbar(UseBinCenter,mean(AgnSCdataRMtx),(std(AgnSCdataRMtx)/sqrt(size(AgnSCdataRMtx,1))),'-o','Color','r','MarkerFaceColor','r','LineWidth',1.4);
h3 = errorbar(UseBinCenter,mean(AgnSCdataLRMtx),(std(AgnSCdataLRMtx)/sqrt(size(AgnSCdataLRMtx,1))),'-o','Color','k','MarkerFaceColor','k','LineWidth',1.4);
xlabel('Pair Distance (um)');
ylabel('Correlation Value');
title({'Signal correlation vs paired distance',sprintf('n = %d',m - 1)});
set(gca,'FontSize',18);
legend([h1,h2,h3],{'LeftSC','RightSC','LRSC'},'FontSize',12);
saveas(h_SCf,'Summary Groupwised DisSC line plot');
saveas(h_SCf,'Summary Groupwised DisSC line plot','png');
close(h_SCf);
