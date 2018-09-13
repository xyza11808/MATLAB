clear
clc

if ismac
    GrandPath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
elseif ispc
    GrandPath = 'S:\BatchData\batch53';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
end
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
nSessPath = length(NormSessPathPass); % NormSessPathTask  NormSessPathPass
for cSess = 1 : nSessPath
    %
    cSessPath = NormSessPathPass{cSess};
%     [~,EndInds] = regexp(cSessPath,'result_save');
%     tline = cSessPath(1:EndInds);
    %
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
%     SessMaxF = squeeze(max(MaxFrameAll));
%     MaxDelta = SessMaxF - SessMeanF;
    MaxDelta = squeeze(mean(MeanFrameAll));
    FrameSizeBase = zeros([1,size(SessMeanF)]);
    SessFrameInds = repmat(FrameSizeBase,nTrs,1,1);
    
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
            RegionSize(1) = 30;
        case 512
            RegionSize(1) = 15;
        otherwise
            CusSize = input([sprintf('cFrame row number is %d, please input the ROI region size.',FrameSize(1)),'\n'],'s');
            RegionSize(1) = str2num(CusSize);
    end
    switch FrameSize(2)
        case 256
            RegionSize(2) = 30;
        case 512
            RegionSize(2) = 15;
        otherwise
            CusSize = input([sprintf('cFrame row number is %d, please input the ROI region size.',FrameSize(2)),'\n'],'s');
            RegionSize(2) = str2num(CusSize);
    end
    if FrameSize(2) == FrameSize(1)
        if FrameSize(2) == 256
            RegionSize = [20,20];
        elseif FrameSize(1) == 512
            RegionSize = [30,30];
        end
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
        
        ROIPixelNum = sum(sum(ROIinfoBU.ROImask{cROI}));
        FrameSizeBase(1,:,:) = double(ROIinfoBU.ROImask{cROI});
        FrameROIBase = repmat(FrameSizeBase,nTrs,1,1);
%         ROImaskInds = SessFrameInds;
%         ROImaskInds(:,yscales(1):yscales(2),xscales(1):xscales(2)) = 1;
        ROIData = MeanFrameAll(logical(FrameROIBase));
        ROIFrameData = (reshape(ROIData,nTrs,ROIPixelNum))';
        ROIFrameBrightness = mean(ROIFrameData);
        [~,MaxInds] = max(ROIFrameBrightness);
        MaxDelta = squeeze(MeanFrameAll(MaxInds,:,:));
        
        ROISelectData = MaxDelta(yscales(1):yscales(2),xscales(1):xscales(2));
        ROImaxlim = prctile(ROISelectData(:),100)*1.05;
        AdjROIpos = cROIpos - repmat([ROIedgeShift_x,ROIedgeShift_y],size(cROIpos,1),1);
        AdjROIcenter = mean(AdjROIpos);

    %    subplot(4,30,k)
       %
       hf = figure('visible','off');
%        hf = figure;
       imagesc(ROISelectData,[0 ROImaxlim]);
       line(AdjROIpos(:,1),AdjROIpos(:,2),'Color','r','linewidth',1.6);
       text(AdjROIcenter(1),AdjROIcenter(2),num2str(cROI),'color','g');
       colormap gray;
       axis off
       
       %
       saveas(hf,sprintf('ROI%d morph plot save',cROI));
       saveas(hf,sprintf('ROI%d morph plot save',cROI),'png');
       pause(2);
       close(hf);
       %
    %    k = k + 1;
        ROIMorphData{cROI,1} = ROISelectData;
        ROIMorphData{cROI,2} = AdjROIpos;
    end
    
    save MorphDataAll.mat ROIMorphData -v7.3
    cd ..;
    %
end

%%
m = 1;
nSession = 1;
tline = NormSessPathTask{34};
CoupleSessPath = NormSessPathTask{65};
Passtline = NormSessPathPass{34};
PassCoupleSessPath = NormSessPathPass{65};
%
if m == 1
    %
    %                 PPTname = input('Please input the name for current PPT file:\n','s');
    PPTname = 'BoundShift_0501_0722_0718';
    if isempty(strfind(PPTname,'.ppt'))
        PPTname = [PPTname,'.pptx'];
    end
    %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
    if ismac
        pptSavePath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    elseif ispc
        pptSavePath = 'N:\PlotSummary_folder';
    end
    %
end
%
Anminfo = SessInfoExtraction(tline);
cTunDataPath = [tline,filesep,'Tunning_fun_plot_New1s'];
cRespColorMap = [tline,filesep,'All BehavType Colorplot'];
BehavDataPath = fullfile(tline,'RandP_data_plots','Behav_fit plot.png');
TunFilesAll = dir(fullfile(cTunDataPath,'ROI* Tunning curve comparison plot.png'));
nFiles = length(TunFilesAll);
ColorFiles = dir(fullfile(cRespColorMap,'ROI* all behavType color plot.png'));
[~,EndInds] = regexp(tline,'result_save');
ROIposfilePath = tline(1:EndInds);
cMorphfiles = fullfile(ROIposfilePath,'ROI_morph_plot');
[~,PassEndInds] = regexp(Passtline,'result_save');
PassROIfilePath = Passtline(1:PassEndInds);
cMorphPassf = fullfile(PassROIfilePath,'ROI_morph_plot');

%         CoupleSessPath = fgetl(ff);
CoupAnmInfo = SessInfoExtraction(CoupleSessPath);
CoupcTunDataPath = [CoupleSessPath,filesep,'Tunning_fun_plot_New1s'];
CoupcColorPath = [CoupleSessPath,filesep,'All BehavType Colorplot'];
CoupBehavPath = fullfile(CoupleSessPath,'RandP_data_plots','Behav_fit plot.png');
CoupTunFileAll = dir(fullfile(CoupcTunDataPath,'ROI* Tunning curve comparison plot.png'));
CoupnFiles = length(CoupTunFileAll);
CoupColorFiles = dir(fullfile(CoupcColorPath,'ROI* all behavType color plot.png'));

[~,CoupEndInds] = regexp(CoupleSessPath,'result_save');
CROIposfilePath = CoupleSessPath(1:CoupEndInds);
CoupMorphfiles = fullfile(CROIposfilePath,'ROI_morph_plot');
[~,CoupPassEndInds] = regexp(PassCoupleSessPath,'result_save');
CoupMorphPassf = fullfile(PassCoupleSessPath(1:CoupPassEndInds),'ROI_morph_plot');
%
if nFiles ~= CoupnFiles
    nCompareFiles = min(nFiles,CoupnFiles);
else
    nCompareFiles = nFiles;
end

pptFullfile = fullfile(pptSavePath,PPTname);
if ~exist(pptFullfile,'file')
    NewFileExport = 1;
else
    NewFileExport = 0;
end
if NewFileExport
    exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
else
    exportToPPTX('open',pptFullfile);
end
%
exportToPPTX('addslide');
exportToPPTX('addtext','Behavior summary','Position',[6 0 4 1],'FontSize',24);
exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
    Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
    'Position',[2 1 2 2],'FontSize',20);
exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
    CoupAnmInfo.BatchNum,CoupAnmInfo.AnimalNum,CoupAnmInfo.SessionDate,CoupAnmInfo.TestNum),...
    'Position',[10 1 2 2],'FontSize',20);
exportToPPTX('addpicture',imread(BehavDataPath),'Position',[1 4 5 3.75]);
exportToPPTX('addpicture',imread(CoupBehavPath),'Position',[9 4 5 3.75]);

for cf = 1 : nCompareFiles
    exportToPPTX('addslide');
    cfColorPlot = fullfile(cRespColorMap,sprintf('ROI%d all behavType color plot.png',cf));
    cfTunName = fullfile(cTunDataPath,sprintf('ROI%d Tunning curve comparison plot.png',cf));
    cfMorph = fullfile(cMorphfiles,sprintf('ROI%d morph plot save.png',cf));
    cfPassMorph = fullfile(cMorphPassf,sprintf('ROI%d morph plot save.png',cf));
    % Anminfo
    exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 0.5],'FontSize',24);
    exportToPPTX('addnote',tline);
    exportToPPTX('addpicture',imread(cfColorPlot),'Position',[0 0.5 8 5.3]);
    exportToPPTX('addpicture',imread(cfMorph),'Position',[0.5 6 1.79 1.5]);
    exportToPPTX('addpicture',imread(cfPassMorph),'Position',[0.5 7.5 1.79 1.5]);%  cMorphPassf
    exportToPPTX('addpicture',imread(cfTunName),'Position',[2.5 6.2 3.5 2.6]);
    
    CoupColorPlot = fullfile(CoupcColorPath,sprintf('ROI%d all behavType color plot.png',cf));
    CoupleTunName = fullfile(CoupcTunDataPath,sprintf('ROI%d Tunning curve comparison plot.png',cf));
    CouplrMorph = fullfile(CoupMorphfiles,sprintf('ROI%d morph plot save.png',cf)); %CoupMorphPassf
    CouplrPassMorph = fullfile(CoupMorphPassf,sprintf('ROI%d morph plot save.png',cf));
    
    exportToPPTX('addpicture',imread(CoupColorPlot),'Position',[8 0.5 8 5.3]);
    exportToPPTX('addpicture',imread(CouplrMorph),'Position',[14 6 1.79 1.5]);
    exportToPPTX('addpicture',imread(CouplrPassMorph),'Position',[14 7.5 1.79 1.5]);
    exportToPPTX('addpicture',imread(CoupleTunName),'Position',[10 6.2 3.5 2.6]);
    
    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
        'Position',[6 6.5 2 2],'FontSize',20);
    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
        CoupAnmInfo.BatchNum,CoupAnmInfo.AnimalNum,CoupAnmInfo.SessionDate,CoupAnmInfo.TestNum),...
        'Position',[8 6.5 2 2],'FontSize',20);
    %
end
saveName = exportToPPTX('saveandclose',pptFullfile);

%%
% performing nonlinear tuning curve fitting

nSess = length(NormSessPathTask);
for cSS = 1 : nSess
    tline = NormSessPathTask{cSS};
%     if isempty(strfind(tline,'NO_Correction\mode_f_change'))
%        tline = fgetl(ff);
%         continue;
%     else
        %
        if isdir(fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots'))
            continue;
        end
            
        SpikeDataPath = [tline,'\Tunning_fun_plot_New1s'];
        cd(SpikeDataPath);
        load('TunningDataSave.mat');
        
        nROIs = size(CorrTunningFun,2);
        if ~isdir('./Curve fitting plots/')
            mkdir('./Curve fitting plots/');
        end
        cd('./Curve fitting plots/');
        warning('off','all');
        if ~isdir('./NewLog_fit_test_new/')
            mkdir('./NewLog_fit_test_new/');
        end
       cd('./NewLog_fit_test_new/');
%       
%         LogFitMSE = zeros(nROIs,1);
%         GauFitMSE = zeros(nROIs,1);
        LogCoefFit = cell(nROIs,1);
        NMLogFit = cell(nROIs,1);
        GauCoefFit = cell(nROIs,1);
        ROIisResponsive = ones(nROIs,1);
        ROIResidueratio = zeros(nROIs,2);
        PassFitResult = cell(nROIs,1);
        PassFitGOF = cell(nROIs,1);
        PassSigmoidalFit = cell(nROIs,2);
        %
        LogResnRatios = zeros(nROIs,2);
        
%         nFitFun = cell(nROIs,1);
        IsCategROI = zeros(nROIs,1);
        IsTunedROI = zeros(nROIs,1);
        LogResidueAll = cell(nROIs,1);
        GauResidueAll = cell(nROIs,1);
        TaskIndexAll = ones(nROIs,1)*(-1);
        PassIndexAll = ones(nROIs,1)*(-1);
        ROISlopeFit = zeros(nROIs,7);
        %
        for ROInum = 1 : nROIs
            % ROInum = 1;
            cROITunData = CorrTunningFun(:,ROInum);
            cROINMData = NonMissTunningFun(:,ROInum);
            PassFreqConsidered = ~(abs(PassFreqOctave) > 1);
            PassTundata = PassTunningfun(PassFreqConsidered,ROInum);
            PassOctave = PassFreqOctave(PassFreqConsidered);
            [PassMaxAmp,PassmaxInds] = max(PassTundata);
            
            IsROItun = 0;
            SortData = sort(cROITunData);
            if max(cROITunData) < 10
                fprintf('ROI%d shows no significant response.\n',ROInum);
                ROIisResponsive(ROInum) = 0;
%                 continue;
            end
            NorTundata = cROITunData(:);%/mean(cROITunData);
            OctaveData = TaskFreqOctave(:);
            NMTunData = cROINMData(:);
            % using logistic fitting of current data
            opts = statset('nlinfit');
            opts.RobustWgtFun = 'bisquare';
            opts.MaxIter = 1000;
            modelfunb = @(b1,b2,b3,b4,x) (b1+ b2./(1+exp(-(x - b3)./b4)));
            % using the new model function
            UL = [max(NorTundata)+abs(min(NorTundata)), Inf, max(OctaveData), 100];
            SP = [min(NorTundata),max(NorTundata) - min(NorTundata), mean(OctaveData), 1];
            LM = [-Inf,-Inf, min(OctaveData), -100];
            ParaBoundLim = ([UL;SP;LM]);
            [fit_model,fitgof] = fit(OctaveData,NorTundata,modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
            OctaveRange = linspace(min(OctaveData),max(OctaveData),500);
            FitCurve = feval(fit_model,OctaveRange);
            FitSlope = fit_model.b2/(4*fit_model.b4);
            EndPointSlope = (NorTundata(end) - NorTundata(1))/(OctaveData(end) - OctaveData(1));
            
            % fit logistic model with NMData
            NMUL = [max(NMTunData)+abs(min(NMTunData)), Inf, max(OctaveData), 100];
            NMSP = [min(NMTunData),max(NMTunData) - min(NMTunData), mean(OctaveData), 1];
            NMLM = [-Inf,-Inf, min(OctaveData), -100];
            
            [NMfitMd,NMgof] = fit(OctaveData,NMTunData,modelfunb,'StartPoint',NMSP,'Upper',NMUL,'Lower',NMLM);
            NMFitCurve = feval(NMfitMd,OctaveRange);
            NMFitSlope = NMfitMd.b2/(4*NMfitMd.b4);
            NMEndPointSlope = (NMTunData(end) - NMTunData(1))/(OctaveData(end) - OctaveData(1));
            
            ROISlopeFit(ROInum,:) = [FitSlope,EndPointSlope,NMFitSlope,NMEndPointSlope,...
                max(NorTundata),max(NMTunData),PassMaxAmp];
            NMLogFit{ROInum} = NMfitMd;
            % first part plots
            hlogNewf = figure('position',[2750 100 450 400]);
            hold on
            plot(OctaveRange,FitCurve,'color','k','LineWidth',2.4);
            plot(OctaveData, NorTundata,'ro','MarkerSize',12);
            yscales = get(gca,'ylim');
            line([fit_model.b3 fit_model.b3],yscales,'Linewidth',2,'LineStyle','--','Color',[.7 .7 .7]);
            FitData = feval(fit_model,OctaveData);
            DiffRatio = sum((NorTundata - FitData).^2)/sum(NorTundata.^2);
            LogResnRatios(ROInum,1) = DiffRatio;
            LogCoefFit{ROInum} = fit_model;
            LogResidueAll{ROInum} = fitgof;
            if fit_model.b3 > OctaveData(2) && fit_model.b3 < OctaveData(end-1)
                if DiffRatio <= 0.1
                    IsCategROI(ROInum) = 1;
                end
            end
            if IsCategROI(ROInum)
%                 SortData = sort(NorTundata);
                GrNum = floor(length(NorTundata)/2);
                LeftMean = mean(NorTundata(1:GrNum));
                RightMean = mean(NorTundata(end-GrNum+1:end));
                if max(LeftMean, RightMean) < 20
                    IsCategROI(ROInum) = 0;
%                     ROIisResponsive(ROInum) = 0;
                    IsROItun = 1;
                else  % high response, but no significant difference between two groups
                    if abs(LeftMean - RightMean) < max([LeftMean , RightMean])/2  % no significant difference between two groups
                        IsCategROI(ROInum) = 0;
                        IsROItun = 0;
                    end
%                     if fit_model.b3 >= 0
%                         if (mean(NorTundata(end-GrNum+1:end)) - mean(NorTundata(1:GrNum))) < mean(NorTundata(end-GrNum+1:end))/2
%                             IsCategROI(ROInum) = 0;
%                             IsROItun = 0;
%                         end
%                     else
%                        if (mean(NorTundata(1:GrNum)) - mean(NorTundata(end-GrNum+1:end))) < mean(NorTundata(1:GrNum))/2
%                             IsCategROI(ROInum) = 0;
%                             IsROItun = 0;
%                        end 
%                     end
                end
            end
% %             text(0.4,mean(NorTundata),sprintf('rmse = %.3f',fitgof.rmse));
            
            if IsCategROI(ROInum)
                cFitbound = fit_model.b3;
                LeftInds = OctaveData < cFitbound;
                LeftMean = max(mean(NorTundata(LeftInds)),0.1);
                RightMean = max(mean(NorTundata(~LeftInds)),0.1);
                TaskIndexAll(ROInum) = abs(LeftMean - RightMean)/(LeftMean + RightMean);
            else
                LeftInds = OctaveData < 0;
                LeftMean = max(mean(NorTundata(LeftInds)),0.1);
                RightMean = max(mean(NorTundata(~LeftInds)),0.1);
                TaskIndexAll(ROInum) = abs(LeftMean - RightMean)/(LeftMean + RightMean);
            end
            
           % fitting the gaussian function
            modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
            [AmpV,AmpInds] = max(NorTundata);
            c0 = [AmpV,OctaveData(AmpInds),mean(abs(diff(OctaveData))),min(NorTundata)];  % 0.4 is the octave step
            cUpper = [max(AmpV*2,0),max(OctaveData),max(OctaveData) - min(OctaveData),AmpV];
            cLower = [min(NorTundata),min(OctaveData),0,-Inf];
            [ffit,gof] = fit(OctaveData(:),NorTundata(:),modelfunc,...
               'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR');  % 'Method','NonlinearLeastSquares',
           OctaveFitValue_gau = feval(ffit,OctaveData(:));
           Thresratio_gau = sum((NorTundata - OctaveFitValue_gau).^2)/sum(NorTundata.^2);
            ROIResidueratio(ROInum,:) = [DiffRatio,Thresratio_gau];
            %
            GauCoefFit{ROInum} = ffit;
            GauResidueAll{ROInum} = gof;
%             GauFitMSE(ROInum) = gof.rmse;
            if ~IsCategROI(ROInum)
               if  Thresratio_gau < 0.2
                   if ROIisResponsive(ROInum)
                       if ffit.c3 < min(abs(diff(OctaveData)))*2
                            IsTunedROI(ROInum) = 1;
                       end
                   end
               end
               if IsROItun
                   IsTunedROI(ROInum) = 1;
               end
            else
                IsTunedROI(ROInum) = 0;
            end
            if ~ROIisResponsive(ROInum)
                IsTunedROI(ROInum) = 0;
            end
            
            text(ffit.c2,mean(NorTundata)*0.8,sprintf('Width = %.3f',ffit.c3),...
                'HorizontalAlignment','center');
            
             GausFitData = feval(ffit,OctaveRange(:));
             plot(OctaveRange,GausFitData,'r','linewidth',1.6);
            
           % ############################################################################################
           % fitting passive data with gaussian function
           
           c0 = [PassMaxAmp,PassOctave(PassmaxInds),mean(abs(diff(PassOctave))),min(PassTundata)];  % 0.4 is the octave step
            cUpper = [PassMaxAmp*2,max(PassOctave),max(PassOctave) - min(PassOctave),PassMaxAmp];
            cLower = [min(PassTundata),min(PassOctave),min(abs(diff(PassOctave))),-Inf];
            [Passffit,Passgof] = fit(PassOctave(:),PassTundata(:),modelfunc,...
               'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR');  % 'Method','NonlinearLeastSquares',
           PassFitValue_gau = feval(Passffit,PassOctave(:));
           %
           if IsCategROI(ROInum)
                LeftInds = PassOctave < cFitbound;
                PassLMean = max(mean(PassTundata(LeftInds)),0.1);
                PassRMean = max(mean(PassTundata(~LeftInds)),0.1);
                PassIndexAll(ROInum) = abs(PassLMean - PassRMean)/(PassLMean + PassRMean);
           else
               LeftInds = PassOctave < 0;
               PassLMean = max(mean(PassTundata(LeftInds)),0.1);
                PassRMean = max(mean(PassTundata(~LeftInds)),0.1);
                PassIndexAll(ROInum) = abs(PassLMean - PassRMean)/(PassLMean + PassRMean);
           end
           
           % fit a sigmoidal function to passive data
           UL = [max(PassTundata)+abs(min(PassTundata)), Inf, max(PassOctave), 100];
            SP = [min(PassTundata),max(PassTundata) - min(PassTundata), mean(PassOctave), 1];
            LM = [-Inf,-Inf, min(PassOctave), -100];
            ParaBoundLim = ([UL;SP;LM]);
            [fit_modelP,fitgofP] = fit(PassOctave(:),PassTundata(:),modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
            PassOctRange = linspace(min(PassOctave),max(PassOctave),500);
            PassFitCurve = feval(fit_modelP,PassOctRange);
            PassLogFitV = feval(fit_modelP,PassOctave(:));
            PassLogDifRatio = sum((PassTundata(:) - PassLogFitV).^2)/sum(PassTundata.^2);
            LogResnRatios(ROInum,2) = PassLogDifRatio;
            PassLogSlope = fit_modelP.b2/(fit_modelP.b4*4);
            PassEndSlope = (PassTundata(end) - PassTundata(1))/(PassOctave(end) - PassOctave(1));
            
            PassSigmoidalFit{ROInum,1} = fit_modelP;
            PassSigmoidalFit{ROInum,2} = fitgofP;
           
            plot(PassOctRange,PassFitCurve,'Color',[0.4 0.4 0.4],'linewidth',1.6);
            plot(PassOctave,PassTundata,'d','Color',[0.4 0.4 0.4],'MarkerSize',12);
            
            yscales = get(gca,'ylim');
            text(0.3,yscales(2)*0.7,sprintf('PassLogRatio = %.4f',PassLogDifRatio));
            line([ffit.c2 ffit.c2],yscales,'Color','m','Linewidth',1.8,'LineStyle','--');
            text(-0.8,yscales(2)*0.8,sprintf('IsResponsive = %d',ROIisResponsive(ROInum)));
            set(gca,'ylim',yscales);
            title({sprintf('ROI%d,LogResratio = %.3f,IsCateg = %d',ROInum,DiffRatio,IsCategROI(ROInum));...
                sprintf('Gauratio = %.3f, IsGauTun = %d',Thresratio_gau,IsTunedROI(ROInum))});
            xlabel(sprintf('Task%.2f-%.2f, Pass%.2f-%.2f',FitSlope,EndPointSlope,PassLogSlope,PassEndSlope));
             %
            saveas(hlogNewf,sprintf('Log Fit test Save ROI%d',ROInum));
            saveas(hlogNewf,sprintf('Log Fit test Save ROI%d',ROInum),'png');
           
           PassFitResult{ROInum} = Passffit;
           PassFitGOF{ROInum} = Passgof;
          close(hlogNewf);
        end
        warning('on','all')
        warning('query','all')
       
%         LogGauFitMSE = [LogFitMSE,GauFitMSE];
        BehavBoundStrc = load(fullfile(tline,'RandP_data_plots\boundary_result.mat'));
        BehavBoundResult = BehavBoundStrc.boundary_result.Boundary - 1;
        
        save NewCurveFitsave.mat LogCoefFit GauCoefFit ROIisResponsive ROIResidueratio PassFitResult PassFitGOF ...
            LogResnRatios IsCategROI IsTunedROI LogResidueAll GauResidueAll BehavBoundResult TaskIndexAll ...
            PassIndexAll ROISlopeFit NMLogFit -v7.3
        %
        FitBoundInds = cellfun(@(x) x.c2,GauCoefFit);
        TunedROIBound = FitBoundInds(logical(IsTunedROI));
        TunBoundSEM = std(TunedROIBound)/sqrt(length(TunedROIBound));
        ts = tinv([0.025  0.975],length(TunedROIBound)-1);
        CI = mean(TunedROIBound) + ts*TunBoundSEM;
        hhf = figure('position',[750 250 430 500]);
        hold on
        plot(ones(size(TunedROIBound)),TunedROIBound,'*','Color',[.7 .7 .7],'MarkerSize',10,'Linewidth',1.4);
        patch([0.9 1.1 1.1 0.9],[CI(1) CI(1) CI(2) CI(2)],1,'EdgeColor','k','FaceColor','none','linewidth',2);
        errorbar(1,mean(TunedROIBound),TunBoundSEM,'bo','linewidth',1.8);
        set(gca,'xlim',[0.5,1.5],'ylim',[min(OctaveData) max(OctaveData)]);
        ll = line([0.7 1.1],[BehavBoundResult BehavBoundResult],'Color','r','linewidth',2,'linestyle','--');
        ll2 = line([0.9 1.3],[mean(TunedROIBound) mean(TunedROIBound)],'Color','k','linewidth',2,'linestyle','--');
        set(gca,'xtick',1,'xticklabel','TunBoundary','FontSize',18);
        legend([ll,ll2],{'Behav Boundary','Mean Boundary'},'location','NorthWest','FontSize',10);
        legend('boxoff')
        %
        saveas(hhf,'Tuning ROI TunedPeak index distribution');
        saveas(hhf,'Tuning ROI TunedPeak index distribution','png');
        close(hhf);
        %         SigROIinds = find(ROIisResponsive > 0);
%         SigLogfitmse = LogFitMSE(SigROIinds);
%         SigGaufitmse = GauFitMSE(SigROIinds);
%         GauCoefFitAll = GauCoefFit(SigROIinds);
%         GauCoefWid = cellfun(@(x) x(3),GauCoefFitAll);
%         FreqTunROIs = ((SigGaufitmse < SigLogfitmse) & (SigGaufitmse < 0.5) & (GauCoefWid < 0.7)) | ...
%             (10 * SigGaufitmse <= SigLogfitmse);
%         FreqCategROIs = ((SigGaufitmse > SigLogfitmse) & (SigLogfitmse < 0.5)) | ...
%             ((SigGaufitmse < SigLogfitmse) & (SigGaufitmse > 10 * SigLogfitmse) & (GauCoefWid >= 0.5 & GauCoefWid < 1));
%         %
%         nTunROI = sum(FreqTunROIs);
%         nCategROI = sum(FreqCategROIs);
%         TunROIInds = SigROIinds(FreqTunROIs);
%         CategROiinds = SigROIinds(FreqCategROIs);
%         
%         save CellCategorySave.mat LogFitMSE GauFitMSE ROIisResponsive TunROIInds CategROiinds LogCoefFit GauCoefFit CorrTunningFun OctaveData -v7.3
%         cd ..;
%         cd ..;
%         
%         NorTunData = CorrTunningFun ./ repmat(mean(CorrTunningFun),size(CorrTunningFun,1),1);
%         TuningROIData = NorTunData(:,TunROIInds);
%         CagROIdata = NorTunData(:,CategROiinds);
%         NoiseROIInds = true(size(NorTunData,2),1);
%         NoiseROIInds(TunROIInds) = false;
%         NoiseROIInds(CategROiinds) = false;
%         NoiseROIdata = NorTunData(:,NoiseROIInds);
%         PerferCagData = zeros(size(CagROIdata));
%         nPairNum = floor(size(CagROIdata,1)/2);
%         for nnn = 1 : size(CagROIdata,2)
%             if sum(CagROIdata(1:nPairNum,nnn)) > sum(CagROIdata(end-nPairNum+1:end,nnn))
%                 PerferCagData(:,nnn) = flipud(CagROIdata(:,nnn));
%             else
%                 PerferCagData(:,nnn) = CagROIdata(:,nnn);
%             end
%         end
%         BehavDataStrc = load('./RandP_data_plots/boundary_result.mat');
%         if ~isdir('./ROI type response plot/')
%             mkdir('./ROI type response plot/');
%         end
%         cd('./ROI type response plot/');
%         
%         if ~isempty(TuningROIData)
%             hTun = figure;
%             hold on
%             plot(OctaveData(:),TuningROIData,'color',[.7 .7 .7]);
%             plot(OctaveData,mean(TuningROIData,2),'k','linewidth',1.8);
%             yscales = get(gca,'ylim');
%             text(0,0.85*yscales(2),sprintf('nROI = %d/%d',size(TuningROIData,2),nROIs),'FontSize',16);
%             xlabel('Octave');
%             ylabel('Normal Firing rate');
%             title('Tunning ROI average');
%             set(gca,'FontSize',16);
%             saveas(hTun,'Tunning ROIs response plot');
%             saveas(hTun,'Tunning ROIs response plot','png');
%             saveas(hTun,'Tunning ROIs response plot','pdf');
%             close(hTun);
%         end
%         
%         if ~isempty(NoiseROIdata)
%             hNos = figure;
%             hold on
%             plot(OctaveData(:),NoiseROIdata,'color',[.7 .7 .7]);
%             plot(OctaveData,mean(NoiseROIdata,2),'k','linewidth',1.8);
%             yscales = get(gca,'ylim');
%             text(0,0.85*yscales(2),sprintf('nROI = %d/%d',size(NoiseROIdata,2),nROIs),'FontSize',16);
%             xlabel('Octave');
%             ylabel('Normal Firing rate');
%             title('Noisy ROI average');
%             set(gca,'FontSize',16);
%             saveas(hNos,'Noisy ROIs response plot');
%             saveas(hNos,'Noisy ROIs response plot','png');
%             saveas(hNos,'Noisy ROIs response plot','pdf');
%             close(hNos);
%         end
%         
%         if ~isempty(PerferCagData)
%             hCag = figure;
%             hold on
%             plot(OctaveData(:),PerferCagData,'color',[.7 .7 .7]);
%             plot(OctaveData(:),mean(PerferCagData,2),'k','linewidth',1.8);
%             yscales = get(gca,'ylim');
%             text(-0.5,0.85*yscales(2),sprintf('nROI = %d/%d',size(PerferCagData,2),nROIs),'FontSize',16);
%             xlabel('Octave');
%             ylabel('Normal Firing rate');
%             title('Categorical ROI average');
%             set(gca,'FontSize',16);
%             saveas(hCag,'Catogorical ROIs response plot');
%             saveas(hCag,'Catogorical ROIs response plot','png');
%             saveas(hCag,'Catogorical ROIs response plot','pdf');
%             close(hCag);
%        
%             BehavCorr = BehavDataStrc.boundary_result.StimCorr;
%             BehavCorr(1:nPairNum) = 1 - BehavCorr(1:nPairNum);
%             Octaves = log2(double(BehavDataStrc.boundary_result.StimType)/16000);
%             MeanCagResp = mean(PerferCagData,2);
%             MeanCagSEM = std(PerferCagData,[],2)/sqrt(size(PerferCagData,2));
%             Patchy = [MeanCagSEM+MeanCagResp;flipud(MeanCagResp - MeanCagSEM)];
%             Patchx = [OctaveData(:);flipud(OctaveData(:))];
%             %
%             hComb = figure;
%             hold on
%             yyaxis left
%             patch(Patchx,Patchy,1,'FaceColor',[.3 .3 .3],'EdgeColor','none','facealpha',0.4);
%             plot(OctaveData(:),mean(PerferCagData,2),'k-o','linewidth',1.8);
%             yscales = get(gca,'ylim');
%             text(-0.5,0.85*yscales(2),sprintf('nROI = %d/%d',size(PerferCagData,2),nROIs),'FontSize',16);
%             ylabel('Nor. FR','Color','k');
%             set(gca,'YColor','k','ytick',[min(mean(PerferCagData,2)),1,max(mean(PerferCagData,2))]);
% 
%             yyaxis right
%             plot(Octaves,BehavCorr,'r-o','linewidth',1.8);
%             xlabel('Octaves');
%             ylabel('RIghtward Frac.','Color','r');
%             set(gca,'YColor','r','ytick',[0.1 0.5 1]);
%             title('Behav and ROI Resp compare');
% 
%             set(gca,'FontSize',16);
%             saveas(hComb,'Catogorical ROIs vs behav response plot');
%             saveas(hComb,'Catogorical ROIs vs behav response plot','png');
%             saveas(hComb,'Catogorical ROIs vs behav response plot','pdf');
%             close(hComb);
%         
%         end
%         save TypeDataSave.mat OctaveData TuningROIData NoiseROIdata PerferCagData BehavCorr Octaves -v7.3
        %
%         cd ..;
%         tline = fgetl(ff);
%     end
end

%% batched colormap plots
CusMap = blue2red_2(32,0.8);
cSessions = length(NormSessPathTask);
for cSess = 1 : cSessions
    tline = NormSessPathTask{cSess};
    % passive tuning frequency colormap plot
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
    [~,EndInds] = regexp(tline,'result_save');
    ROIposfilePath = tline(1:EndInds);
    ROIposfilePosi = dir(fullfile(ROIposfilePath,'ROIinfo*.mat'));
    ROIdataStrc = load(fullfile(ROIposfilePath,ROIposfilePosi(1).name));
    if isfield(ROIdataStrc,'ROIinfoBU')
        ROIinfoData = ROIdataStrc.ROIinfoBU;
    elseif isfield(ROIdataStrc,'ROIinfo')
        ROIinfoData = ROIdataStrc.ROIinfo(1);
    else
        error('No ROI information file detected, please check current session path.');
    end
    ROIcenter = ROI_insite_label(ROIinfoData,0);
    ROIdistance = pdist(ROIcenter);
    DisMatrix = squareform(ROIdistance);
    
    
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
%     end
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    Uncertainty = 1 - BehavCorr;
    if ~isdir('NMTuned Meanfreq colormap plot')
        mkdir('NMTuned Meanfreq colormap plot');
    end
    cd('NMTuned Meanfreq colormap plot');
    % plot the behavior result and uncertainty function
    GroupStimsNum = floor(length(BehavCorr)/2);
    cSessStims = double(BehavBoundfile.boundary_result.StimType);
    BehavOctaves = log2(double(BehavBoundfile.boundary_result.StimType)/min(BehavBoundfile.boundary_result.StimType)) - 1;
    FreqStrs = cellstr(num2str(BehavBoundfile.boundary_result.StimType(:)/1000,'%.1f'));
    FitoctaveData = BehavCorr;
    FitoctaveData(1:GroupStimsNum) = 1 - FitoctaveData(1:GroupStimsNum);
    
    UL = [0.5, 0.5, max(BehavOctaves), 100];
    SP = [FitoctaveData(1),1 - FitoctaveData(end)-FitoctaveData(1), mean(BehavOctaves), 1];
    LM = [0, 0, min(BehavOctaves), 0];
    ParaBoundLim = ([UL;SP;LM]);
    fit_ReNew = FitPsycheCurveWH_nx(BehavOctaves, FitoctaveData, ParaBoundLim);
    UncertainCurve = 0.5 - (abs(0.5 - fit_ReNew.curve(:,2)));
    [~,BoundInds] = min(abs(fit_ReNew.curve(:,2) - 0.5));
    internal_boundary = fit_ReNew.curve(BoundInds,1);
    % ###############################################################################
    % plot the uncertainty curve with psychometric curve
    hf = figure('position',[100 100 400 300]);
    yyaxis left
    hold on
    plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'color','k','LineWidth',2.4);
    plot(BehavOctaves, FitoctaveData,'bo','MarkerSize',12,'linewidth',2.5);
%     line([fit_ReNew.ffit.u fit_ReNew.ffit.u],[0 1],'Color',[1 0.4 0.4],'linestyle','--','LineWidth',2);
    line([internal_boundary internal_boundary],[0 1],'Color',[1 0.4 0.4],'linestyle','--','LineWidth',2);
    set(gca,'xlim',[-1.2 1.2]);
    text(internal_boundary,0.1,'BehavBound','HorizontalAlignment','center','Color','g');
    set(gca,'YColor','k','Ylim',[0 1]);
    ylabel('Right Probability');
    
    yyaxis right
    plot(fit_ReNew.curve(:,1),UncertainCurve,'color',[.7 .7 .7],'LineWidth',2.4);
    set(gca,'YColor',[.7 .7 .7],'ylim',[0 0.5],'Ytick',[0 0.25 0.5],'YtickLabel',[0 0.5 1]);
    ylabel('Norm. uncertainty');
    set(gca,'xtick',BehavOctaves,'xTickLabel',FreqStrs);
    xlabel('Frequency (kHz)');
    set(gca,'FontSize',18);
    
    saveas(hf,'Behavior and uncertainty curve plot');
    saveas(hf,'Behavior and uncertainty curve plot','png');
    close(hf);
    %  ######################################################################################
    %  extract passive session maxium responsive frequency index
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    if size(PassTunningfun,2) > size(DisMatrix,2)
        PassROIUsedInds = 1:size(DisMatrix,2);
    else
        PassROIUsedInds = 1:size(PassTunningfun,2);
    end
    UsedOctaveData = PassTunningfun(UsedOctaveInds,PassROIUsedInds);
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    PassMaxOct = zeros(nROIs,1);
    for cROI = 1 : nROIs
        PassMaxOct(cROI) = UsedOctave(maxInds(cROI));
    end
    modeFreqInds = PassMaxOct == mode(PassMaxOct);
    PassModeInds = [mode(PassMaxOct),mean(PassMaxOct),BehavBoundData]; 
    PassMaxAmp = MaxAmp;
    
%     [PassClusterInterMean,PassRandMean,hhf] =  Within2BetOrRandRatio(DisMatrix,modeFreqInds,'Rand');
%     saveas(hhf,'Passive Rand_vs_intermodeROIs distance ratio distribution');
%     saveas(hhf,'Passive Rand_vs_intermodeROIs distance ratio distribution','png');
%     close(hhf);
%     PreferRandDisSum{m,1} = PassClusterInterMean;
%     PreferRandDisSum{m,2} = PassRandMean;
    %
    AllPassMaxOcts = PassMaxOct;
    PassFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [PassFreqStrs(1:BoundFreqIndex-1);'BehavBound';PassFreqStrs(BoundFreqIndex:end)];
%     NonRespROIInds = (MaxAmp < 20);
    PercentileNum = 0;
    %
    for cPrc = 1 : length(PercentileNum)
        %
        cPrcvalue = PercentileNum(cPrc);
        %
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
%         GrayNonRespROIs = cROIinds & NonRespROIInds;
%         ColorRespROIs = cROIinds & ~NonRespROIInds;
        
        % plot the responsive ROIs with color indicates tuning octave
        AllMasks = ROIinfoData.ROImask(cROIinds);
        cPrcPassMaxOct = PassMaxOct(cROIinds);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * cPrcPassMaxOct(1);
        TestOcts = zeros(nROIs,1);
%         TestOcts(1) = PassMaxOct(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * cPrcPassMaxOct(cROI);
%             TestOcts(cROI) = PassMaxOct(cROI);
        end
        
        %
        hColor = figure('position',[100 100 530 450]);
        ha = axes;
%         axis square
        h_im = imagesc(SumROIcolormask,[-1 1]);
        set(h_im,'AlphaData',SumROImask>0);
        set(gca,'box','off');
        axis off
        hBar = colorbar('westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.2 0 0],'TickLength',0);
        set(hBar,'ytick',[-1 1],'yticklabel',{num2str(min(cSessStims)/1000,'%d'),...
            num2str(max(cSessStims)/1000,'%d')});
        title(hBar,'kHz')
%         title(sprintf('Prc%d map',cPrcvalue));
        h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(PassMaxOct);
        MeanPopuOcts = mean(PassMaxOct);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        LineStartPosMean = [hBar.Position(1)+hBar.Position(3),(MeanPopuOcts-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)]; % position for mean BFs
        
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        MeanArrowx = [LineStartPosMean(1) + 0.03,LineStartPosMean(1)];
        MeanWrrowy = [LineStartPosMean(2),LineStartPosMean(2)];
        
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('arrow',MeanArrowx,MeanWrrowy,'Color','m');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)+0.1,LineStartPositionB(2)];
%             if BoundArrowy(1)> 1
%                 BoundArrowy(1) = 1;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)-0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) < 0
%                 ModeArrowy(1) = 0;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        else
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('arrow',MeanArrowx,MeanWrrowy,'Color','m');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)-0.1,LineStartPositionB(2)];
%             if BoundArrowy(1) < 0
%                 BoundArrowy(1) = 0;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)+0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) > 1
%                 ModeArrowy(1) = 1;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        end
%         annotation('textbox',[LineStartPosMean(1),LineStartPosMean(2),0.1 0.1],'String','*','Box','off','Color','k','FontSize',10);
        set(ha,'position',get(ha,'position')+[0.1 0 0 0])
        colormap(CusMap);
%
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    end
    %
    PassROITunedOctave = AllPassMaxOcts;
    PassOctaves = UsedOctave;
    Octaves = unique(AllPassMaxOcts);
    PassOctaveTypeNum = zeros(length(PassOctaves),1);
    for n = 1 : length(PassOctaves)
        PassOctaveTypeNum(n) = sum(AllPassMaxOcts == PassOctaves(n));
    end

    %
    % extract task session maxium responsive frequency index
    % UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = TaskFreqOctave(:);
    CorrUsedTrNumbers = CorrTypeNum;
    FewTrNumInds = CorrUsedTrNumbers < 5;
    if ~sum(FewTrNumInds)
        UsedOctaveData = CorrTunningFun;
    else  % in case of few correct trials available, NM data will be replaced for correct datas
        UsedOctaveData = CorrTunningFun;
        AdditionalData = NonMissTunningFun(FewTrNumInds,:);
        UsedOctaveData(FewTrNumInds,:) = AdditionalData;
    end
%     UsedOctaveData = NonMissTunningFun;
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    TaskMaxOct = zeros(nROIs,1);
    for cROI = 1 : nROIs
        TaskMaxOct(cROI) = UsedOctave(maxInds(cROI));
    end
    modeFreqInds = TaskMaxOct == mode(TaskMaxOct);
    TaskModeInds = [mode(TaskMaxOct),mean(TaskMaxOct),BehavBoundData];
    TaskMaxAmp = MaxAmp;
    
    save TaskPassBFDis.mat  TaskMaxOct PassMaxOct BehavBoundData TaskMaxAmp PassMaxAmp -v7.3
%     [TaskClusterInterMean,TaskRandMean,hhf] =  Within2BetOrRandRatio(DisMatrix,modeFreqInds,'Rand');
%     saveas(hhf,'Task Rand_vs_intermodeROIs distance ratio distribution');
%     saveas(hhf,'Task Rand_vs_intermodeROIs distance ratio distribution','png');
%     close(hhf);
    
%     PreferRandDisSum{m,3} = TaskClusterInterMean;
%     PreferRandDisSum{m,4} = TaskRandMean;
    
    AllTaskMaxOcts = TaskMaxOct;
    TaskFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [TaskFreqStrs(1:BoundFreqIndex-1);'BehavBound';TaskFreqStrs(BoundFreqIndex:end)];
    PercentileNum = 0;
    %
    for cPrc = 1 : length(PercentileNum)
        %
        cPrcvalue = PercentileNum(cPrc);
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
        AllMasks = ROIinfoData.ROImask(cROIinds);
        TaskMaxOct = AllTaskMaxOcts(cROIinds);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * TaskMaxOct(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * TaskMaxOct(cROI);
        end
        %
        hColor = figure('position',[600 300 530 450]);
         ha = axes;
%         axis square
        h_im = imagesc(SumROIcolormask,[-1 1]);
        set(h_im,'AlphaData',SumROImask>0);
        set(gca,'box','off');
        axis off
        hBar = colorbar('westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.2 0 0]);
        set(hBar,'ytick',[-1 1],'yticklabel',{num2str(min(cSessStims)/1000,'%d'),...
            num2str(max(cSessStims)/1000,'%d')});
        title(hBar,'kHz')
%         title(sprintf('Prc%d map',cPrcvalue));
         h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(TaskMaxOct);
        MeanPopuOcts = mean(TaskMaxOct);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
         LineStartPosMean = [hBar.Position(1)+hBar.Position(3),(MeanPopuOcts-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)]; 
         
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        MeanArrowx = [LineStartPosMean(1) + 0.03,LineStartPosMean(1)];
        MeanWrrowy = [LineStartPosMean(2),LineStartPosMean(2)];
        
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('arrow',MeanArrowx,MeanWrrowy,'Color','m');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)+0.1,LineStartPositionB(2)];
%             if BoundArrowy(1)> 1
%                 BoundArrowy(1) = 1;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)-0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) < 0
%                 ModeArrowy(1) = 0;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        else
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('arrow',MeanArrowx,MeanWrrowy,'Color','m');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)-0.1,LineStartPositionB(2)];
%             if BoundArrowy(1) < 0
%                 BoundArrowy(1) = 0;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)+0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) > 1
%                 ModeArrowy(1) = 1;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        end
        set(ha,'position',get(ha,'position')+[0.1 0 0 0])
        colormap(CusMap)
%
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    end
    TaskROITunedOctave = AllTaskMaxOcts;
    TaskOctaves = UsedOctave;
    %
%     Octaves = unique(TaskMaxOct);
    TaskOctaveTypeNum = zeros(length(UsedOctave),1);
    for n = 1 : length(UsedOctave)
        TaskOctaveTypeNum(n) = sum(AllTaskMaxOcts == UsedOctave(n));
    end
    %
    if mod(length(UsedOctave),2)
        cSessDatafile = load(fullfile(tline,'CSessionData.mat'),'behavResults');
        FreqTypes = double(cSessDatafile.behavResults.Stim_toneFreq);
        ChoiceTypes = double(cSessDatafile.behavResults.Action_choice);
        AllFreqType = unique(FreqTypes);
        CenterFreq = AllFreqType(ceil(length(AllFreqType)/2));
        CenterFreqChoice = ChoiceTypes(FreqTypes == CenterFreq);
        MissChoice = CenterFreqChoice == 2;
        CenterFreqChoice(MissChoice) = [];
        CenterUncertainty = 1 - mean(CenterFreqChoice);
        Uncertainty = (Uncertainty(:))';
        GrFreqNum = length(Uncertainty)/2;
        newUncertainty = [Uncertainty(1:GrFreqNum),CenterUncertainty,Uncertainty(1+GrFreqNum:end)];
        Uncertainty = newUncertainty;
    end
    
    % set boundary color
    ColorIndex = parula(256);
    IndexScale = linspace(min(TaskOctaves),max(TaskOctaves),256);
    [~,BoundaryInds] = min(abs(IndexScale - BehavBoundData));
    BoundaryColor = ColorIndex(BoundaryInds,:);
    
    %
    % Task2BehavBoundDiff = (TaskROITunedOctave - BehavBoundData);
    % Pass2BehavBoundDiff = (PassROITunedOctave - BehavBoundData);
    % 
    % TaskTunBoundSEM = std(Task2BehavBoundDiff)/sqrt(length(Task2BehavBoundDiff));
    % ts = tinv([0.025  0.975],length(Task2BehavBoundDiff)-1);
    % TaskCI = mean(Task2BehavBoundDiff) + ts*TaskTunBoundSEM;
    % PassTunBoundSEM = std(Pass2BehavBoundDiff)/sqrt(length(Pass2BehavBoundDiff));
    % PassCI = mean(Pass2BehavBoundDiff) + ts*PassTunBoundSEM;
    % 
    % hhf = figure('position',[750 250 430 500]);
    % hold on
    % plot(ones(size(Task2BehavBoundDiff)),Task2BehavBoundDiff,'*','Color',[1 .5 .5],'MarkerSize',10,'Linewidth',1.4);
    % plot(ones(size(Task2BehavBoundDiff))+1,Task2BehavBoundDiff,'*','Color',[.7 .7 .7],'MarkerSize',10,'Linewidth',1.4);
    % patch([0.9 1.1 1.1 0.9],[PassCI(1) PassCI(1) PassCI(2) PassCI(2)],1,'EdgeColor','k','FaceColor','none','linewidth',2);
    % patch([0.9 1.1 1.1 0.9]+1,[TaskCI(1) TaskCI(1) TaskCI(2) TaskCI(2)],1,'EdgeColor','r','FaceColor','none','linewidth',2);
    % errorbar([1,2],[mean(Task2BehavBoundDiff),mean(Pass2BehavBoundDiff)],[TaskTunBoundSEM,PassTunBoundSEM],'bo','linewidth',1.8);
    % set(gca,'xlim',[0.5,2.5]);
    % ll = line([1.8 2.2],[mean(Pass2BehavBoundDiff) mean(Pass2BehavBoundDiff)],'Color','k','linewidth',2,'linestyle','--');
    % ll2 = line([0.8 1.2],[mean(Task2BehavBoundDiff) mean(Task2BehavBoundDiff)],'Color','r','linewidth',2,'linestyle','--');
    % set(gca,'xtick',[1,2],'xticklabel',{'TaskDiff','PassDiff'},'FontSize',18);
    % legend([ll,ll2],{'Behav Boundary','Mean Boundary'},'location','NorthWest');
    % legend('boxoff')
    % legend({},'FontSize',10)

    % plot the tuning peak distribution with uncertainty curve
    TaskFreqStrs = num2str((2.^TaskOctaves(:))*BoundFreq/1000,'%.1f');
    hf = figure('position',[3000 300 400 300]);
%     yyaxis left
    hold on
%     ll1 = plot(PassOctaves,PassOctaveTypeNum,'k-*','linewidth',1.8,'MarkerSize',10);
%     ll2 = plot(TaskOctaves,TaskOctaveTypeNum,'r-o','linewidth',1.8,'MarkerSize',10);
    bb1 = bar(PassOctaves-0.08,PassOctaveTypeNum,0.4,'EdgeColor','none','FaceColor',[.7 .7 .7]);
    bb2 = bar(TaskOctaves+0.08,TaskOctaveTypeNum,0.4,'EdgeColor','none','FaceColor',[1 .7 .2]);
    ylabel('Cell Count');

%     yyaxis right
%     ll3 = plot(TaskOctaves,Uncertainty,'m-o','linewidth',1.8,'MarkerSize',10);
%     set(gca,'xtick',TaskOctaves,'xticklabel',TaskFreqStrs);
    yscales = get(gca,'ylim');
    line([BehavBoundData BehavBoundData],yscales,'linewidth',2.1,'Color',BoundaryColor,'Linestyle','--');
    text(BehavBoundData,yscales(1)+diff(yscales*0.95),'BehavBound','Color','g','FontSize',10,'HorizontalAlignment','center');
    set(gca,'ylim',yscales,'xlim',[-1.5 1.5]);
%     ylabel('Uncertainty level');
    xlabel('Frequency (kHz)');

    title('Tuned Inds vs uncertainty');
    set(gca,'FontSize',16);
    if BehavBoundData < 0
%         legend([ll1,ll2,ll3],{'Passive','Task','Uncertainty'},'Location','Northeast','FontSize',8);
        legend([bb1,bb2],{'Passive','Task'},'Location','Northeast','FontSize',8);
    else
%         legend([ll1,ll2,ll3],{'Passive','Task','Uncertainty'},'Location','Northwest','FontSize',8);
        legend([bb1,bb2],{'Passive','Task'},'Location','Northwest','FontSize',8);
    end
    legend('boxoff');
    %
    saveas(hf,'Uncertainty curve vs cell count plot');
    saveas(hf,'Uncertainty curve vs cell count plot','png');
    close(hf);
    %
    TaskDiff2Bound = abs(TaskROITunedOctave - BehavBoundData); 
    PassDiff2Bound = abs(PassROITunedOctave - BehavBoundData); 
    TaskDiffTypes = unique(TaskDiff2Bound);
    PassDiffTypes = unique(PassDiff2Bound);
    CombinationNum = length(TaskDiffTypes) * length(PassDiffTypes);
    TypeCellCounts = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    TypeCellPassx = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    TypeCellTasky = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    for nType = 1 : CombinationNum
        [TaskInds,PassiveInds] = ind2sub([length(TaskDiffTypes) , length(PassDiffTypes)],nType);
        cTypeInds = TaskDiff2Bound == TaskDiffTypes(TaskInds) & PassDiff2Bound == PassDiffTypes(PassiveInds);
        TypeCellCounts(TaskInds,PassiveInds) = sum(cTypeInds);
        TypeCellPassx(TaskInds,PassiveInds) = PassDiffTypes(PassiveInds);
        TypeCellTasky(TaskInds,PassiveInds) = TaskDiffTypes(TaskInds);
    end
    TypeCellCountsVec = TypeCellCounts(:);
    TypeCellPassxVec = TypeCellPassx(:);
    TypeCellTaskyVec = TypeCellTasky(:);
    EmptyData = TypeCellCountsVec == 0;
    hf = figure('position',[600 350 450 400],'Paperpositionmode','auto');
    scatter(TypeCellPassxVec(~EmptyData),TypeCellTaskyVec(~EmptyData),80,TypeCellCountsVec(~EmptyData),'filled','o','linewidth',2);
%     hf = figure('position',[600 350 450 350],'Paperpositionmode','auto');
%     scatter(PassDiff2Bound,TaskDiff2Bound,50,'ro','linewidth',2);
    xyscales = [get(gca,'xlim');get(gca,'ylim')]; 
    CommonScale = [min(xyscales(:,1)),max(xyscales(:,2))];
    set(gca,'xlim',CommonScale,'ylim',CommonScale);
    line(CommonScale,CommonScale,'Linewidth',2,'Color',[.7 .7 .7],'lineStyle','--');
    [~,p] = ttest2(PassDiff2Bound,TaskDiff2Bound);
    title(sprintf('p = %.3e',p));
    hBar = colorbar;
    set(hBar,'position',get(hBar,'position').*[1.1 1 0.3 0.8]+[0.03 0.1 0 0]);
    xlabel('Passive Diff');
    ylabel('Task Diff');
    set(gca,'FontSize',18);
    %
    saveas(hf,'Bound2Behav diff compare scatter plot');
    saveas(hf,'Bound2Behav diff compare scatter plot','png');
    close(hf);
end