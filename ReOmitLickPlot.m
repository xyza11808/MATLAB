function ReOmitLickPlot(LickTime,OnsetT,AnsWerT,EndT,TypeInds,varargin)
% this function used for plot animal lick time in order for comparation of
% normal trials and reward omit trials

% the variable: LickTime
                % this variable is the function output from another
                % function: beha_lickTime_data
%               TypeInds
                % output variable from function: RewardOmitPlot
                % if the omit response plot is not need, just run and stop
                % at the begaining of this function
% XinYu, 2016

if isempty(EndT)
    EndT = 10;  % excluded lick time larger than 10s
end

SoundT = double(OnsetT);
AnsT = double(AnsWerT);

% OnsetTime alignment
AlignTrialT = min(SoundT);
TrialAlignValue = SoundT - AlignTrialT;
AdjustedAnsT = AnsT - TrialAlignValue;

if ~isdir('./Reomit_lick_plot/')
    mkdir('./Reomit_lick_plot/');
end
cd('./Reomit_lick_plot/');

h_lick = figure('position',[200 100 1300 1000],'paperpositionmode','auto');
subplot(3,2,[1,3]); % correct normal left lick 
hold on;
CorrLNorInds = TypeInds.CLNorInds;
CAnsT = AdjustedAnsT(CorrLNorInds);
CLickStruc = LickTime(CorrLNorInds);
CTrialNum = sum(CorrLNorInds);
CAdjustValue = TrialAlignValue(CorrLNorInds);
[AnsTSortV,AnsTSortInds] = sort(CAnsT);
CAdjustValueSort = CAdjustValue(AnsTSortInds);  
CLickStruc = CLickStruc(AnsTSortInds);
%
for nTrial = 1 : CTrialNum
    cLickLT = CLickStruc(nTrial).LickTimeLeft;
    cLickRT = CLickStruc(nTrial).LickTimeRight;
    cLickRT(cLickRT > (EndT*1000)) = [];
    cLickLT(cLickLT > (EndT*1000)) = [];
    
    cLickLTAd = cLickLT - CAdjustValueSort(nTrial);
    cLickRTAd = cLickRT - CAdjustValueSort(nTrial);
    cLickLTAd(cLickLTAd < 0) = [];
    cLickRTAd(cLickRTAd < 0) = [];
    scatter(cLickLTAd,ones(length(cLickLTAd),1)*(CTrialNum-nTrial+1),15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
    scatter(cLickRTAd,ones(length(cLickRTAd),1)*(CTrialNum-nTrial+1),15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
    line([AnsTSortV(nTrial),AnsTSortV(nTrial)],[CTrialNum-nTrial+0.6,CTrialNum-nTrial+1.4],'LineWidth',1.8,'color',[1 0 1]);
end
line([AlignTrialT,AlignTrialT],[0 CTrialNum+1],'LineWidth',2,'color',[.7 .7 .7]);
%
ylim([0 CTrialNum+1]);
CxLLim = get(gca,'xlim');
xlabel('Time(ms)');
ylabel('Trials');
title('Left correct normal trials');
set(gca,'FontSize',20);

subplot(3,2,[2,4]); %correct normal right lick 
hold on;
CorrRNorInds = TypeInds.CRNorInds;
CAnsT = AdjustedAnsT(CorrRNorInds);
CLickStruc = LickTime(CorrRNorInds);
CTrialNum = sum(CorrRNorInds);
CAdjustValue = TrialAlignValue(CorrRNorInds);
[AnsTSortV,AnsTSortInds] = sort(CAnsT);
CAdjustValueSort = CAdjustValue(AnsTSortInds);  
CLickStruc = CLickStruc(AnsTSortInds);

for nTrial = 1 : CTrialNum
    cLickLT = CLickStruc(nTrial).LickTimeLeft;
    cLickRT = CLickStruc(nTrial).LickTimeRight;
    cLickRT(cLickRT > (EndT*1000)) = [];
    cLickLT(cLickLT > (EndT*1000)) = [];
    
    cLickLTAd = cLickLT - CAdjustValueSort(nTrial);
    cLickRTAd = cLickRT - CAdjustValueSort(nTrial);
    cLickLTAd(cLickLTAd < 0) = [];
    cLickRTAd(cLickRTAd < 0) = [];
    scatter(cLickLTAd,ones(length(cLickLTAd),1)*(CTrialNum-nTrial+1),15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
    scatter(cLickRTAd,ones(length(cLickRTAd),1)*(CTrialNum-nTrial+1),15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
    line([AnsTSortV(nTrial),AnsTSortV(nTrial)],[CTrialNum-nTrial+0.6,CTrialNum-nTrial+1.4],'LineWidth',1.8,'color',[1 0 1]);
end
line([AlignTrialT,AlignTrialT],[0 CTrialNum+1],'LineWidth',2,'color',[.8 .8 .8]);
ylim([0 CTrialNum+1]);
CxRLim = get(gca,'xlim');
xlabel('Time(ms)');
ylabel('Trials');
title('Right correct normal trials');
set(gca,'FontSize',20);

subplot(3,2,5); % correct reward omit left lick
hold on
CorrLOmtInds = TypeInds.CLOmtInds;
CAnsT = AdjustedAnsT(CorrLOmtInds);
CLickStruc = LickTime(CorrLOmtInds);
CTrialNum = sum(CorrLOmtInds);
CAdjustValue = TrialAlignValue(CorrLOmtInds);
[AnsTSortV,AnsTSortInds] = sort(CAnsT);
CAdjustValueSort = CAdjustValue(AnsTSortInds);  
CLickStruc = CLickStruc(AnsTSortInds);

for nTrial = 1 : CTrialNum
    cLickLT = CLickStruc(nTrial).LickTimeLeft;
    cLickRT = CLickStruc(nTrial).LickTimeRight;
    cLickRT(cLickRT > (EndT*1000)) = [];
    cLickLT(cLickLT > (EndT*1000)) = [];
    
    cLickLTAd = cLickLT - CAdjustValueSort(nTrial);
    cLickRTAd = cLickRT - CAdjustValueSort(nTrial);
    cLickLTAd(cLickLTAd < 0) = [];
    cLickRTAd(cLickRTAd < 0) = [];
    scatter(cLickLTAd,ones(length(cLickLTAd),1)*(CTrialNum-nTrial+1),15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
    scatter(cLickRTAd,ones(length(cLickRTAd),1)*(CTrialNum-nTrial+1),15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
    line([AnsTSortV(nTrial),AnsTSortV(nTrial)],[CTrialNum-nTrial+0.6,CTrialNum-nTrial+1.4],'LineWidth',1.8,'color',[1 0 1]);
end
line([AlignTrialT,AlignTrialT],[0 CTrialNum+1],'LineWidth',2,'color',[.8 .8 .8]);
ylim([0 CTrialNum+1]);
set(gca,'xlim',CxLLim);
xlabel('Time(ms)');
ylabel('Trials');
title('Left correct omit trials');
set(gca,'FontSize',20);

subplot(3,2,6); % correct reward omit left lick
hold on
CorrLOmtInds = TypeInds.CROmtInds;
CAnsT = AdjustedAnsT(CorrLOmtInds);
CLickStruc = LickTime(CorrLOmtInds);
CTrialNum = sum(CorrLOmtInds);
CAdjustValue = TrialAlignValue(CorrLOmtInds);
[AnsTSortV,AnsTSortInds] = sort(CAnsT);
CAdjustValueSort = CAdjustValue(AnsTSortInds);  
CLickStruc = CLickStruc(AnsTSortInds);

for nTrial = 1 : CTrialNum
    cLickLT = CLickStruc(nTrial).LickTimeLeft;
    cLickRT = CLickStruc(nTrial).LickTimeRight;
    cLickRT(cLickRT > (EndT*1000)) = [];
    cLickLT(cLickLT > (EndT*1000)) = [];
    
    cLickLTAd = cLickLT - CAdjustValueSort(nTrial);
    cLickRTAd = cLickRT - CAdjustValueSort(nTrial);
    cLickLTAd(cLickLTAd < 0) = [];
    cLickRTAd(cLickRTAd < 0) = [];
    scatter(cLickLTAd,ones(length(cLickLTAd),1)*(CTrialNum-nTrial+1),15,'o','MarkerEdgeColor','k','MarkerFaceColor','b');
    scatter(cLickRTAd,ones(length(cLickRTAd),1)*(CTrialNum-nTrial+1),15,'o','MarkerEdgeColor','k','MarkerFaceColor','r');
    line([AnsTSortV(nTrial),AnsTSortV(nTrial)],[CTrialNum-nTrial+0.6,CTrialNum-nTrial+1.4],'LineWidth',1.8,'color',[1 0 1]);
end
line([AlignTrialT,AlignTrialT],[0 CTrialNum+1],'LineWidth',2,'color',[.8 .8 .8]);
ylim([0 CTrialNum+1]);
set(gca,'xlim',CxRLim);
xlabel('Time(ms)');
ylabel('Trials');
title('Right correct omit trials');
set(gca,'FontSize',20);

saveas(h_lick,'Normal_Omit lick plot','png');
saveas(h_lick,'Normal_Omit lick plot','fig');
close(h_lick);

%%
% plot the answer lick rate for each trial
% calculate the lick rate for each trial first and then merge same
% condition togetehr

TrialNum = length(LickTime);
TimeScale = [-0.5,4]; % time scale before and after answer time
TimeWin = 0.1;  % time window used for calculate lick rate
TimeScalems = TimeScale *1000;
TimeWinms = TimeWin * 1000;
WinNum = sum(diff(TimeScale)/TimeWin);
AlignT = abs(TimeScale(1)/TimeWin);  
xtickNum = 0 : 10 : WinNum;

LeftLickRate = zeros(TrialNum,WinNum);
RightLickRate = zeros(TrialNum,WinNum);
for nTr = 1 : TrialNum
    cTLeftLick = LickTime(nTr).LickTimeLeft;
    cTRightLick = LickTime(nTr).LickTimeRight;
    cAnsT = AnsT(nTr);
    for nWin = 1 : WinNum
        cWinBase = (cAnsT + TimeScalems(1)) + (nWin-1) * TimeWinms;
        if ~isempty(cTLeftLick)
            NumWithinWin = sum(cTLeftLick >= cWinBase & cTLeftLick < (cWinBase+TimeWinms));
            LeftLickRate(nTr,nWin) = NumWithinWin/TimeWin;
        end
        if ~isempty(cTRightLick)
            NumWithinWin = sum(cTRightLick >= cWinBase & cTRightLick < (cWinBase+TimeWinms));
            RightLickRate(nTr,nWin) = NumWithinWin/TimeWin;
        end
    end
    LeftLickRate(nTr,:) = smooth(LeftLickRate(nTr,:));
    RightLickRate(nTr,:) = smooth(RightLickRate(nTr,:));
end

%LeftLicks
CorrLNorLickRateL = LeftLickRate(TypeInds.CLNorInds,:);
CorrRNorLickRateL = LeftLickRate(TypeInds.CRNorInds,:);
CorrLOmtLickRateL = LeftLickRate(TypeInds.CLOmtInds,:);
CorrROmtLickRateL = LeftLickRate(TypeInds.CROmtInds,:);

%RightLicks
CorrLNorLickRateR = RightLickRate(TypeInds.CLNorInds,:);
CorrRNorLickRateR = RightLickRate(TypeInds.CRNorInds,:);
CorrLOmtLickRateR = RightLickRate(TypeInds.CLOmtInds,:);
CorrROmtLickRateR = RightLickRate(TypeInds.CROmtInds,:);

LeftDataStrc.ControlOBS1 = CorrLNorLickRateL;
LeftDataStrc.ModulateOBS1 = CorrLOmtLickRateL;
LeftDataStrc.ControlOBS2 = CorrLNorLickRateR;
LeftDataStrc.ModulateOBS2 = CorrLOmtLickRateR;

[h_allL,handlesL,HandlesPatchL] = ModuContMeanPlot(LeftDataStrc,AlignT);
set(handlesL(1,1).LineH,'color','b');
set(handlesL(1,2).LineH,'color','b');
set(handlesL(2,1).LineH,'color','r');
set(handlesL(2,2).LineH,'color','r');
title('Left Trials Lick Rate');
ylabel('Lick Rate (Hz)');
set(gca,'xtick',xtickNum,'xticklabel',xtickNum*TimeWin);
xlabel('Time(s)');
set(gca,'FontSize',20);
saveas(h_allL,'Left trials lick rate plot');
saveas(h_allL,'Left trials lick rate plot','png');
close(h_allL);

RightDataStrc.ControlOBS1 = CorrRNorLickRateL;
RightDataStrc.ModulateOBS1 = CorrROmtLickRateL;
RightDataStrc.ControlOBS2 = CorrRNorLickRateR;
RightDataStrc.ModulateOBS2 = CorrROmtLickRateR;

[h_allR,handlesR,HandlesPatchR] = ModuContMeanPlot(RightDataStrc,AlignT);
set(handlesR(1,1).LineH,'color','b');
set(handlesR(1,2).LineH,'color','b');
set(handlesR(2,1).LineH,'color','r');
set(handlesR(2,2).LineH,'color','r');
title('Right Trials Lick Rate');
ylabel('Lick Rate (Hz)');
set(gca,'xtick',xtickNum,'xticklabel',xtickNum*TimeWin);
xlabel('Time(s)');
set(gca,'FontSize',20);
saveas(h_allR,'Right trials lick rate plot');
saveas(h_allR,'Right trials lick rate plot','png');
close(h_allR);
save lickRateResult.mat LeftDataStrc RightDataStrc AlignT -v7.3

cd ..;