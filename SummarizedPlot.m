function SummarizedPlot(varargin)
% This function will be used for summarized all kind of analysis result
% together and plot those results together according to the session type,
% using defined figure ploy template
% Each data set should contains specific data that will be used for ploting
% specific subplot, but also contains some basic properties for current
% session such as frame rate, align frame and so on
% All data contains in a structure form.

[SessionDesp,SessionData] = deal(varargin{:});
if strcmpi(SessionDesp,'Twotone2afc')
    fprintf('Session is a normal two tone 2afc session.\n');
elseif strcmpi(SessionDesp,'RandomPuretone')
    fprintf('Session is a random puretone session.\n');
elseif strcmpi(SessionDesp,'RewardOmit')
    fprintf('Session is a random puretone session.\n');
else
    fprintf('Session description don''t have default plate, please check session type.\n');
    return;
end

switch SessionDesp
    case 'Twotone2afc'
        % Normal 2afc session, figure subplot(3,2)
        % if v-shape plot exists, plot it at the last subplot
        nROIs = SessionData.nROI;
        for ROInumber = 1 : nROIs
            h_Nor2afc = figure('position',[100,100,1200,900],'paperpositionmode','auto');

            imagextick = 0:SessionData.FrameRate:size(SessionData.LeftAlignData,3); % Data with a three dimensional form, ROI by Trials by Frames
            Timextick = imagextick/SessionData.FrameRate;
            cAx = subplot(3,2,1);
            imagesc(squeeze(SessionData.LeftAlignData(ROInumber,:,:)),SessionData.clims(ROInumber,:));
            set(gca,'ydir','reverse');
            set(gca,'xtick',imagextick,'xticklabel',Timextick);
            LeftAnswer = SessionData.LeftAnsT;
            for nn = 1 : length(LeftAnswer)
                line([LeftAnswer(nn),LeftAnswer(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.8);
            end
            ylim([0.5 nn+0.5]);
            xlim([0.5 size(SessionData.LeftAlignData,3)+0.5]);
            line([SessionData.AlignFrame SessionData.AlignFrame],[0.5,nn+0.5],'color',[.8 .8 .8],'LineWidth',1.5);
            title('Corr Left trials');
            ylabel('# Trials');
            xlabel('Time (s)');
            set(gca,'FontSize',20);
            cImAxis = get(cAx,'position');
            colorbar('westoutside');
            set(cAx,'position',cImAxis);
            LeftMeanTrace = mean(squeeze(SessionData.LeftAlignData(ROInumber,:,:)));
            LeftSEMTrace = std(squeeze(SessionData.LeftAlignData(ROInumber,:,:)))/sqrt(size(SessionData.LeftAlignData,2));
            

            subplot(3,2,3)
            imagesc(squeeze(SessionData.RightAlignData(ROInumber,:,:)),SessionData.clims(ROInumber,:));
            set(gca,'ydir','reverse');
            set(gca,'xtick',imagextick,'xticklabel',Timextick);
            RightAnswer = SessionData.RightAnsT;
            for nn = 1 : length(RightAnswer)
                line([RightAnswer(nn),RightAnswer(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.8);
            end
            ylim([0.5 nn+0.5]);
            xlim([0.5 size(SessionData.RightAlignData,3)+0.5]);
            line([SessionData.AlignFrame SessionData.AlignFrame],[0.5,nn+0.5],'color',[.8 .8 .8],'LineWidth',1.5);
%             set(gca,'FontSize',20);
            title('Corr Right trials');
            ylabel('# Trials');
            xlabel('Time (s)');
            set(gca,'FontSize',20);
            RightMeanTrace = mean(squeeze(SessionData.RightAlignData(ROInumber,:,:)));
            RightSEMTrace = std(squeeze(SessionData.RightAlignData(ROInumber,:,:)))/sqrt(size(SessionData.RightAlignData,2));
            
            ts = (1 : length(LeftMeanTrace))/SessionData.FrameRate;
            xp = [ts,fliplr(ts)];
            yp = [LeftMeanTrace+LeftSEMTrace,fliplr(LeftMeanTrace-LeftSEMTrace)];
            ypR = [RightMeanTrace+RightSEMTrace,fliplr(RightMeanTrace-RightSEMTrace)];
            subplot(3,2,5)
            hold on;
            lh1 = plot(ts,LeftMeanTrace,'b','LineWidth',1.5);
            lh2 = plot(ts,RightMeanTrace,'r','LineWidth',1.5);
            patch(xp,yp,1,'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.6);
            patch(xp,ypR,1,'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.6);
            AlignT = SessionData.AlignFrame/SessionData.FrameRate;
            yaxis = axis;
            patch([AlignT AlignT+0.3 AlignT+0.3 AlignT],[yaxis(3) yaxis(3) yaxis(4) yaxis(4)],1,...
                'facecolor',[.1 .8 .1],'Edgecolor','none','facealpha',0.3);
            legend([lh1,lh2],'LeftMean','RightMean');
            xlabel('Time (s)');
            ylabel('Mean \DeltaF/F_0 (%)');
            title(sprintf('TimeWin AUC = %.4f',SessionData.ROIauc(ROInumber)));
            set(gca,'FontSize',20);
            
            subplot(3,2,2)
            xTime = SessionData.ROCCoursexTick;
            ROCourseData = SessionData.BinROCLR(ROInumber,:);
            plot(xTime,ROCourseData,'r-o','LineWidth',1.6);
            line([AlignT AlignT],[0 1],'color',[.8 .8 .8],'LineWidth',1.5,'LineStyle','--');
            xx=get(gca,'xlim');
            line([0 xx(2)],[0.5 0.5],'color',[.8 .8 .8],'LineWidth',1.5,'LineStyle','--');
            xlabel('Time (s)');
            ylabel('ROC value');
            title('AUC Time course');
            set(gca,'FontSize',20);
            
            if isfield(SessionData,'VShapeData')
                cROIVshapeData = SessionData.VShapeData;
                im_ax = subplot(3,2,4);
                imagesc(1:length(cROIVshapeData.FreqTypes),cROIVshapeData.DBTypes,squeeze(cROIVshapeData.RFdataAll(ROInumber,:,:)),...
                    cROIVshapeData.RFclim(ROInumber,:));
%                 colormap(hot);
                set(gca,'YDir','normal');
                xticklabel = cROIVshapeData.FreqTypes/1000;
                TickLength = length(cROIVshapeData.FreqTypes);
                set(gca,'xtick',1:3:TickLength,'xticklabel',cellstr(num2str(xticklabel(1:3:TickLength),'%.1f')),...
                    'Ytick',flipud(cROIVshapeData.DBTypes),'YTickLabel',flipud(cROIVshapeData.DBTypes));
%                 im_ax = gca;
                colormap(im_ax,hot);
                im_axpos = get(im_ax,'position');
                colorbar;
                set(im_ax,'position',im_axpos);
%                 hcpos = get(h_colorbar,'position');
%                 hPlotPos = get(himage,'position');
%                 set(h_colorbar,'position',[hcpos(1)*1.15 hcpos(2) hcpos(3)*0.4 hcpos(4)]);
                xlabel('Frequency (kHz)');
                ylabel('Sound intensity');
                title('Frequency tuning');
                set(gca,'FontSize',20);
            end
            
%             suptitle(sprintf('ROI%d summarized plot',ROInumber));
            annotation('textbox',[0.43,0.685,0.3,0.3],'String',sprintf('ROI%d summary plot',ROInumber),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',20);
            saveas(h_Nor2afc,sprintf('ROI%d summarized plot',ROInumber));
            saveas(h_Nor2afc,sprintf('ROI%d summarized plot',ROInumber),'png');
            close(h_Nor2afc);
        end
    case 'RandomPuretone'
        % random puretone plots, subplot(3,4)
        % if frequency tuning data exists, plot it out instead of
        % time-course ROC
        nROIs = SessionData.nROI;
        for ROInumber = 1 : nROIs
            h_RandTone2afc = figure('position',[100,100,1600,1000],'paperpositionmode','auto');

            imagextick = 0:SessionData.FrameRate:size(SessionData.LeftAlignData,3); % Data with a three dimensional form, ROI by Trials by Frames
            Timextick = imagextick/SessionData.FrameRate;
            cAx = subplot(3,4,1);
            imagesc(squeeze(SessionData.LeftAlignData(ROInumber,:,:)),SessionData.clims(ROInumber,:));
            set(gca,'ydir','reverse');
            set(gca,'xtick',imagextick,'xticklabel',Timextick);
            LeftAnswer = SessionData.LeftAnsT;
            for nn = 1 : length(LeftAnswer)
                line([LeftAnswer(nn),LeftAnswer(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.8);
            end
            ylim([0.5 nn+0.5]);
            xlim([0.5 size(SessionData.LeftAlignData,3)+0.5]);
            line([SessionData.AlignFrame SessionData.AlignFrame],[0.5,nn+0.5],'color',[.8 .8 .8],'LineWidth',1.5);
            title('Corr Left trials');
            ylabel('# Trials');
            xlabel('Time (s)');
            set(gca,'FontSize',20);
            cImAxis = get(cAx,'position');
            colorbar('westoutside');
            set(cAx,'position',cImAxis);
            LeftMeanTrace = mean(squeeze(SessionData.LeftAlignData(ROInumber,:,:)));
            LeftSEMTrace = std(squeeze(SessionData.LeftAlignData(ROInumber,:,:)))/sqrt(size(SessionData.LeftAlignData,2));
            

            subplot(3,4,5)
            imagesc(squeeze(SessionData.RightAlignData(ROInumber,:,:)),SessionData.clims(ROInumber,:));
            set(gca,'ydir','reverse');
            set(gca,'xtick',imagextick,'xticklabel',Timextick);
            RightAnswer = SessionData.RightAnsT;
            for nn = 1 : length(RightAnswer)
                line([RightAnswer(nn),RightAnswer(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.8);
            end
            ylim([0.5 nn+0.5]);
            xlim([0.5 size(SessionData.RightAlignData,3)+0.5]);
            line([SessionData.AlignFrame SessionData.AlignFrame],[0.5,nn+0.5],'color',[.8 .8 .8],'LineWidth',1.5);
%             set(gca,'FontSize',20);
            title('Corr Right trials');
            ylabel('# Trials');
            xlabel('Time (s)');
            set(gca,'FontSize',20);
            RightMeanTrace = mean(squeeze(SessionData.RightAlignData(ROInumber,:,:)));
            RightSEMTrace = std(squeeze(SessionData.RightAlignData(ROInumber,:,:)))/sqrt(size(SessionData.RightAlignData,2));
            
            ts = (1 : length(LeftMeanTrace))/SessionData.FrameRate;
            xp = [ts,fliplr(ts)];
            yp = [LeftMeanTrace+LeftSEMTrace,fliplr(LeftMeanTrace-LeftSEMTrace)];
            ypR = [RightMeanTrace+RightSEMTrace,fliplr(RightMeanTrace-RightSEMTrace)];
            subplot(3,4,9)
            hold on;
            lh1 = plot(ts,LeftMeanTrace,'b','LineWidth',1.5);
            lh2 = plot(ts,RightMeanTrace,'r','LineWidth',1.5);
            patch(xp,yp,1,'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.6);
            patch(xp,ypR,1,'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.6);
            AlignT = SessionData.AlignFrame/SessionData.FrameRate;
            xlim([0 max(ts)]);
            yaxis = axis;
            patch([AlignT AlignT+0.3 AlignT+0.3 AlignT],[yaxis(3) yaxis(3) yaxis(4) yaxis(4)],1,...
                'facecolor',[.1 .8 .1],'Edgecolor','none','facealpha',0.3);
            legend([lh1,lh2],'LeftMean','RightMean');
            xlabel('Time (s)');
            ylabel('Mean \DeltaF/F_0');
%             title('Mean Trace Plot');
            title(sprintf('TimeWin AUC = %.4f',SessionData.ROIauc(ROInumber)));
            set(gca,'FontSize',10);
                        
            % plotting the different frequencies response seperately
            if ROInumber == 1
                FreqDataAll = SessionData.AllFreqData; % this should be a two dimensional cell dataset, nfreq by nROis, ...
                % each cell elements contains a matrix in form: Trials by
                % Frames
                AnsFrameAll = SessionData.AllAnsFrame; % two dimensional cell, each contains one vector of ans frames
    %             cLims = SessionData.clims;
    %             SessionData.AlignFrame
            end
            for nfreq = 1 : 6
                if nfreq < 4
                    subplot(3,4,nfreq+1);
                else
                    subplot(3,4,nfreq+2);
                end
                cfreqData = FreqDataAll{nfreq,ROInumber};
                cfreqAns = AnsFrameAll{nfreq};
                imagesc(cfreqData,SessionData.clims(ROInumber,:));
                xlim([0.5 size(cfreqData,2)+0.5]);
                ylim([0.5 size(cfreqData,1)+0.5]);
                xticks = 0:SessionData.FrameRate:size(cfreqData,2);
                xticklabel = xticks/SessionData.FrameRate;
                for nn = 1 : length(cfreqAns)
                    line([cfreqAns(nn) cfreqAns(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.5);
                end
%                 yaxis = axis;
                line([SessionData.AlignFrame SessionData.AlignFrame],[0.5 nn+0.5],'color',[.8 .8 .8],'LineWidth',1.6);
                set(gca,'xtick',xticks,'xticklabel',xticklabel);
                xlabel('Time(s)');
                ylabel('# Trials');
                title(sprintf('%d Hz',SessionData.Frequency(nfreq)));
                set(gca,'FontSize',20);
                if nfreq == 6
                    imax = gca;
                    imaxis = get(imax,'position');
                    hbar = colorbar;
                    set(imax,'position',imaxis);
                end
            end
            
            if isfield(SessionData,'VShapeData')
                cROIVshapeData = SessionData.VShapeData;
                im_ax = subplot(3,4,10);
                imagesc(1:length(cROIVshapeData.FreqType),cROIVshapeData.DBType,squeeze(cROIVshapeData.RespData(ROInumber,:,:)),...
                    cROIVshapeData.RFclim(ROInumber,:));
%                 colormap(hot);
                set(gca,'YDir','normal');
                xticklabel = cROIVshapeData.FreqType/1000;
                TickLength = length(cROIVshapeData.FreqTypes);
                set(gca,'xtick',1:3:TickLength,'xticklabel',cellstr(num2str(xticklabel(1:3:TickLength),'%.1f')),...
                    'Ytick',flipud(cROIVshapeData.DBType),'YTickLabel',flipud(cROIVshapeData.DBType));
%                 im_ax = gca;
                im_axpos = get(im_ax,'position');
                colormap(im_ax,hot);
                colorbar('southoutside');
                set(im_ax,'position',im_axpos);
%                 hPlotPos = get(himage,'position');
%                 set(h_colorbar,'position',[hcpos(1)*1.15 hcpos(2) hcpos(3)*0.4 hcpos(4)]);
                xlabel('Frequency (kHz)');
                ylabel('Sound intensity');
                title('Frequency tuning');
                set(gca,'FontSize',20);
            elseif isfield(SessionData,'ROCCoursexTick') && isfield(SessionData,'BinROCLR')
                subplot(3,4,10);
                xTime = SessionData.ROCCoursexTick;
                ROCourseData = SessionData.BinROCLR(ROInumber,:);
                plot(xTime,ROCourseData,'r-o','LineWidth',1.6);
                line([AlignT AlignT],[0 1],'color',[.8 .8 .8],'LineWidth',1.5,'LineStyle','--');
                xx=get(gca,'xlim');
                line([0 xx(2)],[0.5 0.5],'color',[.8 .8 .8],'LineWidth',1.5,'LineStyle','--');
                xlabel('Time (s)');
                ylabel('ROC value');
                title('Time Course of AUC');
                set(gca,'FontSize',10);
            end
            
            % plot frequency response lines
            subplot(3,4,11)
            hold on;
            RespData = squeeze(SessionData.MeanRespData(ROInumber,:,:)); % mean response trace for different frequency
            xt = (1:size(RespData,2))/SessionData.FrameRate;
            FreqStr = double(SessionData.Frequency)/1000;
            LineDataColor = jet(6);
            LegendStr = cell(1,6);
            for nn = 1 : 6
                plot(xt,RespData(nn,:),'color',LineDataColor(nn,:),'LineWidth',1.5);
                LegendStr{nn} = sprintf('%.2f kHz',FreqStr(nn));
            end
            legend(LegendStr,'FontSize',4);
            yaxis = axis;
            patch([AlignT AlignT+0.3 AlignT+0.3 AlignT],[yaxis(3) yaxis(3) yaxis(4) yaxis(4)],1,'FaceColor','g',...
                'EdgeColor','None','FaceAlpha',0.4);
%             line([AlignT AlignT],[yaxis(3) yaxis(4)],'color',[.8 .8 .8],'LineWidth',1.6);
            xlabel('Time (s)');
            ylabel('\DeltaF/F_0  (%)');
            title('Freq response plot');
            set(gca,'FontSize',10);
            
            % plot the last piece
            subplot(3,4,12)
            hold on;
            cellfreq = double(SessionData.Frequency)/1000;
            if isfield(SessionData,'ChoiceProbData')
                DataStoreCell = SessionData.ChoiceProbData;
                FreqTypeTrialNum = SessionData.TypeNumber;
                for nfreq = 1 : 6
                    CorrRandx = ones(FreqTypeTrialNum(ROInumber,nfreq,1),1)*(nfreq-0.2);
                    ErroRandx = ones(FreqTypeTrialNum(ROInumber,nfreq,2),1)*(nfreq+0.2);
                    scatter(CorrRandx,DataStoreCell{ROInumber,nfreq,1}{:},50,'ro','filled');
                    scatter(ErroRandx,DataStoreCell{ROInumber,nfreq,2}{:},50,'bo','filled');
                end
            end
            set(gca,'xtick',1:6,'xticklabel',cellstr(num2str(cellfreq(:),'%.1f')));
            xlabel('Frequency (kHz)');
            ylabel('\DeltaF/F_0');
            title('Choice Prob Plot');
            
            annotation('textbox',[0.44,0.685,0.3,0.3],'String',sprintf('ROI%d summary plot',ROInumber),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',20);
%             suptitle(sprintf('ROI%d summary plot',ROInumber));
            saveas(h_RandTone2afc,sprintf('Random puretone Summarized plot ROI%d',ROInumber));
            saveas(h_RandTone2afc,sprintf('Random puretone Summarized plot ROI%d',ROInumber),'png');
            close(h_RandTone2afc);
        end
    case 'RewardOmit'
        % Reward omit 2afc session, figure subplot(3,3)
        % if v-shape plot exists, plot it at the last subplot
        nROIs = SessionData.nROI;
        for ROInumber = 1 : nROIs
            h_ROmit2afc = figure('position',[100,100,1200,900],'paperpositionmode','auto');
            % the following three subplot indicates all for normal trials
            % data result, prob trials will be stored in other fields
            imagextick = 0:SessionData.FrameRate:size(SessionData.LeftAlignData,3); % Data with a three dimensional form, ROI by Trials by Frames
            Timextick = imagextick/SessionData.FrameRate;
            cAx = subplot(3,3,1);
            imagesc(squeeze(SessionData.LeftAlignData(ROInumber,:,:)),SessionData.clims(ROInumber,:));
            set(gca,'ydir','reverse');
            set(gca,'xtick',imagextick,'xticklabel',Timextick);
            LeftAnswer = SessionData.LeftAnsT;
            for nn = 1 : length(LeftAnswer)
                line([LeftAnswer(nn),LeftAnswer(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.8);
            end
            ylim([0.5 nn+0.5]);
            xlim([0.5 size(SessionData.LeftAlignData,3)+0.5]);
            line([SessionData.AlignFrame SessionData.AlignFrame],[0.5,nn+0.5],'color',[.8 .8 .8],'LineWidth',1.5);
            xlabel('Time (s)');
            ylabel('# Trials');
            title('Corr Left trials');
            set(gca,'FontSize',20);
            cImAxis = get(cAx,'position');
            colorbar('westoutside');
            set(cAx,'position',cImAxis);
            LeftMeanTrace = mean(squeeze(SessionData.LeftAlignData(ROInumber,:,:)));
            LeftSEMTrace = std(squeeze(SessionData.LeftAlignData(ROInumber,:,:)))/sqrt(size(SessionData.LeftAlignData,2));
            

            subplot(3,3,4)
            imagesc(squeeze(SessionData.RightAlignData(ROInumber,:,:)),SessionData.clims(ROInumber,:));
            set(gca,'ydir','reverse');
            set(gca,'xtick',imagextick,'xticklabel',Timextick);
            RightAnswer = SessionData.RightAnsT;
            for nn = 1 : length(RightAnswer)
                line([RightAnswer(nn),RightAnswer(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.8);
            end
            ylim([0.5 nn+0.5]);
            xlim([0.5 size(SessionData.RightAlignData,3)+0.5]);
            line([SessionData.AlignFrame SessionData.AlignFrame],[0.5,nn+0.5],'color',[.8 .8 .8],'LineWidth',1.5);
%             set(gca,'FontSize',20);
            xlabel('Time (s)');
            ylabel('# Trials');
            title('Corr Right trials');
            set(gca,'FontSize',20);
            RightMeanTrace = mean(squeeze(SessionData.RightAlignData(ROInumber,:,:)));
            RightSEMTrace = std(squeeze(SessionData.RightAlignData(ROInumber,:,:)))/sqrt(size(SessionData.RightAlignData,2));
            
            ts = (1 : length(LeftMeanTrace))/SessionData.FrameRate;
            xp = [ts,fliplr(ts)];
            yp = [LeftMeanTrace+LeftSEMTrace,fliplr(LeftMeanTrace-LeftSEMTrace)];
            ypR = [RightMeanTrace+RightSEMTrace,fliplr(RightMeanTrace-RightSEMTrace)];
            subplot(3,3,7)
            hold on;
            lh1 = plot(ts,LeftMeanTrace,'b','LineWidth',1.5);
            lh2 = plot(ts,RightMeanTrace,'r','LineWidth',1.5);
            patch(xp,yp,1,'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.6);
            patch(xp,ypR,1,'facecolor',[.8 .8 .8],'edgecolor','none','facealpha',0.6);
            AlignT = SessionData.AlignFrame/SessionData.FrameRate;
            yaxis = axis;
            patch([AlignT AlignT+0.3 AlignT+0.3 AlignT],[yaxis(3) yaxis(3) yaxis(4) yaxis(4)],1,...
                'facecolor',[.1 .8 .1],'Edgecolor','none','facealpha',0.3);
            xlabel('Time (s)');
            ylabel('Mean \DeltaF/F_0 (%)');
            title(sprintf('TimeWin AUC = %.4f',SessionData.ROIauc(ROInumber)));
            set(gca,'FontSize',20);
            legend([lh1,lh2],{'LeftMean','RightMean'},'FontSize',8);
            
            subplot(3,3,2);
            cLeftOmitData = squeeze(SessionData.LeftAlignOmit(ROInumber,:,:));
            cLeftOmitAnsF = SessionData.LeftOmitAnsF;
            imagesc(cLeftOmitData,SessionData.clims(ROInumber,:));
            set(gca,'ydir','reverse');
            set(gca,'xtick',imagextick,'xticklabel',Timextick);
            for nn = 1 : length(cLeftOmitAnsF)
                line([cLeftOmitAnsF(nn) cLeftOmitAnsF(nn)],[nn-0.5 nn+0.5],'Color',[1 0 1],'LineWidth',1.6);
            end
            line([SessionData.AlignFrame SessionData.AlignFrame],[0.5,nn+0.5],'color',[.8 .8 .8],'LineWidth',1.5);
            xlabel('Time (s)');
            ylabel('# Trials');
            set(gca,'FontSize',20);
            title('Left corr omit trials');
%             LeftOmitMean = mean(cLeftOmitData);
%             LeftOmitSEM = std(cLeftOmitData)/sqrt(size(cLeftOmitData,1));
            
            subplot(3,3,5);
            cRightOmitData = squeeze(SessionData.RightAlignOmit(ROInumber,:,:));
            cRightOmitAnsF = SessionData.RightOmitAnsF;
            imagesc(cRightOmitData ,SessionData.clims(ROInumber,:));
            set(gca,'ydir','reverse');
            set(gca,'xtick',imagextick,'xticklabel',Timextick);
            for nn = 1 : length(cRightOmitAnsF)
                line([cRightOmitAnsF(nn) cRightOmitAnsF(nn)],[nn-0.5 nn+0.5],'Color',[1 0 1],'LineWidth',1.6);
            end
            line([SessionData.AlignFrame SessionData.AlignFrame],[0.5,nn+0.5],'color',[.8 .8 .8],'LineWidth',1.5);
            xlabel('Time (s)');
            ylabel('# Trials');
            set(gca,'FontSize',20);
            title('Left corr omit trials');
%             LeftOmitMean = mean(cRightOmitData);
%             LeftOmitSEM = std(cRightOmitData)/sqrt(size(cRightOmitData,1));
            % plot the mean trace for left and right corr omit trials,
            % aligned to answer time mean, but not sound on time
            
            subplot(3,3,3)
            hold on
            LeftNorMeanAns = squeeze(SessionData.LeftAnsAlMeanTr(ROInumber,1,:));
            LeftNorSemAns = squeeze(SessionData.LeftAnsAlMeanTr(ROInumber,2,:));
            LeftOmitMeanAns = squeeze(SessionData.LeftAnsAlMeanTr(ROInumber,3,:));
            LeftOmitSemAns = squeeze(SessionData.LeftAnsAlMeanTr(ROInumber,4,:));
%             LeftNorMeanAns = SessionData.LeftNorMeanAnsData(ROInumber,:);
%             LeftNorSemAns = SessionData.LeftNorSemAnsData(ROInumber,:);
%             LeftOmitMeanAns = SessionData.LeftOmitMeanAnsData(ROInumber,:);
%             LeftOmitSemAns = SessionData.LeftOmitSemAnsData(ROInumber,:);
            xt = (1:length(LeftNorMeanAns))/SessionData.FrameRate;
            AnsT = SessionData.AlignedF/SessionData.FrameRate;
            hold on;
            patch([xt fliplr(xt)],[(LeftNorMeanAns'+LeftNorSemAns') fliplr(LeftNorMeanAns'-LeftNorSemAns')],1,...
                'FaceColor',[.8 .8 .8],'EdgeColor','None','FaceAlpha',0.8);
            patch([xt fliplr(xt)],[(LeftOmitMeanAns'+LeftOmitSemAns') fliplr(LeftOmitMeanAns'-LeftOmitSemAns')],1,...
                'FaceColor',[.8 .8 .8],'EdgeColor','None','FaceAlpha',0.8);
            hline1 = plot(xt,LeftNorMeanAns,'b','LineWidth',1.6);
            hline2 = plot(xt,LeftOmitMeanAns,'Color',[1 0 1],'LineWidth',1.5);
            yaxis = axis;
            line([AnsT AnsT],[yaxis(3) yaxis(4)],'Color',[.8 .8 .8],'LineWidth',1.6);
            xlabel('Time (s)');
            ylabel('Mean \DeltaF/F_0 (%)');
            xlim([0 max(xt)]);
            set(gca,'FontSize',18);
            legend([hline1,hline2],{'Left Normal','Left Omit'},'FontSize',8);
            
            subplot(3,3,6)
            hold on
            RightNorMeanAns = squeeze(SessionData.RightAnsAlMeanTr(ROInumber,1,:));
            RightNorSemAns = squeeze(SessionData.RightAnsAlMeanTr(ROInumber,2,:));
            RightOmitMeanAns = squeeze(SessionData.RightAnsAlMeanTr(ROInumber,3,:));
            RightOmitSemAns = squeeze(SessionData.RightAnsAlMeanTr(ROInumber,4,:));
%             RightNorMeanAns = SessionData.RightNorMeanAnsData(ROInumber,:);
%             RightNorSemAns = SessionData.RightNorSemAnsData(ROInumber,:);
%             RightOmitMeanAns = SessionData.RightOmitMeanAnsData(ROInumber,:);
%             RightOmitSemAns = SessionData.RightOmitSemAnsData(ROInumber,:);
            xt = (1:length(RightNorMeanAns))/SessionData.FrameRate;
%             AnsT = SessionData.AnsAlignF/SessionData.FrameRate;
            hold on;
            patch([xt fliplr(xt)],[RightNorMeanAns'+RightNorSemAns' fliplr(RightNorMeanAns'-RightNorSemAns')],1,...
                'FaceColor',[.8 .8 .8],'EdgeColor','None','FaceAlpha',0.8);
            patch([xt fliplr(xt)],[RightOmitMeanAns'+RightOmitSemAns' fliplr(RightOmitMeanAns'-RightOmitSemAns')],1,...
                'FaceColor',[.8 .8 .8],'EdgeColor','None','FaceAlpha',0.8);
            hline1 = plot(xt,RightNorMeanAns,'r','LineWidth',1.8);
            hline2 = plot(xt,RightOmitMeanAns,'Color','k','LineWidth',1.8);
            yaxis = axis;
            line([AnsT AnsT],[yaxis(3) yaxis(4)],'Color',[.8 .8 .8],'LineWidth',1.6);
            xlabel('Time (s)');
            ylabel('Mean \DeltaF/F_0 (%)');
            xlim([0 max(xt)]);
            set(gca,'FontSize',18)
            legend([hline1,hline2],{'Right Normal','Right Omit'},'FontSize',8);
            
            subplot(3,3,8)
            xTime = SessionData.ROCCoursexTick;
            ROCourseData = SessionData.BinROCLR(ROInumber,:);
            plot(xTime,ROCourseData,'r-o','LineWidth',1.6);
            line([AlignT AlignT],[0 1],'color',[.8 .8 .8],'LineWidth',1.5,'LineStyle','--');
            xx=get(gca,'xlim');
            line([0 xx(2)],[0.5 0.5],'color',[.8 .8 .8],'LineWidth',1.5,'LineStyle','--');
            xlabel('Time (s)');
            ylabel('ROC value');
            title('Time Course AUC');
%             title(sprintf('TimeWin AUC = %.4f',SessionData.ROIauc(ROInumber)));
            set(gca,'FontSize',20);
            
            if isfield(SessionData,'VShapeData')
                cROIVshapeData = SessionData.VShapeData;
                im_ax = subplot(3,3,9);
                imagesc(1:length(cROIVshapeData.FreqType),cROIVshapeData.DBType,squeeze(cROIVshapeData.RespData(ROInumber,:,:)),...
                    cROIVshapeData.RFclim(ROInumber,:));
%                 colormap(hot);
                set(gca,'YDir','normal');
                xticklabel = cROIVshapeData.FreqType/1000;
                 TickLength = length(cROIVshapeData.FreqTypes);
                set(gca,'xtick',1:3:TickLength,'xticklabel',cellstr(num2str(xticklabel(1:3:TickLength),'%.1f')),...
                    'Ytick',flipud(cROIVshapeData.DBType),'YTickLabel',flipud(cROIVshapeData.DBType));
%                 im_ax = gca;
                im_axpos = get(im_ax,'position');
                colormap(im_ax,hot);
                colorbar('southoutside');
                set(im_ax,'position',im_axpos);
%                 hPlotPos = get(himage,'position');
%                 set(h_colorbar,'position',[hcpos(1)*1.15 hcpos(2) hcpos(3)*0.4 hcpos(4)]);
                xlabel('Frequency (kHz)');
                ylabel('Sound intensity');
                title('Frequency tuning');
                set(gca,'FontSize',20);
            end
            
%             suptitle(sprintf('ROI%d summarized plot ROmit',ROInumber));
            annotation('textbox',[0.44,0.685,0.3,0.3],'String',sprintf('ROI%d summary plot',ROInumber),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',20);
            saveas(h_ROmit2afc,sprintf('ROI%d summarized plot ROmit',ROInumber));
            saveas(h_ROmit2afc,sprintf('ROI%d summarized plot ROmit',ROInumber),'png');
            close(h_ROmit2afc);
        end
    otherwise
        fprintf('Error input Session type, quit current function.\n');
        return;
end
save SumReaultSave.mat SessionData -v7.3
