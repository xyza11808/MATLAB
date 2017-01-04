function UnevenRFrespPlot(PassData,DBArray,FreqArray,FrameRate,varargin)
% this function is specifically used for passive data color plot with some
% trials excluded from analysis
TimeStimOn = 1;
if nargin > 4
    if ~isempty(varargin{1})
        TimeStimOn = varargin{1};
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
    hROI = figure('position',[200 100 1200 900]);
    Coloraxis = subplot(numDB,2,1:2:(numDB*2));
    clim = [0 min([300,max(cROIdata(:))])];
    imagesc(cROIdata,clim);
    set(gca,'xtick',xTicks,'xticklabel',Ticklabel);
    cAxisPos = get(gca,'position');
    xlabel('Time(s)');
    colorbar('westoutside');
    set(Coloraxis,'position',cAxisPos);
    patch([StimOnF,StimOffF,StimOffF,StimOnF],[0.5 0.5 (nTrials+0.5) (nTrials+0.5)],1,'FaceColor','g','EdgeColor','none','facealpha',0.4);
    set(gca,'FontSize',16);
    
    for nDBType = 1 : numDB
        for nFreqtype = 1 : numFreq
            cCombInds = DBArray == DBtypes(nDBType) & FreqArray == FreqTypes(nFreqtype);
            cCombData = cROIdata(cCombInds,:);
            typeData{nROI,nDBType,nFreqtype} = cCombData;
        end
        cDBdatacell = squeeze(typeData(nROI,nDBType,:));
        TrialNum = cellfun(@(x) size(x,1),cDBdatacell);
        TrIndscdfSum = vectorcdf(TrialNum);
        cDBdataMatrix = cell2mat(cDBdatacell);
        subplot(numDB,2,nDBType*2)
        imagesc(cDBdataMatrix,clim);
        set(gca,'xtick',xTicks,'xticklabel',Ticklabel,'ytick',TrIndscdfSum,'yticklabel',yticklabels);
        xlabel('Time (s)');
        ylabel('Frequency');
        patch([StimOnF,StimOffF,StimOffF,StimOnF],[0.5 0.5 (nTrials+0.5) (nTrials+0.5)],1,'FaceColor','g','EdgeColor','none','facealpha',0.4);
        title(sprintf('%d dB',DBtypes(nDBType)),'FontSize',18);
    end
    
    suptitle(sprintf('ROI%d resp plot',nROI));
    saveas(hROI,sprintf('ROI%d passive resp plot',nROI));
    saveas(hROI,sprintf('ROI%d passive resp plot',nROI),'png');
    close(hROI);
end
save UnevenPassdata.mat typeData TimeStimOn FrameRate -v7.3
cd ..;