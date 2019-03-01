cclr
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file'); 
if ~fi
    return; 
end 
fPath = fullfile(fp,fn); 
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessType = 0;
SessPathAll = {};
m = 1;
while ischar(tline)
    if ~isempty(strfind(tline,'######')) % new section flag
        SessType = SessType + 1;
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        SessPathAll{m,2} = SessType;
        
        [~,EndInds] = regexp(tline,'test\d{2,3}');
        cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');

        [~,InfoDataEndInds] = regexp(tline,'result_save');
        PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
        SessPathAll{m,3} = PassPathline;
         
        m = m + 1;
    end
    tline = fgetl(fid);
end
SessIndexAll = cell2mat(SessPathAll(:,2));
%% processing 8k-32k and 4k-16k sessions data
Sess8_32_Inds = SessIndexAll == 4;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);
Sess8_32PassPath = SessPathAll(Sess8_32_Inds,3);

Sess4_16_Part1_Inds = SessIndexAll == 3;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);
Sess4_16PassPath = SessPathAll(Sess4_16_Part1_Inds,3);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%
NumPaths = length(Sess4_16_Part1_PathAll);
%%
AllROITuns = cell(NumPaths,2);
OverlapROITuns = cell(NumPaths,2);
PeakPosShiftSum = zeros(NumPaths,10);
OLPFreq_fracSummry = cell(NumPaths,8);
NorTunDataAlls = cell(NumPaths,8);
OverLapCoefMtxAll = cell(NumPaths,7);
SavePath = 'E:\DataToGo\NewDataForXU\Tuning_distribution\Sess716BFDis';
if ~isdir(SavePath)
    mkdir(SavePath);
end
%%
for cPath = 1 : NumPaths
    %
%     cPath = 7;
    c832Path = Sess8_32PathAll{cPath};
    c832PassPath = Sess8_32PassPath{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    c416PassPath = Sess4_16PassPath{cPath};
    
    cSess832Path = fullfile(c832Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess832TunData = load(cSess832Path);
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416TunData = load(cSess416Path);
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    try
        Sess832ROITunDataStrc = load(fullfile(c832Path,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun','PassTunningfun');
        Sess416ROITunDataStrc = load(fullfile(c416Path,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun','PassTunningfun');
    catch
        Sess832ROITunDataStrc = load(fullfile(c832Path,'Tunning_fun_plot_New1s','TunningDataSave.mat'),'CorrTunningFun','PassTunningfun');
        Sess416ROITunDataStrc = load(fullfile(c416Path,'Tunning_fun_plot_New1s','TunningDataSave.mat'),'CorrTunningFun','PassTunningfun');
    end
    Sess832SigROITunInds = (max(Sess832ROITunDataStrc.CorrTunningFun) > 10)';
    Sess416SigROITunInds = (max(Sess416ROITunDataStrc.CorrTunningFun) > 10)';
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    Sess416BehavStrc = load(fullfile(c416Path,'RandP_data_plots','boundary_result.mat'));
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
%     CommonROIIndex = CommonROIIndex & Sess832SigROITunInds(1:CommonROINum) & Sess416SigROITunInds(1:CommonROINum);
    Sess832ROITunDatas = Sess832ROITunDataStrc.CorrTunningFun(:,CommonROIIndex);
    Sess416ROITunDatas = Sess416ROITunDataStrc.CorrTunningFun(:,CommonROIIndex);
    Sess832ROIPassTunDatas = Sess832ROITunDataStrc.PassTunningfun(:,CommonROIIndex);
    Sess416ROIPassTunDatas = Sess416ROITunDataStrc.PassTunningfun(:,CommonROIIndex);
    
    % considering single neuron representation of frequency is significant
%     % or not
%     c832TaskCoefMtx = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
%     c832PassCoefMtx = load(fullfile(c832PassPath,'PassCoefMtxSave.mat'));
%     c416TaskCoefMtx = load(fullfile(c416Path,'SigSelectiveROIInds.mat'));
%     c416PassCoefMtx = load(fullfile(c416PassPath,'PassCoefMtxSave.mat'));
%     
%     c832TPRespROIs = [c832TaskCoefMtx.SigROIInds(:);c832PassCoefMtx.PassRespROIInds(:)];
%     c416TPRespROIs = [c416TaskCoefMtx.SigROIInds(:);c416PassCoefMtx.PassRespROIInds(:)];
%     Base832RespROIs = false(size(cSess832DataStrc.ROIIndex));
%     Base832RespROIs(c832TPRespROIs) = true;
%     Base416RespROIs = false(size(cSess416DataStrc.ROIIndex));
%     Base416RespROIs(c416TPRespROIs) = true;
%     EitherRespROIs = Base832RespROIs(1:CommonROINum) | Base416RespROIs(1:CommonROINum);
%     CommonROIIndex(~EitherRespROIs) = false;
    
    %
    c832FreqsTypes = Sess832BehavStrc.boundary_result.StimType;
    nFreqsc832 = length(c832FreqsTypes);
    CommonOctRange832 = log2(c832FreqsTypes/4000);  % octave within the 4k and 32k range
    c832ROIs = numel(cSess832DataStrc.ROIIndex);
    
    Freqs416Types = Sess416BehavStrc.boundary_result.StimType;
    nFreqs = length(Freqs416Types);
    CommonOctRange416 = log2(Freqs416Types/4000);  % octave within the 4k and 32k range
    c416ROIs = numel(cSess416DataStrc.ROIIndex);
    
    c832FreqOctaveRange = CommonOctRange832([1,end]);
    c416FreqOctaveRange = CommonOctRange416([1,end]);
    SharedOctRange = [max(c832FreqOctaveRange(1),c416FreqOctaveRange(1)),...
        min(c832FreqOctaveRange(2),c416FreqOctaveRange(2))];
    
    c832WithinShareInds = CommonOctRange832 >= SharedOctRange(1) & CommonOctRange832 <= SharedOctRange(2)+0.01;
    c416WithinShareInds = CommonOctRange416 >= SharedOctRange(1) & CommonOctRange416 <= SharedOctRange(2)+0.01;
    
    c832WithinShareOcts = CommonOctRange832(c832WithinShareInds);
    c416WithinShareOcts = CommonOctRange416(c416WithinShareInds);
    
    c832CommonROITuns = cSess832TunData.TaskMaxOct(CommonROIIndex) + 1 + log2(c832FreqsTypes(1)/4000);
    c416CommonROITuns = cSess416TunData.TaskMaxOct(CommonROIIndex) + 1 + log2(Freqs416Types(1)/4000);
    c832CommonROIPassTuns = cSess832TunData.PassMaxOct(CommonROIIndex) + 1 + log2(c832FreqsTypes(1)/4000);
    c416CommonROIPassTuns = cSess416TunData.PassMaxOct(CommonROIIndex) + 1 + log2(Freqs416Types(1)/4000);
    %
    c832UsedInds = false(numel(c832CommonROITuns),1);
    for cR = 1 : length(c832WithinShareOcts)
        cRTunInds = abs(c832CommonROITuns - c832WithinShareOcts(cR)) < 1e-3;
        c832UsedInds(cRTunInds) = true;
    end
    c416UsedInds = false(numel(c416CommonROITuns),1);
    for cR = 1 : length(c416WithinShareOcts)
        cRTunInds = abs(c416CommonROITuns - c416WithinShareOcts(cR)) < 1e-3;
        c416UsedInds(cRTunInds) = true;
    end
    %
    c832Edges = [-0.1,0.2,0.6,0.85,1,1.15,1.4,1.8,2.1] + log2(c832FreqsTypes(1)/4000);
    c416Edges = [-0.1,0.2,0.6,0.85,1,1.15,1.4,1.8,2.1] + log2(Freqs416Types(1)/4000);
    c832Bins = [0,0.4,0.8,0.9,1.1,1.2,1.6,2] + log2(c832FreqsTypes(1)/4000);
    c416Bins = [0,0.4,0.8,0.9,1.1,1.2,1.6,2] + log2(Freqs416Types(1)/4000);
    Bounds = [log2(Freqs416Types(1)/4000), log2(c832FreqsTypes(1)/4000)] + 1;
    BehavBound = [Sess832BehavStrc.boundary_result.Boundary + log2(c832FreqsTypes(1)/4000),...
        Sess416BehavStrc.boundary_result.Boundary + log2(Freqs416Types(1)/4000)];
    
    NorTunDataAlls(cPath,:) = {Sess832ROITunDatas(c832WithinShareInds,:), Sess416ROITunDatas(c416WithinShareInds,:),...
        Sess832ROIPassTunDatas(c832WithinShareInds,:), Sess416ROIPassTunDatas(c416WithinShareInds,:),...
        c832WithinShareOcts,c416WithinShareOcts,BehavBound(1),BehavBound(2)};
    if sum(c832WithinShareInds) ~= sum(c416WithinShareInds)
        NorTunDataAlls{cPath,1}(sum(c832WithinShareInds)-1,:) = [];
        NorTunDataAlls{cPath,3}(sum(c832WithinShareInds)-1,:) = [];
        NorTunDataAlls{cPath,5}(sum(c832WithinShareInds)-1) = [];
    end
    %
    SharedOctRange = [max(c832Bins(1),c416Bins(1)),...
        min(c832Bins(end),c416Bins(end))];
%     SharedOctRange = [-0.1,3.5]; 
    c832WithinShareInds = c832Bins >= SharedOctRange(1) & c832Bins <= SharedOctRange(2);
    c416WithinShareInds = c416Bins >= SharedOctRange(1) & c416Bins <= SharedOctRange(2);
    
    c832OLP_TunDisN = histcounts(c832CommonROITuns,c832Edges);
    c832OLP_TunDisNPass = histcounts(c832CommonROIPassTuns,c832Edges);
    c832OLP_Octs = c832Bins;
%     zerosComInds = c832OLP_TunDisN == 0 & c832OLP_TunDisNPass == 0;
%     c832OLP_TunDisN = c832OLP_TunDisN(~zerosComInds);
%     c832WithinShareInds(zerosComInds) = [];
%     c832OLP_TunDisNPass = c832OLP_TunDisNPass(~zerosComInds);
%     c832OLP_Octs = c832OLP_Octs(~zerosComInds);
    
    c416OLP_TunDisN = histcounts(c416CommonROITuns,c416Edges);
    c416OLP_TunDisNPass = histcounts(c416CommonROIPassTuns,c416Edges);
    c416OLP_Octs = c416Bins;
    
    c832WSTaskDis = c832OLP_TunDisN(c832WithinShareInds);
    c832WSPassDis = c832OLP_TunDisNPass(c832WithinShareInds);
    c832WSOcts = c832OLP_Octs(c832WithinShareInds);
    c832FracDiffs = c832WSTaskDis - c832WSPassDis;
    
    [~,c832WSTPeakInds] = max(c832WSTaskDis);
    [~,c832WSPPeakInds] = max(c832WSPassDis);
    [~,c832DiffPeakInds] = max(c832FracDiffs);
    c832WSTPeakPos = c832WSOcts(c832WSTPeakInds);
    c832WSPPeakPos = c832WSOcts(c832WSPPeakInds);
    c832DiffPeakPos = c832WSOcts(c832DiffPeakInds);
    
    c416WSTaskDis = c416OLP_TunDisN(c416WithinShareInds);
    c416WSPassDis = c416OLP_TunDisNPass(c416WithinShareInds);
    c416WSOcts = c416OLP_Octs(c416WithinShareInds);
    c416FracDiff = c416WSTaskDis - c416WSPassDis;
    
    [~,c416WSTPeakInds] = max(c416WSTaskDis);
    [~,c416WSPPeakInds] = max(c416WSPassDis);
    [~,c416DiffPeakInds] = max(c416FracDiff);
    c416WSTPeakPos = c416WSOcts(c416WSTPeakInds);
    c416WSPPeakPos = c416WSOcts(c416WSPPeakInds);
    c416DiffPeakPos = c416WSOcts(c416DiffPeakInds);
    
    PeakPosShiftSum(cPath,:) = [c832WSTPeakPos,c832WSPPeakPos,Bounds(2),BehavBound(1),...
        c416WSTPeakPos,c416WSPPeakPos,Bounds(1),BehavBound(2),c832DiffPeakPos,c416DiffPeakPos];
    
    OLPFreq_fracSummry{cPath,1} = (c832WSTaskDis - c832WSPassDis)/numel(c832CommonROITuns);
    OLPFreq_fracSummry{cPath,2} = (c416WSTaskDis - c416WSPassDis)/numel(c416CommonROITuns);
    
    
    OLPFreq_fracSummry{cPath,3} = c832WSOcts;
    OLPFreq_fracSummry{cPath,4} = c416WSOcts;
    OLPFreq_fracSummry{cPath,5} = BehavBound(1);
    OLPFreq_fracSummry{cPath,6} = BehavBound(2);
    OLPFreq_fracSummry{cPath,7} = c832WSTaskDis/numel(c832CommonROITuns);
    OLPFreq_fracSummry{cPath,8} = c416WSTaskDis/numel(c416CommonROITuns);
    OLPFreq_fracSummry{cPath,9} = c832WSPassDis/numel(c832CommonROITuns);
    OLPFreq_fracSummry{cPath,10} = c416WSPassDis/numel(c416CommonROITuns);
    
    %
%     if size(c832TaskCoefMtx.SigROICoefMtx,2) < numel(c832WithinShareInds)
%         % session bin edges is larger than real frequency number
%         NumBins = numel(c832WithinShareInds);
%         WithinUsedInds = true(NumBins,1);
%         WithinUsedInds(ceil(NumBins/2):(floor(NumBins/2)+1)) = false;
%     else
%         WithinUsedInds = true(numel(c832WithinShareInds),1);
%     end
%     
%     c832BaseCoefMtx = zeros(numel(cSess832DataStrc.ROIIndex),sum(c832WithinShareInds));
%     c832TaskOverlapCoef = c832BaseCoefMtx;
%     c832TaskOverlapCoef(c832TaskCoefMtx.SigROIInds,WithinUsedInds) = c832TaskCoefMtx.SigROICoefMtx(:,c832WithinShareInds(WithinUsedInds));
%     c832TaskOverlapCoef(~CommonROIIndex,:) = 0;
%     
%     c832PassOverlapCoef = c832BaseCoefMtx;
%     c832PassOverlapCoef(c832PassCoefMtx.PassRespROIInds,WithinUsedInds) = c832PassCoefMtx.PassRespCoefMtx(:,c832WithinShareInds(WithinUsedInds));
%     c832PassOverlapCoef(~CommonROIIndex,:) = 0;
%     
%     if size(c416TaskCoefMtx.SigROICoefMtx,2) < numel(c416WithinShareInds)
%         % session bin edges is larger than real frequency number
%         NumBins = numel(c416WithinShareInds);
%         WithinUsedInds416 = true(NumBins,1);
%         WithinUsedInds416(ceil(NumBins/2):(floor(NumBins/2)+1)) = false;
%     else
%         WithinUsedInds416 = true(numel(c416WithinShareInds),1);
%     end
%     c416BaseCoefMtx = zeros(numel(cSess416DataStrc.ROIIndex),sum(c416WithinShareInds));
%     c416TaskOverlapCoef = c416BaseCoefMtx;
%     c416TaskOverlapCoef(c416TaskCoefMtx.SigROIInds,WithinUsedInds416) = c416TaskCoefMtx.SigROICoefMtx(:,c416WithinShareInds(WithinUsedInds416));
%     c416TaskOverlapCoef(~CommonROIIndex,:) = 0;
%     
%     c416PassOverlapCoef = c416BaseCoefMtx;
%     c416PassOverlapCoef(c416PassCoefMtx.PassRespROIInds,WithinUsedInds416) = c416PassCoefMtx.PassRespCoefMtx(:,c416WithinShareInds(WithinUsedInds416));
%     c416PassOverlapCoef(~CommonROIIndex,:) = 0;
%     
%     c832OverlapOcts = c832OLP_Octs(c832WithinShareInds);
%     c416OverlapOcts = c416OLP_Octs(c416WithinShareInds);
%     
%     OverLapCoefMtxAll(cPath,:) = {c832TaskOverlapCoef,c832PassOverlapCoef,c416TaskOverlapCoef,c416PassOverlapCoef,c832OverlapOcts,...
%         c416OverlapOcts,BehavBound};

% % % %     %%
% % % %     hcf = figure('position',[100 100 650 240]);
% % % %     subplot(1,2,1)
% % % %     hold on
% % % % %     plot(c832OLP_Octs,c832OLP_TunDisN,'r-o','linewidth',1.4);
% % % % %     plot(c832OLP_Octs,c832OLP_TunDisNPass,'-o','linewidth',1.4,'Color',[0.8 0.3 0.3],'linestyle','--');
% % % % %     plot(c416OLP_Octs,c416OLP_TunDisN,'b-o','linewidth',1.4);
% % % % %     plot(c416OLP_Octs,c416OLP_TunDisNPass,'-o','linewidth',1.4,'Color',[0.3 0.3 0.8],'linestyle','--');
% % % %     plot(c832OLP_Octs(c832WithinShareInds),c832OLP_TunDisN(c832WithinShareInds),'r-o','linewidth',1.4);
% % % %     plot(c832OLP_Octs(c832WithinShareInds),c832OLP_TunDisNPass(c832WithinShareInds),'-o','linewidth',1.4,'Color',[0.8 0.3 0.3],'linestyle','--');
% % % %     plot(c416OLP_Octs(c416WithinShareInds),c416OLP_TunDisN(c416WithinShareInds),'b-o','linewidth',1.4);
% % % %     plot(c416OLP_Octs(c416WithinShareInds),c416OLP_TunDisNPass(c416WithinShareInds),'-o','linewidth',1.4,'Color',[0.3 0.3 0.8],'linestyle','--');
% % % %     xlim([0 3])
% % % %     yscales = get(gca,'ylim');
% % % %     line([BehavBound(1) BehavBound(1)],yscales,'Color','r','linestyle','--');
% % % %     line([BehavBound(2) BehavBound(2)],yscales,'Color','b','linestyle','--');
% % % %     title(sprintf('Session %d plots',cPath));
% % % %     
% % % %     subplot(1,2,2)
% % % %     hold on
% % % %     plot(c832WSOcts,OLPFreq_fracSummry{cPath,1},'r-o','linewidth',1.4);
% % % %     plot(c416WSOcts,OLPFreq_fracSummry{cPath,2},'b-o','linewidth',1.4);
% % % %     yscales = get(gca,'ylim');
% % % %     line([BehavBound(1) BehavBound(1)],yscales,'Color','r','linestyle','--');
% % % %     line([BehavBound(2) BehavBound(2)],yscales,'Color','b','linestyle','--');
% % % %     set(gca,'xlim',[0 3]);
% % % %     title('Task Passive Frac diff');
% % % %     %
% % % %     saveas(hcf,fullfile(SavePath,sprintf('Sess%d BF distribution plots save',cPath)));
% % % %     saveas(hcf,fullfile(SavePath,sprintf('Sess%d BF distribution plots save',cPath)),'png');
% % % %     close(hcf);
% % % %     %%
    c832WSOctDistribution = c832CommonROITuns(c832UsedInds);
    c416WSOctDistribution = c416CommonROITuns(c416UsedInds);
    
    c832WSPassOcts = c832CommonROIPassTuns(c832UsedInds);
    c416WSPassOcts = c416CommonROIPassTuns(c416UsedInds);
    
    AllROITuns{cPath,1} = c832CommonROITuns(:);
    AllROITuns{cPath,2} = c416CommonROITuns(:);
    AllROITuns{cPath,3} = c832CommonROIPassTuns(:);
    AllROITuns{cPath,4} = c416CommonROIPassTuns(:);
    
    OverlapROITuns{cPath,1} = c832WSOctDistribution(:);
    OverlapROITuns{cPath,2} = c416WSOctDistribution(:);
    OverlapROITuns{cPath,3} = c832WSPassOcts(:);
    OverlapROITuns{cPath,4} = c416WSPassOcts(:);
    %
end

%%

AllTuningMtx = cell2mat(AllROITuns);
Overlap832TunMtx = cell2mat(OverlapROITuns(:,[1,3]));
Overlap416TunMtx = cell2mat(OverlapROITuns(:,[2,4]));
%%
c832Edges = [-0.1,0.2,0.6,0.85,1,1.15,1.4,1.8,2.1] + log2(c832FreqsTypes(1)/4000);
c416Edges = [-0.1,0.2,0.6,0.85,1,1.15,1.4,1.8,2.1] + log2(Freqs416Types(1)/4000);
c832Bins = [0,0.4,0.8,0.9,1.1,1.2,1.6,2] + log2(c832FreqsTypes(1)/4000);
c416Bins = [0,0.4,0.8,0.9,1.1,1.2,1.6,2] + log2(Freqs416Types(1)/4000);
Bounds = [log2(Freqs416Types(1)/4000), log2(c832FreqsTypes(1)/4000)] + 1;

c832OLP_TunDisN = histcounts(Overlap832TunMtx(:,1),c832Edges);
c832OLP_TunDisNPass = histcounts(Overlap832TunMtx(:,2),c832Edges);
c832OLP_Octs = c832Bins;

c416OLP_TunDisN = histcounts(Overlap416TunMtx(:,1),c416Edges);
c416OLP_TunDisNPass = histcounts(Overlap416TunMtx(:,2),c416Edges);
c416OLP_Octs = c416Bins;

%%
c832OLP_TunDisNFrac = c832OLP_TunDisN / sum(c832OLP_TunDisN);
c832OLP_TunDisNPFrac = c832OLP_TunDisNPass/ sum(c832OLP_TunDisNPass);

c416OLP_TunDisNFrac = c416OLP_TunDisN / sum(c416OLP_TunDisN);
c416OLP_TunDisNPFrac = c416OLP_TunDisNPass / sum(c416OLP_TunDisNPass);

hf = figure('position',[100 100 380 280]);
hold on
plot(c832OLP_Octs(c832WithinShareInds),c832OLP_TunDisNFrac(c832WithinShareInds),'r-o','linewidth',1.4);
% plot(c832OLP_Octs(c832WithinShareInds),c832OLP_TunDisNPFrac(c832WithinShareInds),'-o','linewidth',1.4,'Color',[0.7 0.3 0.3]);
plot(c416OLP_Octs(c416WithinShareInds),c416OLP_TunDisNFrac(c416WithinShareInds),'b-o','linewidth',1.4);
% plot(c416OLP_Octs(c416WithinShareInds),c416OLP_TunDisNPFrac(c416WithinShareInds),'-o','linewidth',1.4,'Color',[0.3 0.3 0.7]);
yscales = get(gca,'ylim');
line([Bounds(1) Bounds(1)],yscales,'Color','b','linestyle','--');
line([Bounds(2) Bounds(2)],yscales,'Color','r','linestyle','--');
set(gca,'xlim',[-0.1 3.1],'xtick',0:3,'xticklabel',[4 8 16 32]);

%% plot the difference plots

c832_TunDisN = histcounts(AllTuningMtx(:,1),c832Edges);
c832_TunDisNPass = histcounts(AllTuningMtx(:,3),c832Edges);
c832_TunDiffFrac = (c832_TunDisN - c832_TunDisNPass) / sum(c832_TunDisN); 

c416_TunDisN = histcounts(AllTuningMtx(:,2),c416Edges);
c416_TunDisNPass = histcounts(AllTuningMtx(:,4),c416Edges);
c416_TunDiffFrac = (c416_TunDisN - c416_TunDisNPass) / sum(c416_TunDisN);

hf = figure('position',[100 100 380 280]);
hold on
plot(c832OLP_Octs(c832WithinShareInds),c832_TunDiffFrac(c832WithinShareInds),'r-o','linewidth',1.4);
% plot(c832OLP_Octs(c832WithinShareInds),c832OLP_TunDisNPFrac(c832WithinShareInds),'-o','linewidth',1.4,'Color',[0.7 0.3 0.3]);
plot(c416OLP_Octs(c416WithinShareInds),c416_TunDiffFrac(c416WithinShareInds),'b-o','linewidth',1.4);
% plot(c416OLP_Octs(c416WithinShareInds),c416OLP_TunDisNPFrac(c416WithinShareInds),'-o','linewidth',1.4,'Color',[0.3 0.3 0.7]);
yscales = get(gca,'ylim');
line([Bounds(1) Bounds(1)],yscales,'Color','b','linestyle','--');
line([Bounds(2) Bounds(2)],yscales,'Color','r','linestyle','--');
set(gca,'xlim',[-0.1 3.1],'xtick',0:3,'xticklabel',[4 8 16 32]);

%%

saveas(gcf,'8-32 Task fraction plot save');
saveas(gcf,'8-32 Task fraction plot save','png');

%%
SumSavePath = 'E:\DataToGo\NewDataForXU\Tuning_distribution';
c832_2HB_LB_Dis = [abs(PeakPosShiftSum(:,1) - PeakPosShiftSum(:,4)),abs(PeakPosShiftSum(:,1) - PeakPosShiftSum(:,8))];
c416_2HB_LB_Dis = [abs(PeakPosShiftSum(:,5) - PeakPosShiftSum(:,4)),abs(PeakPosShiftSum(:,5) - PeakPosShiftSum(:,8))];

% hPDisf = FourColDataPlots([c832_2HB_LB_Dis,c416_2HB_LB_Dis],{'832T2HB','832T2LB','416T2HB','416T2LB'},{'r','k','b','k'});
hPDisf = FourColDataPlots([c832_2HB_LB_Dis,c416_2HB_LB_Dis],{'832T2HB','832T2LB','416T2HB','416T2LB'},{'r','k','b','k'});
ylabel('Distance (Oct.)')
[~,p_12] = ttest(c832_2HB_LB_Dis(:,1),c832_2HB_LB_Dis(:,2));
GroupSigIndication([1,2],max(c832_2HB_LB_Dis),p_12,hPDisf);
[~,p_34] = ttest(c416_2HB_LB_Dis(:,1),c416_2HB_LB_Dis(:,2));
GroupSigIndication([3,4],max(c416_2HB_LB_Dis),p_34,hPDisf);
title('Session 832')

% saveas(hPDisf,fullfile(SumSavePath,'Peak distance compare832 between task and pass'));
% saveas(hPDisf,fullfile(SumSavePath,'Peak distance compare832 between task and pass'),'png');
%%
save(fullfile(SumSavePath,'Sess832DataSummary.mat'),'PeakPosShiftSum','OLPFreq_fracSummry','-v7.3');
%% examinate session fraction diff for each session
SumSavePath = 'E:\DataToGo\NewDataForXU\Tuning_distribution';

c728SessFracDiffMtx = cell2mat(OLPFreq_fracSummry(:,1));
c416SessFracDiffMtx = cell2mat(OLPFreq_fracSummry(:,2));
c728SessBehavBound = cell2mat(OLPFreq_fracSummry(:,5));
c416SessBehavBound = cell2mat(OLPFreq_fracSummry(:,6));

c728SessFracDiffAvg = mean(c728SessFracDiffMtx);
c416SessFracDiffAvg = mean(c416SessFracDiffMtx);
c728SessFracDiffSem = std(c728SessFracDiffMtx)/sqrt(NumPaths);
c416SessFracDiffSem = std(c416SessFracDiffMtx)/sqrt(NumPaths);
c728SessOcts = OLPFreq_fracSummry{:,3};
c416SessOcts = OLPFreq_fracSummry{:,4};

hf = figure('position',[100 100 380 280]);
hold on
errorbar(c728SessOcts,c728SessFracDiffAvg,c728SessFracDiffSem,'r-o','linewidth',1.4);
errorbar(c416SessOcts,c416SessFracDiffAvg,c416SessFracDiffSem,'b-o','linewidth',1.4);
yscales = get(gca,'ylim');
line([mean(c416SessBehavBound) mean(c416SessBehavBound)],yscales,'Color','b','linestyle','--');
line([mean(c728SessBehavBound) mean(c728SessBehavBound)],yscales,'Color','r','linestyle','--');
title(sprintf('Session FracDiff, n = %d',NumPaths))
set(gca,'xlim',[0 3]);

% saveas(hf,fullfile(SumSavePath,'Sess832 fraction diff summary plots'));
% saveas(hf,fullfile(SumSavePath,'Sess832 fraction diff summary plots'),'png');
% saveas(hf,fullfile(SumSavePath,'Sess832 fraction diff summary plots'),'pdf');

%% examinate session fraction change for each task session
SumSavePath = 'E:\DataToGo\NewDataForXU\Tuning_distribution';

c728SessFracDiffMtx = cell2mat(OLPFreq_fracSummry(:,7));
c416SessFracDiffMtx = cell2mat(OLPFreq_fracSummry(:,8));
c728SessBehavBound = cell2mat(OLPFreq_fracSummry(:,5));
c416SessBehavBound = cell2mat(OLPFreq_fracSummry(:,6));

c728SessFracDiffAvg = mean(c728SessFracDiffMtx);
c416SessFracDiffAvg = mean(c416SessFracDiffMtx);
c728SessFracDiffSem = std(c728SessFracDiffMtx)/sqrt(NumPaths);
c416SessFracDiffSem = std(c416SessFracDiffMtx)/sqrt(NumPaths);
c728SessOcts = OLPFreq_fracSummry{:,3};
c416SessOcts = OLPFreq_fracSummry{:,4};

hf = figure('position',[100 100 380 280]);
hold on
errorbar(c728SessOcts,c728SessFracDiffAvg,c728SessFracDiffSem,'r-o','linewidth',1.4);
errorbar(c416SessOcts,c416SessFracDiffAvg,c416SessFracDiffSem,'b-o','linewidth',1.4);
yscales = get(gca,'ylim');
line([mean(c416SessBehavBound) mean(c416SessBehavBound)],yscales,'Color','b','linestyle','--');
line([mean(c728SessBehavBound) mean(c728SessBehavBound)],yscales,'Color','r','linestyle','--');
title(sprintf('Session Task, n = %d',NumPaths))
set(gca,'xlim',[0 3]);

% saveas(hf,fullfile(SumSavePath,'Sess832 fraction summary plots'));
% saveas(hf,fullfile(SumSavePath,'Sess832 fraction summary plots'),'png');
% saveas(hf,fullfile(SumSavePath,'Sess832 fraction summary plots'),'pdf');

%
%% examinate session fraction change for each passive session
SumSavePath = 'E:\DataToGo\NewDataForXU\Tuning_distribution';

c728SessFracDiffMtx = cell2mat(OLPFreq_fracSummry(:,9));
c416SessFracDiffMtx = cell2mat(OLPFreq_fracSummry(:,10));
c728SessBehavBound = cell2mat(OLPFreq_fracSummry(:,5));
c416SessBehavBound = cell2mat(OLPFreq_fracSummry(:,6));

c728SessFracDiffAvg = mean(c728SessFracDiffMtx);
c416SessFracDiffAvg = mean(c416SessFracDiffMtx);
c728SessFracDiffSem = std(c728SessFracDiffMtx)/sqrt(NumPaths);
c416SessFracDiffSem = std(c416SessFracDiffMtx)/sqrt(NumPaths);
c728SessOcts = OLPFreq_fracSummry{:,3};
c416SessOcts = OLPFreq_fracSummry{:,4};

hf = figure('position',[100 100 380 280]);
hold on
errorbar(c728SessOcts,c728SessFracDiffAvg,c728SessFracDiffSem,'r-o','linewidth',1.4);
errorbar(c416SessOcts,c416SessFracDiffAvg,c416SessFracDiffSem,'b-o','linewidth',1.4);
yscales = get(gca,'ylim');
line([mean(c416SessBehavBound) mean(c416SessBehavBound)],yscales,'Color','b','linestyle','--');
line([mean(c728SessBehavBound) mean(c728SessBehavBound)],yscales,'Color','r','linestyle','--');
title(sprintf('Passive session, n = %d',NumPaths))
set(gca,'xlim',[0 3]);
%%
saveas(hf,fullfile(SumSavePath,'Sess832 Passive fraction summary plots'));
saveas(hf,fullfile(SumSavePath,'Sess832 Passive fraction summary plots'),'png');
saveas(hf,fullfile(SumSavePath,'Sess832 Passive fraction summary plots'),'pdf');

%% calculate the peak distance between two freq ranges
c728PeakPosShiftSum = PeakPosShiftSum;
c728TaskPeakDis = c728PeakPosShiftSum(:,1) - c728PeakPosShiftSum(:,5);
c728PassPeakDis = c728PeakPosShiftSum(:,2) - c728PeakPosShiftSum(:,6);
c728TaskBoundaryDis = c728PeakPosShiftSum(:,4) - c728PeakPosShiftSum(:,8);

% c832TaskPeakDis = c832PeakPosShiftSum(:,1) - c832PeakPosShiftSum(:,5);
% c832PassPeakDis = c832PeakPosShiftSum(:,2) - c832PeakPosShiftSum(:,6);
% c832TaskBoundaryDis = c832PeakPosShiftSum(:,4) - c832PeakPosShiftSum(:,8);
%
% hf = GrdistPlot([c728TaskPeakDis,c728PassPeakDis,c728TaskBoundaryDis,c832TaskPeakDis,c832PassPeakDis,...
%     c832TaskBoundaryDis],{'716Task','716Pass','716Bound','816Task','816Pass','816Bound'});

% TaskDataAll = [c728TaskPeakDis;c832TaskPeakDis];
% PassDataAll = [c728PassPeakDis;c832PassPeakDis];
% BoundDisAll = [c728TaskBoundaryDis;c832TaskBoundaryDis];
TaskDataAll = [c728TaskPeakDis]; %; c728TaskPeakDis
PassDataAll = [c728PassPeakDis]; %; c728PassPeakDis 
BoundDisAll = [c728TaskBoundaryDis]; %;c728TaskBoundaryDis

[~,TaskP] = ttest(TaskDataAll);
[~,PassP] = ttest(PassDataAll);
% TPDisAvg = mean([TaskDataAll,PassDataAll,BoundDisAll]);
% TPDisSEM = std([TaskDataAll,PassDataAll,BoundDisAll])/sqrt(numel(TaskDataAll));
TPDisAvg = mean([TaskDataAll,PassDataAll]);
TPDisSEM = std([TaskDataAll,PassDataAll])/sqrt(numel(TaskDataAll));
hSumf = figure('position',[2000 100 380 300]);
hold on
bar(1,TPDisAvg(1),0.4,'FaceColor',[1 0.7 0.2],'EdgeColor','none');
bar(2,TPDisAvg(2),0.4,'FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
if length(TPDisAvg) > 2
    bar(3,TPDisAvg(3),0.4,'FaceColor','k','EdgeColor','none');
end
plot([1 2],([TaskDataAll,PassDataAll])','Color',[.4 .4 .4],'linewidth',0.6);
% errorbar(1:length(TPDisAvg),TPDisAvg,TPDisSEM,'.','Color','k','linewidth',2,'Marker','none','CapSize',1);
text([1 2],TPDisAvg(1:2),{sprintf('%.4f',TaskP),sprintf('%.4f',PassP)});
xlim([0.5 length(TPDisAvg) + 0.5]);
set(gca,'xtick',1:length(TPDisAvg),'xticklabel',{'Task','Pass','Bound'});
ylabel('Distance (octave)');
set(gca,'FontSize',12);
[~,pTP] = ttest(TaskDataAll,PassDataAll);
GroupSigIndication([1,2],max([TaskDataAll,PassDataAll]),pTP,hSumf);
if length(TPDisAvg) > 2
    [~,pTB] = ttest(TaskDataAll,BoundDisAll);
    GroupSigIndication([1,3],TPDisAvg([1,3])+TPDisSEM([1,3]),pTB,hSumf);
end
% set(gca,'ylim',[-0.5 1],'ytick',[-0.5,0,0.5,1])

% SumSavePath = 'E:\DataToGo\NewDataForXU\Tuning_distribution';
% saveas(hSumf,fullfile(SumSavePath,'Tuning peak distance compare plots for 728Sess AllPoints'));
% saveas(hSumf,fullfile(SumSavePath,'Tuning peak distance compare plots for 728Sess AllPoints'),'pdf');
% saveas(hSumf,fullfile(SumSavePath,'Tuning peak distance compare plots for 728Sess AllPoints'),'png');
% 
% save(fullfile(SumSavePath,'SessPeakDis_dataSave.mat'),'c728PeakPosShiftSum','c832PeakPosShiftSum');

%% calculate the peak distance between FracDiffPeak
c728TaskPeakDis = PeakPosShiftSum(:,1) - PeakPosShiftSum(:,5);
c728PassPeakDis = PeakPosShiftSum(:,2) - PeakPosShiftSum(:,6);
c728FracDiffPeak = PeakPosShiftSum(:,4) - PeakPosShiftSum(:,8);

%
% hf = GrdistPlot([c728TaskPeakDis,c728PassPeakDis,c728TaskBoundaryDis,c832TaskPeakDis,c832PassPeakDis,...
%     c832TaskBoundaryDis],{'716Task','716Pass','716Bound','816Task','816Pass','816Bound'});

% TaskDataAll = [c728TaskPeakDis;c832TaskPeakDis];
% PassDataAll = [c728PassPeakDis;c832PassPeakDis];
% BoundDisAll = [c728TaskBoundaryDis;c832TaskBoundaryDis];
TaskDataAll = [c728TaskPeakDis]; %; c728TaskPeakDis
PassDataAll = [c728PassPeakDis]; %; c728PassPeakDis 
BoundDisAll = [c728FracDiffPeak]; %;c728TaskBoundaryDis

[~,TaskP] = ttest(TaskDataAll);
[~,PassP] = ttest(PassDataAll);
TPDisAvg = mean([TaskDataAll,PassDataAll,BoundDisAll]);
TPDisSEM = std([TaskDataAll,PassDataAll,BoundDisAll])/sqrt(numel(TaskDataAll));
% TPDisAvg = mean([TaskDataAll,PassDataAll]);
% TPDisSEM = std([TaskDataAll,PassDataAll])/sqrt(numel(TaskDataAll));
hSumf = figure('position',[2000 100 380 300]);
hold on
bar(1,TPDisAvg(1),0.4,'FaceColor',[1 0.7 0.2],'EdgeColor','none');
bar(2,TPDisAvg(2),0.4,'FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
if length(TPDisAvg) > 2
    bar(3,TPDisAvg(3),0.4,'FaceColor','k','EdgeColor','none');
end
% plot([1 2],([TaskDataAll,PassDataAll])','Color',[.4 .4 .4],'linewidth',0.6);
errorbar(1:length(TPDisAvg),TPDisAvg,TPDisSEM,'.','Color','k','linewidth',2,'Marker','none','CapSize',1);
text([1 2],TPDisAvg(1:2),{sprintf('%.4f',TaskP),sprintf('%.4f',PassP)});
xlim([0.5 length(TPDisAvg) + 0.5]);
set(gca,'xtick',1:length(TPDisAvg),'xticklabel',{'Task','Pass','Bound'});
ylabel('Distance (octave)');
set(gca,'FontSize',12);
[~,pTP] = ttest(TaskDataAll,PassDataAll);
GroupSigIndication([1,2],max([TaskDataAll,PassDataAll]),pTP,hSumf);
if length(TPDisAvg) > 2
    [~,pTB] = ttest(TaskDataAll,BoundDisAll);
    GroupSigIndication([1,3],TPDisAvg([1,3])+TPDisSEM([1,3]),pTB,hSumf);
end
% set(gca,'ylim',[-0.5 1],'ytick',[-0.5,0,0.5,1])

%%
hhhf = GrdistPlot([c728TaskPeakDis,c728PassPeakDis,c728FracDiffPeak],{'716Task','716Pass','716FracDiff'});
[~,pTP] = ttest(TaskDataAll,PassDataAll);
GroupSigIndication([1,2],max([TaskDataAll,PassDataAll]),pTP,hhhf);
[~,pPB] = ttest(PassDataAll,BoundDisAll);
GroupSigIndication([2,3],max([PassDataAll,BoundDisAll]),pPB,hhhf,1.2);

%% Average the response for each session
c832TaskTunAvg = cellfun(@(x) (mean(zscore(x),2))',NorTunDataAlls(:,1),'UniformOutput',false);
c416TaskTunAvg = cellfun(@(x) (mean(zscore(x),2))',NorTunDataAlls(:,2),'UniformOutput',false);
c832PassTunAvg = cellfun(@(x) (mean(zscore(x),2))',NorTunDataAlls(:,3),'UniformOutput',false);
c416PassTunAvg = cellfun(@(x) (mean(zscore(x),2))',NorTunDataAlls(:,4),'UniformOutput',false);

c832TaskTunMtx = cell2mat(c832TaskTunAvg);
c416TaskTunMtx = cell2mat(c416TaskTunAvg);
c832PassTunMtx = cell2mat(c832PassTunAvg);
c416PassTunMtx = cell2mat(c416PassTunAvg);

c832SessOctVec = mean(cell2mat(NorTunDataAlls(:,5)));
c416SessOctVec = mean(cell2mat(NorTunDataAlls(:,6)));
c832SessBounds = cell2mat(NorTunDataAlls(:,7));
c416SessBounds = cell2mat(NorTunDataAlls(:,8));

nSessions = size(c832TaskTunMtx,1);
c832TaskSessAvg = mean(c832TaskTunMtx);
c832TaskSessSem = std(c832TaskTunMtx)/sqrt(nSessions);
c416TaskSessAvg = mean(c416TaskTunMtx);
c416TaskSessSem = std(c416TaskTunMtx)/sqrt(nSessions);
c832PassSessAvg = mean(c832PassTunMtx);
c832PassSessSem = std(c832PassTunMtx)/sqrt(nSessions);
c416PassSessAvg = mean(c416PassTunMtx);
c416PassSessSem = std(c416PassTunMtx)/sqrt(nSessions);

hf = figure('position',[2500 100 460 300]);
hold on
errorbar(c832SessOctVec,c832TaskSessAvg,c832TaskSessSem,'m-o','linewidth',2);
errorbar(c416SessOctVec,c416TaskSessAvg,c416TaskSessSem,'b-o','linewidth',2);
errorbar(c832SessOctVec,c832PassSessAvg,c832PassSessSem,'m-o','linewidth',2,'linestyle','--');
errorbar(c416SessOctVec,c416PassSessAvg,c416PassSessSem,'b-o','linewidth',2,'linestyle','--');
yscales = get(gca,'ylim');
line([mean(c832SessBounds) mean(c832SessBounds)],yscales,'Color','m','linestyle','--')
line([mean(c416SessBounds) mean(c416SessBounds)],yscales,'Color','b','linestyle','--')
set(gca,'xlim',[0 3],'xtick',0:3,'ylim',yscales);
xlabel('Freqs')
ylabel('Response (Nor.)')
title('AvgResp T&P')
%%
saveas(hf,'Sess Averaged response plots');
saveas(hf,'Sess Averaged response plots','pdf');
saveas(hf,'Sess Averaged response plots','png');
%% plot the diff response line
c832TaskPassTunDiff = cellfun(@(x,y) (mean((zscore(x) - zscore(y)),2))',...
    NorTunDataAlls(:,1),NorTunDataAlls(:,3),'UniformOutput',false);
c416TaskPassTunDiff = cellfun(@(x,y) (mean((zscore(x) - zscore(y)),2))',...
    NorTunDataAlls(:,2),NorTunDataAlls(:,4),'UniformOutput',false);
% c832PassTunAvg = cellfun(@(x) (mean(zscore(x),2))',NorTunDataAlls(:,3),'UniformOutput',false);
% c416PassTunAvg = cellfun(@(x) (mean(zscore(x),2))',NorTunDataAlls(:,4),'UniformOutput',false);
nSessions = length(c832TaskPassTunDiff);
c832TaskPassDiffMtx = cell2mat(c832TaskPassTunDiff);
c416TaskPassDiffMtx = cell2mat(c416TaskPassTunDiff);
c832TaskPassDiffAvg = mean(c832TaskPassDiffMtx);
c416TaskPassDiffAvg = mean(c416TaskPassDiffMtx);
c832TaskPassDiffSEM = std(c832TaskPassDiffMtx)/sqrt(nSessions);
c416TaskPassDiffSEM = std(c416TaskPassDiffMtx)/sqrt(nSessions);

hfDiff = figure('position',[3000 100 380 300]);
hold on
errorbar(c832SessOctVec,c832TaskPassDiffAvg,c832TaskPassDiffSEM,'m-o','linewidth',2);
errorbar(c416SessOctVec,c416TaskPassDiffAvg,c416TaskPassDiffSEM,'b-o','linewidth',2);
yscales = get(gca,'ylim');
line([mean(c832SessBounds) mean(c832SessBounds)],yscales,'Color','m','linestyle','--')
line([mean(c416SessBounds) mean(c416SessBounds)],yscales,'Color','b','linestyle','--')
set(gca,'xlim',[0 3],'xtick',0:3,'ylim',yscales);
%%
saveas(hfDiff,'Sess TaskPassDiff Averaged response plots');
saveas(hfDiff,'Sess TaskPassDiff Averaged response plots','pdf');
saveas(hfDiff,'Sess TaskPassDiff Averaged response plots','png');
