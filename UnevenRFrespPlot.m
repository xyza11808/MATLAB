function UnevenRFrespPlot(PassData,DBArray,FreqArray,FrameRate,varargin)
% this function is specifically used for passive data color plot with some
% trials excluded from analysis
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
for nROI = 1 : nROIs
    cROIdata = squeeze(PassData(:,nROI,:));
    if isplot
        hROI = figure('position',[100 100 1600 900]);
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
        set(gca,'FontSize',16);
    end
    
    for nDBType = 1 : numDB
        for nFreqtype = 1 : numFreq
            cCombInds = DBArray == DBtypes(nDBType) & FreqArray == FreqTypes(nFreqtype);
            cCombData = cROIdata(cCombInds,:);
            typeData{nROI,nDBType,nFreqtype} = cCombData;
        end
        if isplot
            cDBdatacell = squeeze(typeData(nROI,nDBType,:));
            TrialNum = cellfun(@(x) size(x,1),cDBdatacell);
            TrIndscdfSum = vectorcdf(TrialNum);
            cDBdataMatrix = cell2mat(cDBdatacell);
            subplot(numDB,3,(nDBType-1)*3+2)
            imagesc(cDBdataMatrix,clim);
            set(gca,'xtick',xTicks,'xticklabel',Ticklabel,'ytick',TrIndscdfSum,'yticklabel',yticklabels);
            if nDBType == numDB
                xlabel('Time (s)');
            end
            ylabel('Frequency');
            patch([StimOnF,StimOffF,StimOffF,StimOnF],[0.5 0.5 (nTrials+0.5) (nTrials+0.5)],1,'FaceColor','g','EdgeColor','none','facealpha',0.4);
%             if nDBType == 1
                title(sprintf('%d dB',DBtypes(nDBType)),'FontSize',18);
%             end
            %
            MeanTraceCell = cellfun(@mean,cDBdatacell,'UniformOutput',false);
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
            set(gca,'FontSize',12);
            if nDBType == 1
                title('MeanTrace','FontSize',18);
            end
            %
        end
    end
    
    if isplot
        suptitle(sprintf('ROI%d resp plot',nROI));
        saveas(hROI,sprintf('ROI%d passive resp plot',nROI));
        saveas(hROI,sprintf('ROI%d passive resp plot',nROI),'png');
        close(hROI);
    end
end
save UnevenPassdata.mat typeData TimeStimOn FrameRate DBtypes FreqTypes -v7.3
cd ..;