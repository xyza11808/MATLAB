

load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

PlotSavePath = fullfile(ksfolder,'Regressor_ANA');
RegressorDatafile = fullfile(PlotSavePath,'REgressorDataSave.mat');
load(RegressorDatafile);

% prepare unit related area strings
NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
if strcmpi(NewAdd_ExistAreaNames(end),'Others')
    NewAdd_ExistAreaNames(end) = [];
end
NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

Numfieldnames = length(NewAdd_ExistAreaNames);
oExistField_ClusIDs = [];
AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
AreaNameIndex = cell(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    oExistField_ClusIDs = [oExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    AreaNameIndex(cA) = {cA*ones(AreaUnitNumbers(cA),1)};
end

AreaNameIndexVec = cell2mat(AreaNameIndex);

%%
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix

if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;
StimOnsetTimeBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
[TrialNums,UnitNums,FrameBins] = size(SMBinDataMtx);
xTicks = ((1:FrameBins) - StimOnsetTimeBin)*ProbNPSess.USedbin(2);

TrialStimFreqs = double(behavResults.Stim_toneFreq(:));
TrialChoices = double(behavResults.Action_choice(:));

TrialBlockTypes = double(behavResults.BlockType(:));
BlockTypeEdges = abs([1;diff(TrialBlockTypes)]);
BSInds = find(BlockTypeEdges);
if BSInds(end) == length(TrialStimFreqs)
    BSInds(end) = [];
    BlockTypeEdges(end) = 0;
end
SessBlockTypes = TrialBlockTypes(BSInds+1);
BlockType2Index = cumsum(BlockTypeEdges); % convert binary blocks into continued index values
BlockTYpeIndexNums = max(BlockType2Index);
BlockLineColors = lines(BlockTYpeIndexNums); % colors for each indexed block


%%
NumPlotUnits = size(RegressorInfosCell,1);
for cU = 1 : NumPlotUnits
%     cU = 90;
    cU_EVars = RegressorInfosCell{cU,1};
    cU_FullExpVars = mean(cU_EVars.fullmodel_explain_var);
    cU_PartialExpVars = squeeze(mean(cU_EVars.PartialMd_explain_var));
    cU_ShufExpVars = prctile(cat(1,cU_EVars.fullmodel_ShufEVar{:}),99);
    cU_AreaStr = NewAdd_ExistAreaNames{AreaNameIndexVec(cU)};

    InDataUnitInds = ExistField_ClusIDs(cU,2);
    
    % figure 1
    % regressor explained variance plot
    hf1 = figure('position',[1300 140 480 340]);
    hold on
    hl1 = plot(cU_PartialExpVars(:,1),'k'); % omit regression
    hl2 = plot(cU_PartialExpVars(:,2),'Color',[0.8 0.6 0.2]); % omit regression
    plot(sum(cU_PartialExpVars,2),'-o','Color','m');
    line([0 size(cU_PartialExpVars,1)+1],[cU_FullExpVars cU_FullExpVars],'Color','c','linestyle','--');
    line([0 size(cU_PartialExpVars,1)+1],[0.01 0.01],'Color',[.7 .7 .7],'linestyle','-.');
    line([0 size(cU_PartialExpVars,1)+1],[0.02 0.02],'Color',[.3 .3 .3],'linestyle','-.');
    set(gca,'box','off','xtick',1:size(cU_PartialExpVars,1));
    legend([hl1,hl2],{'OmitMD','SingleMD'},'box','off','location','Southwest');
    title(sprintf('(%s) cU = %d, FullEV = %.3f, EVThres = %.3e',cU_AreaStr, InDataUnitInds, cU_FullExpVars, cU_ShufExpVars));
    xlabel('Predictors')
    ylabel('Explained Variance');
    
    % figure 2
    % plot response according to stimulus types
    % seperate as block types

    FreqTypes = unique(TrialStimFreqs);
    FreqNums = length(FreqTypes);
    FreqTypeInds = cell(FreqNums,1);
    for cf = 1 : FreqNums
        FreqTypeInds{cf,1} = TrialStimFreqs == FreqTypes(cf) & TrialChoices ~= 2;
    end

    hAxis = gobjects(FreqNums,1);
    AxScales = zeros(FreqNums,2);
    hf2 = figure('position',[120 750 1500 360]);
    for cSub = 1 : FreqNums

        ax1 = subplot(1,FreqNums,cSub);
        hAxis(cSub) = ax1;

        hls = gobjects(BlockTYpeIndexNums,1);
        IsBlockPlotted = ones(BlockTYpeIndexNums,1);
        for cB = 1 : BlockTYpeIndexNums
            if sum(BlockType2Index == cB) < 50
                IsBlockPlotted(cB) = 0;
                continue;
            end
            cSubFreq_UsedDataInds = FreqTypeInds{cSub} & BlockType2Index == cB;
            cSubFreq_UsedData = squeeze(SMBinDataMtx(cSubFreq_UsedDataInds,InDataUnitInds,:));

            if SessBlockTypes(cB) == 0
                [~,~,hl] = MeanSemPlot(cSubFreq_UsedData,xTicks,ax1,0.5,[.8 .8 .8],...  ,'linestyle','--'
                    'Color',BlockLineColors(cB,:),'linewidth',1);
            else
                [~,~,hl] = MeanSemPlot(cSubFreq_UsedData,xTicks,ax1,0.5,[.8 .8 .8],...
                    'Color',BlockLineColors(cB,:),'linewidth',1);
            end
            hls(cB) = hl;
        end

        if sum(IsBlockPlotted)
            hls(IsBlockPlotted == 0) = [];
            SessBlockTypes(IsBlockPlotted == 0) = [];
        end
        if cSub == FreqNums
            axPos = get(ax1,'position');
            lps = legend(hls,cellstr(num2str(SessBlockTypes(:),'Block %d')),'Box','off',...
                'location','northeast','AutoUpdate','off');
            set(ax1,'position',axPos);
            set(lps,'position',[axPos(1)+axPos(3)+0.03, axPos(2)+0.5, 0.05 0.05]);
        end
        AxScales(cSub,:) = get(ax1,'ylim');
        title(num2str(FreqTypes(cSub),'Freq %dHz'));
        xlabel('Times');
        set(ax1,'xlim',[xTicks(1) min(4,xTicks(end))]); % constrain sp data within 4s window after stimonset
        if cSub == 1
           ylabel('Firing rate (Hz)'); 
        end
    end

    ComYScales = [max(-0.1,min(AxScales(:,1))), max(AxScales(:,2))];

    for cSub = 1 : FreqNums
        line(hAxis(cSub),[0 0],ComYScales,'linewidth',1,'Color','m','linestyle','--');
        set(hAxis(cSub),'ylim',ComYScales);
    end


    %
    % figure 3,plot response according to choice types
    ChoiceInds = cell(2,1);
    ChoiceInds{1} = TrialChoices == 0;
    ChoiceInds{2} = TrialChoices == 1;
    cBlockChoiceColors = {'b','r'};
    cBlockChoiceStr = {'Left Choice','Right Choice'};

    hyAxis = gobjects(2,1);
    AxScales = zeros(2,2);
    hf3 = figure('position',[60 150 840 340]);
    for cChoice = 1 : 2
        ax = subplot(1,2,cChoice);
        hyAxis(cChoice) = ax;

        hls = gobjects(BlockTYpeIndexNums,1);
        IsBlockPlotted = ones(BlockTYpeIndexNums,1);
        for cB = 1 : BlockTYpeIndexNums
            if sum(BlockType2Index == cB) < 50
                IsBlockPlotted(cB) = 0;
                continue;
            end
            cBChoice_DataInds = ChoiceInds{cChoice} & BlockType2Index == cB;
            cBChoice_UsedData = squeeze(SMBinDataMtx(cBChoice_DataInds,InDataUnitInds,:));

            if SessBlockTypes(cB) == 0
                [~,~,hl] = MeanSemPlot(cBChoice_UsedData,xTicks,ax,0.5,[.8 .8 .8],...  ,'linestyle','--'
                    'Color',BlockLineColors(cB,:),'linewidth',1);
            else
                [~,~,hl] = MeanSemPlot(cBChoice_UsedData,xTicks,ax,0.5,[.8 .8 .8],...
                    'Color',BlockLineColors(cB,:),'linewidth',1);
            end
            hls(cB) = hl;
        end

        if sum(IsBlockPlotted)
            hls(IsBlockPlotted == 0) = [];
            SessBlockTypes(IsBlockPlotted == 0) = [];
        end
        if cChoice == 2
            axPos = get(ax,'position');
            lps = legend(hls,cellstr(num2str(SessBlockTypes(:),'Block %d')),'Box','off',...
                'location','northeast','AutoUpdate','off');
            set(ax,'position',axPos+[-0.05 0 0 0]);
            set(lps,'position',[axPos(1)+axPos(3)+0.01, axPos(2)+0.5, 0.02 0.05]);
        end
        AxScales(cChoice,:) = get(ax,'ylim');
        title(cBlockChoiceStr{cChoice},'Color',cBlockChoiceColors{cChoice});
        xlabel('Times');
        set(ax,'xlim',[xTicks(1) min(4,xTicks(end))]); % constrain sp data within 4s window after stimonset
        if cChoice == 1
           ylabel('Firing rate (Hz)'); 
        end

    end

    ComYScales = [max(-0.1,min(AxScales(:,1))), max(AxScales(:,2))];

    for cSub = 1 : 2
        line(hyAxis(cSub),[0 0],ComYScales,'linewidth',1,'Color','m','linestyle','--');
        set(hyAxis(cSub),'ylim',ComYScales);
    end
    
   UnitPlotSaveName1 = fullfile(PlotSavePath,sprintf('Unit%d EVar plot save',InDataUnitInds));
   UnitPlotSaveName2 = fullfile(PlotSavePath,sprintf('Unit%d StimResp plot save',InDataUnitInds));
   UnitPlotSaveName3 = fullfile(PlotSavePath,sprintf('Unit%d ChoiceResp plot save',InDataUnitInds));
   
   saveas(hf1,UnitPlotSaveName1);
   print(hf1,UnitPlotSaveName1,'-dpng','-r0');
   print(hf1,UnitPlotSaveName1,'-dpdf','-bestfit');
   close(hf1);
   
   saveas(hf2,UnitPlotSaveName2);
   print(hf2,UnitPlotSaveName2,'-dpng','-r0');
   print(hf2,UnitPlotSaveName2,'-dpdf','-bestfit');
   close(hf2);
   
   saveas(hf3,UnitPlotSaveName3);
   print(hf3,UnitPlotSaveName3,'-dpng','-r0');
   print(hf3,UnitPlotSaveName3,'-dpdf','-bestfit');
   close(hf3);
   
   
   
end



