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
m = 1;
SessModuInds = {};
SessFluoValue = {};
SessPassUsedInds = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    
    % passive tuning frequency colormap plot
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    load(fullfile(tline,'CSessionData.mat'),'behavResults','smooth_data','start_frame','frame_rate');
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
%     RespDataStrc = load(fullfile(pwd,'Curve fitting plots','NewCurveFitsave.mat'));
%     RespInds = RespDataStrc.ROIisResponsive;
%     ROI_IsSigResp_script

    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1.1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    PassUsedOctave = UsedOctave(:);
    PassUsedOctData = PassTunningfun(UsedOctaveInds,:);
    nROIs = size(PassUsedOctData,2);
    
    TaskUsedOctave = TaskFreqOctave(:);
%     TaskUsedOctave = TaskUsedOctave(:);
    TaskUsedOctData = CorrTunningFun;
    
%     TaskNorData = zscore(TaskUsedOctData);
%     PassNorData = zscore(PassUsedOctData);
    
    disp(TaskUsedOctave');
    disp(PassUsedOctave');
    PassUsedIndsStr = input('Please select the passive octave used Inds:\n','s');
    PassUsedInds = str2num(PassUsedIndsStr);
    if isempty(PassUsedInds)
        tline = fgetl(fid);
        m = m + 1;
        continue;
    else
        PassUsedOctave = PassUsedOctave(PassUsedInds);
        PassUsedOctData = PassUsedOctData(PassUsedInds,:);
        SessPassUsedInds{m} = PassUsedInds;
    end
    [~,TaskInds] = min(abs(TaskUsedOctave - BehavBoundData));
    TaskCloseData = TaskUsedOctData(TaskInds,:);
    [~,PassInds] = min(abs(PassUsedOctave - BehavBoundData));
    PassCloseData = PassUsedOctData(PassInds,:);
    
    ModuInds = (TaskCloseData - PassCloseData)./(abs(PassCloseData)+abs(TaskCloseData));
    SessModuInds{m} = ModuInds;
    SessFluoValue{m} = max([TaskCloseData(:),PassCloseData(:)],[],2);
    %
    tline = fgetl(fid);
    m = m + 1;
end

%%
figure;
hold on
plot(PassUsedOctave,TaskNorData(:,4),'-o','Color',[1 0.7 0.2])
plot(TaskUsedOctave,PassNorData(:,4),'-o','Color','k')
