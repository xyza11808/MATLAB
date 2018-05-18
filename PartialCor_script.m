% % A set of car weights
% weight = [2100 2300 2500 2700 2900 3100 3300 3500 3700 3900 4100 4300]';
% % The number of cars tested at each weight
% tested = [48 42 31 34 31 21 23 23 21 16 17 21]';
% % The number of cars failing the test at each weight
% failed = [1 2 0 3 8 8 14 17 19 15 17 21]';
% % The proportion of cars failing for each weight
% proportion = failed ./ tested;
clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
%% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
fpath = fullfile(fp,fn);
% PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
% PassLine = fgetl(PassFid);
cSess = 1;
SessPartialCorrData = {};
TempporalDataAll = {};
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ff);
        %        PassLine = fgetl(PassFid);
        continue;
    end
    
    cd(tline);
    try
        SPData = load(fullfile(tline,'EstimateSPsaveNew.mat'),'SpikeAligned');
    catch
        SPData = load(fullfile(tline,'EstimateSPsave.mat'),'SpikeAligned');
    end
    load(fullfile(tline,'CSessionData.mat'));
    %
    RespWin = [0.1,0.5];
    RespFrame = round(RespWin*frame_rate)+start_frame;
    TemporalWin = [0.1,1];
    TemporalFrame = round(TemporalWin*frame_rate);
    TimeStep = 0.1;
    FrameStep = round(TemporalFrame(1):(TimeStep*frame_rate):TemporalFrame(2))+start_frame;
    FrameCenter = (FrameStep(1:end-1)+FrameStep(2:end))/2;
    
    ROIRespWinData = sum(SPData.SpikeAligned(:,:,RespFrame(1):RespFrame(2)),3);
    % ROITempWinData = SpikeAligned(:,:,RespFrame(1):RespFrame(2));
    ChoiceAll = double(behavResults.Action_choice);
    NMInds = ChoiceAll ~= 2;
    NMChoiceAll = ChoiceAll(NMInds);
    NMChoiceAll(NMChoiceAll == 0) = -1;
    NMFreqAll = double(behavResults.Stim_toneFreq(NMInds))/16000;
    NMDataAll = ROIRespWinData(NMInds,:);
    NMRawDataAll = SPData.SpikeAligned(NMInds,:,:);
    nROIs = size(ROIRespWinData,2);
    ROIpartialRAll = zeros(nROIs,2);
    ROIpartialPAll = zeros(nROIs,2);
    for cROI = 1 : nROIs
        [roh1,pval1] = partialcorr([NMDataAll(:,cROI),NMFreqAll(:)],NMChoiceAll(:));
        ROIpartialRAll(cROI,1) = roh1(1,2);
        ROIpartialPAll(cROI,1) = pval1(1,2);
        
        [roh2,pval2] = partialcorr([NMDataAll(:,cROI),NMChoiceAll(:)],NMFreqAll(:));
        ROIpartialRAll(cROI,2) = roh2(1,2);
        ROIpartialPAll(cROI,2) = pval2(1,2);
        
    end
    
    TemporalRData = zeros(nROIs,length(FrameCenter),2);
    TemporalPData = zeros(nROIs,length(FrameCenter),2);
    for cFBin = 1 : length(FrameCenter)
        cFData = sum(NMRawDataAll(:,:,FrameStep(cFBin):FrameStep(cFBin+1)),3);
        for cROI = 1 : nROIs
            cROICfData = cFData(:,cROI);
            [roh1,pval1] = partialcorr([cROICfData,NMFreqAll(:)],NMChoiceAll(:));
            TemporalRData(cROI,cFBin,1) = roh1(1,2);
            TemporalPData(cROI,cFBin,1) = pval1(1,2);
            
            [roh2,pval2] = partialcorr([cROICfData,NMChoiceAll(:)],NMFreqAll(:));
            TemporalRData(cROI,cFBin,2) = roh2(1,2);
            TemporalPData(cROI,cFBin,2) = pval2(1,2);
        end
    end
    
    %
    hf = figure('position',[100 100 420 360]);
    hold on
    scatter(ROIpartialRAll(:,1),ROIpartialRAll(:,2),40,'ko')
    set(gca,'xlim',[-1,1],'ylim',[-1,1])
    line([-1 1],[0 0],'Color',[.7 .7 .7],'Linewidth',1.6,'lineStyle','--')
    line([0 0],[-1 1],'Color',[.7 .7 .7],'Linewidth',1.6,'lineStyle','--')
    xlabel('StimCorr')
    ylabel('ChoiceCorr')
    
    SigRValue = sum(ROIpartialPAll < 0.05,2) > 0;
    scatter(ROIpartialRAll(SigRValue,1),ROIpartialRAll(SigRValue,2),40,'ro');
    set(gca,'FontSize',14);
    saveas(hf,'Stimli and choice partialCorr Analysis');
    saveas(hf,'Stimli and choice partialCorr Analysis','png');
    close(hf);
    
    SessPartialCorrData{cSess,1} = ROIpartialRAll;
    SessPartialCorrData{cSess,2} = ROIpartialPAll;
    TempporalDataAll{cSess,1} = TemporalRData;
    TempporalDataAll{cSess,2} = TemporalPData;
    TempporalDataAll{cSess,3} = FrameCenter;
    
    % square coefficient averaged plot
    StimRAll = squeeze(TemporalRData(:,:,1));
    ChoiceRAll = squeeze(TemporalRData(:,:,2));
    StimRAvgSem = [mean(StimRAll.^2);std(StimRAll.^2)/sqrt(size(StimRAll,1))];
    ChoiceRAvgSem = [mean(ChoiceRAll.^2);std(ChoiceRAll.^2)/sqrt(size(ChoiceRAll,1))];
    FrameTime = (FrameCenter/frame_rate) - (start_frame/frame_rate);
    hff1 = figure;
    hold on
    el1 = errorbar(FrameTime,StimRAvgSem(1,:),StimRAvgSem(2,:),'r','linewidth',1.6);
    el2 = errorbar(FrameTime,ChoiceRAvgSem(1,:),ChoiceRAvgSem(2,:),'b','linewidth',1.6);
    legend([el1,el2],{'Stim','Choice'},'Location','Northwest','Box','off');
    xlabel('Time (s)');
    ylabel('Partial Corr. (R, Square)');
    set(gca,'FontSize',16);
    saveas(hff1,'Square Coefficients average plot');
    saveas(hff1,'Square Coefficients average plot','png');
    close(hff1);
    
    % Raw coefficient averaged plot
    StimRAll = squeeze(TemporalRData(:,:,1));
    ChoiceRAll = squeeze(TemporalRData(:,:,2));
    StimRAvgSem = [mean(StimRAll);std(StimRAll)/sqrt(size(StimRAll,1))];
    ChoiceRAvgSem = [mean(ChoiceRAll);std(ChoiceRAll)/sqrt(size(ChoiceRAll,1))];
    FrameTime = (FrameCenter/frame_rate) - (start_frame/frame_rate);
    hff2 = figure;
    hold on
    el1 = errorbar(FrameTime,StimRAvgSem(1,:),StimRAvgSem(2,:),'r','linewidth',1.6);
    el2 = errorbar(FrameTime,ChoiceRAvgSem(1,:),ChoiceRAvgSem(2,:),'b','linewidth',1.6);
    legend([el1,el2],{'Stim','Choice'},'Location','Northwest','Box','off');
    xlabel('Time (s)');
    ylabel('Partial Corr. (R)');
    set(gca,'FontSize',16);
    saveas(hff2,'Raw Coefficients average plot');
    saveas(hff2,'Raw Coefficients average plot','png');
    close(hff2);
    
    % Raw coefficient averaged plot according to sign averaged
    StimRAll = squeeze(TemporalRData(:,:,1));
    ChoiceRAll = squeeze(TemporalRData(:,:,2));
    AvgStimR = mean(StimRAll,2);
    AvgChoiceR = mean(ChoiceRAll,2);
    StimRSignInds = AvgStimR > 0;
    ChoiceRSignInds = AvgChoiceR > 0;
    
    StimRPosAvgSem = [mean(StimRAll(StimRSignInds,:));std(StimRAll(StimRSignInds,:))/sqrt(sum(StimRSignInds))];
    StimRNegAvgSem = [mean(StimRAll(~StimRSignInds,:));std(StimRAll(~StimRSignInds,:))/sqrt(sum(~StimRSignInds))];
    ChoiceRPosAvgSem = [mean(ChoiceRAll(ChoiceRSignInds,:));std(ChoiceRAll(ChoiceRSignInds,:))/sqrt(sum(ChoiceRSignInds))];
    ChoiceRNegAvgSem = [mean(ChoiceRAll(~ChoiceRSignInds,:));std(ChoiceRAll(~ChoiceRSignInds,:))/sqrt(sum(~ChoiceRSignInds))];
    FrameTime = (FrameCenter/frame_rate) - (start_frame/frame_rate);
    hff3 = figure;
    hold on
    el1 = errorbar(FrameTime,StimRPosAvgSem(1,:),StimRPosAvgSem(2,:),'r','linewidth',1.6);
    el2 = errorbar(FrameTime,ChoiceRPosAvgSem(1,:),ChoiceRPosAvgSem(2,:),'b','linewidth',1.6);
    el3 = errorbar(FrameTime,StimRNegAvgSem(1,:),StimRNegAvgSem(2,:),'Color',[0.8 0.2 0.2],'linewidth',1.6,'linestyle','--');
    el4 = errorbar(FrameTime,ChoiceRNegAvgSem(1,:),ChoiceRNegAvgSem(2,:),'Color',[0.2 0.2 0.8],'linewidth',1.6,'linestyle','--');
    xlabel('Time (s)');
    ylabel('Partial Corr. (R)');
    set(gca,'FontSize',16);
    
    legend([el1,el2,el3,el4],{'StimPos','ChoicePos','StimNeg','ChoiceNeg'},'Location','Northeast',...
        'Box','off','FontSize',8);
    saveas(hff3,'Signed Coefficients average plot');
    saveas(hff3,'Signed Coefficients average plot','png');
    close(hff3);
    
    tline = fgetl(ff);
    cSess = cSess + 1;
end

%%
cd('E:\DataToGo\data_for_xu\PartialR_summary');
save ROIPartialRSave.mat SessPartialCorrData TempporalDataAll -v7.3
%%
ROIPartialRAll = cell2mat(SessPartialCorrData(:,1));
ROIPartialPAll = cell2mat(SessPartialCorrData(:,2));

hf = figure('position',[100 100 420 360]);
hold on
scatter(ROIPartialRAll(:,1),ROIPartialRAll(:,2),20,'ko')
set(gca,'xlim',[-1,1],'ylim',[-1,1])
line([-1 1],[0 0],'Color',[.7 .7 .7],'Linewidth',1.6,'lineStyle','--')
line([0 0],[-1 1],'Color',[.7 .7 .7],'Linewidth',1.6,'lineStyle','--')
xlabel('StimCorr')
ylabel('ChoiceCorr')

SigRValue = sum(ROIPartialPAll < 0.05,2) > 0;
scatter(ROIPartialRAll(SigRValue,1),ROIPartialRAll(SigRValue,2),20,'ro');
set(gca,'FontSize',14);
% saveas(hf,'Stimli and choice partialCorr Analysis');
% saveas(hf,'Stimli and choice partialCorr Analysis','png');
% close(hf);

%%
ROIs = size(TempoData);
hf = figure;

for cROI = 1 : ROIs
    cROIData = squeeze(TempoData(cROI,:,:));
    hold on
    plot(cROIData(:,1),'r','linewidth',1.6);
    plot(cROIData(:,2),'b','linewidth',1.6);
    title(sprintf('ROI%d',cROI));
    xlabel('Stimuli');
    ylabel('Choice');
    pause(0.5)
    clf
end
% %% square coefficient averaged plot
% StimRAll = squeeze(TempporalDataAll{1}(:,:,1));
% ChoiceRAll = squeeze(TempporalDataAll{1}(:,:,2));
% StimRAvgSem = [mean(StimRAll.^2);std(StimRAll.^2)/sqrt(size(StimRAll,1))];
% ChoiceRAvgSem = [mean(ChoiceRAll.^2);std(ChoiceRAll.^2)/sqrt(size(ChoiceRAll,1))];
% FrameTime = (FrameCenter/frame_rate) - (start_frame/frame_rate);
% hff1 = figure;
% hold on
% el1 = errorbar(FrameTime,StimRAvgSem(1,:),StimRAvgSem(2,:),'r','linewidth',1.6);
% el2 = errorbar(FrameTime,ChoiceRAvgSem(1,:),ChoiceRAvgSem(2,:),'b','linewidth',1.6);
% legend([el1,el2],{'Stim','Choice'},'Location','Northwest','Box','off');
% xlabel('Time (s)');
% ylabel('Partial Corr. (R, Square)');
% set(gca,'FontSize',16);
% saveas(hff1,'Square Coefficients average plot');
% saveas(hff1,'Square Coefficients average plot','png');
% close(hff1);
%
% %% Raw coefficient averaged plot
% StimRAll = squeeze(TempporalDataAll{1}(:,:,1));
% ChoiceRAll = squeeze(TempporalDataAll{1}(:,:,2));
% StimRAvgSem = [mean(StimRAll);std(StimRAll)/sqrt(size(StimRAll,1))];
% ChoiceRAvgSem = [mean(ChoiceRAll);std(ChoiceRAll)/sqrt(size(ChoiceRAll,1))];
% FrameTime = (FrameCenter/frame_rate) - (start_frame/frame_rate);
% hff2 = figure;
% hold on
% el1 = errorbar(FrameTime,StimRAvgSem(1,:),StimRAvgSem(2,:),'r','linewidth',1.6);
% el2 = errorbar(FrameTime,ChoiceRAvgSem(1,:),ChoiceRAvgSem(2,:),'b','linewidth',1.6);
% legend([el1,el2],{'Stim','Choice'},'Location','Northwest','Box','off');
% xlabel('Time (s)');
% ylabel('Partial Corr. (R)');
% set(gca,'FontSize',16);
% saveas(hff2,'Raw Coefficients average plot');
% saveas(hff2,'Raw Coefficients average plot','png');
% close(hff2);
%
% %% Raw coefficient averaged plot according to sign averaged
% StimRAll = squeeze(TempporalDataAll{1}(:,:,1));
% ChoiceRAll = squeeze(TempporalDataAll{1}(:,:,2));
% AvgStimR = mean(StimRAll,2);
% AvgChoiceR = mean(ChoiceRAll,2);
% StimRSignInds = AvgStimR > 0;
% ChoiceRSignInds = AvgChoiceR > 0;
%
% StimRPosAvgSem = [mean(StimRAll(StimRSignInds,:));std(StimRAll(StimRSignInds,:))/sqrt(sum(StimRSignInds))];
% StimRNegAvgSem = [mean(StimRAll(~StimRSignInds,:));std(StimRAll(~StimRSignInds,:))/sqrt(sum(~StimRSignInds))];
% ChoiceRPosAvgSem = [mean(ChoiceRAll(ChoiceRSignInds,:));std(ChoiceRAll(ChoiceRSignInds,:))/sqrt(sum(ChoiceRSignInds))];
% ChoiceRNegAvgSem = [mean(ChoiceRAll(~ChoiceRSignInds,:));std(ChoiceRAll(~ChoiceRSignInds,:))/sqrt(sum(~ChoiceRSignInds))];
% FrameTime = (FrameCenter/frame_rate) - (start_frame/frame_rate);
% hff3 = figure;
% hold on
% el1 = errorbar(FrameTime,StimRPosAvgSem(1,:),StimRPosAvgSem(2,:),'r','linewidth',1.6);
% el2 = errorbar(FrameTime,ChoiceRPosAvgSem(1,:),ChoiceRPosAvgSem(2,:),'b','linewidth',1.6);
% el3 = errorbar(FrameTime,StimRNegAvgSem(1,:),StimRNegAvgSem(2,:),'Color',[0.8 0.2 0.2],'linewidth',1.6,'linestyle','--');
% el4 = errorbar(FrameTime,ChoiceRNegAvgSem(1,:),ChoiceRNegAvgSem(2,:),'Color',[0.2 0.2 0.8],'linewidth',1.6,'linestyle','--');
% xlabel('Time (s)');
% ylabel('Partial Corr. (R)');
% set(gca,'FontSize',16);
%
% legend([el1,el2,el3,el4],{'StimPos','ChoicePos','StimNeg','ChoiceNeg'},'Location','Northeast',...
%     'Box','off','FontSize',8);
% saveas(hff3,'Signed Coefficients average plot');
% saveas(hff3,'Signed Coefficients average plot','png');
% close(hff3);
%%
clearvars -except fn fp
m = 1;
nSession = 1;

fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);
        
        continue;
    else
        %
        if m == 1
            %
            %                 PPTname = input('Please input the name for current PPT file:\n','s');
            PPTname = 'PartialR_Summary_file';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
            %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
            pptSavePath = 'F:\TestOutputSave';
            %
        end
        Anminfo = SessInfoExtraction(tline);
        cTunDataPath = tline;
        RespPRScatter = fullfile(cTunDataPath,'Stimli and choice partialCorr Analysis.png');
        RawCoefAvgf = fullfile(cTunDataPath,'Raw Coefficients average plot.png');
        SquareCoefAvgf = fullfile(cTunDataPath,'Square Coefficients average plot.png');
        SignCoefAvgf = fullfile(cTunDataPath,'Signed Coefficients average plot.png');
        
        pptFullfile = fullfile(pptSavePath,PPTname);
        if ~exist(pptFullfile,'file')
            NewFileExport = 1;
        else
            NewFileExport = 0;
        end
        if NewFileExport
            exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
        else
            exportToPPTX('open',pptFullfile);
        end
        %
        exportToPPTX('addslide');
        
        % Anminfo
        exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 1],'FontSize',24);
        exportToPPTX('addnote',tline);
        exportToPPTX('addpicture',imread(RespPRScatter),'Position',[1.5 1 4 3]);
        exportToPPTX('addtext','RespPlot','Position',[0 2 1.5 2],'FontSize',20);
        exportToPPTX('addpicture',imread(RawCoefAvgf),'Position',[9 1 5 3.75]);
        exportToPPTX('addtext','RawPartialR','Position',[6.5 2 2.5 2],'FontSize',20);
        exportToPPTX('addpicture',imread(SquareCoefAvgf),'Position',[1.5 5 5 3.75]);
        exportToPPTX('addtext','SquarePartialR','Position',[0 7 1.5 2],'FontSize',20);
        exportToPPTX('addpicture',imread(SignCoefAvgf),'Position',[9 5 5 3.75]);
        exportToPPTX('addtext','SignPartialR','Position',[6.5 7 2.5 2],'FontSize',20);
        
        %                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
        exportToPPTX('addtext',sprintf('Batch:%s Anm: %s\r\nDate: %s Field: %s',...
            Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
            'Position',[10 0 4 1],'FontSize',22);
    end
    m = m + 1;
    nSession = nSession + 1;
    saveName = exportToPPTX('saveandclose',pptFullfile);
    tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);
