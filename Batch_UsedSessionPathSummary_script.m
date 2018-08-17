clear
clc

GrandPath = 'R:\batchData\batch53';
xpath = genpath(GrandPath);
nameSplit = (strsplit(xpath,';'))';
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);
PossibleInds = cellfun(@(x) strcmpi(x(end-12:end),'mode_f_change'),nameSplit);
PossDataPath = nameSplit(PossibleInds);
AllAlignedPInds = cellfun(@(x) strcmpi(x(end-14:end),'im_data_reg_cpu'),nameSplit);
AllAlignedPath = nameSplit(AllAlignedPInds);

ErrorProcessPath = {};
ErrorNum = 0;
ErrorMes = {};
NormSessPathTask = {};
NormSessPathPass = {};
NormSessPathNum = 0;

for cPosInds = 1 : sum(PossibleInds)
    [StartInds,EndInds] = regexp(PossDataPath{cPosInds},'test\d{2,3}');
    if isempty(StartInds)
        ErrorNum = ErrorNum + 1;
        ErrorMes{ErrorNum} = 'Failed to find the test session number for current session';
        ErrorProcessPath{ErrorNum} = PossDataPath{cPosInds};
        continue;
    end
    if EndInds-StartInds > 5
        EndInds = EndInds - 1; % in case of a repeated session sub imaging serial number
    end
    
    cPassDataUpperPath = fullfile(sprintf('%srf',PossDataPath{cPosInds}(1:EndInds)),'im_data_reg_cpu','result_save');
    if ~isdir(cPassDataUpperPath)
        ErrorNum = ErrorNum + 1;
        ErrorMes{ErrorNum} = 'Current session data haven''t been preprocessed';
        ErrorProcessPath{ErrorNum} = sprintf('%srf',PossDataPath{cPosInds}(1:EndInds));
        continue;
    end
        
    if ~isdir(fullfile(cPassDataUpperPath,'plot_save','NO_Correction'))
        cd(cPassDataUpperPath)
        post_ROI_calculation_ForBatch;
    end
    
    TaskPathline = PossDataPath{cPosInds};
    PassPathline = fullfile(cPassDataUpperPath,'plot_save','NO_Correction');
    NormSessPathNum = NormSessPathNum + 1;
    NormSessPathTask{NormSessPathNum} = TaskPathline;
    NormSessPathPass{NormSessPathNum} = PassPathline;
end

%%
nPossTaskPath = length(TaskData);
TaskProcessedPath = zeros(nPossTaskPath,1);
TaskDrawedPath = zeros(nPossTaskPath,1);
for cP = 1 : nPossTaskPath
    cPath = TaskData{cP};
    if isempty(strfind(cPath,'20171118')) && isempty(strfind(cPath,'20171117'))
        if isdir(fullfile(cPath,'result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change'))
            TaskProcessedPath(cP) = 1;
        elseif isdir(fullfile(cPath,'result_save'))
            TaskDrawedPath(cP) = 1;
        end
    end
end

%%
PathSaveFilenames = 'S:\BatchData\batch52\Batch52_usedSess_summaryAdd.txt';
PathSaveFnPass = 'S:\BatchData\batch52\Batch52_usedSess_summaryAdd_Pass.txt';
nPathNum = length(NormSessPathTask);
Taskfid = fopen(PathSaveFilenames,'w+');
Passfid = fopen(PathSaveFnPass,'w+');
StrFrmt = '%s\r\n';
fprintf(Taskfid,'%s\r\n','Task path summary:');
fprintf(Passfid,'%s\r\n','Passive path summary:');
for cp = 1 : nPathNum
    fprintf(Taskfid,StrFrmt,NormSessPathTask{cp});
    fprintf(Passfid,StrFrmt,NormSessPathPass{cp});
end
fclose(Taskfid);
fclose(Passfid);

%%
% session ROI tuning freq colorplot summary plot
nSess = length(NormSessPathTask);
close
cSess = 65;
if cSess <= nSess
    cSessPath = NormSessPathTask{cSess};
    cd(cSessPath);
    try
        Passfig = imread(fullfile(cSessPath,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','Passive top Prc100 colormap save.png'));
        Taskfig = imread(fullfile(cSessPath,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','Task top Prc100 colormap save.png')); 
        Psyfig = imread(fullfile(cSessPath,'RandP_data_plots','Behav_fit plot.png'));
        hf = figure('position',[100 100 1800 480]);
        subplot(131)
        imshow(Taskfig);
        title('Task');

        subplot(132)
        imshow(Passfig);
        title('Pass');

        subplot(133)
        imshow(Psyfig);
    catch ME
        
    end
end

%%
% batched ROI morph plot
nSessPath = length(NormSessPathPass);
for cSess = 1 : nSessPath
    %
    cSessPath = NormSessPathPass{cSess};
%     [~,EndInds] = regexp(cSessPath,'result_save');
%     tline = cSessPath(1:EndInds);
    %%
    [~,EndInds] = regexp(cSessPath,'result_save');
    ROIposfilePath = cSessPath(1:EndInds);
    cd(ROIposfilePath);
    if exist('./ROI_morph_plot/MorphDataAll.mat','file')
%         continue;
    end
    %     if exist(fullfile(ROIposfilePath,'ROI_morph_plot','MorphDataAll.mat'),'file')
    %         tline = fgetl(fid);
    %         continue;
    %     end

    ROIposfilePosi = dir(fullfile(ROIposfilePath,'ROIinfo*.mat'));
    load(ROIposfilePosi(1).name)
    if ~exist('ROIinfoBU','var')
        ROIinfoBU = ROIinfo(1);
    end
    load(fullfile(ROIposfilePath,'SessionFrameProj.mat'));

    % generate the maxdelta figure
    nTrs = length(FrameProjSave);
    FrameSize = size(FrameProjSave(1).MeanFrame);
    MeanFrameAll = zeros([nTrs,FrameSize]);
    MaxFrameAll = zeros([nTrs,FrameSize]);
    for nntr = 1 : nTrs
        cMeanFrame = double(FrameProjSave(nntr).MeanFrame);
        cMaxFrame = double(FrameProjSave(nntr).MaxFrame);
        MeanFrameAll(nntr,:,:) = cMeanFrame;
        MaxFrameAll(nntr,:,:) = cMaxFrame;
    end
    %
    SessMeanF = squeeze(mean(MaxFrameAll));
    SessMaxF = squeeze(max(MaxFrameAll));
    MaxDelta = SessMaxF - SessMeanF;

    % calculate the ROI display region
    nROIs = length(ROIinfoBU.ROIpos);
    ROIcenter = round(cell2mat((cellfun(@mean,ROIinfoBU.ROIpos,'uniformOutput',false))'));
    if length(ROIcenter) == numel(ROIcenter)
        ROIcenter = round(cell2mat(cellfun(@mean,ROIinfoBU.ROIpos,'uniformOutput',false)));
    end
    FrameSize = size(ROIinfoBU.ROImask{1});
    RegionSize = [];
    switch FrameSize(1)
        case 256
            RegionSize(1) = 20;
        case 512
            RegionSize(1) = 30;
        otherwise
            CusSize = input([sprintf('cFrame row number is %d, please input the ROI region size.',FrameSize(1)),'\n'],'s');
            RegionSize(1) = str2num(CusSize);
    end
    switch FrameSize(2)
        case 256
            RegionSize(2) = 20;
        case 512
            RegionSize(2) = 30;
        otherwise
            CusSize = input([sprintf('cFrame row number is %d, please input the ROI region size.',FrameSize(2)),'\n'],'s');
            RegionSize(2) = str2num(CusSize);
    end

    % generate the ROI data for each ROI
    % k = 1;
    if ~isdir('ROI_morph_plot')
        mkdir('ROI_morph_plot');
    end
    cd('ROI_morph_plot');
    ROIMorphData = cell(nROIs,2);
    for cROI = 1 : nROIs
        %
        cROIpos = ROIinfoBU.ROIpos{cROI}; % ROI edge position
        cROICen = ROIcenter(cROI,:);
        %
        xscales = cROICen(1) + ([-1,1]*RegionSize(1));
        ROIedgeShift_x = cROICen(1) - RegionSize(1);
        if xscales(1) < 1
            xscales(1) = 1;
            ROIedgeShift_x = 0;
        elseif xscales(2) > FrameSize(2)
            xscales(2) = FrameSize(2);
            %         ROIedgeShift_x = cROICen(1) - RegionSize(1);
        end
        %
        yscales = cROICen(2) + ([-1,1]*RegionSize(2));
        ROIedgeShift_y = cROICen(2) - RegionSize(2);
        if yscales(1) < 1
            yscales(1) = 1;
            ROIedgeShift_y = 0;
        elseif yscales(2) > FrameSize(1)
            yscales(2) = FrameSize(1);
        end
        ROISelectData = MaxDelta(yscales(1):yscales(2),xscales(1):xscales(2));
        ROImaxlim = prctile(ROISelectData(:),90);
        AdjROIpos = cROIpos - repmat([ROIedgeShift_x,ROIedgeShift_y],size(cROIpos,1),1);
        AdjROIcenter = mean(AdjROIpos);

        %    subplot(4,30,k)
        %
        hf = figure('visible','off');
        imagesc(ROISelectData,[0 ROImaxlim]);
        line(AdjROIpos(:,1),AdjROIpos(:,2),'Color','r','linewidth',1.6);
        text(AdjROIcenter(1),AdjROIcenter(2),num2str(cROI),'color','g');
        colormap gray;
        axis off
        saveas(hf,sprintf('ROI%d morph plot save',cROI));
        saveas(hf,sprintf('ROI%d morph plot save',cROI),'png');
        close(hf);
        %
        %    k = k + 1;
        ROIMorphData{cROI,1} = ROISelectData;
        ROIMorphData{cROI,2} = AdjROIpos;
    end
    save MorphDataAll.mat ROIMorphData -v7.3
    cd ..;
    %%
end