% FolderPath = pwd;
clearvars NewNPClusHandle
FolderPath = ksfolder;
load(fullfile(FolderPath,'NewClassHandle2.mat'));
load(fullfile(FolderPath,'TrigTimeANDallSampNum.mat'));

%%
% SpikeClus = readNPY(fullfile(FolderPath, 'spike_clusters.npy'));
% SpikeTimeSample = readNPY(fullfile(FolderPath, 'spike_times.npy'));
% SpikeStrc = loadParamsPy(fullfile(FolderPath, 'params.py'));
SpikeTimes = single(NewNPClusHandle.SpikeTimeSample)/30000;

TotalSampleTime = single(TotalSampleNums)/30000;
SpikeClus = NewNPClusHandle.SpikeClus;
%%
% ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TaskTrigOnTimes = ProbNPSess.UsedTrigOnTime{ProbNPSess.CurrentSessInds};

BlockSectionInfo = Bev2blockinfoFun(behavResults);

BlockEndsInds = BlockSectionInfo.BlockTrScales(:,2); % where block tr ends
if BlockEndsInds(end) ~= numel(TaskTrigOnTimes)
    AfterBlockSWTrOnTime = TaskTrigOnTimes(BlockEndsInds+1);
else
    AfterBlockSWTrOnTime = [TaskTrigOnTimes(BlockEndsInds(1:end-1) + 1); TaskTrigOnTimes(end)+10];
end
TaskStartTime = TaskTrigOnTimes(1);
TaskEndsTime = TaskTrigOnTimes(end)+10;

% UnitClusIDTypes = unique(SpikeClus);
% UnitClusIDNums = length(UnitClusIDTypes);

UnitClusIDTypes = NewNPClusHandle.UsedClus_IDs;
UnitClusIDNums = length(UnitClusIDTypes);
UnitClusChns = NewNPClusHandle.ChannelUseds_id-1;
%%
figSaveFolder = fullfile(FolderPath,'UsedUnitSPtimeAndTimeAmp');
if ~isfolder(figSaveFolder)
    mkdir(figSaveFolder);
end

%%
% close;
% cClusID = 159;
CountEdges = [0:10:TotalSampleTime,TotalSampleTime];
CountCents = CountEdges(1:end-1)+5;
UnitFRDatas = cell(UnitClusIDNums,4);
for cClusIdInds = 1 : UnitClusIDNums
    cClusID = UnitClusIDTypes(cClusIdInds);
    cID_Inds = SpikeClus == cClusID;
    cClusSPTs = SpikeTimes(cID_Inds);
    cU_chn = UnitClusChns(cClusIdInds);
    
    OverAllFR = numel(cClusSPTs)/TotalSampleTime;
%     if OverAllFR < 0.1
%         continue;
%     end
    [Counts, ~, loc] = histcounts(cClusSPTs,CountEdges);

    BlockFRs = zeros(BlockSectionInfo.NumBlocks, 1);
    for cB = 1 : BlockSectionInfo.NumBlocks
        if cB == 1
            cB_StartEnd = [TaskStartTime, AfterBlockSWTrOnTime(cB)];
        else
            cB_StartEnd = [AfterBlockSWTrOnTime(cB-1)+1,AfterBlockSWTrOnTime(cB)];
        end
        cBFR = cClusSPTs(cClusSPTs >= cB_StartEnd(1) & cClusSPTs < cB_StartEnd(2));
        BlockFRs(cB) = numel(cBFR)/(diff(cB_StartEnd));

    end


    hf = figure('position',[100 100 680 280],'Visible','off');
%     subplot(311);
    hold on
    plot(CountCents,Counts/10,'ko');
    yscales = get(gca,'ylim');
    line([TaskStartTime TaskStartTime],yscales,'Color','b','linewidth',1.2,'linestyle','--');
    line([TaskEndsTime TaskEndsTime],yscales,'Color','r','linewidth',1.2,'linestyle','--');
    for cB = 1 : BlockSectionInfo.NumBlocks
        cb_BlockEndsInds = AfterBlockSWTrOnTime(cB);
        line([cb_BlockEndsInds cb_BlockEndsInds]-0.5,yscales,'Color','m','linewidth',1.4,'linestyle','-');
        text(cb_BlockEndsInds-800,yscales(2)*0.95,num2str(BlockFRs(cB),'FR=%.2f'),'Color','m','FontSize',10);
    end
    xlabel('Time (s)');
    ylabel('Firing rate (Hz)');
    title(sprintf('ClusID = %d, Chn = %d, OverAllFR = %.3f',cClusID,cU_chn,OverAllFR));
    set(gca,'FontSize',12);
   
    cFileSavePath = fullfile(figSaveFolder,sprintf('ClusID %d sptime and AmpPlot',cClusID));
    saveas(hf,cFileSavePath);
%     print(hf,cFileSavePath,'-dpdf','-bestfit');
    print(hf,cFileSavePath,'-dpng','-r350');
    close(hf);
    UnitFRDatas(cClusIdInds,:) = {OverAllFR, BlockFRs,CountCents,Counts/10};
end

dataSaveName = fullfile(figSaveFolder,'FRDataSave.mat');
save(dataSaveName,'UnitFRDatas','AfterBlockSWTrOnTime','UnitClusChns',...
    'UnitClusIDTypes','TaskStartTime','TaskEndsTime','-v7.3');





