
% cA = 1;
FactorStrs = {'Choice','Stim'}; %,'BlockType'
NumAreas = length(BrainAreasStr);
AreaPeakFactor_peakDatasAll = cell(NumAreas,2);

for cA = 1 : NumAreas
    % hf = figure('position',[100 100 1200 340]);
    % figure;
    % cf = 2;
    nFactors = size(AllArea_anovaEVdatas,3);
    % AllArea_BTAnova_freqwise

    for cf = 1 : 2 %nFactors
        cfRealData = AllArea_anovaEVdatas{cA,cf,1};
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
    
end
%%
PeakLocsAll = cat(1,PeakFinds{:,2});
[N, Edges] = histcounts(PeakLocsAll,1:size(cfRealData,1));
figure;plot(Edges(1:end-1),smooth(N,5))

PeakWidth = cat(1,PeakFinds{:,4});
figure;
hist(PeakWidth)

%% % %
figure
hold on
plot(sgf,'k');
scatter(NegLocs,NegPeak,'bo');
plot(cU_Trace,'r');
yscales = get(gca,'ylim');
for cP = 1 : length(NegPeak)
   line([widths(cP,1),widths(cP,1)],yscales,'Color','g'); 
   line([widths(cP,2),widths(cP,2)],yscales,'Color','y'); 
   
end
% plot(sgf,'r')
% % % [NegPeak, NegLocs, widths] = Findpeak_WWds(-sgf,'MinPeakDistance',20,...
% % %         'Annotate','extents','WidthReference','halfheight');







