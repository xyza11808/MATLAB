function OverAllExcludeInds = UsedClusIndsCheckFun(obj,selectops,varargin)
% this function is used to check the used cluster criteria, using the true
% value fields in selectops to check the used cluster selection criteria
% and perform cluster selection

FullClusSelectionops = struct('Unitwaveform',false,...
    'ISIviolation',[],...  % default threshold value is 0.1, or 10%
    'SessSpiketimeCheck',false,...
    'Amplitude',[],... % threshold amplitude value
    'WaveformSpread',[],... % in um, Spatial extent (in μm) of channels in which the waveform amplitude exceeds 12% of the peak amplitude.
    'FiringRate',[],...
    'SNR',[]);
DefaultValues = struct('Unitwaveform',false,...
    'ISIviolation',0.1,...  % default threshold value is 0.1, or 10%
    'SessSpiketimeCheck',false,...
    'Amplitude',20,... % threshold amplitude value, default is 20uv (70 uV for subcortical neurons, for cortical neurons the Amp should be smaller)
    'WaveformSpread',1000,... % 1000um, about 50 channels?.
    'FiringRate',0.01,... % 1Hz
    'SNR',3); 
opsFieldName = fieldnames(selectops);
NumInputFields = length(opsFieldName);
for cf = 1 : NumInputFields
    FullClusSelectionops.(opsFieldName{cf}) = selectops.(opsFieldName{cf});
    % if nan value is given, using default threshold value for filtering
    if ~islogical(FullClusSelectionops.(opsFieldName{cf})) && isnan(FullClusSelectionops.(opsFieldName{cf}))
        FullClusSelectionops.(opsFieldName{cf}) = DefaultValues.(opsFieldName{cf});
    end
end

IsWaveDataGiven = 0;
if nargin > 2  % if the wavefrom data was already given for analysis
    IsWaveDataGiven = 1;
    UnitWaves = varargin{1};
    UnitFeature = varargin{2};
end

if nargin == 2 
    % if the inpput structure already contains the target data fields
   if ~isempty(obj.UnitWaves) && ~isempty(obj.UnitWaveFeatures)
       if (size(obj.UnitWaves,2) == 2 || size(obj.UnitWaves,2) == 3) && size(obj.UnitWaveFeatures,2) == 5 % check whether the field data format is the latest
           IsWaveDataGiven = 1;
           UnitWaves  = obj.UnitWaves;
           UnitFeature= obj.UnitWaveFeatures;
       end
   end
end

fprintf('\n');

if FullClusSelectionops.Unitwaveform % whether performing isoform waveform exclusion
    if IsWaveDataGiven
        UnitFeatures = UnitFeature;
    else
        UnitFeatures = SpikeWaveFeature(obj); % obj sould have raw bin file path and filename provided.
    end
    waveformExclusion = cell2mat(UnitFeatures(:,2)); % excluded unit inds
    fprintf('Waveform exclusion fraction is %d/%d, %.4f...\n',sum(waveformExclusion),numel(waveformExclusion),mean(waveformExclusion));
else
    waveformExclusion = false;
end
SpikeTimes = double(obj.SpikeTimeSample)/30000;
if ~isempty(FullClusSelectionops.ISIviolation)
   ViolationFracThres = FullClusSelectionops.ISIviolation; % the default threshold fraction is 0.1
   refDur = 0.002;
   minISI = 0.0005;
   
   AllClus = obj.GoodClusIDs;
   NumClusters = length(AllClus);
   ClusISIvolFrac = zeros(NumClusters,1);
   for cClus = 1 : NumClusters
       cClusSpiketime = SpikeTimes(obj.SpikeClus == AllClus(cClus));
       if obj.GoodClusFRs(cClus) > 10 % in case of a fast spiking neuron, the refDur should be less
            [ClusISIvolFrac(cClus),~] = ISIViolations(cClusSpiketime, minISI, refDur/2);
       else
           [ClusISIvolFrac(cClus),~] = ISIViolations(cClusSpiketime, minISI, refDur);
       end
   end
    ISIExclusion = ClusISIvolFrac >= ViolationFracThres;
    fprintf('ISI exclusion fraction is %d/%d, %.4f...\n',sum(ISIExclusion),numel(ISIExclusion),mean(ISIExclusion));
else
    ISIExclusion = false;
end

if FullClusSelectionops.SessSpiketimeCheck % session spike time distribution check
    if isempty(obj.TrigData_Bin{obj.CurrentSessInds})
        warning('The PSTH data havent been constructed yet, skip spike time consistance check.\n');
        sessSPdistributionExclusion = false;
    else
        RespCheckInds = SessResp_binnedcheckFun(obj);
        if isempty(RespCheckInds)
            sessSPdistributionExclusion = false;
        else
            sessSPdistributionExclusion = ~RespCheckInds;
            fprintf('Session spike time exclusion fraction is %d/%d, %.4f...\n',sum(sessSPdistributionExclusion),...
                numel(sessSPdistributionExclusion),mean(sessSPdistributionExclusion));
        end
    end
    
else
    sessSPdistributionExclusion = false;
end

if ~isempty(FullClusSelectionops.Amplitude) 
    if IsWaveDataGiven
        UnitFeatures = UnitFeature;
    else
        UnitFeatures = SpikeWaveFeature(obj);
    end
    UnitAmps = cat(1,UnitFeatures{:,4});
    AmpExcludeInds = isnan(UnitAmps) | UnitAmps < FullClusSelectionops.Amplitude;
    fprintf('Amplitude exclusion fraction is %d/%d, %.4f...\n',sum(AmpExcludeInds),numel(AmpExcludeInds),mean(AmpExcludeInds));
else
    AmpExcludeInds = false;
end

if ~isempty(FullClusSelectionops.WaveformSpread) % waveform spread of all channels
    if IsWaveDataGiven
        UnitFeatures = UnitFeature;
        UnitAllchnWaveData = UnitWaves;
    else
        if ~exist('UnitFeatures','var') || ~exist(fullfile(obj.ksFolder,'UnitwaveformDatas.mat'),'file')
            UnitFeatures = SpikeWaveFeature(obj);
        end
        AllchnData = load(fullfile(obj.ksFolder,'UnitwaveformDatas.mat'), 'UnitDatas');
        UnitAllchnWaveData = AllchnData.UnitDatas; % SPNums,channel(384),spikewindowlength    
    end
    
    ToughPeakInds = cell2mat(UnitFeatures(:,5));
    SpreadLengthAll = zeros(size(UnitAllchnWaveData,1),1);
    for cUnit = 1 : size(UnitAllchnWaveData,1)
        if any(isnan(ToughPeakInds(cUnit,:)))
            SpreadLengthAll(cUnit) = 3800; % make the spread length longer enough
        else
            SpreadLengthAll(cUnit) = peakAmpSpreadFun(UnitAllchnWaveData{cUnit,2}, ToughPeakInds(cUnit,:), obj.GoodClusMaxChn(cUnit)+1);
        end
    end
    AmpSpreadExcludeInds = SpreadLengthAll > FullClusSelectionops.WaveformSpread; % larger value indicates noise across all channels
    fprintf('AmpSpread exclusion fraction is %d/%d, %.4f...\n',sum(AmpSpreadExcludeInds),...
        numel(AmpSpreadExcludeInds),mean(AmpSpreadExcludeInds));
else
    AmpSpreadExcludeInds = false;
end


if ~isempty(FullClusSelectionops.FiringRate) % check task period FR, make it larger than 1 Hz
    TaskSessStartTime = obj.UsedTrigOnTime{1}(1);
    TaskSessEndTime = obj.UsedTrigOnTime{1}(end)+10; % extra 30 seconds after last trigger
    TaskDur = TaskSessEndTime - TaskSessStartTime;
    TaskFrs = zeros(numel(obj.GoodClusIDs),1);
    for cUU = 1 : numel(obj.GoodClusIDs)
       cUSPTimes =  obj.SpikeTimes(obj.SpikeClus == obj.GoodClusIDs(cUU));
       cUTask_sptimes = cUSPTimes(cUSPTimes > TaskSessStartTime & cUSPTimes < TaskSessEndTime);
       TaskFrs(cUU) = numel(cUTask_sptimes)/TaskDur;
    end
    
    FRExcludeInds = TaskFrs < FullClusSelectionops.FiringRate; %obj.FRIncludeClusFRs <= FullClusSelectionops.FiringRate;
%     FRExcludeInds = NewNPClusHandle.GoodClusFRs < FullClusSelectionops.FiringRate;
    fprintf('FR exclusion fraction is %d/%d, %.4f...\n',sum(FRExcludeInds),numel(FRExcludeInds),mean(FRExcludeInds));
else
    FRExcludeInds = false;
end

if ~isempty(FullClusSelectionops.SNR) % Amplitude SNR
    if IsWaveDataGiven
        UnitFeatures = UnitFeature;
        UnitAllchnWaveData = UnitWaves;
    else
        if ~exist('UnitFeatures','var') || ~exist(fullfile(obj.ksFolder,'UnitwaveformDatas.mat'),'file')
            UnitFeatures = SpikeWaveFeature(obj);
        end
        AllchnData = load(fullfile(obj.ksFolder,'UnitwaveformDatas.mat'), 'UnitDatas');
        UnitAllchnWaveData = AllchnData.UnitDatas; % SPNums,channel(384),spikewindowlength    
    end
    
    UnitAmps = cat(1,UnitFeatures{:,4});
    %%
    UnitSPWaveformAll = UnitAllchnWaveData(:,1);
    UnitNums = length(UnitSPWaveformAll);
    UnitSNRs = zeros(UnitNums, 1);
    for cUnit = 1 : UnitNums 
        if isnan(UnitAmps(cUnit))
            UnitSNRs(cUnit) = 0;
        else
            cUnitSPwaves = UnitSPWaveformAll{cUnit};
%             cUnitSPwaves((abs(cUnitSPwaves)) > 200) = nan;
            nanSPs = sum(isnan(cUnitSPwaves),2) > 0;
            cUnitSPwaves(nanSPs,:) = [];

            AvgWaveform = mean(cUnitSPwaves);
            Residues = cUnitSPwaves - AvgWaveform;
            ResValueSTD = std(Residues(:));
            
            BaselineAvg = mean(cUnitSPwaves(:,1:10),'all');
            OutlierThres = BaselineAvg + ResValueSTD*6;
            
            cUnitSPwaves((abs(cUnitSPwaves - BaselineAvg)) > OutlierThres) = nan;
            nanSPs2 = sum(isnan(cUnitSPwaves),2) > 0;
            cUnitSPwaves(nanSPs2,:) = [];
            
            AvgWaveform2 = mean(cUnitSPwaves);
            Residues2 = cUnitSPwaves - AvgWaveform2;
            ResValueSTDUsed = std(Residues2(:));
            
            % from siegle et al, 2021 nature paper, the SNR is defined as the
            % ratio between amplitude and residue std
            UnitSNRs(cUnit) = UnitAmps(cUnit) / ResValueSTDUsed;
        end
    end
    %%
    SNRExcludeInds = UnitSNRs < FullClusSelectionops.SNR;
    fprintf('AmpSNR exclusion fraction is %d/%d, %.4f...\n',sum(SNRExcludeInds),numel(SNRExcludeInds),mean(SNRExcludeInds));
else
    SNRExcludeInds = false;
end

OverAllExcludeInds = waveformExclusion | ISIExclusion | sessSPdistributionExclusion ...
    | AmpExcludeInds | AmpSpreadExcludeInds | FRExcludeInds | SNRExcludeInds;
fprintf('##################################################\n');
fprintf('Overall exclusion number is %d/%d, %.4f...\n',sum(OverAllExcludeInds),numel(OverAllExcludeInds),mean(OverAllExcludeInds));

fprintf('\n');
end



% isoformed waveform check function
function UnitFeatures = SpikeWaveFeature(obj,varargin)
    % function used to analysis single unit waveform features
    % the wave form features may includes firerate, peak-to-trough
    % width, refraction peak and so on

    % from "Nuo Li et al, 2016", trough-to-peak interval  less than
    % 0.35ms were defined as fast-spiking neuron and spike width
    % larger than 0.45ms as putative pyramidal neurons


    if isempty(obj.binfilePath) || isempty(obj.RawDataFilename)
        if ~isempty(varargin) && ~isempty(varargin{1})
            obj.binfilePath = varargin{1};
            possbinfilestrc = dir(fullfile(obj.binfilePath,'*.ap.bin'));
            if isempty(possbinfilestrc)
                error('target bin file doesn''t exists.');
            end
            obj.RawDataFilename = possbinfilestrc(1).name;
        else
            error('Bin file location is needed for spikewave extraction.');
        end
    end
    %             if isempty(obj.mmf) && eixst(fullfile(obj.binfilePath,obj.RawDataFilename))
    %                 fullpaths = fullfile(obj.binfilePath, obj.RawDataFilename);
    % %                 dataNBytes = get_file_size(fullpaths); % determine number of bytes per sample
    % %                 obj.Numsamp = dataNBytes/(2*obj.NumChn);
    % %                 obj.mmf = memmapfile(fullpaths, 'Format', {obj.Datatype, [obj.NumChn obj.Numsamp], 'x'});
    % %
    %             end
    fullpaths = fullfile(obj.binfilePath, obj.RawDataFilename);
    ftempid = fopen(fullpaths);

    if ~isfolder(fullfile(obj.ksFolder,'UnitWaveforms'))
        mkdir(fullfile(obj.ksFolder,'UnitWaveforms'));
    end

    NumofUnit = length(obj.UsedClus_IDs);
    UnitDatas = cell(NumofUnit,2);
    UnitFeatures = cell(NumofUnit,4);
    for cUnit = 1 : NumofUnit
        % cUnit = 137;
        %% close;
        cClusInds = obj.UsedClus_IDs(cUnit);
        cClusChannel = obj.ChannelUseds_id(cUnit);
        cClus_Sptimes = obj.SpikeTimeSample(obj.SpikeClus == cClusInds);
        if numel(cClus_Sptimes) < 2000
            UsedSptimes = cClus_Sptimes;
            SPNums = length(UsedSptimes);
        else
            UsedSptimes = cClus_Sptimes(randsample(numel(cClus_Sptimes),2000));
            SPNums = 2000;
        end
        cspWaveform = nan(SPNums,diff(obj.WaveWinSamples));
        AllChannelWaveData = nan(SPNums,384,diff(obj.WaveWinSamples));
        for csp = 1 : SPNums
            cspTime = UsedSptimes(csp);
            cspStartInds = cspTime+obj.WaveWinSamples(1);
            cspEndInds = cspTime+obj.WaveWinSamples(2);
            offsetTimeSample = cspStartInds - 1;
            if offsetTimeSample < 0 || cspEndInds > obj.Numsamp
                continue;
            end
            offsets = 385*(cspStartInds-1)*2;
            status = fseek(ftempid,offsets,'bof');
            if ~status
                % correct offset value is set
                AllChnDatas = fread(ftempid,[385 diff(obj.WaveWinSamples)],'int16');
                cspWaveform(csp,:) = AllChnDatas(cClusChannel,:);
                AllChannelWaveData(csp,:,:) = AllChnDatas(1:384,:); % for waveform spread calculation
            end
        end

%             huf = figure('visible','off');
        AvgWaves = mean(cspWaveform,'omitnan');
        UnitDatas{cUnit,1} = cspWaveform;
        UnitDatas{cUnit,2} = squeeze(mean(AllChannelWaveData,'omitnan'));
        %%
%             plot(AvgWaves);
        try
            [isabnorm,isUsedVec,waveAmplitude,toughPeakInds] = iswaveformatypical(AvgWaves,obj.WaveWinSamples,false);
        catch ME
            fprintf('Errors');
        end
%             title([num2str(cClusChannel,'chn=%d'),'  ',num2str(1-isabnorm,'Ispass = %d')]);
        wavefeature = SPwavefeature(AvgWaves,obj.WaveWinSamples);
%             text(6,0.8*max(AvgWaves),{sprintf('tough2peak = %d',wavefeature.tough2peakT);...
%                 sprintf('posthyper = %d',wavefeature.postHyperT)},'FontSize',8);

%             if wavefeature.IsPrePosPeak
%                 text(50,0.5*max(AvgWaves),{sprintf('pre2postpospeakratio = %.3f',wavefeature.pre2post_peakratio)},'color','r','FontSize',8);
%             end
        UnitFeatures(cUnit,:) = {wavefeature,isabnorm,isUsedVec,waveAmplitude,toughPeakInds};
        %

%             saveName = fullfile(obj.ksFolder,'UnitWaveforms',sprintf('Unit%d waveform plot save',cUnit));
%             saveas(huf,saveName);
%             saveas(huf,saveName,'png');
%             
%             close(huf);

    end

    save(fullfile(obj.ksFolder,'UnitwaveformDatas.mat'), 'UnitDatas', 'UnitFeatures', '-v7.3');

end


function [fpRate, numViolations] = ISIViolations(spikeTrain, minISI, refDur)
% computes an estimated false positive rate of the spikes in the given
% spike train. You probably don't want this to be greater than a few
% percent of the spikes. 
%
% - minISI [sec] = minimum *possible* ISI (based on your cutoff window); likely 1ms
% or so. It's important that you have this number right.
% - refDur [sec] = estimate of the duration of the refractory period; suggested value = 0.002.
% It's also important that you have this number right, but there's no way
% to know... also, if it's a fast spiking cell, you could use a smaller
% value than for regular spiking.

% The false positive value should less than 0.1, Ref from 
% https://doi.org/10.1038/s41586-020-03166-8

totalRate = length(spikeTrain)/spikeTrain(end);
numViolations = sum(diff(spikeTrain) <= refDur);

% Spikes occurring under the minimum ISI are by definition false positives;
% their total rate relative to the rate of the neuron overall gives the
% estimated false positive rate.
% NOTE: This does not use the equation from Dan Hill's paper (see below)
% but instead uses the equation from his UltraMegaSort
violationTime = 2*length(spikeTrain)*(refDur-minISI); % total time available for violations - 
                                                    % there is an available
                                                    % window of length
                                                    % (refDur-minISI) after
                                                    % each spike.
violationRate = numViolations/violationTime;
fpRate = violationRate/totalRate;

if fpRate>1
    % it is nonsense to have a rate >1, however having such large rates
    % does tell you something interesting, namely that the assumptions of
    % this analysis are failing!
    fpRate = 1; 
end

end

function RemainedInds = SessResp_binnedcheckFun(ProbNPSess)
TrigDataFull = cellfun(@full,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}(:,1),'un',0);
SMBinDataMtx = permute(cat(3,TrigDataFull{:}),[1,3,2]);

TrBatchSize = 10;
TrAvgSPnums = mean(SMBinDataMtx,3);
[TrNums, ROINums] = size(TrAvgSPnums);
%%
BatchNums = round(TrNums/TrBatchSize);
BatchBinnedDatas = zeros(ROINums, BatchNums);
ybase = 1;
for cy = 1 : BatchNums
    yend = min(TrBatchSize*cy, TrNums);
    BatchBinnedDatas(:,cy) = mean(TrAvgSPnums(ybase:yend,:));
    ybase = TrBatchSize*cy+1;
end

%%
binMaxValues = prctile(BatchBinnedDatas,95,2);
Isbinlessthanhalfpeak = (BatchBinnedDatas - binMaxValues/2) < 0;
binLessThanhalfPeak = mean(Isbinlessthanhalfpeak, 2);

FRBasedInds = mean(BatchBinnedDatas > 0.1,2);
FRBasedInds2 = mean(BatchBinnedDatas > 10,2);
% %%
% cR = 2;
% % close;
% figure;
% 
% plot(BatchBinnedDatas(cR,:));
% title(num2str(binLessThanhalfPeak(cR),'%.4f'));

%% criterias for unit exclusion
% 1, the binned value should have no more than 70% of the bins have value
% less than half of the maximum value
% 2, for those have less than 70% bins below half-maximum, the consecutive
% bins should not more than 200 trials (normally 20 bins with a bin size of 10 trials)

% criteria 1
criteria1_inds = binLessThanhalfPeak < 0.3;


% criteria 2
UsedInds2 = binLessThanhalfPeak >= 0.3;
UsedInds2_Real = find(UsedInds2);

tempUsedUnit_isless = Isbinlessthanhalfpeak(UsedInds2,:);
tempUsed_binlessthanhalf = binLessThanhalfPeak(UsedInds2);

leftUnitNum = length(tempUsed_binlessthanhalf);
IsGivenasNaN = zeros(leftUnitNum, 1);
for cU = 1 : leftUnitNum
   if tempUsed_binlessthanhalf(cU) < 0.75
       % only use bin number fraction less than 0.5 but more than 0.3
       cunit_binisless =  tempUsedUnit_isless(cU,:);
       binlogi_SM = conv(cunit_binisless, (1/21)*ones(21,1),'same');
       binlogi_SM(1) = 0;
       binlogi_SM(end) = 0;
       Is_consecutiveBins = find(binlogi_SM > 0.99, 1, 'first');
       if ~isempty(Is_consecutiveBins)
           if ~(all(cunit_binisless(1:3) == 0) && all(cunit_binisless(end-2:end) == 0))
               IsGivenasNaN(cU) = NaN;
           end
           if FRBasedInds(UsedInds2_Real(cU)) > 0.6
               IsGivenasNaN(cU) = 0;
           end
       end
   else
       if FRBasedInds2(UsedInds2_Real(cU)) < 0.9
            IsGivenasNaN(cU) = NaN;
       end
   end
end

criteria2_inds = true(size(criteria1_inds));
criteria2_inds(UsedInds2_Real(isnan(IsGivenasNaN))) = false;

% TotalUnits = size(SMBinDataMtx,2);
% RemainedInds = true(TotalUnits,1);
% RemainedInds(isnan(UsedInds1_Real)) = false;
RemainedInds = criteria1_inds | criteria2_inds;


% if exist(fullfile(ProbNPSess.ksFolder,'UnitspikeAmpSave.mat'),'file') 
%     % load unit amplitude data if exists
%    cAmpfData = load(fullfile(ProbNPSess.ksFolder,'UnitspikeAmpSave.mat'));
%    UintExplainV = cellfun(@(x) x.Ordinary,cAmpfData.UnitLlmfits(:,2));
%    AmpExcludeInds = UintExplainV(:) > 0.5 & binLessThanhalfPeak(:) > 0.1; % is the varience explain is too large, excluded it
%    
%    RemainedInds = RemainedInds & ~AmpExcludeInds;
% else
%    warning('Unable to load spike amplitude datas.\n'); 
% end

end


function SpreadLength = peakAmpSpreadFun(AllChnAmpData, toughPeakInds, MaxChnIndex)
% function to calculate the amplitude spread, which is the channel have 12%
% of the maximum channel amplitude

% UnitAllchnWaveData = AllchnData.UnitDatas; % SPNums,channel(384),spikewindowlength    

% Amplitude4AllSP = squeeze(AllChnAmpData(:,:,toughPeakInds(2)) - AllChnAmpData(:,:,toughPeakInds(1)));
% ChnAmp_spikeAvg = mean(Amplitude4AllSP);
try
    ChnAmp_spikeAvg = AllChnAmpData(:,toughPeakInds(2)) - AllChnAmpData(:,toughPeakInds(1));
catch ME
    SpreadLength = 2000;
   fprintf('Something is wrong.\n'); 
    return;
end
MaximumAmp = ChnAmp_spikeAvg(MaxChnIndex);
AmpThres = MaximumAmp * 0.12;

LowerChnThresInds = find(ChnAmp_spikeAvg(1:MaxChnIndex) < AmpThres,1,'last');
if isempty(LowerChnThresInds)
    LowerChnThresInds = 0;
end
RealStartInds = LowerChnThresInds + 1;

HigherChnThresInds = find(ChnAmp_spikeAvg(MaxChnIndex:end) < AmpThres , 1, 'first');
if isempty(HigherChnThresInds)
    HigherChnThresInds = numel(ChnAmp_spikeAvg)+1;
else
    HigherChnThresInds = HigherChnThresInds + MaxChnIndex;
end
RealEndInds = HigherChnThresInds - 1;

if RealEndInds < RealStartInds
    % abnormal distribution for current unit
    fprintf('Something is wrong 2.\n');
    SpreadLength = 2000;
    return;
end
SpreadLength = (RealEndInds - RealStartInds) * 20; % in um, for NP 1.0 probe

end
