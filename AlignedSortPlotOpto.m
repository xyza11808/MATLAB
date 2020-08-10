function varargout = AlignedSortPlotOpto(RawData,BehavStrc,Frate,varargin)
% Function used for plot ROI response for each frequency and outcome
% combination, RawData is the aligned data which is aligned to sound
% skip lick plot at current condition
IsPlot = 1;
if nargin > 3
    if ~isempty(varargin{1})
        IsPlot = varargin{1};
    end
end
OptoTrs = double(BehavStrc.Trial_isOpto);
if ~sum(OptoTrs)
    warning('No optical trial exists, considering using another function for plots.\n');
    return;
end

[AllTrNum,ROInum,FrameNum] = size(RawData);
TrStimOnset = double(BehavStrc.Time_stimOnset);
TrAnsTime = double(BehavStrc.Time_answer);
TrChoice = double(BehavStrc.Action_choice);
TrStimFreq = double(BehavStrc.Stim_toneFreq);

% if IsTrIndsInput
%     AllTrInds = false(length(TrStimOnset),1);
%     AllTrInds(UsedTrInds) = true;
%     TrStimOnset = TrStimOnset(AllTrInds);
%     TrAnsTime = TrAnsTime(AllTrInds);
%     TrChoice = TrChoice(AllTrInds);
%     OptoTrs = OptoTrs(AllTrInds);
%     TrStimFreq = TrStimFreq(AllTrInds);
%     RawData = RawData(AllTrInds,:,:);
%     
%     [AllTrNum,ROInum,FrameNum] = size(RawData);
% end

FreqTypes = unique(TrStimFreq);
NumFreq = length(FreqTypes);

%%
MinStimOnsetTime = min(TrStimOnset);
TrTimeDiff = TrStimOnset - MinStimOnsetTime;
AnsTimeAdj = TrAnsTime - TrTimeDiff;
% TrFrameDiff = round(TrTimeDiff/1000*Frate);

AnsAdjFrame = round(AnsTimeAdj/1000*Frate);

AlignFrameLen = FrameNum;
% AlignData = zeros(AllTrNum,ROInum,AlignFrameLen);
% for nTr = 1 : AllTrNum
%     cTrData = squeeze(RawData(nTr,:,:));
%     cTrBaseFrame = round((TrStimOnset(nTr)/1000)*Frate);
%     BaseMtx = repmat(mean(cTrData(:,1:cTrBaseFrame),2),1,size(cTrData,2));
%     BaseCorrectData = cTrData - BaseMtx;
%     AlignData(nTr,:,:) = BaseCorrectData(:,(TrFrameDiff(nTr)+(1:AlignFrameLen)));
% end
AlignData = RawData;
AlignedFrame = round(MinStimOnsetTime/1000*Frate);
SoundOffFrame = ((MinStimOnsetTime/1000)+0.3)*Frate;
AlignXtick = 0:Frate:AlignFrameLen;
AlignxtickLabel = AlignXtick/Frate;
%%
FreqTypeEventF = cell(NumFreq,4);
AnsFIndsSort = cell(NumFreq,4);
TypeIndices = [0 0 1 1;... % Choice types
    0 1 0 1]; % Opto trial types
TypeStrs = {'LeftCont', 'LeftOpto', 'RightCont', 'RightOpto'};
for cFreqType = 1 : NumFreq
    cFreqInds = TrStimFreq == FreqTypes(cFreqType);
    cFreqChoice = TrChoice(cFreqInds); % using choice but not outcome for classification
    cFreqOpto = OptoTrs(cFreqInds);
    cFreqAnsF = AnsAdjFrame(cFreqInds);
    
    for cPlotType = 1 : 4
        cTypeInds = cFreqChoice(:) == TypeIndices(1,cPlotType) & ...
            cFreqOpto(:) == TypeIndices(2,cPlotType);
        cTypeOutAnsF = cFreqAnsF(cTypeInds);
        [cTypeOutAnsF,cTypeAnsIndsSort] = sort(cTypeOutAnsF);
        cTypeTrIndsNum = length(cTypeOutAnsF);
        ErrorTrXData = reshape(([cTypeOutAnsF(:),cTypeOutAnsF(:),nan(cTypeTrIndsNum,1)])',[],1);
        ErrorTrYData = reshape([(1:cTypeTrIndsNum)-0.5;(1:cTypeTrIndsNum)+0.5;nan(1,cTypeTrIndsNum)],[],1);
        AnsFIndsSort{cFreqType,cPlotType} = cTypeAnsIndsSort;
        FreqTypeEventF{cFreqType,cPlotType} = [ErrorTrXData, ErrorTrYData];
    end

end
    
%% plot all dataset
if ~isdir('./OptoCont Allfreq Colorplot/')
    mkdir('./OptoCont Allfreq Colorplot/');
end
cd('./OptoCont Allfreq Colorplot/');

%%
ROIMeanTraceData = cell(ROInum,NumFreq,4);
LoopAxColIndex = [1,2,4,5];
for nROI = 1 : ROInum
    %%
    cROIdata = squeeze(AlignData(:,nROI,:));
    climMax = prctile(cROIdata(:),85);
    if climMax < 0
        climMax = 10;
    elseif climMax == 0
        climMax = 1;
    end
    clim = [0,climMax];
    if clim(2) > 400
        clim(2) = 200;
    end
    %
    MeanPlotAxes = [];
    MeanyScales = zeros(NumFreq,2);
    if IsPlot
        hROI = figure('position',[20 100 1200 840],'PaperPositionMode','auto',...
            'visible','off'); %,
    end
    for nFreq = 1 : NumFreq
        cFreqInds = TrStimFreq == FreqTypes(nFreq);
        cFreqChoice = TrChoice(cFreqInds);
        cFreqOptoInds = OptoTrs(cFreqInds);
        cFreqData = cROIdata(cFreqInds,:);
        
        % looped color data plots
        for cAx = 1 : 4
            AxCorr = subplot(NumFreq,6,LoopAxColIndex(cAx)+6*(nFreq - 1));
            hold on;
            cDataInds = cFreqChoice == TypeIndices(1,cAx) & ...
                cFreqOptoInds == TypeIndices(2,cAx);
            cTypeData = cFreqData(cDataInds,:);
            if ~isempty(cTypeData)
                if IsPlot
                    cTypeSortInds = AnsFIndsSort{nFreq, cAx};
                    cTypeAnsEventFPlot = FreqTypeEventF{nFreq, cAx};
                    imagesc(cTypeData(cTypeSortInds,:),clim);
                    plot(cTypeAnsEventFPlot(:,1),cTypeAnsEventFPlot(:,2),'Color',[1 0 1],'LineWidth',1);
                    line([AlignedFrame AlignedFrame],[0.5 size(cTypeData,1)+0.5],'Color',[.7 .7 .7],'LineWidth',1);
                    line([SoundOffFrame SoundOffFrame],[0.5 size(cTypeData,1)+0.5],'Color',[.7 .7 .7],...
                        'LineWidth',1,'linestyle','--');

                    set(gca,'yDir','reverse','ylim',[0.5 size(cTypeData,1)+0.5],'xlim',[0 size(cTypeData,2)]);
                    if nFreq == 1 && cAx == 1
                        AxsPos = get(AxCorr,'position');
                        hbar = colorbar('westoutside');
                        set(AxCorr,'position',AxsPos);
                        barPos = get(hbar,'position');
                        set(hbar,'position',[barPos(1)-0.03,barPos(2),barPos(3)*0.8,barPos(4)]);
                    end
                    %
                    if nFreq == 1
                        title(TypeStrs{cAx});
                    end
                    set(AxCorr,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
                    set(AxCorr,'FontSize',6);
                end
                if length(cTypeData) == numel(cTypeData)
                    ROIMeanTraceData{nROI,nFreq,cAx} = cTypeData; 
                else
                    ROIMeanTraceData{nROI,nFreq,cAx} = mean(cTypeData);
                end
            end
            if cAx == 1
                ylabel(AxCorr,sprintf('%dHz',FreqTypes(nFreq)),'Color','r','FontSize',6);
            end
        end
        
        % plot the mean trace for two choice 
           % left choice mean trace
        if IsPlot
            TraceYScales = zeros(2,2);
           if ~isempty(ROIMeanTraceData{nROI,nFreq,1}) || ~isempty(ROIMeanTraceData{nROI,nFreq,2}) 
               AxMean1 = subplot(NumFreq,6,3+6*(nFreq - 1));
               hold on;
               hl = [];
               hlStr = {};
               if ~isempty(ROIMeanTraceData{nROI,nFreq,1})
                   hl1 = plot(ROIMeanTraceData{nROI,nFreq,1},'Color',[0.1 0.1 0.8],'linewidth',1.5);
                   hl = [hl,hl1];
                   hlStr = [hlStr(:);{'LCont'}];
               end
               if ~isempty(ROIMeanTraceData{nROI,nFreq,2})
                   hl2 = plot(ROIMeanTraceData{nROI,nFreq,2},'Color',[0.4 0.4 0.7],'linewidth',1.5,'linestyle','--');
                   hl = [hl,hl2];
                   hlStr = [hlStr(:);{'LOpto'}];
               end
               TraceYScales(1,:) = get(AxMean1,'ylim');
%                line([AlignedFrame AlignedFrame],TraceYScales(1,:),'Color',[.7 .7 .7],'LineWidth',1);
%                 line([SoundOffFrame SoundOffFrame],TraceYScales(1,:),'Color',[.7 .7 .7],...
%                     'LineWidth',1,'linestyle','--');
                set(AxMean1,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
                if nFreq == 1
                    title('Left Choice AvgTrace');
                    legend(hl, hlStr, 'Location', 'Northeast','Box','off',...
                        'FontSize',5,'AutoUpdate','off');
                end
                
                MeanPlotAxes = [MeanPlotAxes,AxMean1];
                ylabel('dff');
           end
           
           if ~isempty(ROIMeanTraceData{nROI,nFreq,3}) || ~isempty(ROIMeanTraceData{nROI,nFreq,4}) 
               AxMean2 = subplot(NumFreq,6,6+6*(nFreq - 1));
               hold on;
               hl_2 = [];
               hlStr_2 = {};
               if ~isempty(ROIMeanTraceData{nROI,nFreq,3})
                   hl3 = plot(ROIMeanTraceData{nROI,nFreq,3},'Color',[0.8 0.1 0.1],'linewidth',1.5);
                   hl_2 = [hl_2, hl3];
                   hlStr_2 = [hlStr_2(:); 'RCont'];
               end
               if ~isempty(ROIMeanTraceData{nROI,nFreq,4})
                   hl4 = plot(ROIMeanTraceData{nROI,nFreq,4},'Color',[0.7 0.4 0.4],'linewidth',1.5,'linestyle','--');
                   hl_2 = [hl_2, hl4];
                   hlStr_2 = [hlStr_2(:); 'ROpto'];
               end
               TraceYScales(2,:) = get(AxMean2,'ylim');
%                line([AlignedFrame AlignedFrame],TraceYScales(2,:),'Color',[.7 .7 .7],'LineWidth',1);
%                 line([SoundOffFrame SoundOffFrame],TraceYScales(2,:),'Color',[.7 .7 .7],...
%                     'LineWidth',1,'linestyle','--');
                set(AxMean2,'xtick',AlignXtick,'xticklabel',AlignxtickLabel);
                if nFreq == NumFreq
                    title('Right Choice AvgTrace');
                    legend(hl_2, hlStr_2, 'Location', 'Northeast','Box','off',...
                        'FontSize',5,'AutoUpdate','off');
                end
                MeanPlotAxes = [MeanPlotAxes,AxMean2];
                ylabel('dff');
                
           end
        end
        MeanyScales(nFreq,:) = [min(TraceYScales(:,1)),max(TraceYScales(:,2))];
    end
%%
    if IsPlot
        ComYScale = [min(MeanyScales(:,1)),max(MeanyScales(:,2))];
        if ComYScale(1) < -20
            ComYScale(1) = -20;
        end
        
        for cF = 1 : length(MeanPlotAxes)
           set(MeanPlotAxes(cF),'ylim',ComYScale);
           line(MeanPlotAxes(cF),[AlignedFrame AlignedFrame],ComYScale,'Color',[.7 .7 .7],'LineWidth',1.2);
           line(MeanPlotAxes(cF),[SoundOffFrame SoundOffFrame],ComYScale,'Color',[.7 .7 .7],'LineWidth',1.2,'linestyle','--');
        end
        
            annotation('textbox',[0.49,0.685,0.3,0.3],'String',['ROI' num2str(nROI)],'FitBoxToText','on','EdgeColor',...
                       'none','FontSize',14);
                   
        saveas(hROI,sprintf('ROI%d opto session color plot',nROI));
        saveas(hROI,sprintf('ROI%d opto session color plot',nROI),'png');
        close(hROI);
    end
    %%
end

save PlotRelatedDataOpto.mat FreqTypeEventF AnsFIndsSort AlignedFrame SoundOffFrame Frate ROIMeanTraceData -v7.3
cd ..;

if nargin > 0
    varargout = {{AlignedFrame,SoundOffFrame,Frate,ROIMeanTraceData}};
end
