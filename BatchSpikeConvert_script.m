
close;
hf = figure;
cROI = 1;
if iscell(nnspike)
    cROIData = squeeze(SpikeAligned(:,cROI,:));
else
    nnspike(:,:,1:5) = 0;
    cROIData = squeeze(nnspike(:,cROI,:));
end
plot(mean(cROIData));
yscales = get(gca,'ylim');
line([start_frame start_frame],yscales,'Color','r','linewidth',1.4,'linestyle','--');
line([start_frame start_frame]+28,yscales,'Color','m','linewidth',1.4,'linestyle','--');
set(gca,'ylim',yscales);

%%
SpikeTimeWin = [0.1,0.5];
SpikeFScale = round(SpikeTimeWin*frame_rate);
SpikeFrameRange = [start_frame+SpikeFScale(1)+1,start_frame+SpikeFScale(2)];

BehavTones = double(behavResults.Stim_toneFreq);
BehavChoice = double(behavResults.Action_choice);
BehavTrTypes = double(behavResults.Trial_Type);
NMTrInds = BehavChoice ~= 2;
NMData = SpikeAligned(NMTrInds,:,:);
NMFreqs = BehavTones(NMTrInds);
NMTrTypes = BehavTrTypes(NMTrInds);
NMChoice = BehavChoice(NMTrInds);
NMOutcomes = double(NMChoice == NMTrTypes);
ROIRespData = sum(NMData(:,:,SpikeFrameRange(1):SpikeFrameRange(2)),3);

%%
FreqTypes = unique(NMFreqs);
nFreqs = length(FreqTypes);
FreqCorrAvgData = zeros(nFreqs,size(ROIRespData,2));
FreqNMAvgData = zeros(nFreqs,size(ROIRespData,2));
for cf = 1 : nFreqs
    cfInds = NMFreqs == FreqTypes(cf);
    cfData = ROIRespData(cfInds,:);
    cfoutcome = NMOutcomes(cfInds);
    FreqCorrAvgData(cf,:) = mean(cfData(cfoutcome == 1,:));
    FreqNMAvgData(cf,:) = mean(cfData);
end

%%
close
cROI = 35;
hf = figure;
hold on
plot(FreqCorrAvgData(:,cROI),'r');
plot(FreqNMAvgData(:,cROI),'k');



%%
clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[TaskPathfn,TaskPathfp,TaskPathfi] = uigetfile('*.txt','Please select the Task session path save file');
[PassPathfn,PassPathfp,PassPathfi] = uigetfile('*.txt','Please select the corresponded passive session path save file');
if ~TaskPathfi || ~PassPathfi
    return;
end
%% batch scripts for 
TaskPathf = fullfile(TaskPathfp,TaskPathfn);
PassPathf = fullfile(PassPathfp,PassPathfn);
Taskfid =  fopen(TaskPathf);
Passfid = fopen(PassPathf);
TaskLine = fgetl(Taskfid);
PassLine = fgetl(Passfid);

while ischar(TaskLine) && ischar(PassLine)
    if isempty(strfind(TaskLine,'NO_Correction\mode_f_change'))  
        TaskLine = fgetl(Taskfid);
        PassLine = fgetl(Passfid);
        continue;
    end
    
%     NewTaskLine = ['D:\data\xinyu\Data\',TaskLine(4:end)];
    load(fullfile(TaskLine,'CSessionData.mat'));
    RawDataPath = strrep(TaskLine,'mode_f_change','DiffFluoResult.mat');
    RawDataStrc = load(RawDataPath,'FChangeData');
    
    cd(TaskLine);
    
    V.Ncells = 1;
%     V.T = 1;
    V.Npixels = 1;
    V.dt = 1/frame_rate;
    P.lam = 10;
    nTau = 1.8;
    P.gam = 1 - V.dt/nTau; 
    nnspike = DataFluo2Spike(RawDataStrc.FChangeData,V,P); 
    
    if iscell(nnspike)
        SPsizeData = [length(nnspike),size(nnspike{1},1),max(FrameInds)];
        SPDataAll = zeros(SPsizeData);
        for cTr = 1 : length(nnspike)
            SPDataAll(cTr,:,:) = [nnspike{cTr},nan(SPsizeData(2),SPsizeData(3) - FrameInds(cTr))];
        end
        UsedSPData = SPDataAll(:,:,1:UsedFrame);
        SPsizeDataNew = size(UsedSPData);
    else
        UsedSPData = nnspike;
        SPsizeDataNew = size(UsedSPData);
    end
    %
    size_data = size(UsedSPData);
    %performing stimulus onset alignment
    %2AFC trigger should be at the begaining of each loop
    onset_time=behavResults.Time_stimOnset;
    stim_type_freq=behavResults.Stim_toneFreq;
    align_time_point=min(onset_time);
    alignment_frames=floor((double((onset_time-align_time_point))/1000)*frame_rate); 
    framelength=size_data(3)-max(alignment_frames);
    alignment_frames(alignment_frames<1)=1;
    start_frame=floor((double(align_time_point)/1000)*frame_rate);
    
    data_aligned = zeros(size_data(1),size_data(2),framelength);
    SpikeAligned = zeros(size_data(1),size_data(2),framelength);
%     zscore_data_aligned=zeros(size_data(1),size_data(2),framelength);
%     NorDataAligned=zeros(size_data(1),size_data(2),framelength);
%     SpikeAlign = zeros(size_data(1),size_data(2),framelength);
    for i=1:size_data(1)
        data_aligned(i,:,:)=data(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
        SpikeAligned(i,:,:)=UsedSPData(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
%         zscore_data_aligned(i,:,1:framelength)=zscore_data(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
%         NorDataAligned(i,:,1:framelength)=NorData(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
%         SpikeAlign(i,:,:) = nSpikes(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
    end
    save EstimateSPsaveNew.mat nnspike SpikeAligned data_aligned behavResults start_frame frame_rate -v7.3
    %
    % passive part
%     NewPassLine = ['D:\data\xinyu\Data\',PassLine(4:end)];
    load(fullfile(PassLine,'rfSelectDataSet.mat'));
    cd(PassLine);
    
    V.Ncells = 1;
    
    V.T = size(SelectData,3);
    V.Npixels = 1;
    V.dt = 1/frame_rate;
    P.lam = 10;
    nTau = 1.8;
    P.gam = 1 - V.dt/nTau; % Tau = 3, decay time for calcium event
    PassSpike = DataFluo2Spike(SelectData,V,P); % estimated spike
    if ~isdir('./SpikeData_analysis/')
        mkdir('./SpikeData_analysis/');
    end
    cd('./SpikeData_analysis/');
    save EsSpikeSaveNew.mat PassSpike SelectSArray frame_rate SelectInds SelectData -v7.3
    %
     TaskLine = fgetl(Taskfid);
     PassLine = fgetl(Passfid);
end
