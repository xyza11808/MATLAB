function UnevenRFrespPlot(PassData,SoundArray,FrameRate,varargin)
% this function is specifically used for passive data color plot with some
% trials excluded from analysis
IsvariedStimDur = 0;
if size(SoundArray,2) > 3
    StimLenDur = SoundArray(:,3);
    [SortDurLen,SortInds] = sort(StimLenDur);
    SoundArray = SoundArray(SortInds,:);
    PassData = PassData(SortInds,:,:);
    StimLenF = round((double(SortDurLen)/1000 + 1) * FrameRate);
    IsvariedStimDur = 1;
else
    StimLenF = repmat(round(1.3 * FrameRate),size(SoundArray,1));
end
DBArray = SoundArray(:,2);
FreqArray = SoundArray(:,1);
TimeStimOn = 1;
if nargin > 4
    if ~isempty(varargin{1})
        TimeStimOn = varargin{1};
    end
end

isplot = 1;
if nargin > 5
    if ~isempty(varargin{2})
      isplot = varargin{2};
    end
end
TimeScale = [0 1];
if nargin > 6
    if ~isempty(varargin{3})
        TimeScale = varargin{3};
    end
end
FrameScales = (TimeStimOn+TimeScale)*FrameRate+[1,0];

DBtypes = unique(DBArray);
FreqTypes = unique(FreqArray);
[nTrials,nROIs,nFrames] = size(PassData);
numDB = length(DBtypes);
numFreq = length(FreqTypes);
if length(FreqArray) ~= size(PassData,1)
    error('Sound Array size is unequal from two photon result.');
end

if ~isdir('./Uneven_colorPlot/')
    mkdir('./Uneven_colorPlot/');
end
cd('./Uneven_colorPlot/');

xTicks = 0:FrameRate:nFrames;
Ticklabel = xTicks/FrameRate;
yticklabels = cellstr(num2str(FreqTypes(:)/1000,'%.2f kHz'));
StimOnF = round(TimeStimOn * FrameRate);
StimOffF = round((TimeStimOn+0.3) * FrameRate);
typeData = cell(nROIs,numDB,numFreq);
TypeFrameInds = cell(numDB,numFreq);
for nROI = 1 : nROIs
    cROIdata = squeeze(PassData(:,nROI,:));
    BaselineData = cROIdata(:,1:StimOnF);
    RespThresV = mean(BaselineData(:)) + 3*std(BaselineData(:));
    if isplot
        hROI = figure('position',[100 100 1600 900],'visible','off');
        Coloraxis = subplot(numDB,3,1:3:(numDB*3));
        climmax = prctile(cROIdata(:),85);
        if climmax < 0
            climmax = 10;
        end
        clim = [0 climmax];
        
        imagesc(cROIdata,clim);
        set(gca,'xtick',xTicks,'xticklabel',Ticklabel);
        cAxisPos = get(gca,'position');
        xlabel('Time(s)');
        colorbar('westoutside');
        set(Coloraxis,'position',cAxisPos);
        patch([StimOnF,StimOffF,StimOffF,StimOnF],[0.5 0.5 (nTrials+0.5) (nTrials+0.5)],1,'FaceColor','g','EdgeColor','none','facealpha',0.4);
        set(gca,'FontSize',14);
    end
    cROIRespData = zeros(numDB,numFreq);
    for nDBType = 1 : numDB
        for nFreqtype = 1 : numFreq
            cCombInds = DBArray == DBtypes(nDBType) & FreqArray == FreqTypes(nFreqtype);
            cCombData = cROIdata(cCombInds,:);
            typeData{nROI,nDBType,nFreqtype} = cCombData;
            TypeFrameInds{nDBType,nFreqtype} = StimLenF(cCombInds);
        end
        if isplot
            cDBdatacell = squeeze(typeData(nROI,nDBType,:));
            TrialNum = cellfun(@(x) size(x,1),cDBdatacell);
            TrIndscdfSum = vectorcdf(TrialNum);
            cDBdataMatrix = cell2mat(cDBdatacell);
            subplot(numDB,3,(nDBType-1)*3+2)
            hold on
            imagesc(cDBdataMatrix,clim);
            set(gca,'xtick',xTicks,'xticklabel',Ticklabel,'ytick',TrIndscdfSum,'yticklabel',yticklabels);
            if nDBType == numDB
                xlabel('Time (s)');
            end
            ylabel('Frequency');
            if ~IsvariedStimDur
                patch([StimOnF,StimOffF,StimOffF,StimOnF],[0.5 0.5 (nTrials+0.5) (nTrials+0.5)],1,...
                    'FaceColor','g','EdgeColor','none','facealpha',0.4);
            else
                line([StimOnF StimOnF],[0.5 (nTrials+0.5)],'Color','m','linewidth',2.4);
            end
%             if nDBType == 1
                title(sprintf('%d dB',DBtypes(nDBType)),'FontSize',14);
%             end
            %
            cDBFreqFrame = TypeFrameInds(nDBType,:);
            cDBFreqFrameMtx = cell2mat(cDBFreqFrame');
            xPlotFrameMtx = [cDBFreqFrameMtx,cDBFreqFrameMtx,nan(numel(cDBFreqFrameMtx),1)];
            yPlotFrameMtx = [(0.5:numel(cDBFreqFrameMtx))',(0.5:numel(cDBFreqFrameMtx))'+1,nan(numel(cDBFreqFrameMtx),1)];
            xPlotFrameVec = reshape(xPlotFrameMtx',[],1);
            yPlotFrameVec = reshape(yPlotFrameMtx',[],1);
            plot(xPlotFrameVec,yPlotFrameVec,'Linewidth',2,'Color','m');
            set(gca,'ylim',[0.5 numel(cDBFreqFrameMtx)+0.5],'box','off','xlim',[0.5 size(cDBdataMatrix,2)+0.5]);
            %
            MeanTraceCell = cellfun(@mean,cDBdatacell,'UniformOutput',false);
            SmoothMeanTrace = cellfun(@(x) smooth(x(StimOnF:end)),MeanTraceCell,'UniformOutput',false);
            SmoothMaxValue = cellfun(@(x) max(x(FrameScales(1) - StimOnF:FrameScales(2) - StimOnF)),SmoothMeanTrace);
            cROIRespData(nDBType,:) = SmoothMaxValue;
            
            nElements = cellfun(@numel,MeanTraceCell);
            if length(unique(nElements)) > 1
                EleTypes = unique(nElements);
                LessIndsType = nElements == EleTypes(1);
                MeanTraceCell(LessIndsType) = cDBdatacell(LessIndsType);
            end
            %
            MeanTraceMtx = cell2mat(MeanTraceCell);
            nFrequency = length(yticklabels);
            LineColors = jet(nFrequency);
            
            subplot(numDB,3,nDBType*3);
            hold on
            linehandle = [];
            for nLines = 1 : nFrequency
                hlh = plot(MeanTraceMtx(nLines,:),'color',LineColors(nLines,:),'linewidth',1.5);
                linehandle = [linehandle,hlh];
            end
            yscales = get(gca,'ylim');
            line([StimOnF StimOnF],yscales,'linewidth',1.5,'linestyle','--','color',[.7 .7 .7]);
            line([StimOffF StimOffF],yscales,'linewidth',1.5,'linestyle','--','color',[.7 .7 .7]);
            set(gca,'xtick',xTicks,'xticklabel',Ticklabel,'FontSize',18,'ylim',yscales);
            if nDBType == numDB
                xlabel('Time (s)');
            end
            if nDBType == 1
                legend(linehandle,yticklabels);
                legend('boxoff');
            end
            ylabel({'\DeltaF/F_0 (%)',sprintf('DB = %d',DBtypes(nDBType))});
            set(gca,'FontSize',8);
            if nDBType == 1
                title('MeanTrace','FontSize',14);
            end
            %
        end
    end
    
    if isplot
        suptitle(sprintf('ROI%d resp plot',nROI));
        saveas(hROI,sprintf('ROI%d passive resp plot',nROI));
        saveas(hROI,sprintf('ROI%d passive resp plot',nROI),'png');
        close(hROI);
        
        
        % plots single ROI response v-shaped plots
        DBStrs = cellstr(num2str(DBtypes(:)));
        FreqStrs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
        h_hf = figure('position',[100 100 380 300],'visible','off');
%         subplot(121)
        imagesc(cROIRespData);
        colormap gray
        set(gca,'yDir','normal','ytick',1:DBtypes,'yticklabel',DBStrs,'xtick',1:numFreq,'xticklabel',FreqStrs,'FontSize',9);
        title(sprintf('ROI%d',nROI));
        
        hhhbar = colorbar;
        set(get(hhhbar,'title'),'String','\DeltaF/F');
        
%         subplot(122)
%         imagesc(cROIRespData > RespThresV);
%         colormap gray
%         set(gca,'yDir','normal','ytick',1:DBtypes,'yticklabel',DBStrs,'xtick',1:numFreq,'xticklabel',FreqStrs,'FontSize',9);
%         
%         
        %
        saveas(h_hf,sprintf('ROI%d response value colorplot',nROI));
        saveas(h_hf,sprintf('ROI%d response value colorplot',nROI),'png');
        close(h_hf);
    end
end
save UnevenPassdata.mat typeData TimeStimOn FrameRate DBtypes FreqTypes TypeFrameInds -v7.3
cd ..;