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
                  if any(NewLocs < StimOnsetBin)
                      UsedPeakInds = NewLocs >= StimOnsetBin;
                      PeakFinds(cU,:) = {NewPeaks(UsedPeakInds), NewLocs(UsedPeakInds),...
                          NewWidths(UsedPeakInds,:),NewWidths(UsedPeakInds,2) - NewWidths(UsedPeakInds,1)};
                  else
                      PeakFinds(cU,:) = {NewPeaks, NewLocs,NewWidths,NewWidths(:,2) - NewWidths(:,1)};
                  end
               else
                   if any(NegLocs < StimOnsetBin)
                       UsedPeakInds = NegLocs >= StimOnsetBin;
                       PeakFinds(cU,:) = {NegPeak(UsedPeakInds), NegLocs(UsedPeakInds),...
                          widths(UsedPeakInds,:),widths(UsedPeakInds,2) - widths(UsedPeakInds,1)};
                   else
                        PeakFinds(cU,:) = {NegPeak, NegLocs, widths, widths(:,2) - widths(:,1)}; 
                   end
               end
            elseif length(NegPeak) == 1
                if NegLocs < StimOnsetBin
                    IsUnitNoPeakFind(cU) = true;
                else
                    PeakFinds(cU,:) = {NegPeak, NegLocs, widths, widths(:,2) - widths(:,1)};
                end
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
% AnovaDataSumDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas';
AnovasumPlotPath = fullfile(AnovaDataSumDatafile,'AnovaPeak_sumPlot');
if ~isfolder(AnovasumPlotPath)
    mkdir(AnovasumPlotPath);
end
UnitNumThres = 5;
ValueAllAreaDatas = nan(NumAreas,6,4); % the last dimension is median and mean
% ValueAllAreaCIs = nan(NumAreas,6,2); % CIs 
BTValuesIsEnough = false(NumAreas,1);
for cA = 1 : NumAreas
    cA_ChoiceData = AreaPeakFactor_peakDatasAll{cA,1};
    cA_StimData = AreaPeakFactor_peakDatasAll{cA,2};
    NonRevData = AreaBT_AvgDatasAll{cA,1};
    if (isempty(cA_ChoiceData) || size(cA_ChoiceData,1) < UnitNumThres) && ...
            (isempty(cA_StimData) || size(cA_StimData,1) < UnitNumThres) && ...
            (isempty(NonRevData) || size(NonRevData,1) < UnitNumThres)
        continue;
    end
    hf = figure('position',[100 100 1080 520]);
    if ~isempty(cA_ChoiceData)
        cA_ChoicePeakAmp = cat(1,cA_ChoiceData{:,1});
        cA_ChoiceFirstPeakBin = cellfun(@(x) x(1),cA_ChoiceData(:,2));
        cA_ChoiceFirstPeakTime = (cA_ChoiceFirstPeakBin - StimOnsetBin)*winGoesStep;
        ChoiceANDEventNum = [size(cA_ChoiceData,1),numel(cA_ChoicePeakAmp)];
    else
        ChoiceANDEventNum = [NaN, NaN];
    end
     if ~isempty(cA_ChoiceData) && size(cA_ChoiceData,1) >= UnitNumThres
        cA_ChoicePeakWidthBin = cat(1,cA_ChoiceData{:,4});
        cA_ChoicePeakWidth = cA_ChoicePeakWidthBin * winGoesStep;
        
        ValueAllAreaDatas(cA,1,:) = [median(cA_ChoicePeakAmp), mean(cA_ChoicePeakAmp),prctile(cA_ChoicePeakAmp,[10 90])];
%         ValueAllAreaCIs(cA,1,:) = [prctile(cA_ChoicePeakAmp,[10 90])];
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
        
        ValueAllAreaDatas(cA,2,:) = [median(cA_ChoiceFirstPeakTime),mean(cA_ChoiceFirstPeakTime),prctile(cA_ChoiceFirstPeakTime,[10 90])];
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
        
        ValueAllAreaDatas(cA,3,:) = [median(cA_ChoicePeakWidth),mean(cA_ChoicePeakWidth),prctile(cA_ChoicePeakWidth,[10 90])];
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
    if ~isempty(cA_StimData)
        cA_StimPeakAmp = cat(1,cA_StimData{:,1});
        cA_StimFirstPeakBin = cellfun(@(x) x(1),cA_StimData(:,2));
        cA_StimFirstPeakTime = (cA_StimFirstPeakBin - StimOnsetBin)*winGoesStep;
        StimANDEventNum = [size(cA_StimData,1),numel(cA_StimPeakAmp)];
    else
        StimANDEventNum = [NaN, NaN];
    end
    if ~isempty(cA_StimData) && size(cA_StimData,1) >= UnitNumThres
        cA_StimPeakWidthBin = cat(1,cA_StimData{:,4});
        cA_StimPeakWidth = cA_StimPeakWidthBin * winGoesStep;
        
        ValueAllAreaDatas(cA,4,:) = [median(cA_StimPeakAmp),mean(cA_StimPeakAmp),prctile(cA_StimPeakAmp,[10 90])];
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
        
        ValueAllAreaDatas(cA,5,:) = [median(cA_StimFirstPeakTime),mean(cA_StimFirstPeakTime),prctile(cA_StimFirstPeakTime,[10 90])];
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
        
        ValueAllAreaDatas(cA,6,:) = [median(cA_StimPeakWidth),mean(cA_StimPeakWidth),prctile(cA_StimPeakWidth,[10 90])];
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
    if ~isempty(NonRevData) && size(NonRevData,1) >= UnitNumThres
        
        BTValuesIsEnough(cA) = true;
        
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
        text(0.02,CommonScales(2)*0.9,{'SigUnit/UnitNum';sprintf('%d/%d',sum(SigUnitInds),numel(SigUnitInds))},...
            'Color',[0 0.4 0]);
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
        text(0.02,CommonScales(2)*0.9,{'SigUnit/UnitNum';sprintf('%d/%d',sum(SigUnitInds),numel(SigUnitInds))},...
            'Color',[0 0.4 0]);
        set(ax8,'xlim',CommonScales,'ylim',CommonScales,'box','off');
        xlabel('Baseline EV');
        ylabel('AfterResp(1.5s) EV');
        title(sprintf('RevTr EV (p = %.2e)',RevP));
        
    end
    annotation('textbox',[0.01 0.02 0.05 0.15],'String',{sprintf('Area %s',BrainAreasStr{cA});...
            sprintf('Unit/Events:%d/%d',ChoiceANDEventNum(1),ChoiceANDEventNum(2));...
            sprintf('Unit/Events:%d/%d',StimANDEventNum(1),StimANDEventNum(2));...
            sprintf('Unit: %d',BTUnitNums)},'FitBoxToText','on','Color','b','FontSize',8);
    
    savePath = fullfile(AnovasumPlotPath,sprintf('Area %s anova peak plot save',BrainAreasStr{cA}));
    saveas(hf,savePath);
    print(hf,savePath,'-dpng','-r350');
    print(hf,savePath,'-dpdf','-bestfit');
    close(hf);
    
end


%% save anova peak analysis summary data
saveFilePath = fullfile(AnovasumPlotPath,'AnovaPeakSumData.mat');
save(saveFilePath,'AreaPeakFactor_peakDatasAll','AreaBT_AvgDatasAll','StimOnsetBin',...
    'winGoesStep','BrainAreasStr','BTValuesIsEnough','ValueAllAreaDatas','-v7.3');

%% add allen scores

% AllenHScoreFullPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_CreConf.xlsx';
AllenHScoreFullPath = 'K:\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_CreConf.xlsx';
AllenRegionStrsCell = readcell(AllenHScoreFullPath,'Range','A:A',...
        'Sheet','hierarchy_all_regions');
AllenRegionStrsUsed = AllenRegionStrsCell(2:end);
AllenRegionStrsModi = strrep(AllenRegionStrsUsed,'-','');

RegionScoresCell = readcell(AllenHScoreFullPath,'Range','H:H',...
        'Sheet','hierarchy_all_regions');
% RegionScoresCell = readcell(AllenHScoreFullPath,'Range','F:F',...
%     'Sheet','hierarchy_all_regions');
IsCellMissing = cellfun(@(x) any(ismissing(x)),RegionScoresCell);
RegionScoresCell(IsCellMissing) = {NaN};
RegionScoresUsed = cell2mat(RegionScoresCell(2:end));

NanInds = isnan(RegionScoresUsed);
if any(NanInds)
    RegionScoresUsed(NanInds) = [];
    AllenRegionStrsModi(NanInds) = [];
end

%% plot the area values

% plot Stim peak times
AreaStimPeakTime = squeeze(ValueAllAreaDatas(:,5,:));
AreaStimPeakValue = squeeze(ValueAllAreaDatas(:,4,:));
AreaStimPeakWidth = squeeze(ValueAllAreaDatas(:,6,:));

StimValidAreaInds = ~isnan(AreaStimPeakTime(:,1));
StimValidPeakTime = AreaStimPeakTime(StimValidAreaInds,:);
StimValidAreaStr = BrainAreasStr(StimValidAreaInds);
StimValidPeakValue = AreaStimPeakValue(StimValidAreaInds,:);
StimValidPeakWidth = AreaStimPeakWidth(StimValidAreaInds,:);

[StimPeakTimeSort, StimPTsortInds] = sort(StimValidPeakTime(:,1));
StimAreaInds = (1:numel(StimPeakTimeSort))';
StimSortPeakValue = StimValidPeakValue(StimPTsortInds,1);
StimPV2Size = (StimSortPeakValue - mean(StimSortPeakValue)) * 2000+50;

SortStimAreaStr = StimValidAreaStr(StimPTsortInds);
ExistedAreaAHSdatas = nan(numel(SortStimAreaStr),1);
for cAs = 1 : numel(SortStimAreaStr)
    TF = matches(AllenRegionStrsModi,StimValidAreaStr(cAs),'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
            continue;
        end
        ExistedAreaAHSdatas(cAs,1) = RegionScoresUsed(AllenRegionInds);
    end
    
end
StimPTsortAHSData = ExistedAreaAHSdatas(StimPTsortInds);
AHSValidScoresIndex = find(~isnan(StimPTsortAHSData));
AHSValidScores = StimPTsortAHSData(AHSValidScoresIndex);
AHSScoreColors = linearValue2colorFun(AHSValidScores);
[~,ColorSortInds] = sort(AHSValidScores);

h2f = figure('position',[100 100 1240 810]);
ax11 = subplot(141);
hold on
errorbar(StimPeakTimeSort,StimAreaInds,0.5*(StimPeakTimeSort - StimValidPeakTime(StimPTsortInds,3)),...
    0.5*(StimValidPeakTime(:,4)-StimPeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(StimPeakTimeSort,StimAreaInds,StimPV2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);

scatter(ax11,StimPeakTimeSort(AHSValidScoresIndex),StimAreaInds(AHSValidScoresIndex),...
    StimPV2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
colormap(AHSScoreColors(ColorSortInds,:));
hbar = colorbar;
oldBarPos = get(hbar,'position');
set(hbar,'position',[0.05 0.1 oldBarPos(3) oldBarPos(4)*0.2]);
set(get(hbar,'title'),'String','AllenScores');

yscales = get(ax11,'ylim');
line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('StimPeakTime (s)');
set(ax11,'ytick',StimAreaInds,'yticklabel',SortStimAreaStr,'ylim',[0 numel(StimPeakTimeSort)+1]);
title('StimPeakTime sort');

% stim peak width sort plot
[StimPeakWidthSort, StimPWsortInds] = sort(StimValidPeakWidth(:,1));
StimPWsortAHSData = ExistedAreaAHSdatas(StimPWsortInds);
AHSValidScoresIndex = find(~isnan(StimPWsortAHSData));
AHSValidScores = StimPWsortAHSData(AHSValidScoresIndex);
AHSScoreColors = linearValue2colorFun(AHSValidScores);
[~,ColorSortInds2] = sort(AHSValidScores);

ax12 = subplot(142);
hold on
errorbar(StimPeakWidthSort,StimAreaInds,0.5*(StimPeakWidthSort - StimValidPeakWidth(StimPWsortInds,3)),...
    0.5*(StimValidPeakWidth(:,4)-StimPeakWidthSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(StimPeakWidthSort,StimAreaInds,StimPV2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);
scatter(ax12,StimPeakWidthSort(AHSValidScoresIndex),StimAreaInds(AHSValidScoresIndex),...
    StimPV2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');

yscales = get(ax12,'ylim');
% line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('StimPeakWidth (s)');
set(ax12,'ytick',StimAreaInds,'yticklabel',StimValidAreaStr(StimPWsortInds),'ylim',[0 numel(StimPeakWidthSort)+1]);
title('StimPeakWidth sort');
%
% ####################################################
% choice peak time
AreaChoicePeakTime = squeeze(ValueAllAreaDatas(:,2,:));
AreaChoicePeakValue = squeeze(ValueAllAreaDatas(:,1,:));
AreaChoicePeakWidth = squeeze(ValueAllAreaDatas(:,3,:));

ChoiceValidAreaInds = ~isnan(AreaChoicePeakTime(:,1));
ChoiceValidPeakTime = AreaChoicePeakTime(ChoiceValidAreaInds,:);
ChoiceValidAreaStr = BrainAreasStr(ChoiceValidAreaInds);
ChoiceValidPeakValue = AreaChoicePeakValue(ChoiceValidAreaInds,:);
ChoiceValidPeakWidth = AreaChoicePeakWidth(ChoiceValidAreaInds,:);

[ChoicePeakTimeSort, ChoicePTsortInds] = sort(ChoiceValidPeakTime(:,1));
ChoiceAreaInds = (1:numel(ChoicePeakTimeSort))';
ChoiceSortPeakValue = ChoiceValidPeakValue(ChoicePTsortInds,1);
ChoicePV2Size = (ChoiceSortPeakValue - mean(ChoiceSortPeakValue)) * 2000+50;

SortChoiceAreaStr = ChoiceValidAreaStr(ChoicePTsortInds);
ExistedAreaAHSdatas = nan(numel(SortChoiceAreaStr),1);
for cAs = 1 : numel(SortChoiceAreaStr)
    TF = matches(AllenRegionStrsModi,ChoiceValidAreaStr(cAs),'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
            continue;
        end
        ExistedAreaAHSdatas(cAs,1) = RegionScoresUsed(AllenRegionInds);
    end
    
end
ChoicePTAHSdatas = ExistedAreaAHSdatas(ChoicePTsortInds);
AHSValidScoresIndex = find(~isnan(ChoicePTAHSdatas));
AHSValidScores = ChoicePTAHSdatas(AHSValidScoresIndex);
AHSScoreColors = linearValue2colorFun(AHSValidScores);
[~,ColorSortInds] = sort(AHSValidScores);

% h2f = figure('position',[100 100 1240 810]);
ax13 = subplot(143);
hold on
errorbar(ChoicePeakTimeSort,ChoiceAreaInds,0.5*(ChoicePeakTimeSort - ChoiceValidPeakTime(ChoicePTsortInds,3)),...
    0.5*(ChoiceValidPeakTime(:,4)-ChoicePeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(ChoicePeakTimeSort,ChoiceAreaInds,ChoicePV2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);

% yscales = get(ax13,'ylim');
% line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('ChoicePeakTime (s)');
set(ax13,'ytick',ChoiceAreaInds,'yticklabel',SortChoiceAreaStr,'ylim',[0 numel(ChoicePeakTimeSort)+1]);
title('ChoicePeakTime sort');

scatter(ax13,ChoicePeakTimeSort(AHSValidScoresIndex),ChoiceAreaInds(AHSValidScoresIndex),...
    ChoicePV2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
colormap(AHSScoreColors(ColorSortInds,:));
hbar2 = colorbar;
oldBarPos = get(hbar2,'position');
set(hbar2,'position',[0.94 0.1 oldBarPos(3) oldBarPos(4)*0.2]);
set(get(hbar2,'title'),'String','AllenScores');

% Choice peak width sort plot
[ChoicePeakWidthSort, ChoicePWsortInds] = sort(ChoiceValidPeakWidth(:,1));
ChoicePWAHSdatas = ExistedAreaAHSdatas(ChoicePWsortInds);
AHSValidScoresIndex = find(~isnan(ChoicePWAHSdatas));
AHSValidScores = ChoicePWAHSdatas(AHSValidScoresIndex);
AHSScoreColors = linearValue2colorFun(AHSValidScores);
[~,ColorSortInds] = sort(AHSValidScores);

ax14 = subplot(144);
hold on
errorbar(ChoicePeakWidthSort,ChoiceAreaInds,0.5*(ChoicePeakWidthSort - ChoiceValidPeakWidth(ChoicePWsortInds,3)),...
    0.5*(ChoiceValidPeakWidth(:,4)-ChoicePeakWidthSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(ChoicePeakWidthSort,ChoiceAreaInds,ChoicePV2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);
scatter(ax14,ChoicePeakWidthSort(AHSValidScoresIndex),ChoiceAreaInds(AHSValidScoresIndex),...
    ChoicePV2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
% yscales = get(ax14,'ylim');
% line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('ChoicePeakWidth (s)');
set(ax14,'ytick',ChoiceAreaInds,'yticklabel',ChoiceValidAreaStr(ChoicePWsortInds),'ylim',[0 numel(ChoicePeakWidthSort)+1]);
title('ChoicePeakWidth sort');


%% ############################## 
% change the second and forth data also sorted by onset time, but the
% circle size is defiend by stim peak width

% plot Stim peak times
AreaStimPeakTime = squeeze(ValueAllAreaDatas(:,5,:));
AreaStimPeakValue = squeeze(ValueAllAreaDatas(:,4,:));
AreaStimPeakWidth = squeeze(ValueAllAreaDatas(:,6,:));

StimValidAreaInds = ~isnan(AreaStimPeakTime(:,1));
StimValidPeakTime = AreaStimPeakTime(StimValidAreaInds,:);
StimValidAreaStr = BrainAreasStr(StimValidAreaInds);
StimValidPeakValue = AreaStimPeakValue(StimValidAreaInds,:);
StimValidPeakWidth = AreaStimPeakWidth(StimValidAreaInds,:);

[StimPeakTimeSort, StimPTsortInds] = sort(StimValidPeakTime(:,1));
StimAreaInds = (1:numel(StimPeakTimeSort))';
StimSortPeakValue = StimValidPeakValue(StimPTsortInds,1);
StimPV2Size = (StimSortPeakValue - mean(StimSortPeakValue)) * 2000+50;

SortStimAreaStr = StimValidAreaStr(StimPTsortInds);
ExistedAreaAHSdatas = nan(numel(SortStimAreaStr),1);
for cAs = 1 : numel(SortStimAreaStr)
    TF = matches(AllenRegionStrsModi,StimValidAreaStr(cAs),'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
            continue;
        end
        ExistedAreaAHSdatas(cAs,1) = RegionScoresUsed(AllenRegionInds);
    end
    
end
StimPTsortAHSData = ExistedAreaAHSdatas(StimPTsortInds);
AHSValidScoresIndex = find(~isnan(StimPTsortAHSData));
AHSValidScores = StimPTsortAHSData(AHSValidScoresIndex);
AHSScoreColors = linearValue2colorFun(AHSValidScores);
[~,ColorSortInds] = sort(AHSValidScores);

h3f = figure('position',[100 100 1240 810]);
ax11 = subplot(141);
hold on
errorbar(StimPeakTimeSort,StimAreaInds,0.5*(StimPeakTimeSort - StimValidPeakTime(StimPTsortInds,3)),...
    0.5*(StimValidPeakTime(:,4)-StimPeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(StimPeakTimeSort,StimAreaInds,StimPV2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);

scatter(ax11,StimPeakTimeSort(AHSValidScoresIndex),StimAreaInds(AHSValidScoresIndex),...
    StimPV2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
colormap(AHSScoreColors(ColorSortInds,:));
hbar = colorbar;
oldBarPos = get(hbar,'position');
set(hbar,'position',[0.05 0.1 oldBarPos(3) oldBarPos(4)*0.2]);
set(get(hbar,'title'),'String','AllenScores');

yscales = get(ax11,'ylim');
line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('StimPeakTime (s)');
set(ax11,'ytick',StimAreaInds,'yticklabel',SortStimAreaStr,'ylim',[0 numel(StimPeakTimeSort)+1]);
title('Size (PeakValue)');

% stim peak width sort plot
StimPWSort = StimValidPeakWidth(StimPTsortInds,1);
StimPeakWidth2Size = (StimPWSort - mean(StimPWSort)) * 600+50;

ax12 = subplot(142);
hold on
errorbar(StimPeakTimeSort,StimAreaInds,0.5*(StimPeakTimeSort - StimValidPeakTime(StimPTsortInds,3)),...
    0.5*(StimValidPeakTime(:,4)-StimPeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(StimPeakTimeSort,StimAreaInds,StimPeakWidth2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);

scatter(ax12,StimPeakTimeSort(AHSValidScoresIndex),StimAreaInds(AHSValidScoresIndex),...
    StimPeakWidth2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');

% line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('StimPeakTime (s)');
set(ax12,'ytick',StimAreaInds,'yticklabel',SortStimAreaStr,'ylim',[0 numel(StimPeakTimeSort)+1]);
title('Size (PeakWidth)');
%
% ####################################################
% choice peak time
AreaChoicePeakTime = squeeze(ValueAllAreaDatas(:,2,:));
AreaChoicePeakValue = squeeze(ValueAllAreaDatas(:,1,:));
AreaChoicePeakWidth = squeeze(ValueAllAreaDatas(:,3,:));

ChoiceValidAreaInds = ~isnan(AreaChoicePeakTime(:,1));
ChoiceValidPeakTime = AreaChoicePeakTime(ChoiceValidAreaInds,:);
ChoiceValidAreaStr = BrainAreasStr(ChoiceValidAreaInds);
ChoiceValidPeakValue = AreaChoicePeakValue(ChoiceValidAreaInds,:);
ChoiceValidPeakWidth = AreaChoicePeakWidth(ChoiceValidAreaInds,:);

[ChoicePeakTimeSort, ChoicePTsortInds] = sort(ChoiceValidPeakTime(:,1));
ChoiceAreaInds = (1:numel(ChoicePeakTimeSort))';
ChoiceSortPeakValue = ChoiceValidPeakValue(ChoicePTsortInds,1);
ChoicePV2Size = (ChoiceSortPeakValue - mean(ChoiceSortPeakValue)) * 2000+50;

SortChoiceAreaStr = ChoiceValidAreaStr(ChoicePTsortInds);
ExistedAreaAHSdatas = nan(numel(SortChoiceAreaStr),1);
for cAs = 1 : numel(SortChoiceAreaStr)
    TF = matches(AllenRegionStrsModi,ChoiceValidAreaStr(cAs),'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
            continue;
        end
        ExistedAreaAHSdatas(cAs,1) = RegionScoresUsed(AllenRegionInds);
    end
    
end
ChoicePTAHSdatas = ExistedAreaAHSdatas(ChoicePTsortInds);
AHSValidScoresIndex = find(~isnan(ChoicePTAHSdatas));
AHSValidScores = ChoicePTAHSdatas(AHSValidScoresIndex);
AHSScoreColors = linearValue2colorFun(AHSValidScores);
[~,ColorSortInds] = sort(AHSValidScores);

% h2f = figure('position',[100 100 1240 810]);
ax13 = subplot(143);
hold on
errorbar(ChoicePeakTimeSort,ChoiceAreaInds,0.5*(ChoicePeakTimeSort - ChoiceValidPeakTime(ChoicePTsortInds,3)),...
    0.5*(ChoiceValidPeakTime(:,4)-ChoicePeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(ChoicePeakTimeSort,ChoiceAreaInds,ChoicePV2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);

xlabel('ChoicePeakTime (s)');
set(ax13,'ytick',ChoiceAreaInds,'yticklabel',SortChoiceAreaStr,'ylim',[0 numel(ChoicePeakTimeSort)+1]);
title('Size (PeakValue)');

scatter(ax13,ChoicePeakTimeSort(AHSValidScoresIndex),ChoiceAreaInds(AHSValidScoresIndex),...
    ChoicePV2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
colormap(AHSScoreColors(ColorSortInds,:));
hbar2 = colorbar;
oldBarPos = get(hbar2,'position');
set(hbar2,'position',[0.94 0.1 oldBarPos(3) oldBarPos(4)*0.2]);
set(get(hbar2,'title'),'String','AllenScores');

% Choice peak time sort plot
ChoicePWsort = ChoiceValidPeakWidth(ChoicePTsortInds,1);
ChoicePW2Size = (ChoicePWsort - mean(ChoicePWsort))*400+50;

ax14 = subplot(144);
hold on
errorbar(ChoicePeakTimeSort,ChoiceAreaInds,0.5*(ChoicePeakTimeSort - ChoiceValidPeakTime(ChoicePTsortInds,3)),...
    0.5*(ChoiceValidPeakTime(:,4)-ChoicePeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(ChoicePeakTimeSort,ChoiceAreaInds,ChoicePW2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);
scatter(ax14,ChoicePeakTimeSort(AHSValidScoresIndex),ChoiceAreaInds(AHSValidScoresIndex),...
    ChoicePW2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
% yscales = get(ax14,'ylim');
% line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('ChoicePeakTime (s)');
set(ax14,'ytick',ChoiceAreaInds,'yticklabel',SortChoiceAreaStr,'ylim',[0 numel(ChoicePeakTimeSort)+1]);
title('Size (PeakWidth)');

%%
AnovaDataSumDatafile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas\AnovaPeak_sumPlot';
% AnovaDataSumDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas\AnovaPeak_sumPlot';
AnovasumPlotPath2 = fullfile(AnovaDataSumDatafile,'AreaSummaryPlots');
if ~isfolder(AnovasumPlotPath2)
    mkdir(AnovasumPlotPath2);
end

sortSavePath = fullfile(AnovasumPlotPath2,'StimANDChioce_peaktime_sortPlot');
saveas(h3f,sortSavePath);

print(h3f,sortSavePath,'-dpng','-r350');
print(h3f,sortSavePath,'-dpdf','-bestfit');

%% ￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥
% only the first peak was considered  in the analysis
cclr
AnovaDataSumDataPath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas';
% AnovaDataSumDataPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas';
% AnovasumPlotPath = fullfile(AnovaDataSumDatafile,'AnovaPeak_sumPlot');
% % if ~isfolder(AnovasumPlotPath)
% %     mkdir(AnovasumPlotPath);
% % end
% saveFilePath = fullfile(AnovasumPlotPath,'AnovaPeakSumData.mat');


% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds);{'Others'}];

AnovaDataSumDatafile = fullfile(AnovaDataSumDataPath,'AllArea_anovaEV_ANDAUC_datas.mat');
load(AnovaDataSumDatafile,'AllArea_anovaEVdatas');
StimOnsetBin = 149;
winGoesStep = 0.01;
BinLength = size(AllArea_anovaEVdatas{1,1,1},1);

%% 
FirstPeakplotSavePath = fullfile(AnovaDataSumDataPath,'AnovaPeak_sumPlot','FirstPeakAnaPlot');
if ~isfolder(FirstPeakplotSavePath)
    mkdir(FirstPeakplotSavePath);
end
saveFilePath = fullfile(AnovaDataSumDataPath,'AnovaPeak_sumPlot','AnovaPeakSumData.mat');
load(saveFilePath,'AreaPeakFactor_peakDatasAll','AreaBT_AvgDatasAll')

%%
UnitNumThres = 10;
NumAreas = length(BrainAreasStr);
ValueAllAreaDatas = nan(NumAreas,6,4); % the last dimension is median and mean
% ValueAllAreaCIs = nan(NumAreas,6,2); % CIs 
BTValuesIsEnough = false(NumAreas,1);
for cA = 1 : NumAreas
    cA_ChoiceData = AreaPeakFactor_peakDatasAll{cA,1};
    cA_StimData = AreaPeakFactor_peakDatasAll{cA,2};
    NonRevData = AreaBT_AvgDatasAll{cA,1};
    if (isempty(cA_ChoiceData) || size(cA_ChoiceData,1) < UnitNumThres) && ...
            (isempty(cA_StimData) || size(cA_StimData,1) < UnitNumThres) && ...
            (isempty(NonRevData) || size(NonRevData,1) < UnitNumThres)
        continue;
    end
    h6f = figure('position',[100 100 1080 520]);
    if ~isempty(cA_ChoiceData)
        cA_ChoicePeakAmp = cellfun(@(x) x(1),cA_ChoiceData(:,1)); %cat(1,cA_ChoiceData{:,1});
        cA_ChoiceFirstPeakBin = cellfun(@(x) x(1),cA_ChoiceData(:,2));
        cA_ChoiceFirstPeakTime = (cA_ChoiceFirstPeakBin - StimOnsetBin)*winGoesStep;
        ChoiceANDEventNum = size(cA_ChoiceData,1);
    else
        ChoiceANDEventNum = NaN;
    end
     if ~isempty(cA_ChoiceData) && size(cA_ChoiceData,1) >= UnitNumThres
        cA_ChoicePeakWidthBin = cellfun(@(x) x(1),cA_ChoiceData(:,4)); %cat(1,cA_ChoiceData{:,4});
        cA_ChoicePeakWidth = cA_ChoicePeakWidthBin * winGoesStep;
        
        ValueAllAreaDatas(cA,1,:) = [median(cA_ChoicePeakAmp), mean(cA_ChoicePeakAmp),prctile(cA_ChoicePeakAmp,[10 90])];
%         ValueAllAreaCIs(cA,1,:) = [prctile(cA_ChoicePeakAmp,[10 90])];
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
        
        ValueAllAreaDatas(cA,2,:) = [median(cA_ChoiceFirstPeakTime),mean(cA_ChoiceFirstPeakTime),prctile(cA_ChoiceFirstPeakTime,[10 90])];
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
        
        ValueAllAreaDatas(cA,3,:) = [median(cA_ChoicePeakWidth),mean(cA_ChoicePeakWidth),prctile(cA_ChoicePeakWidth,[10 90])];
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
    if ~isempty(cA_StimData)
        cA_StimPeakAmp = cellfun(@(x) x(1),cA_StimData(:,1)); %cat(1,cA_StimData{:,1});
        cA_StimFirstPeakBin = cellfun(@(x) x(1),cA_StimData(:,2));
        cA_StimFirstPeakTime = (cA_StimFirstPeakBin - StimOnsetBin)*winGoesStep;
        StimANDEventNum = size(cA_StimData,1);
    else
        StimANDEventNum = NaN;
    end
    if ~isempty(cA_StimData) && size(cA_StimData,1) >= UnitNumThres
        cA_StimPeakWidthBin = cellfun(@(x) x(1),cA_StimData(:,4)); %cat(1,cA_StimData{:,4});
        cA_StimPeakWidth = cA_StimPeakWidthBin * winGoesStep;
        
        ValueAllAreaDatas(cA,4,:) = [median(cA_StimPeakAmp),mean(cA_StimPeakAmp),prctile(cA_StimPeakAmp,[10 90])];
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
        
        ValueAllAreaDatas(cA,5,:) = [median(cA_StimFirstPeakTime),mean(cA_StimFirstPeakTime),prctile(cA_StimFirstPeakTime,[10 90])];
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
        
        ValueAllAreaDatas(cA,6,:) = [median(cA_StimPeakWidth),mean(cA_StimPeakWidth),prctile(cA_StimPeakWidth,[10 90])];
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
    if ~isempty(NonRevData) && size(NonRevData,1) >= UnitNumThres
        
        BTValuesIsEnough(cA) = true;
        
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
        text(0.02,CommonScales(2)*0.9,{'SigUnit/UnitNum';sprintf('%d/%d',sum(SigUnitInds),numel(SigUnitInds))},...
            'Color',[0 0.4 0]);
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
        text(0.02,CommonScales(2)*0.9,{'SigUnit/UnitNum';sprintf('%d/%d',sum(SigUnitInds),numel(SigUnitInds))},...
            'Color',[0 0.4 0]);
        set(ax8,'xlim',CommonScales,'ylim',CommonScales,'box','off');
        xlabel('Baseline EV');
        ylabel('AfterResp(1.5s) EV');
        title(sprintf('RevTr EV (p = %.2e)',RevP));
        
    end
    annotation('textbox',[0.01 0.02 0.05 0.15],'String',{sprintf('Area %s',BrainAreasStr{cA});...
            sprintf('Unit:%d/%d',ChoiceANDEventNum);...
            sprintf('Unit:%d',StimANDEventNum);...
            sprintf('Unit: %d',BTUnitNums)},'FitBoxToText','on','Color','b','FontSize',8);
    
    savePath = fullfile(FirstPeakplotSavePath,sprintf('Area %s anova peak plot save',BrainAreasStr{cA}));
    saveas(h6f,savePath);
    print(h6f,savePath,'-dpng','-r350');
    print(h6f,savePath,'-dpdf','-bestfit');
    close(h6f);
    
end

%%
saveFilePath = fullfile(AnovaDataSumDataPath,'AnovaPeak_sumPlot','AnovaInitPeakSumData.mat');
save(saveFilePath,'AreaPeakFactor_peakDatasAll','AreaBT_AvgDatasAll','StimOnsetBin',...
    'winGoesStep','BrainAreasStr','BTValuesIsEnough','ValueAllAreaDatas','-v7.3');

%
%% ############################## 
% change the second and forth data also sorted by onset time, but the
% circle size is defiend by stim peak width

% plot Stim peak times
AreaStimPeakTime = squeeze(ValueAllAreaDatas(:,5,:));
AreaStimPeakValue = squeeze(ValueAllAreaDatas(:,4,:));
AreaStimPeakWidth = squeeze(ValueAllAreaDatas(:,6,:));

StimValidAreaInds = ~isnan(AreaStimPeakTime(:,1));
StimValidPeakTime = AreaStimPeakTime(StimValidAreaInds,:);
StimValidAreaStr = BrainAreasStr(StimValidAreaInds);
StimValidPeakValue = AreaStimPeakValue(StimValidAreaInds,:);
StimValidPeakWidth = AreaStimPeakWidth(StimValidAreaInds,:);

[StimPeakTimeSort, StimPTsortInds] = sort(StimValidPeakTime(:,1));
StimAreaInds = (1:numel(StimPeakTimeSort))';
StimSortPeakValue = StimValidPeakValue(StimPTsortInds,1);
StimPV2Size = (StimSortPeakValue - mean(StimSortPeakValue)) * 1500+50;

SortStimAreaStr = StimValidAreaStr(StimPTsortInds);
ExistedAreaAHSdatas = nan(numel(SortStimAreaStr),1);
for cAs = 1 : numel(SortStimAreaStr)
    TF = matches(AllenRegionStrsModi,StimValidAreaStr(cAs),'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
            continue;
        end
        ExistedAreaAHSdatas(cAs,1) = RegionScoresUsed(AllenRegionInds);
    end
    
end
StimPTsortAHSData = ExistedAreaAHSdatas(StimPTsortInds);
AHSValidScoresIndex = find(~isnan(StimPTsortAHSData));
AHSValidScores = StimPTsortAHSData(AHSValidScoresIndex);
AHSScoreColors = linearValue2colorFun(AHSValidScores);
[~,ColorSortInds] = sort(AHSValidScores);

h3f = figure('position',[100 100 1240 810]);
ax11 = subplot(141);
hold on
errorbar(StimPeakTimeSort,StimAreaInds,0.5*(StimPeakTimeSort - StimValidPeakTime(StimPTsortInds,3)),...
    0.5*(StimValidPeakTime(:,4)-StimPeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(StimPeakTimeSort,StimAreaInds,StimPV2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);

scatter(ax11,StimPeakTimeSort(AHSValidScoresIndex),StimAreaInds(AHSValidScoresIndex),...
    StimPV2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
colormap(AHSScoreColors(ColorSortInds,:));
hbar = colorbar;
oldBarPos = get(hbar,'position');
set(hbar,'position',[0.05 0.1 oldBarPos(3) oldBarPos(4)*0.2]);
set(get(hbar,'title'),'String','AllenScores');

% yscales = get(ax11,'ylim');
% line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('StimPeakTime (s)');
set(ax11,'ytick',StimAreaInds,'yticklabel',SortStimAreaStr,'ylim',[0 numel(StimPeakTimeSort)+1]);
title('Size (PeakValue)');

% stim peak width sort plot
StimPWSort = StimValidPeakWidth(StimPTsortInds,1);
StimPeakWidth2Size = (StimPWSort - mean(StimPWSort)) * 400+50;

ax12 = subplot(142);
hold on
errorbar(StimPeakTimeSort,StimAreaInds,0.5*(StimPeakTimeSort - StimValidPeakTime(StimPTsortInds,3)),...
    0.5*(StimValidPeakTime(:,4)-StimPeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(StimPeakTimeSort,StimAreaInds,StimPeakWidth2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);

scatter(ax12,StimPeakTimeSort(AHSValidScoresIndex),StimAreaInds(AHSValidScoresIndex),...
    StimPeakWidth2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');

% line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('StimPeakTime (s)');
set(ax12,'ytick',StimAreaInds,'yticklabel',SortStimAreaStr,'ylim',[0 numel(StimPeakTimeSort)+1]);
title('Size (PeakWidth)');
%
% ####################################################
% choice peak time
AreaChoicePeakTime = squeeze(ValueAllAreaDatas(:,2,:));
AreaChoicePeakValue = squeeze(ValueAllAreaDatas(:,1,:));
AreaChoicePeakWidth = squeeze(ValueAllAreaDatas(:,3,:));

ChoiceValidAreaInds = ~isnan(AreaChoicePeakTime(:,1));
ChoiceValidPeakTime = AreaChoicePeakTime(ChoiceValidAreaInds,:);
ChoiceValidAreaStr = BrainAreasStr(ChoiceValidAreaInds);
ChoiceValidPeakValue = AreaChoicePeakValue(ChoiceValidAreaInds,:);
ChoiceValidPeakWidth = AreaChoicePeakWidth(ChoiceValidAreaInds,:);

[ChoicePeakTimeSort, ChoicePTsortInds] = sort(ChoiceValidPeakTime(:,1));
ChoiceAreaInds = (1:numel(ChoicePeakTimeSort))';
ChoiceSortPeakValue = ChoiceValidPeakValue(ChoicePTsortInds,1);
ChoicePV2Size = (ChoiceSortPeakValue - mean(ChoiceSortPeakValue)) * 2000+50;
%
SortChoiceAreaStr = ChoiceValidAreaStr(ChoicePTsortInds);
ExistedAreaAHSdatas = nan(numel(SortChoiceAreaStr),1);
for cAs = 1 : numel(SortChoiceAreaStr)
    TF = matches(AllenRegionStrsModi,ChoiceValidAreaStr(cAs),'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
            continue;
        end
        ExistedAreaAHSdatas(cAs,1) = RegionScoresUsed(AllenRegionInds);
    end
    
end
ChoicePTAHSdatas = ExistedAreaAHSdatas(ChoicePTsortInds);
AHSValidScoresIndex = find(~isnan(ChoicePTAHSdatas));
AHSValidScores = ChoicePTAHSdatas(AHSValidScoresIndex);
AHSScoreColors = linearValue2colorFun(AHSValidScores);
[~,ColorSortInds] = sort(AHSValidScores);

% h2f = figure('position',[100 100 1240 810]);
ax13 = subplot(143);
hold on
errorbar(ChoicePeakTimeSort,ChoiceAreaInds,0.5*(ChoicePeakTimeSort - ChoiceValidPeakTime(ChoicePTsortInds,3)),...
    0.5*(ChoiceValidPeakTime(:,4)-ChoicePeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(ChoicePeakTimeSort,ChoiceAreaInds,ChoicePV2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);

xlabel('ChoicePeakTime (s)');
set(ax13,'ytick',ChoiceAreaInds,'yticklabel',SortChoiceAreaStr,'ylim',[0 numel(ChoicePeakTimeSort)+1]);
title('Size (PeakValue)');

scatter(ax13,ChoicePeakTimeSort(AHSValidScoresIndex),ChoiceAreaInds(AHSValidScoresIndex),...
    ChoicePV2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
colormap(AHSScoreColors(ColorSortInds,:));
hbar2 = colorbar;
oldBarPos = get(hbar2,'position');
set(hbar2,'position',[0.94 0.1 oldBarPos(3) oldBarPos(4)*0.2]);
set(get(hbar2,'title'),'String','AllenScores');

% Choice peak time sort plot
ChoicePWsort = ChoiceValidPeakWidth(ChoicePTsortInds,1);
ChoicePW2Size = (ChoicePWsort - mean(ChoicePWsort))*400+50;

ax14 = subplot(144);
hold on
errorbar(ChoicePeakTimeSort,ChoiceAreaInds,0.5*(ChoicePeakTimeSort - ChoiceValidPeakTime(ChoicePTsortInds,3)),...
    0.5*(ChoiceValidPeakTime(:,4)-ChoicePeakTimeSort),'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(ChoicePeakTimeSort,ChoiceAreaInds,ChoicePW2Size,'MarkerEdgecolor','k',...
    'linewidth',1.5);
scatter(ax14,ChoicePeakTimeSort(AHSValidScoresIndex),ChoiceAreaInds(AHSValidScoresIndex),...
    ChoicePW2Size(AHSValidScoresIndex),AHSScoreColors,'o','filled');
% yscales = get(ax14,'ylim');
% line([0.2 0.2],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.3 0.3],yscales,'Color','c','linewidth',1.4,'linestyle','--');
% line([0.6 0.6],yscales,'Color','c','linewidth',1.4,'linestyle','--');
xlabel('ChoicePeakTime (s)');
set(ax14,'ytick',ChoiceAreaInds,'yticklabel',SortChoiceAreaStr,'ylim',[0 numel(ChoicePeakTimeSort)+1]);
title('Size (PeakWidth)');

%%
AnovaDataSumDatafile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas\AnovaPeak_sumPlot\FirstPeakAnaPlot';
% AnovaDataSumDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas\AnovaPeak_sumPlot\FirstPeakAnaPlot';
% AnovasumPlotPath3 = fullfile(AnovaDataSumDatafile,'AreaSummaryPlots');
% if ~isfolder(AnovasumPlotPath2)
%     mkdir(AnovasumPlotPath2);
% end

sortSavePath = fullfile(AnovaDataSumDatafile,'StimANDChioce_peaktime_sortPlot');
saveas(h3f,sortSavePath);

print(h3f,sortSavePath,'-dpng','-r350');
print(h3f,sortSavePath,'-dpdf','-bestfit');

%% stim peak time ranges
FreqwiseStr = {'NonRevF','RevF'};

StimEdges = [0,0.2,0.3,0.4,2]; % the last term could indicates inf, but use 2s for more resonable definition
AreaStimPeakTime = squeeze(ValueAllAreaDatas(:,5,1));
AreaStimPeakWidth = squeeze(ValueAllAreaDatas(:,6,1));

NumAreas = size(AreaBT_AvgDatasAll,1);
AreaBTAvgsAll = nan(NumAreas,4);
for cA = 1 : size(AreaBT_AvgDatasAll,1)
    cA_nonRevTr_BTs = AreaBT_AvgDatasAll{cA,1};
    if ~isempty(cA_nonRevTr_BTs) && size(cA_nonRevTr_BTs,1) >= 10
        AreaBTAvgsAll(cA,:) = [mean(cA_nonRevTr_BTs(:,1)),mean(cA_nonRevTr_BTs(:,3)),...
            mean(cA_nonRevTr_BTs(cA_nonRevTr_BTs(:,1) > cA_nonRevTr_BTs(:,2),1)),...
            mean(cA_nonRevTr_BTs(cA_nonRevTr_BTs(:,3) > cA_nonRevTr_BTs(:,4),3))];
    end
end

NonNanInds = ~isnan(AreaStimPeakTime) & ~isnan(AreaBTAvgsAll(:,1));
NonNanStimPT = AreaStimPeakTime(NonNanInds);
NonNanStimPW = AreaStimPeakWidth(NonNanInds);
NonNanBTAvgs = AreaBTAvgsAll(NonNanInds,:);

PTbinData = cell(length(StimEdges)-1,3);
for cSEdge = 1 : length(StimEdges)-1
    cPTbin_edges = [StimEdges(cSEdge),StimEdges(cSEdge+1)];
    cPTbin_Inds = NonNanStimPT > cPTbin_edges(1) & NonNanStimPT <= cPTbin_edges(2);
    cPTbin_Datas = NonNanBTAvgs(cPTbin_Inds,:);
    PTbinData(cSEdge,:) = {cPTbin_Datas, cSEdge*ones(size(cPTbin_Datas,1),1),...
        NonNanStimPW(cPTbin_Inds)};
end

PTbinDataMtx = cell2mat(PTbinData(:,1));
PTbinDataGrInds = cell2mat(PTbinData(:,2));
PWbinDataMtx = cat(1,PTbinData{:,3});




