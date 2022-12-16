
load(fullfile(ksfolder,'jeccAnA','CCA_TypeSubCal.mat'), 'OutDataStrc');
load(fullfile(ksfolder,'NewClassHandle2.mat'), 'behavResults');

%%
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NumFrameBins = size(NewBinnedDatas,3);

OnsetBin = OutDataStrc.TriggerStartBin - 1;
BaselineResp = mean(NewBinnedDatas(:,:,1:OnsetBin),3);
BaseLineEndInds = OutDataStrc.TriggerStartBin - 1;

%%
BlockSectionInfo = Bev2blockinfoFun(behavResults);
AllTrFreqs = double(behavResults.Stim_toneFreq(:));
AllTrBlocks = double(behavResults.BlockType(:));
AllTrChoices = double(behavResults.Action_choice(:));
NMTrInds = AllTrChoices(1:sum(BlockSectionInfo.BlockLens)) ~= 2;
NMTrFreqs = AllTrFreqs(NMTrInds);
NMBlockTypes = AllTrBlocks(NMTrInds);
NMBlockBoundVec = [1;abs(diff(NMBlockTypes))];
NMBlockBoundIndex = cumsum(NMBlockBoundVec);
NMActionChoice = AllTrChoices(NMTrInds);
NMBinDatas = permute(NewBinnedDatas(NMTrInds,:,:),[1,3,2]);
NumBlocks = BlockSectionInfo.NumBlocks;
xtimes = OutDataStrc.BinCenters;
%%
freqTypes = unique(NMTrFreqs);
NumFreqTypes = length(freqTypes);
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
NumRevFreqs = length(RevFreqs);
cU = 30;
cUdata = NMBinDatas(:,:,cU);
close
hf = figure('position',[100 100 220*NumBlocks 560]);
AxsAll = gobjects(NumRevFreqs*NumBlocks, 1);
AllAxsScale = zeros(NumRevFreqs*NumBlocks, 2);
isLegAdd = 0;
IsRHave = 0;
IsLHave = 0;
k = 1;
for cB = 1 : NumBlocks
    for cFreq = 1 : NumRevFreqs
        cTrInds = NMBlockBoundIndex == cB & NMTrFreqs == RevFreqs(cFreq);
        cTraceData = cUdata(cTrInds,:);
        cTrChoice = NMActionChoice(cTrInds);
        
        cLeftTraceData = cTraceData(cTrChoice == 0,:);
        cRightTraceData = cTraceData(cTrChoice == 1,:);
        
        cAx = subplot(3,NumBlocks,(cFreq-1)*NumBlocks+cB);
        AxsAll(k) = cAx;
        hold on
        if ~isempty(cLeftTraceData)
            IsLHave = 1;
            [~,~,hl] = MeanSemPlot(cLeftTraceData,xtimes,cAx,0.5,[0.4 0.4 0.8],'Color','b','linewidth',1.5);
        end
        if ~isempty(cRightTraceData)
            IsRHave = 1;
            [~,~,hr] = MeanSemPlot(cRightTraceData,xtimes,cAx,0.5,[0.8 0.4 0.4],'Color','r','linewidth',1.5);
        end 
        yscales = get(cAx,'ylim');
        if ~isLegAdd
            if IsLHave && IsRHave
                legend([hl,hr],{'LeftC','RightC'},'box','off','location','northeast',...
                    'FontSize',8,'autoupdate','off');
                isLegAdd = 1;
            end
        end
        AllAxsScale(k,:) = yscales;
        
        if cFreq == NumRevFreqs
            xlabel(sprintf('Time (s), Block %d',BlockSectionInfo.BlockTypes(cB)));
        end
        if k == 1
            title(sprintf('Unit %d, %d Hz, L(%d)R(%d)',cU, RevFreqs(cFreq),sum(cTrChoice == 0),sum(cTrChoice == 1)));
        else
            title(sprintf('%d Hz, L(%d)R(%d)',RevFreqs(cFreq),sum(cTrChoice == 0),sum(cTrChoice == 1)));
        end
        k = k + 1;
        if cB == 1
            ylabel('Firing rate');
        end
        IsLHave = 0;
        IsRHave = 0;
    end
end
CommonyScales = [max(0,min(AllAxsScale(:,1))),max(AllAxsScale(:,2))];
k = 1;
for ck = 1 : NumRevFreqs*NumBlocks
    line(AxsAll(ck),[0 0],CommonyScales,'Color','c','linewidth',1,'linestyle','--');
    set(AxsAll(ck),'ylim',CommonyScales);
end


