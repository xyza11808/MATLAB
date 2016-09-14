function FreqRespCallFun(AlignDataAll,TrialFreq,TrialOutcome,TrialSelect,varargin)
% this function is just a call function of FreqRespDiffPlot, to easiest
% functioon structure
% the value of TrialSelect can be either 0,1,2, whereas 0 means all trials
% include, 1 means no miss trials, and 2 means all correct trials. the
% default value will be 1.

if isempty(TrialSelect)
    TrialSelect = 1;
end
if size(AlignDataAll,1) ~= length(TrialFreq)
    error('matrix dimension mismatch.');
end
if ~TrialSelect
    fprintf('All Trials included for analysis.\n');
    TrialInds = true(length(TrialFreq),1);
elseif TrialSelect == 1
    fprintf('Miss Trials excluded for analysis.\n');
    TrialInds = TrialOutcome ~= 2;
elseif TrialSelect > 1
    fprintf('Only correct Trials included for analysis.\n');
    TrialInds = TrialOutcome == 1;
else
    fprintf('Error TrialSelection type, quit current analysis.\n');
end
SelectData = AlignDataAll(TrialInds,:,:);
SelectTrialFreq = TrialFreq(TrialInds);
if length(varargin) < 3
    error('Not enough input');
end

if length(varargin) == 3
    [Timescale,FrameRate,OnsetFrame] = deal(varargin{:});
    FreqRespDiffPlot(SelectData,SelectTrialFreq,Timescale,FrameRate,OnsetFrame);
elseif length(varargin) ==4
    [~,FrameRate,OnsetFrame,TimeWinPlot] = deal(varargin{:});
    if TimeWinPlot
        % plotting a serial plot of frequency response accoriding to
        % different time window
        DefaultWin = 1; % seconds
        FRameLength = floor((size(SelectData,3)/FrameRate)/DefaultWin);
        TimeScaleCell = cell(1,FRameLength);
        TimeWinCenter = zeros(1,FRameLength); %center for each time window
        for nnn = 1 : FRameLength
            if nnn == 1
                TimeScaleCell(1) = {DefaultWin};
                TimeWinCenter(1) = DefaultWin/2;
            else
                TimeScaleCell(nnn) = {[nnn-1,nnn]*DefaultWin};
                TimeWinCenter(nnn) = (nnn - 0.5)*DefaultWin;  
            end
        end
        [TimeScaleData,AlignMeanTrace] = FreqRespDiffPlot(SelectData,SelectTrialFreq,TimeScaleCell,FrameRate,OnsetFrame,0);
%         RealCenterTime = TimeWinCenter + OnsetFrame/FrameRate;
        [TimeScaleNum,ROINum,~] = size(TimeScaleData);
        Frequencies = double(unique(SelectTrialFreq));
        FreqOcta = log2(Frequencies/min(Frequencies));
        DifferentColor = cool;
        ColorInds = floor(linspace(1,size(DifferentColor,1),TimeScaleNum));
        
        if ~isdir('Time_vary_FreqRespPlot')
            mkdir('Time_vary_FreqRespPlot');
        end
        cd('Time_vary_FreqRespPlot');
        % ROI plot for all time windows
        for nsROI = 1 : ROINum
            cROIWinData = squeeze(TimeScaleData(:,nsROI,:));
            hROI=figure('position',[400 250 1000 850],'paperpositionmode','auto');
            hold on;
            for nlines = 1 : TimeScaleNum
                plot(FreqOcta,cROIWinData(nlines,:),'LineWidth',1.4,'color',DifferentColor(ColorInds(nlines),:));
            end
            legend(cellstr(num2str(TimeWinCenter(:),'%.2f')));
            set(gca,'xtick',FreqOcta,'xticklabel',cellstr(num2str((Frequencies(:)/1000),'%.2f')),'FontSize',20);
            xlabel('Frequency (KHz)');
            ylabel('\DeltaF/F_0');
            title(sprintf('Time varied ROI%d response',nsROI));
            saveas(hROI,sprintf('ROI%d Freq response plot',nsROI));
            saveas(hROI,sprintf('ROI%d Freq response plot',nsROI),'png');
            close(hROI);
        end
        cd ..;
    end
end