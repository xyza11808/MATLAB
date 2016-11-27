%script for summary plot of extimated spike across time plot

add_char = 'y';
inputChoice = input('would like to added new session data into last summary result?\n','s');
if strcmpi(inputChoice,'y')
    [fnx,fpx,fix] = uigetfile('SessionDataSum.mat','Please load your last summary plot result');
    if fix
        load(fullfile(fpx,fnx));
        isOldLoad = 1;
    else
        isOldLoad = 0;
    end
else
    isOldLoad = 0;
end
if ~isOldLoad
    m = 1;
    datapath = {};
    DataSum = {};
    TimeWinScale = {};
    TrWinPerf = {};
else
   m = length(DataSum) + 1;
end

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('MWinCLassData.mat','Please select your ROI fraction based classification result save');
    if fi
        datapath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        DataSum{m} = xx;
        TimeWinScale{m} = xx.MultiTScale;
        TrWinPerf{m} = xx.TrWinClassPerf;
        
    end
    add_char = input('Do you want to add with more session data?\n','s');
    m = m + 1;
end
m = m - 1;

fp = uigetdir(pwd,'Please select a session to save your current data');
cd(fp);
f = fopen('Session_resp_path.txt','w');
fprintf(f,'Sessions path for response summary plot:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,datapath{nbnb});
end
fclose(f);
save SessionDataSum.mat DataSum TimeWinScale TrWinPerf -v7.3

%%
TrScaleLen = cellfun(@length,TimeWinScale);

if length(unique(TrScaleLen)) > 1
    fprintf('Multi length time scale exists, using the min time scale for plotting.\n');
    TargetLen = min(TrScaleLen);
    DataCellAll = cellfun(@(x,y) CellDataExtract(x,TargetLen),TrWinPerf,'UniformOutput',false);
    DataCellAll = (DataCellAll(:))';
    DataMatrixAll = (cell2mat(DataCellAll))';
else
    fprintf('Unique length of all time scales, convert into number matrix.\n');
    DataCellAll = (TrWinPerf(:))';
    DataMatrixAll = (cell2mat(DataCellAll))';
end
DataMatrixAll = 1 - DataMatrixAll;
xTickScaleLen = TimeWinScale{1}(1:TargetLen);
TimeWinStep = diff(xTickScaleLen(1:2));
xTickScaleLen(xTickScaleLen < 0) = xTickScaleLen(xTickScaleLen < 0) + TimeWinStep;
xTickScaleLen = xTickScaleLen(:);
TrWinPerfMean = mean(DataMatrixAll);
TrWinPerfSEM = std(DataMatrixAll)/sqrt(size(DataMatrixAll,1));
xTickP = [xTickScaleLen;flipud(xTickScaleLen)];
TrWinPerfPatch = [(TrWinPerfMean + TrWinPerfSEM),fliplr(TrWinPerfMean - TrWinPerfSEM)];

h = figure('position',[300 200 1000 800]);
patch(xTickP,TrWinPerfPatch,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
plot(xTickScaleLen,TrWinPerfMean,'k','LineWidth',1.6);
line([0 0],[0.4 1],'Color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
ylim([0.4 1]);
xlims = get(gca,'xlim');
line([xlims(1),xlims(2)],[0.5 0.5],'Color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
xlabel('Time (s)');
ylabel('Classification Accuracy');
title('Temporal profile of choice classification');
set(gca,'FontSize',20);
saveas(h,'Time Win classification of choice by extimated spike');
saveas(h,'Time Win classification of choice by extimated spike','png');
% close(h);

save MeanTimeWinData.mat xTickScaleLen DataMatrixAll -v7.3