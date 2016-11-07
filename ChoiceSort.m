function ChoiceSort(AlignData,SortingF,TrialTypes,TrialOutcomes,FrameRate,varargin)
% Data should be aligned to choice time, reported by the first lick after
% stim onset as choice time;
% Trialtypes can be either a two elements vector or a nfreq elements vector
% which containts the frequency for each trial, which corresponded to
% normal two-tone 2AFC session or a random puretone session
isTimeScaleGiven = 0;
if ~isempty(varargin)
    TimeScale = varargin{1};
    isTimeScaleGiven = 1;
    if length(TimeScale) == 1
        FrameScale = sort([SortingF SortingF+round(TimeScale*FrameRate)]);
    elseif length(TimeScale) == 2
        FrameScale = sort([SortingF+round(TimeScale(1)*FrameRate) SortingF+round(TimeScale(2)*FrameRate)]);
    end
    if FrameScale(1) >= size(AlignData,3)
        fprintf('Error TimeScale input, Please check your input, quit current function.\n');
        return;
    elseif FrameScale(2) > size(AlignData,3)
        FrameScale(2) = size(AlignData,3);
    end
end

CorrTrialInds = TrialOutcomes == 1;
CorrDatas = AlignData(CorrTrialInds,:,:);
CorrTrialTypes = TrialTypes(CorrTrialInds);

[CorrTrials,nROIs,nFrames] = size(CorrDatas);
nTrialType = unique(CorrTrialTypes);
NumTrialType = length(nTrialType);

if nTrialType == 2
    fprintf('Considering current session as a normal two-tone 2AFC session.\n');
elseif nTrialType >= 6
    fprintf('Considering current session as a random tone 2AFC session.\n');
end
TrialTStr = {'Left','Right'};

if ~isdir('./Response_sort_plot/')
    mkdir('./Response_sort_plot/');
end
cd('./Response_sort_plot/');

for nROI = 1 : nROIs
    cROIdata = squeeze(CorrDatas(:,nROI,:));
    clims(1) = max([0 min(cROIdata(:))]);
    clims(2) = min([max(cROIdata(:)),300]);
    
    SubInds = NumTrialType / 2;
    if NumTrialType == 2
        hROI = figure('position',[360,120,1100,920],'Paperpositionmode','auto');
    elseif NumTrialType >= 6
        hROI = figure('position',[130,110,1600,920],'Paperpositionmode','auto');
    end
    for cfreq = 1 : NumTrialType
        cFreInds = CorrTrialTypes == nTrialType(cfreq);
        cSubData = cROIdata(cFreInds,:);
        if ~isTimeScaleGiven
            TrialRespInds = sum(cSubData(:,SortingF:end),2);
        else
            TrialRespInds = sum(cSubData(:,FrameScale(1):FrameScale(2)),2);
        end
        [~,SortInds] = sort(TrialRespInds,'descend');
        
        ax = subplot(2,SubInds,cfreq);
        imagesc(cSubData(SortInds,:),clims);
        line([SortingF SortingF],[0.5,size(cSubData,1)+0.5],'Color',[.8 .8 .8],'LineWidth',1.8);
        Fxtick = 0:FrameRate:size(cSubData,2);
        fxtickLabel = Fxtick/FrameRate;
        set(gca,'xtick',Fxtick,'xticklabel',fxtickLabel);
        xlabel('Time (s)');
        ylabel('# Trials');
        if NumTrialType == 2
            title([TrialTStr{cfreq},' Trials']);
        else
            title(sprintf('%d Hz',nTrialType(cfreq)));
        end
        set(gca,'FontSize',18);
    end
    axPos = get(ax,'position');
    hbar = colorbar;
    set(ax,'position',axPos);
    annotation('textbox',[0.47 0.685 0.3 0.3],'String',sprintf('ROI%03d',nROI),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',18);
    saveas(hROI,sprintf('ROI%d response sort plot',nROI));
    saveas(hROI,sprintf('ROI%d response sort plot',nROI),'png');
    close(hROI);
end
cd ..;
