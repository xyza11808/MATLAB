% batch scripts for morphology and color-plot merge scripts
clear
clc

GrandPath = 'R:\batch\batch43';
xpath = genpath(GrandPath);
nameSplit = strsplit(xpath,';');
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);
%
TargetPath = {};
nTargetPath = 0;

ErrorSessPath = {};
nErrorSessNum = 0;
ErrorPathMessage = {};
%
for np = 1 : DirLength
    cPATH = nameSplit{np};
    try
%     if isempty(strfind(cPATH,'NO_Correction\Uneven_colorPlot')) || isempty(strfind(cPATH,'rf'))
    if ~strcmpi(cPATH(end-10:end),'result_save')  % have GUI analysis results 
        continue; % no target mat file at current path
    else
        if ~isempty(strfind(cPATH,'Uneven_colorPlot\Uneven_colorPlot')) %#ok<*STREMP>
            continue; % in case of a multiple-path during debugging process
        end
        %
%         SessRawDataInds = strfind(cPATH,'\result_save\plot_save');
%         cROIinfoPath = [cPATH(1:SessRawDataInds-1) filesep 'result_save'];  % path without '\'
%         cROIinfoPath = [cROIinfoPath filesep 'result_save'];
        cROIinfoPath = cPATH;
        ROIinfoStrc = dir([cROIinfoPath filesep 'ROIinfo*.mat']);
        FrameProjStrc = dir([cROIinfoPath filesep 'SessionFrameProj.mat']);
        if isempty(ROIinfoStrc) || isempty(FrameProjStrc)
            continue;
        end
        if length(ROIinfoStrc) > 1 % in case of both simple and full mat files both exists
            ROIinfoStrc = dir([cROIinfoPath filesep 'ROIinfoBU*.mat']);
            if isempty(ROIinfoStrc)
                continue;
            end
        end
        % in case there was an empty folder during code debugging process        
        if isdir([cROIinfoPath filesep 'ROI_morph_plot']) && exist([cROIinfoPath filesep 'ROI_morph_plot' filesep 'MorphDataAll.mat'],'file') > 0
            nTargetPath = nTargetPath + 1;
            TargetPath{nTargetPath} = [cROIinfoPath filesep 'ROI_morph_plot'];
            continue; % plots already exists, joint to the final path used directly
        end 
        clearvars ROIinfoBU ROIinfo FrameProjSave % clear last loop data
        load([cROIinfoPath filesep ROIinfoStrc.name]);
        load([cROIinfoPath filesep FrameProjStrc.name]);
        
        %
    end
    %
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
        %
        if ~exist('ROIinfoBU','var') && exist('ROIinfo','var') > 0
            ROIinfoBU = ROIinfo(1);
        end
        nROIs = length(ROIinfoBU.ROIpos);
        ROIcenter = round(cell2mat((cellfun(@mean,ROIinfoBU.ROIpos,'uniformOutput',false))'));
        FrameSize = size(ROIinfoBU.ROImask{1});
        RegionSize = [];
        switch FrameSize(1)
            case 256
                RegionSize(1) = 20;
            case 512
                RegionSize(1) = 30;
            otherwise
%                 CusSize = input([sprintf('cFrame row number is %d, please input the ROI region size.',FrameSize(1)),'\n'],'s');
                RegionSize(1) = 25; % for automatic usage
        end
        switch FrameSize(2)
            case 256
                RegionSize(2) = 20;
            case 512
                RegionSize(2) = 30;
            otherwise
%                 CusSize = input([sprintf('cFrame row number is %d, please input the ROI region size.',FrameSize(2)),'\n'],'s');
                RegionSize(2) = 25; % str2num(CusSize);
        end
        cd(cROIinfoPath);
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
            elseif xscales(2) > FrameSize(1)
                xscales(2) = FrameSize(1);
        %         ROIedgeShift_x = cROICen(1) - RegionSize(1);
            end
            %
            yscales = cROICen(2) + ([-1,1]*RegionSize(2));
            ROIedgeShift_y = cROICen(2) - RegionSize(2);
            if yscales(1) < 1
                yscales(1) = 1;
                ROIedgeShift_y = 0;
            elseif yscales(2) > FrameSize(2)
                yscales(2) = FrameSize(2);
            end
            ROISelectData = MaxDelta(yscales(1):yscales(2),xscales(1):xscales(2));
            ROImaxlim = prctile(ROISelectData(:),90);
            AdjROIpos = cROIpos - repmat([ROIedgeShift_x,ROIedgeShift_y],size(cROIpos,1),1);
            AdjROIcenter = mean(AdjROIpos);

        %   subplot(4,30,k)
           %
           hf = figure;
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
        %
% %         ROImorphPath = [cROIinfoPath filesep 'ROI_morph_plot'];  %uigetdir(pwd,'Please select the ROI morph plot path');
% %         ROIrespPath = cPATH;  %uigetdir(pwd,'Please select the ROI response plot path');
% %         MorphFiles = dir([ROImorphPath,'\ROI* morph plot save.png']);
% %         RespFiles = dir([ROIrespPath,'\ROI* passive resp plot.png']);
% %         if length(MorphFiles) ~= length(RespFiles)
% %             error('unequal number of ROI plots');
% %         end
% %         %
% %         SavePath = strrep(ROImorphPath,'ROI_morph_plot','ROI_merge_figure');
% %         if ~isdir(SavePath)
% %             mkdir(SavePath);
% %         end
% %         cd(SavePath);
% %         for cf = 1 : length(MorphFiles)
% %             %
% %             morphfn = MorphFiles(cf).name;
% %             Respfn = RespFiles(cf).name;
% %             morphfid = imread([ROImorphPath,'\',morphfn]);
% %             Respfid = imread([ROIrespPath,'\',Respfn]);
% % 
% %             hhf = figure('position',[100 120 1700 950]);
% %             subplot(3,4,1)
% %             imshow(morphfid);
% %             axis off
% % 
% %             subplot(3,4,[2,3,4,6,7,8,10,11,12])
% %             imshow(Respfid);
% %             axis off
% % 
% %             ROIstrs = strsplit(morphfn,' ');
% %             saveas(hhf,sprintf('%s Merged figure save',ROIstrs{1}));
% %             saveas(hhf,sprintf('%s Merged figure save',ROIstrs{1}),'png');
% %             close(hhf);
% %         end
        nTargetPath = nTargetPath + 1;
        TargetPath{nTargetPath} = [cROIinfoPath filesep 'ROI_merge_figure'];
        %
    catch ME
        nErrorSessNum = nErrorSessNum + 1;
        ErrorSessPath{nErrorSessNum} = cPATH;
        ErrorPathMessage{nErrorSessNum} = ME;
    end
end
cd(GrandPath);
save TargetRFPathSave.mat TargetPath ErrorSessPath ErrorPathMessage -v7.3