% this scription is used for summarized plot of multiple sessions data into
% one plot, summaried all sessions' ROI response into one plot

add_char = 'y';
m = 1;
datapath = {};
DataSum = {};
AlignFrame = [];
FrameDis = [];
while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('SessionSumData.mat','Please select your ROI response summary plot');
    if fi
        datapath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        DataSum{m} = xx;
        AlignFrame(m) = xx.FrameDis(1) + 1;
        FrameDis(m,:) = xx.FrameDis;
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
save SessionDataSum.mat DataSum -v7.3

%%
FrameDisAll = min(FrameDis);
DataAllSum = [];
for nxnx = 1 : m
    cData = DataSum{nxnx};
    cNorData = cData.DataNor(:,(AlignFrame(nxnx) - FrameDisAll(1)):(AlignFrame(nxnx)+FrameDisAll(2)));
    DataAllSum = [DataAllSum;cNorData];
end
[~,MaxInds] = max(DataAllSum,[],2);
[~,SortInds] = sort(MaxInds);
%%
h_all = figure('position',[300 200 1000 800]);
imagesc(DataAllSum(SortInds,:));
line([FrameDisAll(1)+1 FrameDisAll(1)+1],[0.5,size(DataAllSum,1)+0.5],'Color',[.8 .8 .8],'LineWidth',2);
h = colorbar;
set(get(h,'Title'),'String','z-score')
xlabel('Frames');
ylabel('nROIs');
title({'Across session Normalized response plot';sprintf('nROIs = %d',size(DataAllSum,1))});
set(gca,'FontSize',20);
set(gca,'clim',[-2 2]);
saveas(h_all,'Multi-session Normalized response color plot');
saveas(h_all,'Multi-session Normalized response color plot','png');
close(h_all);

save MultiSessionData.mat DataAllSum FrameDisAll -v7.3
