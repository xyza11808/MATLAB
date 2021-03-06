% scripts for compare the "tunning function" for task and passive
% comparison
clear
clc

% loading task data
[Taskfn,Taskfp,Taskfi] = uigetfile('*.txt','Please select the task data file');
if ~Taskfi
    return;
end
TaskPath = fullfile(Taskfp,Taskfn);
TaskID = fopen(TaskPath);
Taskline = fgetl(TaskID);
% TaskDataStrc = load(TaskPath);
% cd(Taskfp);
% loading passive data   % \SpikeData_analysis
[Passfn,Passfp,Passfi] = uigetfile('*.txt','Please select the passive data file');
if ~Passfi
    return;
end
PassPath = fullfile(Passfp,Passfn);
% PassDataStrc = load(PassPath);
passID = fopen(PassPath);
Passline = fgetl(passID);
while ischar(Taskline)
    if isempty(strfind(Taskline,'\mode_f_change'))
        Taskline = fgetl(TaskID);
        Passline = fgetl(passID);
        continue;
    end
    TaskDataPath = fullfile(Taskline,'SpikeDataSave\EstimateSPsave.mat');
    TaskDataStrc = load(TaskDataPath);
    cd(Taskline);
    PassDataPath = fullfile(Passline,'\SpikeDataSave\PassEstimateSPsave.mat');
    PassDataStrc = load(PassDataPath);
    %
    % extract Task stimulus 
    TaskTrFreq = double(TaskDataStrc.behavResults.Stim_toneFreq);
    TaskTrTypes = TaskDataStrc.behavResults.Trial_Type;
    TaskTrChoice = TaskDataStrc.behavResults.Action_choice;
    TaskOutcome = double(TaskTrTypes(:) == TaskTrChoice(:));
    TaskOutcome(TaskTrChoice == 2) = 2;
    % TaskOutcome = TaskDataStrc.trial_outcome;
    TaskData = TaskDataStrc.nnspike;
    nROIs = size(TaskData,2);
    DataRespWinT = 0.5; % using only 500ms time window for sensory response
    DataRespWinF = round(DataRespWinT*TaskDataStrc.frame_rate);
    TaskDataResp = mean(TaskData(:,:,(TaskDataStrc.start_frame+1):(TaskDataStrc.start_frame+DataRespWinF)),3);
    NonMissTrInds = TaskOutcome ~= 2;
    CorrectInds = TaskOutcome == 1;

    NonMissFreqs = TaskTrFreq(NonMissTrInds);
    NonMissData = TaskDataResp(NonMissTrInds,:);
    CorrTrFreqs = TaskTrFreq(CorrectInds);
    CorrTrData = TaskDataResp(CorrectInds,:);

    FreqTypes = unique(TaskTrFreq);
    FreqNum = length(FreqTypes);

    NonMissTunningFun = zeros(FreqNum,nROIs);
    NonMissTunningFunSEM = zeros(FreqNum,nROIs);
    CorrTunningFun = zeros(FreqNum,nROIs);
    CorrTunningFunSEM = zeros(FreqNum,nROIs);
    for nTFreq = 1 : FreqNum
        cfreq = FreqTypes(nTFreq);
        % non-miss data
        cfreqInds = NonMissFreqs == cfreq;
        cFreqDataNM = NonMissData(cfreqInds,:);
        MeanROIResp = mean(cFreqDataNM);
        NonMissTunningFun(nTFreq,:) = MeanROIResp;
        NonMissTunningFunSEM(nTFreq,:) = std(cFreqDataNM)/sqrt(size(cFreqDataNM,1));

        %correct data
        cfreqInds = CorrTrFreqs == cfreq;
        cFreqDataCorr = CorrTrData(cfreqInds,:);
        CorrTunningFun(nTFreq,:) = mean(cFreqDataCorr);
        CorrTunningFunSEM(nTFreq,:) = std(cFreqDataCorr)/sqrt(size(cFreqDataCorr,1));
    end

    % passive data extaction
    PassiveData = PassDataStrc.nnspike;
    nPassROI = size(PassiveData,2);
    if nPassROI > nROIs
        PassiveData = PassiveData(:,1:nROIs,:);
        nPassROI = nROIs;
    end
    PassRespWinT = 0.5;
    PassRespWinF = round(PassRespWinT*PassDataStrc.frame_rate);
    PassRespData = mean(PassiveData(:,:,(PassDataStrc.frame_rate+1):(PassDataStrc.frame_rate+PassRespWinF)),3);
    PassFreqTypes = unique(PassDataStrc.SelectSArray);
    nPassFreq = length(PassFreqTypes);

    PassTunningfun = zeros(nPassFreq,nPassROI);
    PassTunningfunSEM = zeros(nPassFreq,nPassROI);
    for nnfreq = 1 : nPassFreq
        cPasFreq = PassFreqTypes(nnfreq);
        cFreqInds = PassDataStrc.SelectSArray == cPasFreq;
        PassTunningfun(nnfreq,:) = mean(PassRespData(cFreqInds,:));
        PassTunningfunSEM(nnfreq,:) = std(PassRespData(cFreqInds,:))/size(PassRespData(cFreqInds,:),1);
    end

    BoundFreq = 16000;
    TaskFreqOctave = log2(FreqTypes/BoundFreq);
    PassFreqOctave = log2(PassFreqTypes/BoundFreq);
    if ~isdir('./Spike_Tunfun_plotNewmean/')
        mkdir('./Spike_Tunfun_plotNewmean/');
    end
    cd('./Spike_Tunfun_plotNewmean/');

    save TunningDataSave.mat NonMissTunningFun CorrTunningFun PassTunningfun ...
        PassTunningfunSEM NonMissTunningFunSEM CorrTunningFunSEM TaskFreqOctave PassFreqOctave BoundFreq -v7.3
    %
    for cROI = 1 : nROIs
        h = figure;
        hold on;
        cROItaskNM = NonMissTunningFun(:,cROI);
        cROItaskCorr = CorrTunningFun(:,cROI);
        cROIpass = PassTunningfun(:,cROI);
        l1 = errorbar(TaskFreqOctave,cROItaskNM,NonMissTunningFunSEM(:,cROI),'c-o','LineWidth',1.6);
        l2 = errorbar(TaskFreqOctave,cROItaskCorr,CorrTunningFunSEM(:,cROI),'r-o','LineWidth',1.6);
        l3 = errorbar(PassFreqOctave,cROIpass,PassTunningfunSEM(:,cROI),'k-o','LineWidth',1.6);
        xlabel('Octave From Boundary');
        ylabel('Mean Estimate FR');
        xlim([min(PassFreqOctave) - 0.2,max(PassFreqOctave)+0.2]);
        title(sprintf('ROI%d Tunning',cROI));
        set(gca,'FontSize',20);
        legend([l1,l2,l3],{'Task Non-miss','Task Corr','Passive'},'FontSize',8,'location','eastoutside');
        saveas(h,sprintf('ROI%d Tunning curve comparison plot',cROI));
        saveas(h,sprintf('ROI%d Tunning curve comparison plot',cROI),'png');
        close(h);
    end
    Taskline = fgetl(TaskID);
    Passline = fgetl(passID);
end
% %% calculated the difference between task and passive and normalized to plot together
% if length(TaskFreqOctave) == length(PassFreqOctave)
%     TunDifNorData = (CorrTunningFun - PassTunningfun)./repmat(max(CorrTunningFun),length(TaskFreqOctave),1);
%     InterpPassData = PassTunningfun;
% else
%     InerpXpoint = linspace(min(PassFreqOctave),max(PassFreqOctave),500);
%     InterpPassDataAll = zeros(500,nROIs);
%     for ncROI = 1 : nROIs
%         cROIpassData = PassTunningfun(:,ncROI);
%         InterpData = interp1(PassFreqOctave,cROIpassData,InerpXpoint,'spline');
%         InterpPassDataAll(:,ncROI) = InterpData;
%     end
%         
%     InterpPassData = zeros(length(TaskFreqOctave),nROIs);
%     for nTaskFreq = 1 : length(TaskFreqOctave)
%         cTaskFreq = TaskFreqOctave(nTaskFreq);
%         [~,ClrInterpInds] = min(abs(InerpXpoint - cTaskFreq));
%         InterpPassData(nTaskFreq,:) = InterpPassDataAll(ClrInterpInds,:);
%     end
%     TunDifNorData = (CorrTunningFun - InterpPassData)./repmat(max(CorrTunningFun),length(TaskFreqOctave),1);
% end
% save TaskPassDifSave.mat CorrTunningFun InterpPassData TaskFreqOctave -v7.3
% 
% %% sort the sequence
% [~,ROIsortInds] = sort(sum(TunDifNorData));
% hf = figure;
% imagesc(TunDifNorData(:,ROIsortInds)');
% colorbar
% saveas(hf,'Sorted Tunning dif colorplot');
% saveas(hf,'Sorted Tunning dif colorplot','png');
% saveas(hf,'Sorted Tunning dif colorplot','pdf');
% close(hf);
% 
% CorrNorTunningFunAll = CorrTunningFun./repmat(max(CorrTunningFun),length(TaskFreqOctave),1);
% PassNorTunFunAll = PassTunningfun./repmat(max(PassTunningfun),length(PassFreqOctave),1);
% hmeanf = figure;
% hold on
% plot(TaskFreqOctave,mean(CorrNorTunningFunAll,2),'r-o','Linewidth',1.5);
% plot(PassFreqOctave,mean(PassNorTunFunAll,2),'k-o','Linewidth',1.5);
% xlabel('Octave from Boundary');
% ylabel('Nor. \DeltaF/F');
% saveas(hmeanf,'Mean Normalized Resp plot')
% saveas(hmeanf,'Mean Normalized Resp plot','png')
% saveas(hmeanf,'Mean Normalized Resp plot','pdf')
% close(hmeanf);
% cd ..;
% %%
% % shape the direction of preferred response side
% GrSize = floor(FreqNum/2);
% PreferSideTunning = zeros(FreqNum,nROIs);
% RevertInds = zeros(nROIs,1);
% for cROI = 1 : size(CorrTunningFun,2)
%     cROItun = CorrTunningFun(:,cROI);
%     if mean(cROItun(1:GrSize)) > mean(cROItun(end-GrSize+1:end))
%         PreferSideTunning(:,cROI) = fliplr(cROItun);
%         RevertInds(cROI) = 1;
%     else
%         PreferSideTunning(:,cROI) = cROItun;
%     end
% end
% %% normalized the firing rate
% ROImeanResp = repmat(mean(PreferSideTunning),FreqNum,1);
% ROImeanRespSub = ROImeanResp;
% ROImeanRespSub(ROImeanRespSub == 0) = 1;
% NormalRespSub = PreferSideTunning./ROImeanRespSub;
% figure;
% plot(mean(NormalRespSub,2))
