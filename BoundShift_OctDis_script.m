clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end
%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);

PreferRandDisSum = {};
m = 1;
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    
    % passive tuning frequency colormap plot
    load(fullfile(tline,'Tunning_fun_plot_New1s_Minmax','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s_Minmax'));
    
    %     BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    %     if isempty(BehavBoundData)
    try
        BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
        BehavBoundData = BehavBoundfile.boundary_result.FitModelAll{1}{2}.ffit.u - 1;
    catch
        cd(tline);
        load(fullfile(tline,'CSessionData.mat'),'behavResults');
        rand_plot(behavResults,4,[],1);
        BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
        BehavBoundData = BehavBoundfile.boundary_result.FitModelAll{1}{2}.ffit.u - 1;
    end

    %  ######################################################################################
    % extract passive session maxium responsive frequency index
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    PassUsedOctave = UsedOctave(:);
%     if size(PassTunningfun,2) > size(DisMatrix,2)
%         PassROIUsedInds = 1:size(DisMatrix,2);
%     else
%         PassROIUsedInds = 1:size(PassTunningfun,2);
%     end
    PassUsedOctaveData = PassTunningfun(UsedOctaveInds,:);
    nROIs = size(PassUsedOctaveData,2);
    [MaxAmp,PassmaxInds] = max(PassUsedOctaveData);
    PassMaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        PassMaxIndsOctave(cROI) = PassUsedOctave(PassmaxInds(cROI));
    end
    
    % extract task session maxium responsive frequency index
    % UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    TaskUsedOctave = TaskFreqOctave(:);
    %     UsedOctave = UsedOctave(:);
    UsedOctaveData = CorrTunningFun;
%     UsedOctaveData = NonMissTunningFun;
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,TaskmaxInds] = max(UsedOctaveData);
    TaskMaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        TaskMaxIndsOctave(cROI) = TaskUsedOctave(TaskmaxInds(cROI));
    end
    UsedROIInds = min(numel(PassMaxIndsOctave),numel(TaskMaxIndsOctave));
    
    PassModeInds = [mode(PassMaxIndsOctave(1:UsedROIInds)),mean(PassMaxIndsOctave(1:UsedROIInds)),BehavBoundData];
    TaskModeInds = [mode(TaskMaxIndsOctave(1:UsedROIInds)),mean(TaskMaxIndsOctave(1:UsedROIInds)),BehavBoundData];
    Task2PassDiff = TaskMaxIndsOctave(1:UsedROIInds) - PassMaxIndsOctave(1:UsedROIInds); % signed distance
    
    PreferRandDisSum{m,1} = PassModeInds;
    PreferRandDisSum{m,2} = TaskModeInds;
    PreferRandDisSum{m,3} = Task2PassDiff;
    PreferRandDisSum{m,4} = TaskMaxIndsOctave;
    PreferRandDisSum{m,5} = PassMaxIndsOctave;
    %
    tline = fgetl(fid);
    m = m + 1;
end

%%
cd('E:\DataToGo\data_for_xu\BoundShiftData');
save PreferDisSaveModified_NewBlock.mat PreferRandDisSum -v7.3
% load('E:\DataToGo\data_for_xu\BoundShiftData\SessBlockBoundData.mat');
Numbers = xlsread('E:\DataToGo\data_for_xu\BoundShiftData\BoundShift_NewBlock_TypeInds\NewBlock_TypeInds.xlsx');

%%
ShapedBlockInds = logical(reshape(SessBlockBound',[],1));

%%
TaskSessAll = PreferRandDisSum(:,2);
LowSessData = cell2mat(TaskSessAll(~ShapedBlockInds));
HighSessData = cell2mat(TaskSessAll(ShapedBlockInds));

LowSessModeDiff = abs(LowSessData(:,1) - LowSessData(:,3));
LowSessModeHighDiff = abs(LowSessData(:,1) - HighSessData(:,3));
LowSessMeanDiff = abs(LowSessData(:,2) - LowSessData(:,3));
LowSessMeanHighDiff = abs(LowSessData(:,2) - HighSessData(:,3));


HighSessModeDiff = abs(HighSessData(:,1) - HighSessData(:,3));
HighSessModeLowDiff = abs(HighSessData(:,1) - LowSessData(:,3));
HighSessMeanDiff = abs(HighSessData(:,2) - HighSessData(:,3));
HighSessMeanLowDiff = abs(HighSessData(:,2) - LowSessData(:,3));

%%
PassSessAll = PreferRandDisSum(:,1);
LowSessPassData = cell2mat(PassSessAll(~ShapedBlockInds));
HighSessPassData = cell2mat(PassSessAll(ShapedBlockInds));

LowSess2BoundDisMode = abs(LowSessPassData(:,1) - LowSessPassData(:,3));
LowSess2BoundDisMean = abs(LowSessPassData(:,2) - LowSessPassData(:,3));

HighSess2BoundDisMode = abs(HighSessPassData(:,1) - HighSessPassData(:,3));
HighSess2BoundDisMean = abs(HighSessPassData(:,2) - HighSessPassData(:,3));



%%
TaskDiffAll = PreferRandDisSum(:,3);
UsedTaskDiffAll = cell(length(TaskDiffAll),1);
nSessAll = length(TaskDiffAll);
for cSess = 1 : nSessAll/2
    FormerSess = (cSess - 1) * 2 + 1;
    PostSessInds = cSess * 2;
    FormerSessData = TaskDiffAll{FormerSess};
    PostSessData = TaskDiffAll{PostSessInds};
    UsedROIInds = min(numel(FormerSessData),numel(PostSessData));
    UsedTaskDiffAll{FormerSess} = FormerSessData(1:UsedROIInds);
    UsedTaskDiffAll{PostSessInds} = PostSessData(1:UsedROIInds);
end

LowTaskDiffChange = cell2mat(UsedTaskDiffAll(~ShapedBlockInds));
HighTaskDiffChange = cell2mat(UsedTaskDiffAll(ShapedBlockInds));
ExInds = abs(LowTaskDiffChange) < 0.1 & abs(HighTaskDiffChange) < 0.1;

[LowDiffy,LowDiffx] = hist(LowTaskDiffChange(~ExInds),20);
[HighDiffy,HighDiffx] = hist(HighTaskDiffChange(~ExInds),20);
hf = figure;
hold on;
plot(LowDiffx,LowDiffy,'b','linewidth',1.4);
plot(HighDiffx,HighDiffy,'r','linewidth',1.4);

%%
SessTaskOctaveAll = reshape(PreferRandDisSum(:,4),2,[]);
SessPassOctaveAll = reshape(PreferRandDisSum(:,5),2,[]);
SessROIsAll = cellfun(@length,SessTaskOctaveAll);
UsedROIInds = num2cell(repmat(min(SessROIsAll),2,1));
UsedTaskDataAll = cellfun(@(x,y) x(1:y),SessTaskOctaveAll,UsedROIInds,'UniformOutput',false);
UsedPassDataAll = cellfun(@(x,y) x(1:y),SessPassOctaveAll,UsedROIInds,'UniformOutput',false);
UsedTaskDataAlls = UsedTaskDataAll(:);
UsedPassDataAlls = UsedPassDataAll(:);
ShapedBlockInds = logical(reshape(SessBlockBound',[],1));

LowSessDataCell = UsedTaskDataAlls(~ShapedBlockInds);
LowSessData = cell2mat(LowSessDataCell);
HighSessDataCell = UsedTaskDataAlls(ShapedBlockInds);
HighSessData = cell2mat(HighSessDataCell);

LowPassSessData = cell2mat(UsedPassDataAlls(~ShapedBlockInds));
HighPassSessData = cell2mat(UsedPassDataAlls(ShapedBlockInds));
%% Session Avg octave compare plots
LowSessAvgOct = cellfun(@mean,LowSessDataCell);
HighSessAvgOct = cellfun(@mean,HighSessDataCell);
CompareScatterPlot(LowSessAvgOct,HighSessAvgOct);

%% compare single ROI BF distribution for low and high boundary blocks
SessTypeInds = Numbers;
LowSessInds = SessTypeInds(:,1) + 1;
ROIBFAlls = PreferRandDisSum(:,4:5);
TaskBFsAll = (reshape(ROIBFAlls(:,1),2,[]))';
PassBFsAll = (reshape(ROIBFAlls(:,2),2,[]))';


nSess = size(ROIBFAlls,1)/2;
LowSessBFs = cell(nSess,2); % first column is task, second column is passive
HighSessBFs = cell(nSess,2);
for css = 1 : nSess
    LowSessBFs(css,1) = TaskBFsAll(css,LowSessInds(css));
    HighSessBFs(css,1) = TaskBFsAll(css,3-LowSessInds(css));
    
    LowSessBFs(css,2) = PassBFsAll(css,LowSessInds(css));
    HighSessBFs(css,2) = PassBFsAll(css,3-LowSessInds(css));
end
%%
cSess = 12;
close
cSessLowBFs = TaskBFsAll{cSess,SessTypeInds(cSess,1)+1};
cSessHighBFs = TaskBFsAll{cSess,2-SessTypeInds(cSess,1)};
[Lowy,Lowx] = ecdf(cSessLowBFs);
[Highy,Highx] = ecdf(cSessHighBFs);
figure;
hold on
plot(Lowx,Lowy,'b');
plot(Highx,Highy,'r');

