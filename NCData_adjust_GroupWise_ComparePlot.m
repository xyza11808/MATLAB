% this scripts is used for correct the distance based effect on noise
% correlation value, and tried to see whether the between group noise
% correlation value is still significantly small than within group noise
% correlation coefficients
clear
clc

[fn,fp,fi] = uigetfile('CoefDisSave.mat','Please select your noise correlation coefficient and distance data');
if ~fi
    return;
else
    cPath = fullfile(fp,fn);
    NCDataStrc = load(cPath);
    cd(fp);
%     try
%         NCDataVector = NCDataStrc.NCDataAll;
%         PairedDisVector = (NCDataStrc.ROIRealDis)';
%     catch
%         NCDataStrc = load('CoefDisSave.mat');
        NCDataVector = NCDataStrc.PairedNoiseCoef;
        PairedDisVector = (NCDataStrc.ROIEucDis)';
%     end
        
    [tbl,~] = lmFunCalPlot(PairedDisVector,NCDataVector,0);
    a = tbl.Coefficients.Estimate(1);
    b = tbl.Coefficients.Estimate(2);
    modelfun = @(x) (b * x + a);
    PredDisNC = modelfun(PairedDisVector);
    AdjNCvector = (NCDataVector - PredDisNC) + mean(PredDisNC);
end

%% loading ROI group-wised index
[FN,FP,FI] = uigetfile('RespGroupNCData.mat','Please select the ROI group index file');
if ~FI
    return;
else
    csPath = fullfile(FP,FN);
    IndexStrc = load(csPath);
    LeftIndex = IndexStrc.LeftSigROIAUCIndex;
    RightIndex = IndexStrc.RightSigROIAUCIndex;
end
AdjNCMtx = squareform(AdjNCvector);
ROIDisMtx = squareform(PairedDisVector);

LeftGroupNCMtx = AdjNCMtx(LeftIndex,LeftIndex);
RightGroupNCMtx = AdjNCMtx(RightIndex,RightIndex);
BetGroupNCMtx = AdjNCMtx(LeftIndex,RightIndex);

LeftGroupDisMtx = ROIDisMtx(LeftIndex,LeftIndex);
RightGroupDisMtx = ROIDisMtx(RightIndex,RightIndex);
BetGroupDisMtx = ROIDisMtx(LeftIndex,RightIndex);

LeftGroupNCVec = LeftGroupNCMtx(logical(tril(ones(size(LeftGroupNCMtx)),-1)));
RightGroupNCVec = RightGroupNCMtx(logical(tril(ones(size(RightGroupNCMtx)),-1)));
BetGroupNCVec = BetGroupNCMtx(:);

LeftGroupDisVec = LeftGroupDisMtx(logical(tril(ones(size(LeftGroupDisMtx)),-1)));
RightGroupDisVec = RightGroupDisMtx(logical(tril(ones(size(RightGroupDisMtx)),-1)));
BetGroupDisVec = BetGroupDisMtx(:);

save DisNCData.mat NCDataStrc IndexStrc -v7.3
save GroupNCDisData.mat LeftGroupNCVec RightGroupNCVec BetGroupNCMtx LeftGroupDisVec RightGroupDisVec BetGroupDisMtx -v7.3

%% Group wised NC distribution plot
BetGrNCdata = BetGroupNCVec;
WinGrNCdata = [LeftGroupNCVec;RightGroupNCVec];
[BetGrNCCumuDtn,Betx] = ecdf(BetGrNCdata);
[WinGrNCCumuDtn,Winx] = ecdf(WinGrNCdata);
p = ranksum(BetGrNCdata,WinGrNCdata);

hhh = figure;
hold on
hl1 = plot(Betx,BetGrNCCumuDtn,'m','lineWidth',1.8);
hl2 = plot(Winx,WinGrNCCumuDtn,'b','lineWidth',1.8);
set(gca,'xlim',[-1 1],'xtick',[-1,0,1],'ytick',[0 0.5 1]);
xlabel('Noise correlation coefficient');
ylabel('Cumulative fraction');
set(gca,'FontSize',18);
legend([hl1,hl2],{sprintf('BetGr, Mean = %.3f',mean(BetGrNCdata)),sprintf('WinGr, Mean = %.3f',mean(WinGrNCdata))},...
    'FontSize',10,'location','northwest');
text(0.5,0.3,sprintf('p = %.2e',p),'FontSize',12);
saveas(hhh,'Adjusted NC winthin and between Gr cumulative plot');
saveas(hhh,'Adjusted NC winthin and between Gr cumulative plot','png');
close(hhh);

%% summarization of all session results
clear
clc

%%
DataSum = {};
DataPath = {};
m = 1;
addchar = 'y';
BetGrNCall = [];
WinGrNCall = [];

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('GroupNCDisData.mat','Please select you group wised NC data');
    if ~fi
        continue;
    else
        cPath = fullfile(fp,fn);
        DataPath{m} = cPath;
        NCdataStrc = load(cPath);
        DataSum{m} = NCdataStrc;
        BetGrNCall = [BetGrNCall;NCdataStrc.BetGroupNCMtx(:)];
        WinGrNCall = [WinGrNCall;[NCdataStrc.LeftGroupNCVec;NCdataStrc.RightGroupNCVec]];
    end
    
    addchar = input('Would you like to add another session data?\n','s');
    m = m + 1;
end

%%
m = m - 1;
SaveDirs = uigetdir(pwd,'Please select the data save path for summarized data');
cd(SaveDirs);
fid = fopen('Adjust_NC_session_data_path.txt','w');
fprintf(fid,'The session path for all used sessions:\r\n');
fForm = '%s;\r\n';
for njhu = 1 : m
    fprintf(fid,fForm,DataPath{njhu});
end
fclose(fid);
save AdjustNCGrSave.mat DataPath DataSum BetGrNCall WinGrNCall -v7.3

%% plots of all summarized data set
BetGrNCdata = BetGrNCall;
WinGrNCdata = WinGrNCall;
[BetGrNCCumuDtn,Betx] = ecdf(BetGrNCdata);
[WinGrNCCumuDtn,Winx] = ecdf(WinGrNCdata);
p = ranksum(BetGrNCdata,WinGrNCdata);

hhh = figure;
hold on
hl1 = plot(Betx,BetGrNCCumuDtn,'m','lineWidth',1.8);
hl2 = plot(Winx,WinGrNCCumuDtn,'b','lineWidth',1.8);
set(gca,'xlim',[-1 1],'xtick',[-1,0,1],'ytick',[0 0.5 1]);
xlabel('Noise correlation coefficient');
ylabel('Cumulative fraction');
set(gca,'FontSize',18);
legend([hl1,hl2],{sprintf('BetGr, Mean = %.3f',mean(BetGrNCdata)),sprintf('WinGr, Mean = %.3f',mean(WinGrNCdata))},...
    'FontSize',10,'location','northwest');
text(0.5,0.3,sprintf('p = %.2e',p),'FontSize',12);
saveas(hhh,'Adjusted NC Gr cumulative plot summary');
saveas(hhh,'Adjusted NC Gr cumulative plot summary','png');
% close(hhh);

%% barplots for four different conditions
% for adjusted NC data savage
% load task data
[TaskNCfn,TaskNCfp,TaskNCfi] = uigetfile('AdjustNCGrSave.mat','Please select the sunmarized task NC data');
TaskNCdataStrc = load(fullfile(TaskNCfp,TaskNCfn));
cd(TaskNCfp);
TaskNCdataBet = TaskNCdataStrc.BetGrNCall;
TaskNCdataWin = TaskNCdataStrc.WinGrNCall;

% load passive data
[PassNCfn,PassNCfp,PassNCfi] = uigetfile('AdjustNCGrSave.mat','Please select the sunmarized passive NC data');
PassNCdataStrc = load(fullfile(PassNCfp,PassNCfn));
PassNCdataBet = PassNCdataStrc.BetGrNCall;
PassNCdataWin = PassNCdataStrc.WinGrNCall;

%%
%% barplots for four different conditions
% for normal NC data savage
% load task data
[TaskNCfn,TaskNCfp,TaskNCfi] = uigetfile('GroupWise_NCsave.mat','Please select the sunmarized task NC data');
TaskNCdataStrc = load(fullfile(TaskNCfp,TaskNCfn));
cd(TaskNCfp);
TaskNCdataBet = TaskNCdataStrc.BetLRROINCall;
TaskNCdataWin = [TaskNCdataStrc.LeftROINCall;TaskNCdataStrc.RightROINCall];

% load passive data
[PassNCfn,PassNCfp,PassNCfi] = uigetfile('PassDataSave.mat','Please select the sunmarized passive NC data');
PassNCdataStrc = load(fullfile(PassNCfp,PassNCfn));
try
    PassNCdataBet = PassNCdataStrc.BetDataAll;
    PassNCdataWin = [PassNCdataStrc.LeftDataAll;PassNCdataStrc.LeftDataAll;RightDataAll];
catch
    PassNCdataBet = cell2mat(PassNCdataStrc.PassNCGroupDataBet);
    PassNCdataWin = [cell2mat(PassNCdataStrc.PassNCGroupDataLeft);cell2mat(PassNCdataStrc.PassNCGroupDataRight)];
end

%%
MeanNCData = [mean(TaskNCdataBet),mean(TaskNCdataWin),mean(PassNCdataBet),mean(PassNCdataWin)];
hBarPlot = figure('position',[500 300 980 800]);
hold on
hTaskNCBet = bar(1,mean(TaskNCdataBet),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','none');
hTaskNCWin = bar(2,mean(TaskNCdataWin),0.3,'FaceColor',[.2 .2 .2],'EdgeColor','none');
hPassNCBet = bar(3,mean(PassNCdataBet),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','none');
hPassNCWin = bar(4,mean(PassNCdataWin),0.3,'FaceColor',[.2 .2 .2],'EdgeColor','none');
p_TaskBet_PassBet = ranksum(TaskNCdataBet,PassNCdataBet);
p_TaskBet_TaskWin = ranksum(TaskNCdataBet,TaskNCdataWin);
p_TaskWin_PassWin = ranksum(TaskNCdataWin,PassNCdataWin);
p_PassBet_PassWin = ranksum(PassNCdataBet,PassNCdataWin);
hhf = GroupSigIndication([1,3],[mean(TaskNCdataBet),mean(PassNCdataBet)],p_TaskBet_PassBet,hBarPlot,[],mean(TaskNCdataWin));
hhf = GroupSigIndication([1,2],[mean(TaskNCdataBet),mean(TaskNCdataWin)],p_TaskBet_TaskWin,hhf,1.2);
hhf = GroupSigIndication([2,4],[mean(TaskNCdataWin),mean(PassNCdataWin)],p_TaskWin_PassWin,hhf,1.25);
hhf = GroupSigIndication([3,4],[mean(PassNCdataBet),mean(PassNCdataWin)],p_PassBet_PassWin,hhf,1.4);
text([1,2,3,4],MeanNCData*1.01,cellstr(num2str(MeanNCData(:),'%.3f')),'HorizontalAlignment','center','FontSize',16);
set(gca,'xtick',[1,2,3,4],'xticklabel',{'Bet','Win','Bet','Win'});
yscales = get(gca,'ylim');
set(gca,'ytick',yscales(1):0.1:yscales(2));
ylabel({'Mean';'Noise correlation coeficient value'});
set(gca,'FontSize',18);
text(1.5,-0.02,'Task','FontSize',14,'HorizontalAlignment','center');
text(3.5,-0.02,'Passive','FontSize',14,'HorizontalAlignment','center');
saveas(hhf,'Task Passive compare bar plot');
saveas(hhf,'Task Passive compare bar plot','png');
saveas(hhf,'Task Passive compare bar plot','pdf'); % saved in pdf and then will be able to open in illustrator directlly
