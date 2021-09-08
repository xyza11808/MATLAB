
% all the anatomy results of the probe location and the spike sorting
% results were saved at different locations, but we use a xls file to save
% each probe's anatomy location and spike soorting results, so that we can
% load that xls file and merge the channel location with both spike times
% and behavior datas

% The default .xls file name is "probeANDNPData_location.xlsx" which
% contains all the mentioned results
clear
clc

[xlsfilefn,xlsfilefp,xlsfilefnfi] = uigetfile('probeANDNPData_location*.xlsx');
if ~xlsfilefnfi
    return;
end

xlsfile_fullpath = fullfile(xlsfilefp,xlsfilefn);
try
    DataCellWithNames = readcell(xlsfile_fullpath);
catch
    [~,~,DataCellWithNames] = xlsread(xlsfile_fullpath);
end
DataCell = DataCellWithNames(2:end,:);
%%
ProbeNums = size(DataCell,1);
BadProbeInds = cellfun(@(x) isempty(x) | strcmpi(x,'NaN') | ismissing({x}),DataCell(:,3)) | ... % lack of ks folder path
    cellfun(@(x) isempty(x) | strcmpi(x,'NaN') | ismissing({x}),DataCell(:,4)) | ... % lack of behavior data path
    cellfun(@(x) strcmpi(x,'No'),DataCell(:,7)); % unable to check probe location

UsedDataCells = DataCell(~BadProbeInds,:);

%%
Errors = cell(size(UsedDataCells,1),1);
for cProbe = 1 : size(UsedDataCells,1)
% cProbe = 6;
    try
        %
        clearvars ProbNPSess
        fprintf('Processing probe %d...\n',cProbe);
        cProbeStr = num2str(UsedDataCells{cProbe,1},'Probe%d');
        ProbeFileLocation = UsedDataCells{cProbe,2};
        [~,~,ProbeChn_regionCells] = xlsread(ProbeFileLocation,cProbeStr);
        ProbespikeFolder = UsedDataCells{cProbe,3};
        BehaviorDataPath = UsedDataCells{cProbe,4};
        [fPath, ~, ~] = fileparts(BehaviorDataPath);
        PassiveFileFullPath = fullfile(fPath,UsedDataCells{cProbe,5});

        if ~exist(ProbeFileLocation,'file') || ~exist(fullfile(ProbespikeFolder,'kilosort3'),'dir') || ...
                ~exist(BehaviorDataPath,'file')
            warning('At least one of the file location string doesnt exist.');
%             return;
            error('File does not exists');
        end
        BehaviorExcludeInds = UsedDataCells{cProbe,6};
        %
        if exist(fullfile(ProbespikeFolder,'kilosort3','ClassAnaHandleAll.mat'),'file')
            load(fullfile(ProbespikeFolder,'kilosort3','ClassAnaHandleAll.mat'));
        else
            ProbNPSess = NPspikeDataMining(fullfile(ProbespikeFolder,'kilosort3'),'Task');
        end
        %
%         if exist(fullfile(ProbNPSess.ksFolder,'ClassAnaHandle.mat'),'file')
%             continue;
%         end
        if contains(ProbespikeFolder,'b103a04_20210408')
            ProbNPSess = ProbNPSess.triggerOnsetTime([],[2,6],[]); 
        else
            ProbNPSess = ProbNPSess.triggerOnsetTime([],[6,2],[]); 
        end
        
        %
        ProbNPSess.CurrentSessInds = strcmpi('task',ProbNPSess.SessTypeStrs);
        %
        if isempty(ProbNPSess.UnitWaves) || isempty(ProbNPSess.UnitWaveFeatures)
            % unit spike waveform extraction
            fprintf('Current ks folder path is: \n <%s> \nPlease select the corresponded bin file location.\n', ProbespikeFolder);
            RawbinfilePath = uigetdir(pwd,'Please select the raw bin file path');
            if ~ischar(RawbinfilePath)
                fprintf('No file was selected.!\n');
                return;
            end
            ProbNPSess = ProbNPSess.SpikeWaveFeature(RawbinfilePath);
            
        end
        % exclude isoformed spike wave units
        ProbNPSess = ProbNPSess.wavefeatureExclusion;
        %
        task_colorplot_script;
        %
        ProbNPSess.CurrentSessInds = strcmpi('passive',ProbNPSess.SessTypeStrs);
        Passive_colorplot_script;
        
        ProbNPSess.refractoryPeriodCal([],2,1e-3);
        %
        save(fullfile(ProbNPSess.ksFolder,'ClassAnaHandleAll.mat'),'ProbNPSess','-v7.3');
    catch ME
        disp(ME.message);
        Errors{cProbe} = ME;
    end
end
%% # replot the single unit colorplot and raster plot, correct the licktime plots
% updates plot the licks aligned to answer times

Errors3 = cell(size(UsedDataCells,1),1);
for cProbe = 1 : size(UsedDataCells,1)
% cProbe = 6;
    try
        %
        clearvars ProbNPSess
        fprintf('Processing probe %d...\n',cProbe);
        cProbeStr = num2str(UsedDataCells{cProbe,1},'Probe%d');
        ProbeFileLocation = UsedDataCells{cProbe,2};
        [~,~,ProbeChn_regionCells] = xlsread(ProbeFileLocation,cProbeStr);
        ProbespikeFolder = UsedDataCells{cProbe,3};
        BehaviorDataPath = UsedDataCells{cProbe,4};
        [fPath, ~, ~] = fileparts(BehaviorDataPath);
        PassiveFileFullPath = fullfile(fPath,UsedDataCells{cProbe,5});
        %
        if ~exist(ProbeFileLocation,'file') || ~exist(fullfile(ProbespikeFolder,'kilosort3'),'dir') || ...
                ~exist(BehaviorDataPath,'file')
            warning('At least one of the file location string does not exist.');
%             return;
            error('File does not exists');
        end
        BehaviorExcludeInds = UsedDataCells{cProbe,6};
        %
        if ~exist(fullfile(ProbespikeFolder,'kilosort3','ClassAnaHandle2.mat'),'file')
            error('Unable to find existed NPsess analysis handle saved results.');
        end
        load(fullfile(ProbespikeFolder,'kilosort3','ClassAnaHandle2.mat'));
        
        ProbNPSess.CurrentSessInds = strcmpi('task',ProbNPSess.SessTypeStrs);
        ProbNPSess.TrigAlignType = {'stim','trigger'};
        task_colorplot_script;
        
%         ProbNPSess.CurrentSessInds = strcmpi('passive',ProbNPSess.SessTypeStrs);
%         Passive_colorplot_script;
        
        save(fullfile(ProbNPSess.ksFolder,'ClassAnaHandle2.mat'),'ProbNPSess','-v7.3');
        %
    catch ME
        Errors3{cProbe} = ME;
    end
end

%% spike autocorrelation function
% PlotClusInds = 1:3;
% totalTimes = obj.Numsamp/obj.SpikeStrc.sample_rate;
% SumInds = false(numel(obj.SpikeClus),1);
% for cInds = 1 : length(PlotClusInds)
%     ClusInds = obj.SpikeClus == obj.UsedClus_IDs(PlotClusInds(cInds));
%     SumInds = SumInds | ClusInds;
% end
% 
% ClusSPAll = obj.SpikeTimes(SumInds);
% ClusSPclus = obj.SpikeClus(SumInds);
% %%
% clusccgStrc = Spikeccgfun(ClusSPAll,ClusSPclus,1.5,0.01);

%% refractory period calculation
Errors2 = cell(size(UsedDataCells,1),1);
SessClusCCgs = cell(size(UsedDataCells,1),1);
for cProbe = 1 : size(UsedDataCells,1)
% cProbe = 6;
    try
        %
        clearvars ProbNPSess
        fprintf('Processing probe %d...\n',cProbe);
        cProbeStr = num2str(UsedDataCells{cProbe,1},'Probe%d');
        ProbeFileLocation = UsedDataCells{cProbe,2};
        [~,~,ProbeChn_regionCells] = xlsread(ProbeFileLocation,cProbeStr);
        ProbespikeFolder = UsedDataCells{cProbe,3};
        BehaviorDataPath = UsedDataCells{cProbe,4};
        [fPath, ~, ~] = fileparts(BehaviorDataPath);
        PassiveFileFullPath = fullfile(fPath,UsedDataCells{cProbe,5});
        %
        if ~exist(ProbeFileLocation,'file') || ~exist(fullfile(ProbespikeFolder,'kilosort3'),'dir') || ...
                ~exist(BehaviorDataPath,'file')
            warning('At least one of the file location string does not exist.');
%             return;
            error('File does not exists');
        end
        BehaviorExcludeInds = UsedDataCells{cProbe,6};
        %
        if ~exist(fullfile(ProbespikeFolder,'kilosort3','ClassAnaHandle.mat'),'file')
            error('Unable to find existed NPsess analysis handle saved results.');
        end
        load(fullfile(ProbespikeFolder,'kilosort3','ClassAnaHandle.mat'));
        SessClusCCgs{cProbe} = ProbNPSess.refractoryPeriodCal([],2,1e-3);
%         ProbNPSess = NPspikeDataMining(fullfile(ProbespikeFolder,'kilosort3'),'Task');
  %      
    catch ME
        Errors2{cProbe} = ME;
    end
end

%% extract raw spike waveform from the raw bin file data
% since the raw bin file location is not for sure, this section will not
% run automatically, but the raw bin file location have to been predefined

for cProbe = 3 : size(UsedDataCells,1)
% cProbe = 6;
    try
        %%
        clearvars ProbNPSess
        fprintf('Processing probe %d...\n',cProbe);
        cProbeStr = num2str(UsedDataCells{cProbe,1},'Probe%d');
        ProbeFileLocation = UsedDataCells{cProbe,2};
        [~,~,ProbeChn_regionCells] = xlsread(ProbeFileLocation,cProbeStr);
        ProbespikeFolder = UsedDataCells{cProbe,3};
        BehaviorDataPath = UsedDataCells{cProbe,4};
        [fPath, ~, ~] = fileparts(BehaviorDataPath);
        PassiveFileFullPath = fullfile(fPath,UsedDataCells{cProbe,5});
        %
        if ~exist(ProbeFileLocation,'file') || ~exist(fullfile(ProbespikeFolder,'kilosort3'),'dir') || ...
                ~exist(BehaviorDataPath,'file')
            warning('At least one of the file location string does not exist.');
%             return;
            error('File does not exists');
        end
        BehaviorExcludeInds = UsedDataCells{cProbe,6};
        %%
        if ~exist(fullfile(ProbespikeFolder,'kilosort3','ClassAnaHandle.mat'),'file')
            error('Unable to find existed NPsess analysis handle saved results.');
        end
        load(fullfile(ProbespikeFolder,'kilosort3','ClassAnaHandle.mat'));
        
        fprintf('Current ks folder path is: \n <%s> \nPlease select the corresponded bin file location.\n', ProbespikeFolder);
        RawbinfilePath = uigetdir(pwd,'Please select the raw bin file path');
        if ~ischar(RawbinfilePath)
            fprintf('No file was selected.!\n');
            return;
        end
        ProbNPSess = ProbNPSess.SpikeWaveFeature(RawbinfilePath);
        
        save(fullfile(ProbNPSess.ksFolder,'ClassAnaHandleWithwave.mat'),'ProbNPSess','-v7.3');
        %%
        catch ME
        Errors2{cProbe} = ME;
    end
end


%% ways to calculate the refractory period for each unit

% firstly, the ccg save file should be loaded before running following
% codes

% load(fullfile(ProbNPSess.ksFolder,'AllClusccgData.mat'));
default_binsize = 1e-3;
if ~exist('binsize_time','var')
    binsize_time = default_binsize;
end
baselinefr_timebin = [600, 900]; % ms
baselinefr_bin = round(baselinefr_timebin/1000/default_binsize);

% ccgData = ClusSelfccg{1};
RefracBinNum = cellfun(@(x) refractoryperiodFun(x,baselinefr_bin),ClusSelfccg);
RefracBinTime = RefracBinNum*binsize_time;








%%







