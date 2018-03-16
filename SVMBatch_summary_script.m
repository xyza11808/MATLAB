clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
[Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
%%

fpath = fullfile(fp,fn);
PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
PassLine = fgetl(PassFid);
cSess = 1;
TaskErrorsAll = {};
TaskNBErrorsAll = {};
TaskStimErrorAll = {};
TaskNBStimErrorAll = {};
PassErroAll = {};
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
       PassLine = fgetl(PassFid);
        continue;
    end
    
    TaskNBDataPath = fullfile(tline,'NoBoundSVMAccuracy.mat');
    TaskDataPath = fullfile(tline,'SVMAccuracy.mat');
    TaskDataStrc = load(TaskDataPath); %save NoBoundSVMAccuracy.mat StimBasedRProb ChoiceBasedRProb CorrBasedRProb StimTypes
    TaskNBDataStrc = load(TaskNBDataPath); 
    TaskOctaves = log2(TaskDataStrc.StimTypes/16000);
    % all ROI data
    TaskStimErro = TaskDataStrc.StimBasedRProb;
    GrNum = floor(length(TaskOctaves)/2);
    TaskStimErro(GrNum+1:end) = 1 - TaskStimErro(GrNum+1:end);
    TaskChoiceErro = TaskDataStrc.ChoiceBasedRProb;
    TaskChoiceErro(GrNum+1:end) = 1 - TaskChoiceErro(GrNum+1:end);
    TaskCorrErro = TaskDataStrc.CorrBasedRProb;
    TaskCorrErro(GrNum+1:end) = 1 - TaskCorrErro(GrNum+1:end);
    % no boundary tuning data
    TaskNBStimErro = TaskNBDataStrc.StimBasedRProb;
%     GrNum = floor(length(TaskNBOctaves)/2);
    TaskNBStimErro(GrNum+1:end) = 1 - TaskNBStimErro(GrNum+1:end);
    TaskNBChoiceErro = TaskNBDataStrc.ChoiceBasedRProb;
    TaskNBChoiceErro(GrNum+1:end) = 1 - TaskNBChoiceErro(GrNum+1:end);
    TaskNBCorrErro = TaskNBDataStrc.CorrBasedRProb;
    TaskNBCorrErro(GrNum+1:end) = 1 - TaskNBCorrErro(GrNum+1:end);
    TaskErrorsAll{cSess} = [mean(TaskStimErro),mean(TaskChoiceErro),mean(TaskCorrErro)];
    TaskNBErrorsAll{cSess} = [mean(TaskNBStimErro),mean(TaskNBChoiceErro),mean(TaskNBCorrErro)];
    disp((TaskDataStrc.StimTypes(:))');
    UsedIndsTr = input('Please input the used task inds:\n','s');
    UsedInds = str2num(UsedIndsTr);
    TaskStimErrorAll{cSess} = reshape(TaskStimErro(UsedInds),1,[]);
    TaskNBStimErrorAll{cSess} = reshape(TaskNBStimErro(UsedInds),1,[]);
    
    %
    PassNBPath = fullfile(PassLine,'NoBoundPassSVMSave.mat');  %save NoBoundPassSVMSave.mat StimBasedRProb StimTypes -v7.3
    PassPath = fullfile(PassLine,'PassSVMSave.mat');  %save NoBoundPassSVMSave.mat StimBasedRProb StimTypes -v7.3
    PasssDataStrc = load(PassPath);
    PasssNBDataStrc = load(PassNBPath);
    PassShiftStims = PasssDataStrc.StimTypes > 16000;
    PassErro = PasssDataStrc.StimBasedRProb;
    PassErro(PassShiftStims) = 1 - PassErro(PassShiftStims);
    PassNBErro = PasssNBDataStrc.StimBasedRProb;
    PassNBErro(PassShiftStims) = 1 - PassNBErro(PassShiftStims);
    PassErroAll{cSess} = [mean(PassErro),mean(PassNBErro)];
    
     %
    tline = fgetl(ff);
    PassLine = fgetl(PassFid);
    cSess = cSess + 1;
end

%% plot the overall accuracy
TaskErroMtx = cell2mat(TaskErrorsAll');
TaskNBErroMtx = cell2mat(TaskNBErrorsAll');
TaskStimErrorMtx = cell2mat(TaskStimErrorAll');
TaskNBStimErrorMtx = cell2mat(TaskNBStimErrorAll');
nSess = length(TaskStimErrorMtx);
[~,pp] = ttest(TaskErroMtx(:,1),TaskNBErroMtx(:,1));
AllAvgData = [TaskErroMtx(:,1),TaskNBErroMtx(:,1)];
[~,pAll] = ttest(TaskStimErrorMtx,TaskNBStimErrorMtx);
TaskStimErrorAvg = mean(TaskStimErrorMtx);
TaskStimErrorSem = std(TaskStimErrorMtx)/sqrt(nSess);
TaskNBStimErrorAvg = mean(TaskNBStimErrorMtx);
TaskNBStimErrorSem = std(TaskNBStimErrorMtx)/sqrt(nSess);

hf = figure('position',[100 100 720 300]);
hold on
plot([0.8 1.2],([TaskErroMtx(:,1),TaskNBErroMtx(:,1)])','Color',[.7 .7 .7],'linewidth',1);
errorbar([0.8 1.2],mean(AllAvgData),std(AllAvgData)/sqrt(nSess),'k-o','linewidth',1.6);
hf = GroupSigIndication([0.8 1.2],[max(TaskErroMtx(:,1)),max(TaskNBErroMtx(:,1))],pp,hf);
for cts = 1 : size(TaskStimErrorMtx,2)
    plot([0.8 1.2]+cts,([TaskStimErrorMtx(:,cts),TaskNBStimErrorMtx(:,cts)])','Color',[.7 .7 .7],'linewidth',1);
    errorbar([0.8 1.2]+cts,[TaskStimErrorAvg(cts),TaskNBStimErrorAvg(cts)],[TaskStimErrorSem(cts),TaskNBStimErrorSem(cts)],...
        'k-o','linewidth',1.6);
    hf = GroupSigIndication([0.8 1.2]+cts,[max(TaskStimErrorMtx(:,cts)),max(TaskNBStimErrorMtx(:,cts))],pAll(cts),hf);
end
set(gca,'xlim',[0 8],'xtick',1:7,'xticklabel',{'AllAvg','8kHz','10.6kHz','13.9kHz','18.4kHz','24.3kHz','32kHz'});
set(gca,'ylim',[-0.05 1],'yTick',[0 0.5 1]);
ylabel('Error rate');
title('Error rate');
set(gca,'FontSize',12);

saveas(hf,'OverSum compare plot save');
saveas(hf,'OverSum compare plot save','png');
