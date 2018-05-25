clearvars -except fn fp
m = 1;
nSession = 1;

fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);
        
        continue;
    else
        %
        if m == 1
            %
            %                 PPTname = input('Please input the name for current PPT file:\n','s');
            PPTname = 'PopuFreqCompare_Color_AllROI';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
            %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
            pptSavePath = 'F:\TestOutputSave\SigROITest';
            %
        end
        Anminfo = SessInfoExtraction(tline);
        cTunDataPathMode = [tline,filesep,'Tunning_fun_plot_New1s',filesep,'NMTuned Modefreq colormap plot'];
        cTunDataPathMean = [tline,filesep,'Tunning_fun_plot_New1s',filesep,'NMTuned Meanfreq colormap plot'];
        
        TaskRespMapMode = fullfile(cTunDataPathMode,'Task top Prc100 colormap save.png');
        PassRespMapMode = fullfile(cTunDataPathMode,'Passive top Prc100 colormap save.png');
        TaskRespMapMean = fullfile(cTunDataPathMean,'Task top Prc100 colormap save.png');
        PassRespMapMean = fullfile(cTunDataPathMean,'Passive top Prc100 colormap save.png');
        
        CoupleSessPath = fgetl(ff);
        CoupAnmInfo = SessInfoExtraction(CoupleSessPath);
        CoupcTunDataPathMode = [CoupleSessPath,filesep,'Tunning_fun_plot_New1s',filesep,'NMTuned Modefreq colormap plot'];
        CoupcTunDataPathMean = [CoupleSessPath,filesep,'Tunning_fun_plot_New1s',filesep,'NMTuned Meanfreq colormap plot'];
        
        CoupTaskRespMapMode = fullfile(CoupcTunDataPathMode,'Task top Prc100 colormap save.png');
        CoupPassRespMapMode = fullfile(CoupcTunDataPathMode,'Passive top Prc100 colormap save.png');
        CoupTaskRespMapMean = fullfile(CoupcTunDataPathMean,'Task top Prc100 colormap save.png');
        CoupPassRespMapMean = fullfile(CoupcTunDataPathMean,'Passive top Prc100 colormap save.png');
        
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
        %                 cBehavPlotPath = fullfile(cTunDataPath,'Behavior and uncertainty curve plot.png');
        %                 BehavPlotf = imread(cBehavPlotPath);
        exportToPPTX('addslide');
        
        % Anminfo
        exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 1],'FontSize',24);
        exportToPPTX('addnote',tline);
        exportToPPTX('addpicture',imread(PassRespMapMode),'Position',[0 1 4 3.4]);
        exportToPPTX('addpicture',imread(TaskRespMapMode),'Position',[4 1 4 3.4]);
        exportToPPTX('addpicture',imread(PassRespMapMean),'Position',[0 5 4 3.4]);
        exportToPPTX('addpicture',imread(TaskRespMapMean),'Position',[4 5 4 3.4]);
        
        exportToPPTX('addpicture',imread(CoupPassRespMapMode),'Position',[8 1 4 3.4]);
        exportToPPTX('addpicture',imread(CoupTaskRespMapMode),'Position',[12 1 4 3.4]);
        exportToPPTX('addpicture',imread(CoupPassRespMapMean),'Position',[8 5 4 3.4]);
        exportToPPTX('addpicture',imread(CoupTaskRespMapMean),'Position',[12 5 4 3.4]);
        
        exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
            Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
            'Position',[0 8.4 8 0.6],'FontSize',20);
        exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
            CoupAnmInfo.BatchNum,CoupAnmInfo.AnimalNum,CoupAnmInfo.SessionDate,CoupAnmInfo.TestNum),...
            'Position',[8 8.4 8 0.6],'FontSize',20);
    end
    m = m + 1;
    nSession = nSession + 1;
    saveName = exportToPPTX('saveandclose',pptFullfile);
    tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);

%% 
clearvars -except fn fp
nSession = 1;
SessBFSum = {};
%%
fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
%%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);
        continue;
    else
        CoupleSessPath = fgetl(ff);
        %
        Sess1CellBFStrc = load(fullfile(tline,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat'));
        Sess2CellBFStrc = load(fullfile(CoupleSessPath,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat'));
        
        Sess1TaskBF = Sess1CellBFStrc.TaskMaxOct;
        Sess1TaskBFAmp = Sess1CellBFStrc.TaskMaxAmp;
        Sess1PassBF = Sess1CellBFStrc.PassMaxOct;
        Sess1PassBFAmp = Sess1CellBFStrc.PassMaxAmp;
        
        Sess2TaskBF = Sess2CellBFStrc.TaskMaxOct;
        Sess2TaskBFAmp = Sess2CellBFStrc.TaskMaxAmp;
        Sess2PassBF = Sess2CellBFStrc.PassMaxOct;
        Sess2PassBFAmp = Sess2CellBFStrc.PassMaxAmp;
        
        USedROIs = min(numel(Sess1TaskBF),numel(Sess2TaskBF));
        SessBFSum{nSession,1} = Sess1TaskBF(1:USedROIs);
        SessBFSum{nSession,2} = Sess2TaskBF(1:USedROIs);
        SessBFSum{nSession,3} = [Sess1CellBFStrc.BehavBoundData,Sess2CellBFStrc.BehavBoundData];
        SessBFSum{nSession,4} = Sess1PassBF(1:USedROIs);
        SessBFSum{nSession,5} = [Sess1TaskBFAmp(:),Sess1PassBFAmp(:)];
        SessBFSum{nSession,6} = [Sess2TaskBFAmp(:),Sess2PassBFAmp(:)];
        
    end
    nSession = nSession + 1;
    tline = fgetl(ff);
end
fclose(ff);
%%
load('E:\DataToGo\data_for_xu\BoundShiftData\SessBlockBoundData.mat');
HighBoundDataAll = [];
LowBoundDataAll = [];
HighBoundDis = [];
LowBoundDis = [];
High2LowDis = [];
Low2HighDis = [];
nCoupSess = size(SessBFSum,1);
BehavBoundAll = zeros(nCoupSess,2); % lower bound for first column, and higher bound for second column
for cSess = 1 : nCoupSess
    cSessBlockInds = SessBlockBound(cSess);
    HighBoundDataAll = [HighBoundDataAll;SessBFSum{cSess,2 - cSessBlockInds(1)}];
    LowBoundDataAll = [LowBoundDataAll;SessBFSum{cSess,1 + cSessBlockInds(1)}];
    
    BehavBoundAll(cSess,1) = SessBFSum{cSess,3}(1 + cSessBlockInds(1));
    BehavBoundAll(cSess,2) = SessBFSum{cSess,3}(2 -  cSessBlockInds(1)); % high bound block
    
    HighBoundDis = [HighBoundDis;abs(SessBFSum{cSess,2 - cSessBlockInds(1)} - BehavBoundAll(cSess,2))];
    LowBoundDis = [LowBoundDis;abs(SessBFSum{cSess,1 + cSessBlockInds(1)} - BehavBoundAll(cSess,1))];
    High2LowDis = [High2LowDis;abs(SessBFSum{cSess,2 - cSessBlockInds(1)} - BehavBoundAll(cSess,1))];
    Low2HighDis = [Low2HighDis;abs(SessBFSum{cSess,1 + cSessBlockInds(1)} - BehavBoundAll(cSess,2))];
end
GrdistPlot(BehavBoundAll,{'Low','High'});

%% plot the BF to boundary distance
hf = figure('position',[3000 100 460 320]);
hold on
DataAlls = [HighBoundDis,High2LowDis,LowBoundDis,Low2HighDis];
DataDespStr = {'High','H2L','Low','L2H'};
lColor = jet(size(DataAlls,2));
lineh = [];
for cCol = 1 : size(DataAlls,2)
    [Cly,Clx] = ecdf(DataAlls(:,cCol));
    hl = plot(Clx,Cly,'Color',lColor(cCol,:),'linewidth',2);
    lineh = [lineh,hl];
end
legend(lineh,DataDespStr,'Location','NorthWest','Box','off');
GcaPos = get(gca,'position');
AxInsert = axes('position',[GcaPos(1)+GcaPos(3)*2/3,GcaPos(2)+0.06,GcaPos(3)/3,GcaPos(4)/2]);
hold(AxInsert, 'on');
Bary = mean(DataAlls);
BarySEM = std(DataAlls)/sqrt(size(DataAlls,1))*10;
bar(AxInsert,1 : size(DataAlls,2),Bary,0.7,'FaceColor',[.7 .7 .7],'edgecolor','none');
errorbar(AxInsert,1 : size(DataAlls,2),Bary,BarySEM,'ko','linewidth',1.4,'MarkerSize',4);
set(AxInsert,'xtick',1 : size(DataAlls,2),'xticklabel',DataDespStr','box','off');
ylabel(AxInsert,'Distance');

%% export files into one ppt
 % 
 clear
 clc
[fn,fp,fi] = uigetfile('*.txt','Please select the boundary shift sesison data path');
% clearvars -except fn fp
m = 1;
nSession = 1;

fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
%%
while ischar(tline) 
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);
        continue;
    else
        %
        if m == 1
            %
            %                 PPTname = input('Please input the name for current PPT file:\n','s');
            PPTname = 'BoundShift_SingleNeuTuning_withMorph';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
            %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
            pptSavePath = 'F:\TestOutputSave\BoundShiftSum';
            %
        end
        Anminfo = SessInfoExtraction(tline);
        cTunDataPath = [tline,filesep,'Tunning_fun_plot_New1s'];
        cRespColorMap = [tline,filesep,'All BehavType Colorplot'];
        TunFilesAll = dir(fullfile(cTunDataPath,'ROI* Tunning curve comparison plot.png'));
        nFiles = length(TunFilesAll);
        ColorFiles = dir(fullfile(cRespColorMap,'ROI* all behavType color plot.png'));
        [~,EndInds] = regexp(tline,'result_save');
        ROIposfilePath = tline(1:EndInds);
        cMorphfiles = fullfile(ROIposfilePath,'ROI_morph_plot');
        
        CoupleSessPath = fgetl(ff);
        CoupAnmInfo = SessInfoExtraction(CoupleSessPath);
        CoupcTunDataPath = [CoupleSessPath,filesep,'Tunning_fun_plot_New1s'];
        CoupcColorPath = [CoupleSessPath,filesep,'All BehavType Colorplot'];
        CoupTunFileAll = dir(fullfile(CoupcTunDataPath,'ROI* Tunning curve comparison plot.png'));
        CoupnFiles = length(CoupTunFileAll);
        CoupColorFiles = dir(fullfile(CoupcColorPath,'ROI* all behavType color plot.png'));
        [~,CoupEndInds] = regexp(CoupleSessPath,'result_save');
        CROIposfilePath = CoupleSessPath(1:CoupEndInds);
        CoupMorphfiles = fullfile(CROIposfilePath,'ROI_morph_plot');
        
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
        for cf = 1 : nCompareFiles
            exportToPPTX('addslide');
            cfColorPlot = fullfile(cRespColorMap,sprintf('ROI%d all behavType color plot.png',cf));
            cfTunName = fullfile(cTunDataPath,sprintf('ROI%d Tunning curve comparison plot.png',cf));
            cfMorph = fullfile(cMorphfiles,sprintf('ROI%d morph plot save.png',cf));
            % Anminfo
            exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 0.5],'FontSize',24);
            exportToPPTX('addnote',tline);
            exportToPPTX('addpicture',imread(cfColorPlot),'Position',[0 0.5 8 5.3]);
            exportToPPTX('addpicture',imread(cfMorph),'Position',[0 6.6 2.8 2.1]);
            exportToPPTX('addpicture',imread(cfTunName),'Position',[2.5 6.2 3.5 2.6]);
            
            CoupColorPlot = fullfile(CoupcColorPath,sprintf('ROI%d all behavType color plot.png',cf));
            CoupleTunName = fullfile(CoupcTunDataPath,sprintf('ROI%d Tunning curve comparison plot.png',cf));
            CouplrMorph = fullfile(CoupMorphfiles,sprintf('ROI%d morph plot save.png',cf));
            
            exportToPPTX('addpicture',imread(CoupColorPlot),'Position',[8 0.5 8 5.3]);
            exportToPPTX('addpicture',imread(CouplrMorph),'Position',[13.2 6.6 2.5 2.1]);
            exportToPPTX('addpicture',imread(CoupleTunName),'Position',[10 6.2 3.5 2.6]);

            exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
                Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                'Position',[6 6.5 2 2],'FontSize',20);
            exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
                CoupAnmInfo.BatchNum,CoupAnmInfo.AnimalNum,CoupAnmInfo.SessionDate,CoupAnmInfo.TestNum),...
                'Position',[8 6.5 2 2],'FontSize',20);
            %
        end
        %
    end
    m = m + 1;
    nSession = nSession + 1;
    saveName = exportToPPTX('saveandclose',pptFullfile);
    tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);