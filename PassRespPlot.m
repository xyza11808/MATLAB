function PassRespPlot(PassData,DBArray,FreqArray,FrameRate,varargin)
% plot the passive response data by seprating different frequencies (in columns). if
% multi-DB exists, plot in rows
% plot the mean trace at the bottom row

TimeStimOn = 1;
if nargin > 4
    if ~isempty(varargin{1})
        TimeStimOn = varargin{1};
    end
end
DBType = unique(DBArray);
nRows = length(DBType); % extra line for mean Trace plot
BaseFigureSize = [110 80 1700 300]; % single DB with mean trace, with one extra DB, increase 200 at height
RealSize = BaseFigureSize + [0 0 0 (nRows-1)*200];
MeanTraceSize = [110,80,400,300];
MeanRealSize = MeanTraceSize + [0 0 0 (nRows-1)*200];
FreqTypes = unique(FreqArray);
nCols = length(FreqTypes);
[~,nROIs,nFrames] = size(PassData);
StimStart = TimeStimOn*FrameRate;
StimOffset = round(FrameRate*(TimeStimOn + 0.3));
xticks = 0:FrameRate:nFrames;
xticklabels = xticks/FrameRate;
FreqColors = jet(nCols);
Strs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));

if ~isdir('./SepFreq_passive_plots/')
    mkdir('./SepFreq_passive_plots/');
end
cd('./SepFreq_passive_plots/');

MeanTraceSave = zeros(nRows,nCols,nFrames);
cROIColorScale = zeros(nCols,2);
for cROI = 1 : nROIs
    cROIdata = squeeze(PassData(:,cROI,:));
    cROIColorScale(cROI,:) = [0,prctile(cROIdata(:),85)]; % set uniform colorscale for all subplots
    if cROIColorScale(cROI,2) < 0
        cROIColorScale(cROI,2) = 10;
    end
    hf = figure('position',RealSize,'Paperpositionmode','auto');
    for cDB = 1 : nRows
        for cFreq = 1 : nCols
            cStimInds = DBArray(:) == DBType(cDB) & FreqArray(:) == FreqTypes(cFreq);
            cUniqueSoundData = cROIdata(cStimInds,:);
            cTrs = size(cUniqueSoundData,1);
            if cTrs > 1
                MeanTraceSave(cDB,cFreq,:) = mean(cUniqueSoundData);
            else
                MeanTraceSave(cDB,cFreq,:) = (cUniqueSoundData);
            end
            
            % colorplot part
            ax = subplot(nRows,nCols,(cFreq+(cDB-1)*nCols));
            imagesc(cROIdata(cStimInds,:),cROIColorScale(cROI,:));
            patch([StimStart StimStart StimOffset StimOffset],...
                [0.5 cTrs+0.5 cTrs+0.5 0.5],1,'FaceColor','g',...
                'edgeColor','none','Facealpha',0.4);
            set(gca,'xlim',[0.5,nFrames+0.5],'ylim',[0.5 cTrs+0.5],'xtick',xticks,...
                'xticklabel',xticklabels);
            if cFreq == 1
                ylabel(sprintf('%d DB Trials',DBType(cDB)));
            end
            if cDB == nRows
                xlabel('Time (s)');
            end
            if cDB == 1
                title(sprintf('%dHz',FreqTypes(cFreq)));
            end
            set(ax,'FontSize',16);
            % add colorbar position
            if cDB == nRows && cFreq == 1
                AxPos = get(ax,'position');
                hbar = colorbar('westoutside');
                set(gca,'position',AxPos);
                BarPos = get(hbar,'position');
                set(hbar,'position',BarPos.*[0.75 1 0.4 1]);
%                 set(ax,'position',AxPos)
            end
            
        end
    end
    annotation('textbox',[0.5,0.695,0.3,0.3],'String',['ROI' num2str(cROI)],'FitBoxToText','on','EdgeColor',...
               'none','FontSize',20,'Color','r');
    saveas(hf,sprintf('ROI%d SepFreq  Color plot save',cROI));
    saveas(hf,sprintf('ROI%d SepFreq  Color plot save',cROI),'png');
    close(hf);
    
    % mean trace plot
    hmean = figure('position',MeanRealSize,'Paperpositionmode','auto');
    AllLhandle = [];
    for cDB = 1 : nRows
        cDBData = (squeeze(MeanTraceSave(cDB,:,:)))'; % transformed for plots
        subplot(nRows,1,cDB)
        newHand = plot(cDBData,'linewidth',1.4);
        AllLhandle = [AllLhandle,newHand];
        set(gca,'xtick',xticks, 'xticklabel',xticklabels);
        yscales = get(gca,'ylim');
        line([StimStart,StimStart],yscales,'Color',[.7 .7 .7],'linewidth',1);
        line([StimOffset,StimOffset],yscales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
        set(gca,'ylim',yscales);
        ylabel('Mean \DeltaF/F_0 (%)');
        if cDB == 1
            title(sprintf('ROI%d, %dDB',cROI,DBType(cDB)));
        else
            title(sprintf('%dDB',DBType(cDB)));
        end
        set(gca,'FontSize',14);
        if cDB == nRows
            xlabel('Time (s)');
            if nRows == 1
               legend(newHand,Strs,'FontSize',8,'Position',[0.24 0.7 0.05 0.006]);
            elseif nRows == 2
               legend(newHand,Strs,'FontSize',8,'Position',[0.24 0.44 0.05 0.006]);
            elseif nRows == 3
                legend(newHand,Strs,'FontSize',8,'Position',[0.24 0.24 0.05 0.006]);
            end
            legend('boxoff');
        end
    end
    for cFreq = 1 : nCols
        set(AllLhandle(cFreq,:),'Color',FreqColors(cFreq,:));
    end
    saveas(hmean,sprintf('ROI%d Mean Trace plot save',cROI));
    saveas(hmean,sprintf('ROI%d Mean Trace plot save',cROI),'png');
    close(hmean);
end
cd ..;
% % start plotting, seperated into two figures, color plot and mean trace plot
% for cROI = 1 : nROIs
%     cROIdata = squeeze(PassData(:,cROI,:));
%     cROIscale = cROIColorScale(cROI,:);
%     
%     for cDB = 