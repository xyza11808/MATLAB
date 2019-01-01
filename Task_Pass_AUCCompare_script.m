cclr
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessPathAll = {};
m = 1;
while ischar(tline)
    
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        
        [~,EndInds] = regexp(tline,'test\d{2,3}');
        cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');
        
        [~,InfoDataEndInds] = regexp(tline,'result_save');
        PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
        SessPathAll{m,2} = PassPathline;
        
        m = m + 1;
    end
    tline = fgetl(fid);
end

%% Task and passive AUC compare script
Sess8_32PathAll = SessPathAll(:,1);
Sess8_32PassPathAll = SessPathAll(:,2);

NumPaths = length(Sess8_32PathAll);
SourceUpperPath = 'D:\Test\Temp';
%
for cPath = 4 : NumPaths
    %
    
    c832Path = Sess8_32PathAll{cPath};
    c832PassPath = Sess8_32PassPathAll{cPath};
    cd(c832Path);
    
    TSourceFolder = fullfile(SourceUpperPath,c832Path(4:end),'UsedROI_AUC');
    TTargFolder = fullfile(c832Path,'UsedROI_AUC');
    copyfile( TSourceFolder, TTargFolder, 'f');
    
    PSourceFolder = fullfile(SourceUpperPath,c832PassPath(4:end),'UsedROI_AUC');
    PTargFolder = fullfile(c832PassPath,'UsedROI_AUC');
    copyfile(PSourceFolder, PTargFolder, 'f');
    
    
%     Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
%     IndexCopyfile = fullfile(SourceUpperPath,Sess832ROIIndexFile(4:end));
%     if exist(Sess832ROIIndexFile,'file')
%         cSess832DataStrc = load(Sess832ROIIndexFile);
%         CommonROINum = min(numel(cSess832DataStrc.ROIIndex));
%         CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum);
%     else
%         CommonROINum = size(data_aligned,2);
%         CommonROIIndex = true(CommonROINum,1);
%     end
%     UsedROIInds = CommonROIIndex;
%     
%     Sess832Behavfile = fullfile(c832Path,'RandP_data_plots','boundary_result.mat');
%     BehavTargPath = fullfile(SourceUpperPath,c832Path(4:end),'RandP_data_plots','boundary_result.mat');
%     mkdir(fullfile(SourceUpperPath,c832Path(4:end),'RandP_data_plots'));
%     copyfile(Sess832Behavfile,BehavTargPath,'f');
% %     TaskSessAUCFile = fullfile(c832Path,'Stim_time_Align','ROC_Left2Right_result','ROC_score.mat');
%     
%     SourPath = fullfile(c832Path,'CSessionData.mat');
%     TargetPath = fullfile(SourceUpperPath,c832Path(4:end),'CSessionData.mat');
%     mkdir(fullfile(SourceUpperPath,c832Path(4:end)));
%     copyfile(SourPath,TargetPath,'f');
%     mkdir(fullfile(SourceUpperPath,c832Path(4:end),'Tunning_fun_plot_New1s'));
%     copyfile(Sess832ROIIndexFile,IndexCopyfile,'f');
%     
%     PassDatafile = fullfile(c832PassPath,'rfSelectDataSet.mat');
%     TargetPassFile = fullfile(SourceUpperPath,PassDatafile(4:end));
%     mkdir(fullfile(SourceUpperPath,c832PassPath(4:end)));
%     copyfile(PassDatafile,TargetPassFile,'f');
%     
%      PassUsedIndsfile = fullfile(c832PassPath,'PassFreqUsedInds.mat');
%      PassTrIndsTarg = fullfile(SourceUpperPath,c832PassPath(4:end),'PassFreqUsedInds.mat');
%      mkdir(fullfile(SourceUpperPath,c832PassPath(4:end)));
%      copyfile(PassUsedIndsfile,PassTrIndsTarg,'f');
    %
end
%%
Sess8_32PathAll = SessPathAll(:,1);
Sess8_32PassPathAll = SessPathAll(:,2);

NumPaths = length(Sess8_32PathAll);
SessTPAUCAll = cell(NumPaths,2);
%
for cPath = 1 : NumPaths
    
    c832Path = Sess8_32PathAll{cPath};
    c832PassPath = Sess8_32PassPathAll{cPath};
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    if exist(Sess832ROIIndexFile,'file')
        cSess832DataStrc = load(Sess832ROIIndexFile);
        CommonROINum = min(numel(cSess832DataStrc.ROIIndex));
        CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum);
    else
        CommonROINum = size(data_aligned,2);
        CommonROIIndex = true(CommonROINum,1);
    end
    UsedROIInds = CommonROIIndex;
    
    TaskAUCfilePath = fullfile(c832Path,'UsedROI_AUC','Stim_time_Align','ROC_Left2Right_result','ROC_score.mat');
    TaskAUCfileStrc = load(TaskAUCfilePath);
    TROIAUCABS = TaskAUCfileStrc.ROCarea;
    TROIAUCABS(logical(TaskAUCfileStrc.ROCRevert)) = 1 - TROIAUCABS(logical(TaskAUCfileStrc.ROCRevert));
    
    ROIIndex = find(UsedROIInds);
    
    PassAUCfilePath = fullfile(c832PassPath,'UsedROI_AUC','Stim_time_Align_select','ROC_Left2Right_result','ROC_score.mat');
    PassAUCfileStrc = load(PassAUCfilePath);
    PROIAUCABS = PassAUCfileStrc.ROCarea;
    PROIAUCABS(logical(PassAUCfileStrc.ROCRevert)) = 1 - PROIAUCABS(logical(PassAUCfileStrc.ROCRevert));
    
    if length(TROIAUCABS) ~= length(PROIAUCABS)
        warning('Task and passive ROI number is not the same for session %d.\n',cPath);
    end
    SessTPAUCAll{cPath,1} = TROIAUCABS(:);
    SessTPAUCAll{cPath,2} = PROIAUCABS(:);
end

%%
SessTAUCAll = cell2mat(SessTPAUCAll(:,1));
SessPAUCAll = cell2mat(SessTPAUCAll(:,2));


