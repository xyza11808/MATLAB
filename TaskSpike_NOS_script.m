% task spike data noise correlation group-wise save
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the file contains all session path to be analized');
if ~fi
    return;
end
Sessionfilepath = fullfile(fp,fn);
fid = fopen(Sessionfilepath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    SpikeNOSpath = strrep(tline,'\Group_NC_cumulativePlot\RespGroupNCData.mat;','\spikeData\Popu_Corrcoef_save_NOS\TimeScale 0_1500ms noise correlation');
    if ~isdir(SpikeNOSpath)
        SpikeNOSpath = strrep(tline,'\Group_NC_cumulativePlot\RespGroupNCData.mat;','\spikeData\Popu_Corrcoef_save_NOS\NOS');
    end
    SpikeNOSDataStrc = load(fullfile(SpikeNOSpath,'ROIModified_coefSaveMean.mat'));
    TaskIndexData = strrep(tline,'RespGroupNCData.mat;','RespGroupNCData.mat');
    TaskIndexStrc = load(TaskIndexData);
    
    SPNCdataMtx = squareform(SpikeNOSDataStrc.PairedROIcorr);
    TaskLeftIndex = TaskIndexStrc.LeftSigROIAUCIndex;
    TaskRightIndex = TaskIndexStrc.RightSigROIAUCIndex;
    TaskNosRespROIindex = TaskIndexStrc.NoiseRespROIInds;

    SPLeftNC = SPNCdataMtx(TaskLeftIndex,TaskLeftIndex);
    SPRightNC = SPNCdataMtx(TaskRightIndex,TaskRightIndex);
    SPBetNC = SPNCdataMtx(TaskLeftIndex,TaskRightIndex);
    SPNosRespNC = SPNCdataMtx(TaskNosRespROIindex,TaskNosRespROIindex);
    SPNosRespBetSigNC = SPNCdataMtx([TaskLeftIndex(:);TaskRightIndex(:)],TaskNosRespROIindex);

    SPLeftNCVec = SPLeftNC(logical(tril(ones(size(SPLeftNC)),-1)));
    SPRightVec = SPRightNC(logical(tril(ones(size(SPRightNC)),-1)));
    SPNosRespNCVec = SPNosRespNC(logical(tril(ones(size(SPNosRespNC)),-1)));
    SPBetNCVec = SPBetNC(:);
    SPNosRespBetSigNC = SPNosRespBetSigNC(:);
    
    cd(strrep(tline,'Group_NC_cumulativePlot\RespGroupNCData.mat;','\spikeData'));
%     cd('spikeData');
    save SPGrwiseDatasave.mat SPLeftNCVec SPRightVec SPNosRespNCVec SPBetNCVec SPNosRespBetSigNC -v7.3
    tline = fgetl(fid);
end

%% passive session spike data analysis
clear
clc
[Passfn,Passfp,Passfi] = uigetfile('*.txt','Please select passive session data path');
[fn,fp,fi] = uigetfile('*.txt','Please select the file contains all session path to be analized');
if ~Passfi
    return;
end
passid = fopen(fullfile(Passfp,Passfn));
tline = fgetl(passid);
TaskID = fopen(fullfile(fp,fn));
Taskline = fgetl(TaskID);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\Correlation_distance_coefPlot'))
        tline = fgetl(passid);
        Taskline = fgetl(TaskID);
        continue;
    end
    PassSPpath = strrep(tline,'Correlation_distance_coefPlot\DisNCData.mat;','SpikeData_analysis');
    cd(PassSPpath);
    TaskIndexPath = strrep(Taskline,';','');
    TaskIndexStrc = load(TaskIndexPath);
    
    TaskLeftIndex = TaskIndexStrc.LeftSigROIAUCIndex;
    TaskRightIndex = TaskIndexStrc.RightSigROIAUCIndex;
    TaskNosRespROIindex = TaskIndexStrc.NoiseRespROIInds;
    
    load('EsSpikeSave.mat');
    DataSPObj = DataAnalysisSum(nnspike,SelectSArray,frame_rate,frame_rate,1);
    DataSPObj.popuZscoredCorr(0.5,'Mean'); % first response peak response noise correlation
    PassSPNOSdata = load('.\Popu_Corrcoef_save_NOS\TimeScale 0_500ms noise correlation\ROIModified_coefSaveMean.mat');
    PassSPNCdataMtx = squareform(PassSPNOSdata.PairedROIcorr);
    
    PassSPLeftNC = PassSPNCdataMtx(TaskLeftIndex,TaskLeftIndex);
    PassSPRightNC = PassSPNCdataMtx(TaskRightIndex,TaskRightIndex);
    PassSPBetNC = PassSPNCdataMtx(TaskLeftIndex,TaskRightIndex);
    PassSPNosRespNC = PassSPNCdataMtx(TaskNosRespROIindex,TaskNosRespROIindex);
    PassSPNosRespBetSigNC = PassSPNCdataMtx([TaskLeftIndex(:);TaskRightIndex(:)],TaskNosRespROIindex);

    PassSPLeftNCVec = PassSPLeftNC(logical(tril(ones(size(PassSPLeftNC)),-1)));
    PassSPRightVec = PassSPRightNC(logical(tril(ones(size(PassSPRightNC)),-1)));
    PassSPNosRespNCVec = PassSPNosRespNC(logical(tril(ones(size(PassSPNosRespNC)),-1)));
    PassSPBetNCVec = PassSPBetNC(:);
    PassSPNosRespBetSigNC = PassSPNosRespBetSigNC(:);
    
    save PassSPGrwiseNOSsave.mat PassSPLeftNCVec PassSPRightVec PassSPNosRespNCVec PassSPBetNCVec PassSPNosRespBetSigNC -v7.3
    tline = fgetl(passid);
    Taskline = fgetl(TaskID);
end

%%
clear
clc
TaskSPNCall = struct('SPwinNCAll',[],'SPbetNCAll',[],'SPNonrespNCAll',[],'SPNR2SigNCAll',[]);
PassSPNCall = struct('SPwinNCAll',[],'SPbetNCAll',[],'SPNonrespNCAll',[],'SPNR2SigNCAll',[]);
[Passfn,Passfp,Passfi] = uigetfile('*.txt','Please select passive session data path');
[fn,fp,fi] = uigetfile('*.txt','Please select the file contains all session path to be analized');
Passid = fopen(fullfile(Passfp,Passfn));
Passline = fgetl(Passid);
Taskid = fopen(fullfile(fp,fn));
Taskline = fgetl(Taskid);
while ischar(Passline)
    if isempty(strfind(Passline,'Correlation_distance_coefPlot\DisNCData.mat;'))
        Passline = fgetl(Passid);
        Taskline = fgetl(Taskid);
        continue;
    end
    PassSPNCdata = load(strrep(Passline,'Correlation_distance_coefPlot\DisNCData.mat;',...
        'SpikeData_analysis\PassSPGrwiseNOSsave.mat'));
    TaskSPNCdata = load(strrep(Taskline,'Group_NC_cumulativePlot\RespGroupNCData.mat;',...
        'SpikeData\SPGrwiseDatasave.mat'));
    PassSPNCall.SPwinNCAll = [PassSPNCall.SPwinNCAll;[PassSPNCdata.PassSPLeftNCVec;PassSPNCdata.PassSPRightVec]];
    PassSPNCall.SPbetNCAll = [PassSPNCall.SPbetNCAll;PassSPNCdata.PassSPBetNCVec];
    PassSPNCall.SPNonrespNCAll = [PassSPNCall.SPNonrespNCAll;PassSPNCdata.PassSPNosRespNCVec];
    PassSPNCall.SPNR2SigNCAll = [PassSPNCall.SPNR2SigNCAll;PassSPNCdata.PassSPNosRespBetSigNC];
    
    TaskSPNCall.SPwinNCAll = [TaskSPNCall.SPwinNCAll;[TaskSPNCdata.SPLeftNCVec;TaskSPNCdata.SPRightVec]];
    TaskSPNCall.SPbetNCAll = [TaskSPNCall.SPbetNCAll;TaskSPNCdata.SPBetNCVec];
    TaskSPNCall.SPNonrespNCAll = [TaskSPNCall.SPNonrespNCAll;TaskSPNCdata.SPNosRespNCVec];
    TaskSPNCall.SPNR2SigNCAll = [TaskSPNCall.SPNR2SigNCAll;TaskSPNCdata.SPNosRespBetSigNC];
    
    Passline = fgetl(Passid);
    Taskline = fgetl(Taskid);
end

%%
SavePath = uigetdir(pwd,'Please select one path to save current summary data');
cd(SavePath);
save TaskPassSPNCsum.mat PassSPNCall TaskSPNCall -v7.3

%%
TaskDataSum = TaskSPNCall;
PassDataSum = PassSPNCall;
TaskMeanAll = [mean(TaskDataSum.SPwinNCAll,'omitnan'),mean(TaskDataSum.SPbetNCAll,'omitnan'),mean(TaskDataSum.SPNonrespNCAll,'omitnan'),...
    mean(TaskDataSum.SPNR2SigNCAll,'omitnan')];
PassMeanAll = [mean(PassDataSum.SPwinNCAll,'omitnan'),mean(PassDataSum.SPbetNCAll,'omitnan'),mean(PassDataSum.SPNonrespNCAll,'omitnan'),...
    mean(PassDataSum.SPNR2SigNCAll,'omitnan')];
habr = figure('position',[250 300 900 600]);
hold on;
bar([0.8,1.8,2.8,3.8],TaskMeanAll,0.4,'FaceColor','k','EdgeColor','none');
bar([1.2,2.2,3.2,4.2],PassMeanAll,0.4,'FaceColor',[.7 .7 .7],'EdgeColor','none');
text([0.8,1.8,2.8,3.8],TaskMeanAll*1.05,cellstr(num2str(TaskMeanAll(:),'%.3f')),'FontSize',12,'HorizontalAlignment','center');
text([1.2,2.2,3.2,4.2],PassMeanAll*1.05,cellstr(num2str(PassMeanAll(:),'%.3f')),'FontSize',12,'HorizontalAlignment','center','color',[.5 .5 .5]);
set(gca,'xtick',[1,2,3,4],'xticklabel',{'Win','Bet','NonSelc','Non2Sig'});
xlabel('Group');
ylabel('Noise correlation');
title('Task(k) and passive(gray) NC comparison');
set(gca,'FontSize',16);
p_Win_TaskPass = ranksum(TaskDataSum.SPwinNCAll,PassDataSum.SPwinNCAll);
p_Bet_TaskPass = ranksum(TaskDataSum.SPbetNCAll,PassDataSum.SPbetNCAll);
p_NonResp_TaskPass = ranksum(TaskDataSum.SPNonrespNCAll,PassDataSum.SPNonrespNCAll);
p_NonR2Sig = ranksum(PassDataSum.SPNR2SigNCAll,TaskDataSum.SPNR2SigNCAll);
hbarf = GroupSigIndication([0.8,1.2],[TaskMeanAll(1),PassMeanAll(1)],p_Win_TaskPass,habr,[],0.3);
hbarf = GroupSigIndication([1.8,2.2],[TaskMeanAll(2),PassMeanAll(2)],p_Bet_TaskPass,hbarf,1.2);
hbarf = GroupSigIndication([2.8,3.2],[TaskMeanAll(3),PassMeanAll(3)],p_NonResp_TaskPass,hbarf,1.2);
hbarf = GroupSigIndication([3.8,4.2],[TaskMeanAll(4),PassMeanAll(4)],p_NonR2Sig,hbarf,1.2);
saveas(hbarf,'Task and passive compare plot');
saveas(hbarf,'Task and passive compare plot','png');
saveas(hbarf,'Task and passive compare plot','pdf');
close(hbarf);
