load('CSessionData.mat');
load('CaTrialsSIM_2P1517_20190122_3x_power1920_per50_depth170_boundarySh_dftReg_.mat', 'SavedCaTrials');
%%
MissTrInds = behavResults.Action_choice(:) ~= 2;
NMBlockIndsAll = double(behavResults.Block_Type(MissTrInds));
NMTrFreqs = double(behavResults.Stim_toneFreq(MissTrInds));
NMTrChoice = double(behavResults.Action_choice(MissTrInds));

%% Correct all tr-time events to sound-aligned value
TrStimOnT = double(behavResults.Time_stimOnset);
TrAnsT = double(behavResults.Time_answer);
TrRewardT = double(behavResults.Time_reward);

MinOnsetTime = min(TrStimOnT);
TrTimeShift = TrStimOnT - MinOnsetTime;
AgAnsT = TrAnsT - TrTimeShift;
AgRewardT = TrRewardT - TrTimeShift;

NMAgAnsT = AgAnsT(MissTrInds);
NMAgRewardT = AgRewardT(MissTrInds);

%%

NMAlignData = squeeze(data_aligned(MissTrInds,:,:));
ViewTrNum = 80;
Block1Type = NMBlockIndsAll(1);
Block2Type = 1 - Block1Type;

Block1Sum.AlignData = NMAlignData(NMBlockIndsAll == Block1Type,:,:);
Block2Sum.AlignData = NMAlignData(NMBlockIndsAll == Block2Type,:,:);
Block1Sum.BlockTrNum = size(Block1Sum.AlignData,1);
Block2Sum.BlockTrNum = size(Block2Sum.AlignData,1);
Block1Sum.TrFreqs = NMTrFreqs(NMBlockIndsAll == Block1Type);
Block2Sum.TrFreqs = NMTrFreqs(NMBlockIndsAll == Block2Type);
Block1Sum.TrChoice = NMTrChoice(NMBlockIndsAll == Block1Type);
Block2Sum.TrChoice = NMTrChoice(NMBlockIndsAll == Block2Type);
Block1Sum.AnsLickT = AgAnsT(NMBlockIndsAll == Block1Type);
Block2Sum.AnsLickT = AgAnsT(NMBlockIndsAll == Block2Type);

PlotInds = {1:ViewTrNum,(Block1Sum.BlockTrNum-ViewTrNum+1):Block1Sum.BlockTrNum,...
    1:ViewTrNum,(Block2Sum.BlockTrNum-ViewTrNum+1):Block2Sum.BlockTrNum};
nPlots = length(PlotInds);
PlotBlocks = {'Block1Sum','Block1Sum','Block2Sum','Block2Sum'};
BlockDescrip = {sprintf('B1 1-%d',ViewTrNum),sprintf('B1 last%d',ViewTrNum),...
    sprintf('B2 1-%d',ViewTrNum),sprintf('B2 %d',ViewTrNum)};
AllFreqTypes = unique(NMTrFreqs);
nFreqs = length(AllFreqTypes);
FreqReveIndicate = ones(nFreqs,1);
FreqReveIndicate(1:2) = 0;
FreqReveIndicate(end-1:end) = 0;
FreqRevChanges = [abs(diff(FreqReveIndicate));0];

RawAcqDatas = SavedCaTrials.f_raw(MissTrInds);
Block1Sum.RawAcqData = RawAcqDatas(NMBlockIndsAll == Block1Type);
Block2Sum.RawAcqData = RawAcqDatas(NMBlockIndsAll == Block2Type);


%% plots
close;
hf = figure('position',[2000 200 1500 600]); %#ok<*NASGU>
nPlotCols = length(PlotInds);

%
cROI = 112;
cROIData = squeeze(data_aligned(:,cROI,:));
cclim = [0 prctile(cROIData(:),95)];
for cPlot = 1 : nPlotCols
    %
    eval(['cPlotStrc = ',PlotBlocks{cPlot},';']);
    cBlockROIData = squeeze(cPlotStrc.AlignData(PlotInds{cPlot},cROI,:));
    cBlockFreqs = cPlotStrc.TrFreqs(PlotInds{cPlot});
    cBlockAnsT = cPlotStrc.AnsLickT(PlotInds{cPlot});
    cBlockChoice = cPlotStrc.TrChoice(PlotInds{cPlot});
%     NreshapedData = zeros(size(cBlockROIData));
    ReshapeTrInds = cell(nFreqs,3);
    IsWithinReveFreqs = 0;
    k = 1;
    m = 1;
    TempData = {};
    NreshapedData = {};
    TrInds = {};
    TempTrInds = {};
    FreqTypeTrInds = [];
    for cFreq = 1 : nFreqs
        cFreqInds = find(cBlockFreqs == AllFreqTypes(cFreq));
        cFreqChoice = cBlockChoice(cFreqInds);
        cFreqAnsT = cBlockAnsT(cFreqInds);
        [SortAnsT,AnsSortInds] = sort(cFreqAnsT);
        SortedTrInds = cFreqInds(AnsSortInds);
        SortedTrChoice = cFreqChoice(AnsSortInds);
        ReshapeTrInds(cFreq,:) = {SortedTrInds,SortedTrInds(SortedTrChoice == 0),...
            SortedTrInds(SortedTrChoice == 1)};
        if ~IsWithinReveFreqs
            NreshapedData{k,1} = cBlockROIData(SortedTrInds,:); %#ok<*SAGROW>
            NreshapedData{k,2} = AllFreqTypes(cFreq);
            TrInds{k,1} = SortedTrInds;
        else
            NreshapedData{k,1} = cBlockROIData(ReshapeTrInds{cFreq,2},:);
            NreshapedData{k,2} = AllFreqTypes(cFreq);
            TrInds{k,1} = SortedTrInds(SortedTrChoice == 0);
            TempData{m,1} = cBlockROIData(ReshapeTrInds{cFreq,3},:);
            TempData{m,2} = AllFreqTypes(cFreq);
            TempTrInds{m,1} = SortedTrInds(SortedTrChoice == 1);
            m = m + 1;
        end
        
        if FreqRevChanges(cFreq)
            if IsWithinReveFreqs
                NreshapedData((k+1):(k+m-1),:) = TempData;
                TrInds((k+1):(k+m-1),1) = TempTrInds;
                k = k+m-1;
                TempData = {};
                TempTrInds = {};
            end
            IsWithinReveFreqs = 1 - IsWithinReveFreqs;
        end
        k = k + 1;
    end
    EmptyInds = cellfun(@isempty,TrInds);
    nCellTrNum = cellfun(@numel,TrInds);
    nRealTrNums = nCellTrNum(~EmptyInds);
    nRealTrFreqs = cell2mat(NreshapedData(~EmptyInds,2));
    TrNumCumNum = cumsum(nRealTrNums);
    
    IndexedDataAll = cell2mat(NreshapedData(:,1));
    nFrames = size(IndexedDataAll,2);
    
    TrIndexAll = (cell2mat(TrInds'))';
    IndexTrAnsF = round(cBlockAnsT(TrIndexAll)/1000*frame_rate);
    IndexedTrChoice = cBlockChoice(TrIndexAll);
    
    IndexedAnsFMtx = ([IndexTrAnsF-0.5;IndexTrAnsF+0.5;nan(1,ViewTrNum)]);
    IndexMtx = ([(1:ViewTrNum)-0.5;(1:ViewTrNum)+0.5;nan(1,ViewTrNum)]);
    %
    LeftChoice_xIndexData = IndexMtx(:,~IndexedTrChoice);
    LeftChoice_yIndexData = IndexedAnsFMtx(:,~IndexedTrChoice);
    RightChoice_xIndexData = IndexMtx(:,logical(IndexedTrChoice));
    RightChoice_yIndexData = IndexedAnsFMtx(:,logical(IndexedTrChoice));
    
    ha = subplot(5,nPlotCols,cPlot+(0:3)*nPlotCols);
    hold on
    imagesc(IndexedDataAll,cclim);
    line([start_frame start_frame],[0.5 0.5+ViewTrNum],'Color',[.7 .7 .7],'linewidth',2);
    HoriSeglCenter = ([1;TrNumCumNum(1:(end-1))]+TrNumCumNum(1:end))/2;
    for cHoriSegLine = 1 : length(TrNumCumNum)
        line([0.5,nFrames+0.5],TrNumCumNum+[0.5,0.5],'Color',[.7 .7 .7],'linewidth',1.8);
    end
%     if cPlot == nPlotCols
        set(gca,'ytick',HoriSeglCenter,'yticklabel',nRealTrFreqs);
%     end
    set(gca,'xtick',0:frame_rate:nFrames,'xticklabel',0:nFrames/frame_rate);
    % plot left ans licks
    plot(LeftChoice_yIndexData(:),LeftChoice_xIndexData(:),'Color','g',...
        'linewidth',1.4);
    % plot right ans licks
    plot(RightChoice_yIndexData(:),RightChoice_xIndexData(:),...
        'Color','m','linewidth',1.4);
    set(gca,'xlim',[0.5 nFrames+0.5],'ylim',[0.5 ViewTrNum+0.5]);
    set(gca,'yDir','reverse')
    if cPlot == 1
        ylabel(sprintf('ROI %d',cROI));
    end
    if cPlot == nPlotCols
        PlotPosition = get(ha,'position');
        hbar = colorbar;
        BarOldPos = get(hbar,'position');
        set(hbar,'position',[PlotPosition(1)+PlotPosition(3)+0.01,BarOldPos(2),0.3*BarOldPos(3),0.3*BarOldPos(4)]);
        set(ha,'position',PlotPosition);
    end
    % plot raw acq data trace
    cRawDatas = cPlotStrc.RawAcqData(PlotInds{cPlot});
    cRawDataAlls = cellfun(@(x) (x(cROI,:)),cRawDatas,'UniformOutput',false);
    cRawDataTrace = cell2mat(cRawDataAlls');
    [Count,Cents] = hist(cRawDataTrace,100);
    [~,Inds] = max(Count);
    Base = Cents(Inds);
    
    subplot(5,nPlotCols,cPlot+4*nPlotCols)
    hold on
    plot(cRawDataTrace,'k','linewidth',1.2);
    line([0 numel(cRawDataTrace)],[Base Base],'Color',[1 0.7 0.2],'linewidth',1.4);
    xlabel(sprintf('BaseValue %.3f',Base));
    title(BlockDescrip{cPlot});
    set(gca,'xlim',[0 numel(cRawDataTrace)+1]);
    if cPlot == 1
        ylabel('Raw Fluo Trace');
    end
    %
end


%% 
cROI = 106;
close
Block1Type = NMBlockIndsAll(1);
Block2Type = 1 - Block1Type;
Block1Data = squeeze(data_aligned(NMBlockIndsAll == Block1Type,cROI,:));
Block2Data = squeeze(data_aligned(NMBlockIndsAll == Block2Type,cROI,:));

ColorScim = [0 150];

hf = figure('position',[200 200 1500 340]);
subplot(141)
imagesc(Block1Data(1:ViewTrNum,:),ColorScim);
title(sprintf('Block1 1-%d',ViewTrNum))

subplot(142)
imagesc(Block1Data((end+1-ViewTrNum):end,:),ColorScim);
title(sprintf('Block1 last%d',ViewTrNum))

subplot(143)
imagesc(Block2Data(1:ViewTrNum,:),ColorScim);
title(sprintf('Block2 1-%d',ViewTrNum))

subplot(144)
imagesc(Block2Data((end+1-ViewTrNum):end,:),ColorScim);
title(sprintf('Block2 last%d',ViewTrNum))

%%
% load('SessionFrameProj.mat')
cTrs = length(FrameProjSave);
hf = figure;
for cf = 1 : cTrs
    figure(hf);
    imagesc(FrameProjSave(cf).MeanFrame,[0 500])
    colormap gray
    pause(0.2);
end
