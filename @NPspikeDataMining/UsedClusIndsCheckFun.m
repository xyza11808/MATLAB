function UsedClusIndsCheckFun(obj,selectops)
% this function is used to check the used cluster criteria, using the true
% value fields in selectops to check the used cluster selection criteria
% and perform cluster selection

FullClusSelectionops = struct('Unitwaveform',false,...
    'ISIviolation',[],...
    'SessSpiketimeCheck',false,...
    'Amplitude',[],... % threshold amplitude value
    'WaveformSpread',[],... % in um, Spatial extent (in μm) of channels in which the waveform amplitude exceeds 12% of the peak amplitude.
    'FiringRate',[]);

opsFieldName = fieldnames(selectops);
NumInputFields = length(opsFieldName);
for cf = 1 : NumInputFields
    FullClusSelectionops.(opsFieldName{cf}) = selectops.(opsFieldName{cf});
end
f
if FullClusSelectionops.Unitwaveform % whether performing isoformed waveform exclusion
    UnitFeatures = SpikeWaveFeature(obj); % obj sould have raw bin file path and filename provided.
    waveformExclusion = cell2mat(UnitFeatures(:,2)); % excluded unit inds
else
    waveformExclusion = false;
end

if ~isempty(FullClusSelectionops.ISIviolation)
   ViolationFracThres = FullClusSelectionops.ISIviolation; % the default threshold fraction is 0.1
   refDur = 0.002;
   minISI = 0.0005;

   AllClus = obj.FRIncludeClus;
   NumClusters = length(AllClus);
   ClusISIvolFrac = zeros(NumClusters,1);
   for cClus = 1 : NumClusters
       cClusSpiketime = obj.SpikeTimes(obj.SpikeClus == AllClus(cClus));
       [ClusISIvolFrac(cClus),~] = ISIViolations(cClusSpiketime, minISI, refDur);
   end
    ISIExclusion = ClusISIvolFrac >= ViolationFracThres;
else
    ISIExclusion = false;
end

if FullClusSelectionops.SessSpiketimeCheck % session spike time distribution check
    sessSPdistributionExclusion = SessResp_binnedcheckFun(obj);
else
    sessSPdistributionExclusion = false;
end

if ~isempty(FullClusSelectionops.Amplitude) % default threshold value is 70uv
    if ~exist('UnitFeatures','var')
        UnitFeatures = SpikeWaveFeature(obj);
    end
    UnitAmps = cell2mat(UnitFeatures(:,4));
    AmpExcludeInds = UnitAmps < FullClusSelectionops.Amplitude;
else
    AmpExcludeInds = false;
end

if ~isempty(FullClusSelectionops.WaveformSpread) % waveform spread of all channels
    AllchnData = load(fullfile(obj.ksFolder,'UnitwaveformDatas.mat'), 'UnitDatas');
    if ~exist('UnitFeatures','var') || ~exist(fullfile(obj.ksFolder,'UnitwaveformDatas.mat'),'file')
        UnitFeatures = SpikeWaveFeature(obj);
    end
    ToughPeakInds = cell2mat(UnitFeatures(:,5));
    UnitAllchnWaveData = AllchnData.UnitDatas; % SPNums,channel(384),spikewindowlength    
    SpreadLengthAll = zeros(size(UnitAllchnWaveData,1),1);
    for cUnit = 1 : size(UnitAllchnWaveData,1)
        SpreadLengthAll(cUnit) = peakAmpSpreadFun(UnitAllchnWaveData{cUnit,2}, ToughPeakInds, obj.FRIncludeChans(cUnit));
    end
    AmpSpreadExcludeInds = SpreadLengthAll > FullClusSelectionops.WaveformSpread; % larger value indicates noise across all channels
else
    AmpSpreadExcludeInds = false;
end


if ~isempty(FullClusSelectionops.FiringRate)
    FRExcludeInds = obj.FRIncludeClusFRs <= FullClusSelectionops.FiringRate;
else
    FRExcludeInds = false;
end



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
        UnitDatas{cUnit,2} = AllChannelWaveData;
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

