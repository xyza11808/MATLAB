% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds);{'Others'}];

AnovaDataSumDatafile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas\AllArea_anovaEV_ANDAUC_datas.mat';
% AnovaDataSumDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas\AllArea_anovaEV_ANDAUC_datas.mat';
load(AnovaDataSumDatafile,'AllArea_anovaEVdatas','AllArea_BTAnova_freqwise');
StimOnsetBin = 149;
winGoesStep = 0.01;
BinLength = size(AllArea_anovaEVdatas{1,1,1},1);

%%
% cA = 1;
FreqwiseStr = {'NonRevF','RevF'};
FactorStrs = {'Choice','Stim'}; %,'BlockType'
NumAreas = length(BrainAreasStr);
AreaPeakFactor_peakDatasAll = cell(NumAreas,2);
AreaBT_AvgDatasAll = cell(NumAreas,2);
for cA = 1 : NumAreas
    % hf = figure('position',[100 100 1200 340]);
    % figure;
    % cf = 2;
    nFactors = size(AllArea_anovaEVdatas,3);
    % AllArea_BTAnova_freqwise

    for cf = 1 : 2 %nFactors
        cfRealData = AllArea_anovaEVdatas{cA,cf,1};
        cfThresData = AllArea_anovaEVdatas{cA,cf,2};
        if isempty(cfRealData)
            continue;
        end
    %     cfThresData = AllArea_anovaEVdatas{cA,cf,2};
    %     
    %     cA_AvgTrace = mean(cfRealData,2);
    %     cA_ThresAvg = mean(cfThresData,2);
    %     
    %     hf = figure('position',[100 100 380 260]);
    %     hold on
    %     plot(UnitCalWinTimes, cfRealData,'Color',[.7 .7 .7]);
    %     plot(UnitCalWinTimes, cA_AvgTrace,'k','linewidth',1.5);
    %     plot(UnitCalWinTimes, cA_ThresAvg,'c','linewidth',1,'linestyle','--');
    %     line([0 0],[0 0.3],'Color','m','linewidth',1,'linestyle','--');
    %     set(gca,'xlim',[-1.5 3.5])
    %     xlabel('Times');
    %     ylabel(FactorStrs{cf});
    %     title('MOs EV');
    % %     saveas(hf,sprintf('%s MOs EV plot save',FactorStrs{cf}));
    % %     saveas(hf,sprintf('%s MOs EV plot save',FactorStrs{cf}),'png');
    % %     [pks,locs,w,p] = findpeaks(cA_AvgTrace,'MinPeakDistance',50,'MinPeakProminence',cA_ThresAvg,'MinPeakHeight',0.01,...
    % %         'Annotate','extents','WidthReference','halfheight');

        %
        % close
        % cU = 121;
        TotalUnitNum = size(cfRealData,2);
        PeakFinds = cell(TotalUnitNum, 4);
        IsUnitNoPeakFind = false(TotalUnitNum, 1);
        for cU = 1 :TotalUnitNum 
            cU_Trace = cfRealData(:,cU);
            % figure;
            sgf = sgolayfilt(cU_Trace,3,41);
            HeightThres = min(max(sgf)/3,0.02);
            [NegPeak, NegLocs,~,~,widths] = Findpeak_WWds(sgf,'MinPeakDistance',20,'MinPeakProminence',0.01,'MinPeakHeight',HeightThres,...
                    'Annotate','extents','WidthReference','halfheight');
            PeakNumIndex = 1:length(NegPeak);
            if length(NegPeak) > 1
               for cP = 1 : length(NegPeak)-1
                   if (widths(cP+1,1)-widths(cP,2)) < 5 % within 5 bins, corresponded to 50ms
                       PeakNumIndex(cP+1) = PeakNumIndex(cP);
                   end
               end
               PeakIndexTypes = unique(PeakNumIndex);
               if length(PeakIndexTypes) ~= length(NegPeak)
                  NewPeaks = zeros(length(PeakIndexTypes),1);
                  NewLocs = zeros(length(PeakIndexTypes),1);
                  NewWidths = zeros(length(PeakIndexTypes),2);
                  for cNP = 1 : length(PeakIndexTypes)
                      cNPInds =  PeakNumIndex == PeakIndexTypes(cNP);
                      if sum(cNPInds) > 1 % multiple peaks need to be merged
                          [Peaks, pealLocInds] = max(NegPeak(cNPInds));
                          AllPeakLocs = NegLocs(cNPInds);
                          NewPeaks(cNP) = Peaks;
                          NewLocs(cNP) = AllPeakLocs(pealLocInds);
                          AllPeakWidths = widths(cNPInds,:);
                          NewWidths(cNP,:) = [min(AllPeakWidths(:,1)), max(AllPeakWidths(:,2))];
                      else
                          NewPeaks(cNP) = NegPeak(cNPInds);
                          NewLocs(cNP) = NegLocs(cNPInds);
                          NewWidths(cNP,:) = widths(cNPInds,:);
                      end
                  end
                  PeakFinds(cU,:) = {NewPeaks, NewLocs,NewWidths,NewWidths(:,2) - NewWidths(:,1)};
               else
                  PeakFinds(cU,:) = {NegPeak, NegLocs, widths, widths(:,2) - widths(:,1)}; 
               end
            elseif length(NegPeak) == 1
                PeakFinds(cU,:) = {NegPeak, NegLocs, widths, widths(:,2) - widths(:,1)};
            else
                IsUnitNoPeakFind(cU) = true;
            end
        end
        PeakFinds(IsUnitNoPeakFind,:) = [];
        
        AreaPeakFactor_peakDatasAll(cA,cf) = {PeakFinds};
    end
    
    % calculate the trial-wise EVs
    cA_BT_freqwiseData = squeeze(AllArea_BTAnova_freqwise(cA,:,:));
    if ~isempty(cA_BT_freqwiseData{1})
        cA_BT_BaseAvgs = cellfun(@(x) (mean(x(1:StimOnsetBin,:)))',cA_BT_freqwiseData,'un',0);
        
        cA_BT_AfterRespAvgs = cellfun(@(x) (mean(x((1+StimOnsetBin):(StimOnsetBin+150),:)))',cA_BT_freqwiseData,'un',0);
        
        cA_BTAvg_Mtx = {[cA_BT_BaseAvgs{1,1},cA_BT_BaseAvgs{1,2},cA_BT_AfterRespAvgs{1,1},cA_BT_AfterRespAvgs{1,2}],... % NonRevF 
            [cA_BT_BaseAvgs{2,1},cA_BT_BaseAvgs{2,2},cA_BT_AfterRespAvgs{2,1},cA_BT_AfterRespAvgs{2,2}]}; % RevF
        
        AreaBT_AvgDatasAll(cA,:) = cA_BTAvg_Mtx;
    end
end
% % %%
% % PeakLocsAll = cat(1,PeakFinds{:,2});
% % [N, Edges] = histcounts(PeakLocsAll,1:size(cfRealData,1));
% % figure;plot(Edges(1:end-1),smooth(N,5))
% % 
% % PeakWidth = cat(1,PeakFinds{:,4});
% % figure;
% % hist(PeakWidth) 
% % 
% % %% % %
% % figure
% % hold on
% % plot(sgf,'k');
% % scatter(NegLocs,NegPeak,'bo');
% % plot(cU_Trace,'r');
% % yscales = get(gca,'ylim');
% % for cP = 1 : length(NegPeak)
% %    line([widths(cP,1),widths(cP,1)],yscales,'Color','g'); 
% %    line([widths(cP,2),widths(cP,2)],yscales,'Color','y'); 
% %    
% % end
% % % plot(sgf,'r')
% % % % % [NegPeak, NegLocs, widths] = Findpeak_WWds(-sgf,'MinPeakDistance',20,...
% % % % %         'Annotate','extents','WidthReference','halfheight');


%%
AnovaDataSumDatafile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas';
AnovasumPlotPath = fullfile(AnovaDataSumDatafile,'AnovaPeak_sumPlot');
if ~isfolder(AnovasumPlotPath)
    mkdir(AnovasumPlotPath);
end

for cA = 1 : NumAreas
    cA_ChoiceData = AreaPeakFactor_peakDatasAll{cA,1};
    cA_StimData = AreaPeakFactor_peakDatasAll{cA,2};
    NonRevData = AreaBT_AvgDatasAll{cA,1};
    if (isempty(cA_ChoiceData) || size(cA_ChoiceData,1) < 10) && ...
            (isempty(cA_StimData) || size(cA_StimData,1) < 10) && ...
            (isempty(NonRevData) || size(NonRevData,1) < 10)
        continue;
    end
    hf = figure('position',[100 100 1080 520]);
    
    cA_ChoicePeakAmp = cat(1,cA_ChoiceData{:,1});
    cA_ChoiceFirstPeakBin = cellfun(@(x) x(1),cA_ChoiceData(:,2));
    cA_ChoiceFirstPeakTime = (cA_ChoiceFirstPeakBin - StimOnsetBin)*winGoesStep;
    ChoiceANDEventNum = [size(cA_ChoiceData,1),numel(cA_ChoicePeakAmp)];
        
     if ~isempty(cA_ChoiceData) && size(cA_ChoiceData,1) >= 10   
        cA_ChoicePeakWidthBin = cat(1,cA_ChoiceData{:,4});
        cA_ChoicePeakWidth = cA_ChoicePeakWidthBin * winGoesStep;
        
        ax1 = subplot(2,4,1); % forst row, choice datas
        [label1Count, label1Edge] = histcounts(cA_ChoicePeakAmp,50);
        label1centers = (label1Edge(1:end-1)+label1Edge(2:end))/2;
        Counts = max(0,sgolayfilt(label1Count,5,9));
        plot(label1centers, Counts, 'k','linewidth',1.4);
        yscales = get(ax1,'ylim');
        line([median(cA_ChoicePeakAmp) median(cA_ChoicePeakAmp)],...
            yscales,'Color','m','linestyle','--','linewidth',1.2);
        line([mean(cA_ChoicePeakAmp) mean(cA_ChoicePeakAmp)],...
            yscales,'Color','g','linestyle','--','linewidth',1.2);
        text(median(cA_ChoicePeakAmp), yscales(2)*0.9,...
            sprintf('PeakAmp mean = %.4f',median(cA_ChoicePeakAmp)),'Color','m');
        set(ax1,'ylim',[max(-2,yscales(1)),yscales(2)],'box','off');
        xlabel('PeakAmps (EV)');
        ylabel('PeakCounts');
        title('Choice EV peakAmps');
        
        ax2 = subplot(2,4,2); % forst row, choice datas
        [label1Count, label1Edge] = histcounts(cA_ChoiceFirstPeakTime,50);
        label1centers = (label1Edge(1:end-1)+label1Edge(2:end))/2;
        Counts = max(0,sgolayfilt(label1Count,5,9));
        plot(label1centers, Counts, 'k','linewidth',1.4);
        yscales = get(ax2,'ylim');
        line([median(cA_ChoiceFirstPeakTime) median(cA_ChoiceFirstPeakTime)],...
            yscales,'Color','m','linestyle','--','linewidth',1.2);
        line([mean(cA_ChoiceFirstPeakTime) mean(cA_ChoiceFirstPeakTime)],...
            yscales,'Color','g','linestyle','--','linewidth',1.2);
        text(median(cA_ChoiceFirstPeakTime), yscales(2)*0.9,...
            sprintf('PeakTimes = %.4f s',median(cA_ChoiceFirstPeakTime)),'Color','m');
        set(ax2,'ylim',[max(-2,yscales(1)),yscales(2)],'box','off');
        xlabel('PeakTime (s)');
%         ylabel('PeakCounts');
        title('Choice EVpeak Time');
        
        ax3 = subplot(2,4,3); % forst row, choice datas
        [label1Count, label1Edge] = histcounts(cA_ChoicePeakWidth,50);
        label1centers = (label1Edge(1:end-1)+label1Edge(2:end))/2;
        Counts = max(0,sgolayfilt(label1Count,5,9));
        plot(label1centers, Counts, 'k','linewidth',1.4);
        yscales = get(ax3,'ylim');
        line([median(cA_ChoicePeakWidth) median(cA_ChoicePeakWidth)],...
            yscales,'Color','m','linestyle','--','linewidth',1.2);
        line([mean(cA_ChoicePeakWidth) mean(cA_ChoicePeakWidth)],...
            yscales,'Color','g','linestyle','--','linewidth',1.2);
        text(median(cA_ChoicePeakWidth), yscales(2)*0.9,...
            sprintf('Peak width = %.4f s',median(cA_ChoicePeakWidth)),'Color','m');
        set(ax3,'ylim',[max(-2,yscales(1)),yscales(2)],'box','off');
        xlabel('PeakWidth (s)');
%         ylabel('PeakCounts');
        title('Choice EVpeak width');
        
    end
    
    % stim EV plots
    
    cA_StimPeakAmp = cat(1,cA_StimData{:,1});
    cA_StimFirstPeakBin = cellfun(@(x) x(1),cA_StimData(:,2));
    cA_StimFirstPeakTime = (cA_StimFirstPeakBin - StimOnsetBin)*winGoesStep;
    StimANDEventNum = [size(cA_StimData,1),numel(cA_StimPeakAmp)];
    
    if ~isempty(cA_StimData) && size(cA_StimData,1) >= 10
        cA_StimPeakWidthBin = cat(1,cA_StimData{:,4});
        cA_StimPeakWidth = cA_StimPeakWidthBin * winGoesStep;
        
%         hf = figure('position',[100 100 980 520]);
        ax4 = subplot(2,4,5); % forst row, Stim datas
        [label1Count, label1Edge] = histcounts(cA_StimPeakAmp,50);
        label1centers = (label1Edge(1:end-1)+label1Edge(2:end))/2;
        Counts = max(0,sgolayfilt(label1Count,5,9));
        plot(label1centers, Counts, 'k','linewidth',1.4);
        yscales = get(ax4,'ylim');
        line([median(cA_StimPeakAmp) median(cA_StimPeakAmp)],...
            yscales,'Color','m','linestyle','--','linewidth',1.2);
        line([mean(cA_StimPeakAmp) mean(cA_StimPeakAmp)],...
            yscales,'Color','g','linestyle','--','linewidth',1.2);
        text(median(cA_StimPeakAmp), yscales(2)*0.9,...
            sprintf('PeakAmp mean = %.4f',median(cA_StimPeakAmp)),'Color','m');
        set(ax4,'ylim',[max(-2,yscales(1)),yscales(2)],'box','off');
        xlabel('PeakAmps (EV)');
        ylabel('PeakCounts');
        title('Stim EV peakAmps');
        
        ax5 = subplot(2,4,6); % forst row, Stim datas
        [label1Count, label1Edge] = histcounts(cA_StimFirstPeakTime,50);
        label1centers = (label1Edge(1:end-1)+label1Edge(2:end))/2;
        Counts = max(0,sgolayfilt(label1Count,5,9));
        plot(label1centers, Counts, 'k','linewidth',1.4);
        yscales = get(ax5,'ylim');
        line([median(cA_StimFirstPeakTime) median(cA_StimFirstPeakTime)],...
            yscales,'Color','m','linestyle','--','linewidth',1.2);
        line([mean(cA_StimFirstPeakTime) mean(cA_StimFirstPeakTime)],...
            yscales,'Color','g','linestyle','--','linewidth',1.2);
        text(median(cA_StimFirstPeakTime), yscales(2)*0.9,...
            sprintf('PeakTimes = %.4f s',median(cA_StimFirstPeakTime)),'Color','m');
        set(ax5,'ylim',[max(-2,yscales(1)),yscales(2)],'box','off');
        xlabel('PeakTime (s)');
%         ylabel('PeakCounts');
        title('Stim EVpeak Time');
        
        ax6 = subplot(2,4,7); % forst row, Stim datas
        [label1Count, label1Edge] = histcounts(cA_StimPeakWidth,50);
        label1centers = (label1Edge(1:end-1)+label1Edge(2:end))/2;
        Counts = max(0,sgolayfilt(label1Count,5,9));
        plot(label1centers, Counts, 'k','linewidth',1.4);
        yscales = get(ax6,'ylim');
        line([median(cA_StimPeakWidth) median(cA_StimPeakWidth)],...
            yscales,'Color','m','linestyle','--','linewidth',1.2);
        line([mean(cA_StimPeakWidth) mean(cA_StimPeakWidth)],...
            yscales,'Color','g','linestyle','--','linewidth',1.2);
        text(median(cA_StimPeakWidth), yscales(2)*0.9,...
            sprintf('Peak width = %.4f s',median(cA_StimPeakWidth)),'Color','m');
        set(ax6,'ylim',[max(-2,yscales(1)),yscales(2)],'box','off');
        xlabel('PeakWidth (s)');
%         ylabel('PeakCounts');
        title('Stim EVpeak width');
        
    end
    
    % NonRef Trials BT
    BTUnitNums = size(NonRevData,1);
    if ~isempty(NonRevData) && size(NonRevData,1) >= 10
        ax7 = subplot(2,4,4);
        hold on
        SigUnitInds = NonRevData(:,1) > NonRevData(:,2) | ...
            NonRevData(:,3) > NonRevData(:,4);
        [~, NonRevP] = ttest(NonRevData(:,1),NonRevData(:,3));
        
        scatter(NonRevData(~SigUnitInds,1),NonRevData(~SigUnitInds,3),20,'o','MarkerEdgeColor',[.7 .7 .7],'linewidth',1.2);
        scatter(NonRevData(SigUnitInds,1),NonRevData(SigUnitInds,3),20,'k.');
        xscales = get(gca,'xlim');
        yscales = get(gca,'ylim');
        CommonScales = [-0.01, max(xscales(2),yscales(2))];
        line(CommonScales,CommonScales, 'Color',[1 0.6 0.2],'linewidth',1.2,'linestyle','--');
        text(CommonScales(2)*0.7,CommonScales(1)+0.04,{sprintf('x:%.4f',mean(NonRevData(:,1)));...
            sprintf('y:%.4f',mean(NonRevData(:,3)))});
        set(ax7,'xlim',CommonScales,'ylim',CommonScales,'box','off');
        xlabel('Baseline EV');
        ylabel('AfterResp(1.5s) EV');
        title(sprintf('NonRevTr EV (p = %.2e)',NonRevP));
        

        % Ref Trials BT
        ax8 = subplot(2,4,8);
        hold on
        RevData = AreaBT_AvgDatasAll{cA,2};
        SigUnitInds = RevData(:,1) > RevData(:,2) | ...
            RevData(:,3) > RevData(:,4);
        [~, RevP] = ttest(RevData(:,1),RevData(:,3));
        scatter(RevData(~SigUnitInds,1),RevData(~SigUnitInds,3),20,'o','MarkerEdgeColor',[.7 .7 .7],'linewidth',1.2);
        scatter(RevData(SigUnitInds,1),RevData(SigUnitInds,3),20,'k.');
        xscales = get(gca,'xlim');
        yscales = get(gca,'ylim');
        CommonScales = [-0.01, max(xscales(2),yscales(2))];
        line(CommonScales,CommonScales, 'Color',[1 0.6 0.2],'linewidth',1.2,'linestyle','--');
        text(CommonScales(2)*0.7,CommonScales(1)+0.04,{sprintf('x:%.4f',mean(RevData(:,1)));...
            sprintf('y:%.4f',mean(RevData(:,3)))});
        set(ax8,'xlim',CommonScales,'ylim',CommonScales,'box','off');
        xlabel('Baseline EV');
        ylabel('AfterResp(1.5s) EV');
        title(sprintf('RevTr EV (p = %.2e)',RevP));

        annotation('textbox',[0.01 0.02 0.05 0.15],'String',{sprintf('Area %s',BrainAreasStr{cA});...
            sprintf('Unit/Events:%d/%d',ChoiceANDEventNum(1),ChoiceANDEventNum(2));...
            sprintf('Unit/Events:%d/%d',StimANDEventNum(1),StimANDEventNum(2));...
            sprintf('Unit: %d',BTUnitNums)},'FitBoxToText','on','Color','b','FontSize',8);
    end
    
    savePath = fullfile(AnovasumPlotPath,sprintf('Area %s anova peak plot save',BrainAreasStr{cA}));
    saveas(hf,savePath);
    print(hf,savePath,'-dpng','-r350');
    print(hf,savePath,'-dpdf','-bestfit');
    close(hf);
    
end


%% save anova peak analysis summary data
saveFilePath = fullfile(AnovasumPlotPath,'AnovaPeakSumData.mat');
save(saveFilePath,'AreaPeakFactor_peakDatasAll','AreaBT_AvgDatasAll','StimOnsetBin',...
    'winGoesStep','BrainAreasStr','-v7.3');






