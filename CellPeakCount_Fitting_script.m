clear
clc
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
CellCountFit = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    
    %% passive tuning frequency colormap plot
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
    ROIcenters = ROI_insite_label(ROIinfoData,0);
    
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    
    %Passive Tuning Octave
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    UsedOctaveData = PassTunningfun(UsedOctaveInds,:);
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    PassMaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        PassMaxIndsOctave(cROI) = UsedOctave(maxInds(cROI));
    end
    %%
    PassOctavesType = unique(PassMaxIndsOctave);
    IterTypeNumData = zeros(50,length(PassOctavesType));
    
    for cIter = 1 : 50
        cIterInds = randsample(nROIs,nROIs,true);
        
        PassOctaveTypeNum = zeros(length(PassOctavesType),1);
        for n = 1 : length(PassOctavesType)
            PassOctaveTypeNum(n) = sum(PassMaxIndsOctave(cIterInds) == PassOctavesType(n));
        end
        IterTypeNumData(cIter,:) = PassOctaveTypeNum;
    end
    MeanIterTypeNum = mean(IterTypeNumData);
    IterTypeOcts = repmat(PassOctavesType',50,1);
    %
    OctaveData = PassOctavesType;
    NorTundata = MeanIterTypeNum;
    modelfunc = @(c1,c2,c3,c4,c5,c6,c7,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4+c5*exp((-1)*((x - c6).^2)./(2*(c7^2)));
    [Value,Inds] = sort(MeanIterTypeNum,'descend');
    [AmpV,AmpInds] = max(MeanIterTypeNum);
    c0 = [AmpV,OctaveData(AmpInds),mean(abs(diff(OctaveData))),min(NorTundata),Value(2),OctaveData(Inds(2)),mean(abs(diff(OctaveData)))];  % 0.4 is the octave step
    cUpper = [AmpV*2,max(OctaveData),max(OctaveData) - min(OctaveData),AmpV,AmpV*2,max(OctaveData),max(OctaveData) - min(OctaveData)];
    cLower = [min(NorTundata),min(OctaveData),0,-Inf,min(NorTundata),min(OctaveData),0];
    [ffit,gof] = fit(IterTypeOcts(:),IterTypeNumData(:),modelfunc,...
       'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
    PassOctRange = linspace(min(PassOctavesType),max(PassOctavesType),500);
    PassFitData = feval(ffit,PassOctRange(:));
    
    %
    % task Tuning Octave
    TaskUsedOctave = TaskFreqOctave(:);
    TaskUsedOctaveData = CorrTunningFun;
    nROIs = size(TaskUsedOctaveData,2);
    [MaxAmp,maxInds] = max(TaskUsedOctaveData);
    TaskMaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        TaskMaxIndsOctave(cROI) = TaskUsedOctave(maxInds(cROI));
    end
    
    TaskIterTypeNum = zeros(50,length(TaskUsedOctave));
    TaskOctaveTypeNum = zeros(length(TaskUsedOctave),1);
    for cIter = 1 : 50
        cIterInds = randsample(nROIs,nROIs,true);
        for n = 1 : length(TaskUsedOctave)
            TaskOctaveTypeNum(n) = sum(TaskMaxIndsOctave(cIterInds) == TaskUsedOctave(n));
        end
        TaskIterTypeNum(cIter,:) = TaskOctaveTypeNum;
    end
    MeantaskTypeNum = mean(TaskIterTypeNum);
    IterTaskOctAll = repmat(TaskUsedOctave',50,1);
    % fit data
    OctaveData = TaskUsedOctave;
    NorTundata = MeantaskTypeNum;
    modelfunc = @(c1,c2,c3,c4,c5,c6,c7,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4+c5*exp((-1)*((x - c6).^2)./(2*(c7^2)));
    [Value,Inds] = sort(MeantaskTypeNum,'descend');
    [AmpV,AmpInds] = max(MeantaskTypeNum);
    c0 = [AmpV,OctaveData(AmpInds),mean(abs(diff(OctaveData))),min(NorTundata),Value(2),OctaveData(Inds(2)),mean(abs(diff(OctaveData)))];  % 0.4 is the octave step
    cUpper = [AmpV*2,max(OctaveData),max(OctaveData) - min(OctaveData),AmpV,AmpV*2,max(OctaveData),max(OctaveData) - min(OctaveData)];
    cLower = [min(NorTundata),min(OctaveData),0,-Inf,min(NorTundata),min(OctaveData),0];
    [Taskffit,Taskgof] = fit(IterTaskOctAll(:),TaskIterTypeNum(:),modelfunc,...
       'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
    TaskOctRange = linspace(min(TaskUsedOctave),max(TaskUsedOctave),500);
    TaskFitData = feval(Taskffit,TaskOctRange(:));
    PassFitCellCount = feval(ffit,TaskUsedOctave(:));
    %
    hf = figure('position',[100 100 380 300]);
    hold on
    plot(TaskOctRange,TaskFitData,'r','linewidth',1.6);
    plot(TaskUsedOctave,MeantaskTypeNum,'ro','markerSize',14,'linewidth',2);

    plot(PassOctRange,PassFitData,'k','linewidth',1.6);
    plot(PassOctavesType,MeanIterTypeNum,'ko','markerSize',14,'linewidth',2);
    yscales = get(gca,'ylim');
    line([BehavBoundData BehavBoundData],yscales,'Color',[.7 .7 .7],'Linewidth',2.4,'linestyle','--');
    text(BehavBoundData,yscales(2)*0.9,'BehavBound','FontSize',12);
    
    xlabel('Octaves');
    ylabel('Cell Count');
    set(gca,'FontSize',16);
    
    
    CellCountFit{m,1} = MeantaskTypeNum;
    CellCountFit{m,2} = MeanIterTypeNum;
    CellCountFit{m,3} = PassFitCellCount;
    CellCountFit{m,4} = BehavBoundData;
    CellCountFit{m,5} = TaskUsedOctave;
    CellCountFit{m,6} = PassOctavesType;
    if ~isdir('CellPeakCount_fitData')
        mkdir('CellPeakCount_fitData');
    end
    cd('CellPeakCount_fitData');
    
    saveas(hf,'celllcount fitting comparison plot');
    saveas(hf,'celllcount fitting comparison plot','png');
    close(hf);
    
    save CllCountFitSave.mat Taskffit ffit PassOctavesType TaskUsedOctave MeantaskTypeNum MeanIterTypeNum PassFitCellCount -v7.3
    cd ..;
    
    tline = fgetl(fid);
    m = m + 1;
end

%%
cd('E:\DataToGo\data_for_xu\CellTunPeak_fitSummary');
save SessFitFracSave.mat CellCountFit -v7.3
%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
m = 1;
SessPeakPos = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end

end
%%
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
        if m == 1
            %
            PPTname = input('Please input the name for current PPT file:\n','s');
%             PPTname = 'testuncertaintySave_20171214Add_GrayColor';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
            pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
%             pptSavePath = 'F:\TestOutputSave\SigROITest';
            %
        end
            Anminfo = SessInfoExtraction(tline);
            cTunDataPath = fullfile(tline,'Tunning_fun_plot_New1s','CellPeakCount_fitData');
            ClfColorplotf = fullfile(cTunDataPath,'celllcount fitting comparison plot.png');
%             OneStepCompare = fullfile(cTunDataPath,'OneStep classification accuracy comparison.png');
            
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

            exportToPPTX('addslide');
            % Anminfo
            exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 1],'FontSize',24);
            exportToPPTX('addnote',tline);
            exportToPPTX('addpicture',imread(ClfColorplotf),'Position',[3 2 6 4.74]);

            exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s \r\nField: %s',...
                Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                'Position',[10 2 4 4],'FontSize',24);
    end
     m = m + 1;
     nSession = nSession + 1;
     saveName = exportToPPTX('saveandclose',pptFullfile);
     tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);


%% cell type fraction analysis
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
m = 1;
SessFracCellData = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    SessFracData = struct();
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
    ROIcenters = ROI_insite_label(ROIinfoData,0);
    ROIDisMtx = squareform(pdist(ROIcenters));
    
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    SessFracData.BehavBound = BehavBoundData;
    
    %Passive Tuning Octave
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    UsedOctaveData = PassTunningfun(UsedOctaveInds,:);
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    PassMaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        PassMaxIndsOctave(cROI) = UsedOctave(maxInds(cROI));
    end
    %
    PassOctavesType = UsedOctave;

    PassOctaveTypeNum = zeros(length(PassOctavesType),1);
    for n = 1 : length(PassOctavesType)
        PassOctaveTypeNum(n) = sum(PassMaxIndsOctave == PassOctavesType(n));
    end
    PassOctTypeFrac = PassOctaveTypeNum/sum(PassOctaveTypeNum);
    [SortCellCOunt,SortInds] = sort(PassOctTypeFrac,'descend');
    PassToptwoOctave = PassOctavesType(SortInds(1:2));
    SessFracData.PassTTwoFrac = SortCellCOunt(1:2);
    SessFracData.PassTTwoOct = PassToptwoOctave;
    
    for cROI = 1 : nROIs
        cROIDis = ROIDisMtx(cROI,:);
        [DisSortV, DisSortInds] = sort(cROIDis);
        Near5Inds = DisSortInds(2:6);
        Near5ROIoctaves = PassMaxIndsOctave(Near5Inds);
        ROINearOctSameFracPass(cROI) = mean(Near5ROIoctaves == PassMaxIndsOctave(cROI));
    end
    
    %
    % task Tuning Octave
    TaskUsedOctave = TaskFreqOctave(:);
    TaskUsedOctaveData = CorrTunningFun;
    nROIs = size(TaskUsedOctaveData,2);
    [MaxAmp,maxInds] = max(TaskUsedOctaveData);
    TaskMaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        TaskMaxIndsOctave(cROI) = TaskUsedOctave(maxInds(cROI));
    end
    TaskOctaveTypeNum = zeros(length(TaskUsedOctave),1);
    for n = 1 : length(TaskUsedOctave)
        TaskOctaveTypeNum(n) = sum(TaskMaxIndsOctave == TaskUsedOctave(n));
    end
    TaskOctTypeFrac = TaskOctaveTypeNum/sum(TaskOctaveTypeNum);
    [TaskSortCCount,TaskSortInds] = sort(TaskOctTypeFrac,'descend');
    TaskToptwoOctave = TaskUsedOctave(TaskSortInds(1:2));
    SessFracData.TaskTTwoFrac = TaskSortCCount(1:2);
    SessFracData.TaskTTwoOct = TaskToptwoOctave;
    SessFracData.TaskRandFrac = 1 / length(TaskUsedOctave);
    SessFracData.PassRandFrac = 1 / length(PassOctavesType);
    
    ROINearOctSameFracTask = zeros(nROIs,1);
    ROINearOctSameFracPass = zeros(nROIs,1);
    ShufFracTask = zeros(nROIs,100);
    ShufFracPass = zeros(nROIs,100);
    for cROI = 1 : nROIs
        cROIDis = ROIDisMtx(cROI,:);
        [DisSortV, DisSortInds] = sort(cROIDis);
        Near5Inds = DisSortInds(2:6);
        Near5ROIoctaves = TaskMaxIndsOctave(Near5Inds);
        ROINearOctSameFracTask(cROI) = mean(Near5ROIoctaves == TaskMaxIndsOctave(cROI));
        
        Near5ROIoctaves = PassMaxIndsOctave(Near5Inds);
        ROINearOctSameFracPass(cROI) = mean(Near5ROIoctaves == PassMaxIndsOctave(cROI));
        parfor iter = 1 : 100
            TaskShufTunOct = Vshuffle(TaskMaxIndsOctave);
            PassShufTunOct = Vshuffle(PassMaxIndsOctave);
            Near5ROIoctaves = TaskShufTunOct(Near5Inds);
            ShufFracTask(cROI,iter) = mean(Near5ROIoctaves == TaskShufTunOct(cROI));
            
            Near5ROIoctaves = PassShufTunOct(Near5Inds);
            ShufFracPass(cROI,iter) = mean(Near5ROIoctaves == PassShufTunOct(cROI));
        end
    end
    SessFracData.NearCellSameFrac = [ROINearOctSameFracTask(:),ROINearOctSameFracPass(:)];
    SessFracData.TaskShuf = mean(ShufFracTask,2);
    SessFracData.PassShuf = mean(ShufFracPass,2);
    %
    SessFracCellData{m} = SessFracData;
    tline = fgetl(fid);
    m = m + 1;
end
cd('E:\DataToGo\data_for_xu\CellTunPeak_fitSummary');
save SessFracSummary.mat SessFracCellData -v7.3
%%
SessNum = length(SessFracCellData);
TaskMaxTwoFrac = zeros(SessNum,2);
PassMaxTwoFrac = zeros(SessNum,2);
TaskMaxTwoOcts = zeros(SessNum,2);
PassMaxTwoOcts = zeros(SessNum,2);
SessBehavBoundary = zeros(SessNum,1);
TaskPassRandFrac = zeros(SessNum,2);
TaskNearSameFrac = [];
PassNearSameFrac = [];
TaskNearShufFrac = [];
PassNearShufFrac = [];

for cSess = 1 : SessNum
    cSesData = SessFracCellData{cSess};
    TaskMaxTwoFrac(cSess,:) = cSesData.TaskTTwoFrac;
    PassMaxTwoFrac(cSess,:) = cSesData.PassTTwoFrac;
    TaskMaxTwoOcts(cSess,:) = cSesData.TaskTTwoOct;
    PassMaxTwoOcts(cSess,:) = cSesData.PassTTwoOct;
    SessBehavBoundary(cSess) = cSesData.BehavBound;
    TaskPassRandFrac(cSess,:) = [cSesData.TaskRandFrac, cSesData.PassRandFrac];
    TaskNearSameFrac = [TaskNearSameFrac;cSesData.NearCellSameFrac(:,1)];
    PassNearSameFrac = [PassNearSameFrac;cSesData.NearCellSameFrac(:,2)];
    TaskNearShufFrac = [TaskNearShufFrac;cSesData.TaskShuf];
    PassNearShufFrac = [PassNearShufFrac;cSesData.PassShuf];
end
%% Top two frac octave distance
TaskTwoFracOctDiff = abs(TaskMaxTwoOcts(:,1) - TaskMaxTwoOcts(:,2));
PassTwoFracOctDiff = abs(PassMaxTwoOcts(:,1) - PassMaxTwoOcts(:,2));
CombinedData = [TaskTwoFracOctDiff,PassTwoFracOctDiff];
OctaveDifSEM = std(CombinedData)/sqrt(size(CombinedData,1));
[~,p] = ttest(TaskTwoFracOctDiff,PassTwoFracOctDiff);
hhf = figure('position',[3200 100 380 300]);
hold on
plot([1,2],CombinedData,'Color',[.7 .7 .7],'Linewidth',1.6);
SEMbar = errorbar([0.9 2.1],mean(CombinedData),OctaveDifSEM,'ko','linewidth',2);
set(gca,'xtick',[1,2],'xticklabel',{'Task','Pass'},'xlim',[0.5 2.5]);
hhf = GroupSigIndication([1,2],max(CombinedData),p,hhf);
set(gca,'FontSize',14);
title('Sess top two frac octave distance');
saveas(hhf,'Top two frac octave distance plot');
saveas(hhf,'Top two frac octave distance plot','pdf');
saveas(hhf,'Top two frac octave distance plot','png');

%% plot the fraction compared with random value
TaskMaxTwoFracAboveRand = TaskMaxTwoFrac - repmat(TaskPassRandFrac(:,1),1,2);
PassMaxTwoFracAboveRand = PassMaxTwoFrac - repmat(TaskPassRandFrac(:,2),1,2);
TaskSEM = std(TaskMaxTwoFracAboveRand)./sqrt(size(TaskMaxTwoFracAboveRand,1));
PassSEM = std(PassMaxTwoFracAboveRand)./sqrt(size(PassMaxTwoFracAboveRand,1));
[~,ppp] = ttest([TaskMaxTwoFracAboveRand,PassMaxTwoFracAboveRand]);
hhf = figure('position',[100 100 380 300]);
hold on
TaskBar = bar([0.8 1.8],mean(TaskMaxTwoFracAboveRand),0.4,'EdgeColor','none','FaceColor',[1 .7 .2]);
PassBar = bar([1.2,2.2],mean(PassMaxTwoFracAboveRand),0.4,'EdgeColor','none','FaceColor',[.5 .5 .5]);
errorbar([0.8 1.8],mean(TaskMaxTwoFracAboveRand),TaskSEM,'mo','Linewidth',2.2);
errorbar([1.2 2.2],mean(PassMaxTwoFracAboveRand),PassSEM,'ko','Linewidth',2.2);
set(gca,'xtick',[1,2],'xticklabel',{'MaxFrac.','SecondFrac.'},'xlim',[0.5 2.5]);

GroupSigIndication([0.8 2.2],max([mean(TaskMaxTwoFracAboveRand);mean(PassMaxTwoFracAboveRand)]),max(ppp),hhf);
lgd = legend([TaskBar,PassBar],{'Task','Pass'},'FontSize',9,'Box','off');
cLgdPos = get(lgd,'position');
set(lgd,'position',cLgdPos+[0 -0.2 0 0]);
ylabel('Frac Above chance level');
set(gca,'FontSize',14);
% saveas(hhf,'Task Passive Fraction compare with chance value')
% saveas(hhf,'Task Passive Fraction compare with chance value','png')

%% calculate the nearby octave fraction
[TaskNearSamey,TaskNearSamex] = ecdf(TaskNearSameFrac);
[PassNearSamey,PassNearSamex] = ecdf(PassNearSameFrac);
[TaskNearShufy,TaskNearShufx] = ecdf(TaskNearShufFrac);
[PassNearShufy,PassNearShufx] = ecdf(PassNearShufFrac);
Task_p = ranksum(TaskNearSameFrac,TaskNearShufFrac);
Pass_p = ranksum(PassNearSameFrac,PassNearShufFrac);
hf = figure;
hold on
Tl = plot(TaskNearSamex,TaskNearSamey,'Color',[1 0.7 0.2],'linewidth',2.4);
Pl = plot(PassNearSamex,PassNearSamey,'Color','k','linewidth',2.4);
plot(TaskNearShufx,TaskNearShufy,'Color',[1 0.8 0.6],'linewidth',2);
plot(PassNearShufx,PassNearShufy,'Color',[.7 .7 .7],'linewidth',2);
set(gca,'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
xlabel('SameCluster Frac.');
ylabel('Cumulative Frac.');
set(gca,'FontSize',16);
legend([Tl,Pl],{sprintf('Task p = %.3e',Task_p),sprintf('Pass p = %.3e',Pass_p)},'location','Southeast','FontSize',9,...
    'Box','off','AutoUpdate','off');
title({sprintf('Task %.4f std %.4f',mean(TaskNearSameFrac),std(TaskNearSameFrac));...
    sprintf('Pass %.4f std %.4f',mean(PassNearSameFrac),std(PassNearSameFrac))});
% saveas(hf,'Near cell same tuning peak fraction');
% saveas(hf,'Near cell same tuning peak fraction','png');

%% calculate the top two fraction compared with 0.5
TaskTopTwoSum = sum(TaskMaxTwoFrac,2);
PassTopTwoSum = sum(PassMaxTwoFrac,2);
TaskSEM = std(TaskTopTwoSum)./sqrt(size(TaskTopTwoSum,1));
PassSEM = std(PassTopTwoSum)./sqrt(size(PassTopTwoSum,1));
[~,ppp] = ttest([TaskTopTwoSum,PassTopTwoSum]);
hhf = figure('position',[100 100 380 300]);
hold on
TaskBar = bar(0.8,mean(TaskTopTwoSum),0.3,'EdgeColor','none','FaceColor',[1 .7 .2]);
PassBar = bar(1.2,mean(PassTopTwoSum),0.3,'EdgeColor','none','FaceColor',[.5 .5 .5]);
% errorbar([0.8 1.8],mean(TaskTopTwoSum),TaskSEM,'mo','Linewidth',2.2);
errorbar([0.8 1.2],[mean(TaskTopTwoSum),mean(PassTopTwoSum)],[TaskSEM,PassSEM],'ko','Linewidth',2.2);
set(gca,'xlim',[0 2],'xticklabel','TopTwoFracSum','xTick',1);
line([0.5 1.5],[0.5 0.5],'Color','m','Linewidth',2,'Linestyle','--');
GroupSigIndication([0.8 1.2],[mean(TaskTopTwoSum),mean(PassTopTwoSum)],max(ppp),hhf);
lgd = legend([TaskBar,PassBar],{'Task','Pass'},'FontSize',9,'Box','off');
% cLgdPos = get(lgd,'position');
% set(lgd,'position',cLgdPos+[0 -0.2 0 0]);
ylabel('TopTwo Fraction');
set(gca,'FontSize',14);
saveas(hhf,'Task Passive TopTwp fraction sum')
saveas(hhf,'Task Passive TopTwp fraction sum','png')
saveas(hhf,'Task Passive TopTwp fraction sum','pdf')
