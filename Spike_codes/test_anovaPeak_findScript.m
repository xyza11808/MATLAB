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
AreaBT_AvgDatasAll = cell(NumAreas,1);
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
            else
                PeakFinds(cU,:) = {NegPeak, NegLocs, widths, widths(:,2) - widths(:,1)};
            end
        end
        
        AreaPeakFactor_peakDatasAll(cA,cf) = {PeakFinds};
    end
    
    % calculate the trial-wise EVs
    cA_BT_freqwiseData = squeeze(AllArea_BTAnova_freqwise(cA,:,:));
    if ~isempty(cA_BT_freqwiseData{1})
        cA_BT_BaseAvgs = cellfun(@(x) (mean(x(1:StimOnsetBin,:)))',cA_BT_freqwiseData,'un',0);
        
        cA_BT_AfterRespAvgs = cellfun(@(x) (mean(x((1+StimOnsetBin):(StimOnsetBin+150),:)))',cA_BT_freqwiseData,'un',0);
        
        cA_BTAvg_Mtx = {[cA_BT_BaseAvgs{1,1},cA_BT_BaseAvgs{1,2},cA_BT_AfterRespAvgs{1,1},cA_BT_AfterRespAvgs{1,2}],...
            [cA_BT_BaseAvgs{2,1},cA_BT_BaseAvgs{2,2},cA_BT_AfterRespAvgs{2,1},cA_BT_AfterRespAvgs{2,2}]};
        
        AreaBT_AvgDatasAll{cA} = cA_BTAvg_Mtx;
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







