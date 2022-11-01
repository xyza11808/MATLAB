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
       if size(obj.UnitWaves,2) == 3 && size(obj.UnitWaveFeatures,2) == 5 % check whether the field data format is the latest
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
    UnitAmps = cell2mat(UnitFeatures(:,4));
    AmpExcludeInds = UnitAmps < FullClusSelectionops.Amplitude;
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
        SpreadLengthAll(cUnit) = peakAmpSpreadFun(UnitAllchnWaveData{cUnit,2}, ToughPeakInds(cUnit,:), obj.GoodClusMaxChn(cUnit)+1);
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
    
    UnitAmps = cell2mat(UnitFeatures(:,4));
    
    UnitSPWaveformAll = UnitAllchnWaveData(:,1);
    UnitNums = length(UnitSPWaveformAll);
    UnitSNRs = zeros(UnitNums, 1);
    for cUnit = 1 : UnitNums 
        cUnitSPwaves = UnitSPWaveformAll{cUnit};
        nanSPs = sum(isnan(cUnitSPwaves),2) > 0;
        cUnitSPwaves(nanSPs,:) = [];
        
        AvgWaveform = mean(cUnitSPwaves);
        Residues = cUnitSPwaves - AvgWaveform;
        ResValueSTD = std(Residues(:));
        
        % from siegle et al, 2021 nature paper, the SNR is defined as the
        % ratio between amplitude and residue std
        UnitSNRs(cUnit) = UnitAmps(cUnit) / ResValueSTD;
        
    end
    
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

