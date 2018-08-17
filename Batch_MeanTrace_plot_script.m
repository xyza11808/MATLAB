% script fot batch plot of mean trace for each ROI using same colormap
clear
clc
MapsWhole = blue2red_2(100,0.8);
Octspace = linspace(-1,1,100);
[fn,fp,fi] = uigetfile('*.txt','Please select your data path savege file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
fid = fopen(fPath);
tline = fgetl(fid);
%%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    clearvars data_aligned behavResults
    cd(tline);
    load('CSessionData.mat')
    
    if ~isdir('./MeanTrace_plot_save/')
        mkdir('./MeanTrace_plot_save/');
    end
    cd('./MeanTrace_plot_save/');

    % example neuron mean trace plot,only correct trial used
    nROIs = size(data_aligned,2);
    for cROI = 1 : nROIs
        % cROI = 37;

        TrFreqs = double(behavResults.Stim_toneFreq);
        TrTypes = double(behavResults.Trial_Type);
        TrChoice = double(behavResults.Action_choice);
        UsedTrTypeInds = TrTypes(:) == TrChoice(:);  % all trials; Non-missing trials; Correct trials
        UsedTrType = TrTypes(UsedTrTypeInds);
        UsedTrFreqs = TrFreqs(UsedTrTypeInds);
        UsedData = data_aligned(UsedTrTypeInds,:,:);
        cROIusedData = squeeze(UsedData(:,cROI,1:round(frame_rate*4.5)));
        % cROIusedData = squeeze(UsedData(:,cROI,:));
        FreqTypes = unique(UsedTrFreqs);
        nFreqs = length(FreqTypes);
        OctTypes = log2(FreqTypes(:)/16000);

        % cMaps = blue2red_2(8,0.8);
        % cMaps = cMaps([1,2,3,4,5,6,7,8],:);

        [~,StimClosestInds] = min(abs(repmat(Octspace,nFreqs,1) - repmat(OctTypes,1,100)),[],2);
        cMaps = MapsWhole(StimClosestInds,:);

        %
        % TaaskInds = [1,2,3,6,7,8];
        % TaskInds = [1,2,3,4,5,6,7,8];
        %
        % FreqTypes = FreqTypes(TaskInds);
        % TrTypes = double(FreqTypes < 16000);
        MeanTrace = zeros(nFreqs,size(cROIusedData,2));
        for cFreq = 1 : nFreqs
            cFreqInds = UsedTrFreqs == FreqTypes(cFreq);
            if sum(cFreqInds) > 1
                cFreqData = cROIusedData(cFreqInds,:);
                cFreqMean = mean(cFreqData);
            else
                cFreqMean = cROIusedData(cFreqInds,:);
            end
            cFreqMean = cFreqMean - mean(cFreqMean(1:start_frame));
        %     cFreqMean = cFreqMean - mean(cFreqMean(1:start_frame));
            smoothedMean = smooth(cFreqMean,7,'sgolay',2);
            MeanTrace(cFreq,:) = smoothedMean;
        end

        MeanTrTypeTrace = zeros(2,size(cROIusedData,2));
        MeanTrTypeTrace(1,:) = mean(cROIusedData(UsedTrType == 0,:));
        MeanTrTypeTrace(2,:) = mean(cROIusedData(UsedTrType == 1,:));

        StartFTime = start_frame/frame_rate;
        FrameTime = (1:size(cROIusedData,2))/frame_rate;
        % FrameTime = 1:5;
        xTickTime = 0:floor(FrameTime(end));
        %
        FreqStrs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
        PlotMeanTrace = MeanTrace(:,1:end);
        PlotTime = FrameTime(1:end);
        % UsedMap = jet(length(FreqTypes));
        linehand = [];
        hf = figure('position',[3000 100 450 380]);
        hold on
        for cf = 1 : length(FreqTypes)
            hl = plot(PlotTime,PlotMeanTrace(cf,:),'Color',cMaps(cf,:),'linewidth',1.6);
            linehand = [linehand,hl];
        end
        lgd = legend(linehand,FreqStrs,'location','Northeast','FontSize',6,'autoupdate','off');
        legend('boxoff');
        yscales = get(gca,'ylim');
        line([StartFTime StartFTime],yscales,'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
        patch([StartFTime StartFTime StartFTime+0.3 StartFTime+0.3],[yscales(1) yscales(2) yscales(2) yscales(1)],1,...
            'FaceColor','g','EdgeColor','none','FaceAlpha',0.4);
        xlabel('Time (s)');
        ylabel('\DeltaF/F_0 (%)');
        % set(gca,'xlim',[0 4.5])

        hTrf = figure('position',[2500 100 450 380]);
        hold on
        hl1 = plot(PlotTime,MeanTrTypeTrace(1,:),'Color',[0.1 0.1 0.9],'linewidth',1.8);
        hl2 = plot(PlotTime,MeanTrTypeTrace(2,:),'Color',[0.9 0.1 0.1],'linewidth',1.8);
        legend([hl1,hl2],{'Low','High'},'location','Northeast','FontSize',6,'autoupdate','off');
        legend('boxoff');
        yscales = get(gca,'ylim');
        line([StartFTime StartFTime],yscales,'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
        patch([StartFTime StartFTime StartFTime+0.3 StartFTime+0.3],[yscales(1) yscales(2) yscales(2) yscales(1)],1,...
            'FaceColor','g','EdgeColor','none','FaceAlpha',0.4);
        xlabel('Time (s)');
        ylabel('\DeltaF/F_0 (%)');


        %
        saveas(hf,sprintf('ROI%d mean trace plot save',cROI));
        saveas(hf,sprintf('ROI%d mean trace plot save',cROI),'png');

        saveas(hTrf,sprintf('ROI%d TrType mean trace plot save',cROI));
        saveas(hTrf,sprintf('ROI%d TrType mean trace plot save',cROI),'png');

        close(hTrf);
        close(hf);
    end
    
    tline = fgetl(fid);
end