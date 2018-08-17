
clear;
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the boundary shift data savage file');
if ~fi
    return;
end

fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
%%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);
        continue;
    end
    %
    CoupleSessPath = fgetl(ff);
    %
    ChoiceClfDataPath = fullfile(tline,'ChoiceTrClfModel.mat');
    CoupChoiceClfDataPath = fullfile(CoupleSessPath,'ChoiceTrClfModel.mat');
    try
        ChoiceClfDatas = load(ChoiceClfDataPath);
        CoupChoiceClfDatas = load(CoupChoiceClfDataPath);
        
        SessAlphaTrainData = ChoiceClfDatas.NormTrainMd.X;
        SessAlphaTrainLabel = ChoiceClfDatas.NormTrainMd.Y;
        
        SessBetaTrainData = CoupChoiceClfDatas.NormTrainMd.X;
        SessBetaTrainLabel = CoupChoiceClfDatas.NormTrainMd.Y;
        
        if size(SessAlphaTrainData,2) ~= size(SessBetaTrainData,2)
            warning('Unequal number of ROIs for two coupled sessions');
            tline = fgetl(ff);
            continue;
        end
        AlphaPredBetaLabel = predict(ChoiceClfDatas.NormTrainMd,SessBetaTrainData);
        AlphaPredBetaPerf = AlphaPredBetaLabel(:) == SessBetaTrainLabel(:);
        
        BetaPredAlphaLabel = predict(CoupChoiceClfDatas.NormTrainMd,SessAlphaTrainData);
        BetaPredAlphaPerf = BetaPredAlphaLabel(:) == SessAlphaTrainLabel(:);
        
        AlphaStims = ChoiceClfDatas.StimsAll;
        BetaStims = CoupChoiceClfDatas.StimsAll;
        AlphaOcts = log2(unique(AlphaStims)/16000);
        BetaOcts = log2(unique(BetaStims)/16000);
        
        hf = figure('position',[2000 100 800 350]);
        
        % calculate the alpha stim prediction error
        AlphaStimTypes = unique(AlphaStims);
        AlphaStimNums = length(AlphaStimTypes);
        AlphaStimAccuracy = zeros(AlphaStimNums,1);
        for cStim = 1 : AlphaStimNums
            cStimInds = AlphaStims == AlphaStimTypes(cStim);
            AlphaStimAccuracy(cStim) = mean(BetaPredAlphaPerf(cStimInds));
        end
        subplot(121)
        hold on
        hl1 = plot(AlphaOcts,AlphaStimAccuracy,'b-o');
        hl2 = plot(AlphaOcts,ChoiceClfDatas.BehavRProb,'k-o');
        hl3 = plot(AlphaOcts,ChoiceClfDatas.ChoiceNorScore,'r-o');
        legend([hl1,hl2,hl3],{'PredAccu','AlphaBehav','AlphaNeuro'},'Location','Northwest','Box','off');
        set(gca,'ylim',[0 1]);
        xlabel('Octave');
        ylabel('R_Prob/CrossPredAccu');
        
        % calculate the beta stim prediction error
        BetaStimTypes = unique(BetaStims);
        BetaStimNums = length(BetaStimTypes);
        BetaStimAccuracy = zeros(BetaStimNums,1);
        for cStim = 1 : BetaStimNums
            cStimInds = BetaStims == BetaStimTypes(cStim);
            BetaStimAccuracy(cStim) = mean(AlphaPredBetaPerf(cStimInds));
        end
        subplot(122)
        hold on
        hl4 = plot(BetaOcts,BetaStimAccuracy,'b-o');
        hl5 = plot(BetaOcts,CoupChoiceClfDatas.BehavRProb,'k-o');
        hl6 = plot(BetaOcts,CoupChoiceClfDatas.ChoiceNorScore,'r-o');
        legend([hl1,hl2,hl3],{'PredAccu','BetaBehav','BetaNeuro'},'Location','Northwest','Box','off');
        set(gca,'ylim',[0 1]);
        xlabel('Octave');
        ylabel('R_Prob/CrossPredAccu');
        
        FigSavePath = [tline,filesep,'Cross prediction accuracy plots'];
        saveas(hf,FigSavePath,'fig');
        saveas(hf,FigSavePath,'png');
        close(hf);
    catch ME
        warning('Error occurs for session:\n%s\n%s',tline,ME.message);
    end
    %
    tline = fgetl(ff);
    
end

%%
clearvars -except fn fp
m = 1;
fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);
        continue;
    end
    %
    CoupleSessPath = fgetl(ff);
    
    if m == 1
        %
        %                 PPTname = input('Please input the name for current PPT file:\n','s');
        PPTname = 'CrossSession_prediction_summary';
        if isempty(strfind(PPTname,'.ppt'))
            PPTname = [PPTname,'.pptx'];
        end
        %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
        pptSavePath = 'F:\TestOutputSave\BoundShiftSum';
        %
    end
    Anminfo = SessInfoExtraction(tline);
    cfilePath = fullfile(tline,'Cross prediction accuracy plots.png');
    
    if ~exist(cfilePath,'file')
        warning('No file exists for session:\n %s\n',tline);
        tline = fgetl(ff);
        continue;
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
    
    % Anminfo
    exportToPPTX('addtext',sprintf('Session%d',m),'Position',[2 0 2 1],'FontSize',22);
    exportToPPTX('addnote',tline);
    exportToPPTX('addnote',CoupleSessPath);
    exportToPPTX('addpicture',imread(cfilePath),'Position',[0.5 1.5 10 4.38]);
    
    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s\r\nDate: %s Field: %s',...
        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
        'Position',[6 7.3 5 1.5],'FontSize',22);
    
    m = m + 1;
    saveName = exportToPPTX('saveandclose',pptFullfile);
    tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);