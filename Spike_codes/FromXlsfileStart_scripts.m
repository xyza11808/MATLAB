
% all the anatomy results of the probe location and the spike sorting
% results were saved at different locations, but we use a xls file to save
% each probe's anatomy location and spike soorting results, so that we can
% load that xls file and merge the channel location with both spike times
% and behavior datas

% The default .xls file name is "probeANDNPData_location.xlsx" which
% contains all the mentioned results
clear
clc

[xlsfilefn,xlsfilefp,xlsfilefnfi] = uigetfile('probeANDNPData_location.xlsx');
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
cProbe = 2;
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
    return;
end
BehaviorExcludeInds = UsedDataCells{cProbe,6};
%%
ProbNPSess = NPspikeDataMining(fullfile(ProbespikeFolder,'kilosort3'),'Task');
ProbNPSess = ProbNPSess.triggerOnsetTime([],[6,2],[]); 

%%
ProbNPSess.CurrentSessInds = strcmpi('task',ProbNPSess.SessTypeStrs);

task_colorplot_script;
%%
ProbNPSess.CurrentSessInds = strcmpi('passive',ProbNPSess.SessTypeStrs);
Passive_colorplot_script;

%%
save(fullfile(ProbNPSess.ksFolder,'ClassAnaHandle.mat'),'ProbNPSess','-v7.3');

%% spike autocorrelation function
PlotClusInds = 1:3;
totalTimes = obj.Numsamp/obj.SpikeStrc.sample_rate;
SumInds = false(numel(obj.SpikeClus),1);
for cInds = 1 : length(PlotClusInds)
    ClusInds = obj.SpikeClus == obj.UsedClus_IDs(PlotClusInds(cInds));
    SumInds = SumInds | ClusInds;
end

ClusSPAll = obj.SpikeTimes(SumInds);
ClusSPclus = obj.SpikeClus(SumInds);
%%
clusccgStrc = Spikeccgfun(ClusSPAll,ClusSPclus,1.5,0.01);




