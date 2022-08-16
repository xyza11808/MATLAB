
cA = 1;
FactorStrs = {'Choice','Stim','BlockType'};
% hf = figure('position',[100 100 1200 340]);
figure;
cf = 2;
nFactors = size(AllArea_anovaEVdatas,3);
% AllArea_BTAnova_freqwise

% for cf = 1 : nFactors
    cfRealData = AllArea_anovaEVdatas{cA,cf,1};
    cfThresData = AllArea_anovaEVdatas{cA,cf,2};
    
    cA_AvgTrace = mean(cfRealData,2);
    cA_ThresAvg = median(cfThresData(:));
    [pks,locs,w,p] = findpeaks(cA_AvgTrace,'MinPeakDistance',50,'MinPeakProminence',cA_ThresAvg,'MinPeakHeight',0.01,...
        'Annotate','extents','WidthReference','halfheight');
    
    

% end

%%
close
cU = 121;
cU_Trace = cfRealData(:,cU);
figure;
sgf = sgolayfilt(cU_Trace,3,41);
HeightThres = max(sgf)/3;
findpeaks(sgf,'MinPeakDistance',20,'MinPeakProminence',0.01,'MinPeakHeight',HeightThres,...
        'Annotate','extents','WidthReference','halfheight');
%

hold on
plot(cU_Trace,'r');
% plot(sgf,'r')
[NegPeak, NegLocs] = findpeaks(-sgf,'MinPeakDistance',20,...
        'Annotate','extents','WidthReference','halfheight');







