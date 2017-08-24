clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'\All BehavType Colorplot','\');
    else
        SessPath = tline;
    end
    load(fullfile(SessPath,'CSessionData.mat'));
    cd(SessPath);
    AnsTimeAlignPlot(data_aligned,behavResults,1,frame_rate,trial_outcome,1); 
    
    AnsDataPath = [SessPath,'\AnsTime_Align_plot'];
    cd(AnsDataPath);
    if exist('AnsAlignData.mat','file')
        load('AnsAlignData.mat');
        TrOctaves = log2(NMStimFreq/16000);
        InputData = AnsAlignData;
        nROIs = size(AnsAlignData,2);
        nFrames = size(AnsAlignData,3);
        TrAnsChice = NMChoice(:);
        TrAnsOutcome = NMOutcome(:);
    else
        load('EarlyAnsAlignSave.mat');
        TrOctaves = log2(EarlyAnsStimFreq/16000);
        InputData = EarlyAnsAlignData;
        nROIs = size(EarlyAnsAlignData,2);
        nFrames = size(EarlyAnsAlignData,3);
        TrAnsChice = EarlyAnsChoice(:);
        TrAnsOutcome = EarlyAnsOutcome(:);
    end
    
    pValueMatrix = zeros(nROIs,nFrames,3);
    for cROI = 1 : nROIs
        cROIdata = squeeze(InputData(:,cROI,:));
        for nf = 1 : nFrames
            cFrameData = cROIdata(:,nf);
            p = anovan(cFrameData,{TrOctaves(:),TrAnsChice,TrAnsOutcome},'display','off');
             pValueMatrix(cROI,nf,:) = p;
        end
    end
    save AnsAnovanPsave.mat pValueMatrix -v7.3
    %
    if ~isdir('./ROIsig_plot/')
        mkdir('./ROIsig_plot/');
    end
    cd('./ROIsig_plot/');
    pSigPlotMtx = pValueMatrix < 0.01;
    nFrames = size(pSigPlotMtx,2);
    xticks = 0:frame_rate:nFrames;
    xticklabels = xticks/frame_rate;
%     SoundOffFrame = start_frame + 0.3*frame_rate;
    for nr = 1 : nROIs
        cROIMtx = squeeze(pSigPlotMtx(nr,:,:));
        hf = figure('position',[700 150 580 900]);
        subplot(2,1,1);
        imagesc(cROIMtx');
        line([MinAnsF MinAnsF],[0.5,3.5],'Color',[.7 .7 .7],'linewidth',1.2);
        set(gca,'xlim',[0.5 0.5 + nFrames],'ylim',[0.5 3.5],'FontSize',14);
        set(gca,'ytick',1:3,'yticklabel',{'Freq','Choice','Reward'},'xtick',xticks,'xticklabel',xticklabels);
        xlabel('Time (s)');
        title(sprintf('ROI%d coef plot',nr));

        logpMtxPlot = (-1)*log10(squeeze(pValueMatrix(nr,:,:)));
        SmooLogp = zeros(size(logpMtxPlot));
        for nnn = 1 : size(cROIMtx,2);
            SmooLogp(:,nnn) = smooth(logpMtxPlot(:,nnn));
        end
        subplot(2,1,2);
        hold on
        hl1 = plot(SmooLogp(:,1),'r','linewidth',1.6);
        hl2 = plot(SmooLogp(:,2),'b','linewidth',1.6);
        hl3 = plot(SmooLogp(:,3),'k','linewidth',1.6);
        yscales = get(gca,'ylim');
        xscales = get(gca,'xlim');
        line([MinAnsF,MinAnsF],yscales,'Color',[.7 .7 .7],'linewidth',1.4);
        line(xscales,[2 2],'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
%         line([SoundOffFrame SoundOffFrame],yscales,'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
        text(xscales(2)*0.9,2,'p = 0.01','FontSize',16);
        set(gca,'xtick',xticks,'xticklabel',xticklabels,'ytick',[],'FontSize',18);
        set(gca,'xlim',xscales,'ylim',yscales);
        legend([hl1,hl2,hl3],{'Sound','Choice','Reward'},'FontSize',16);
        legend('boxoff');
        xlabel('Time (s)');
        ylabel('-Log(P)');
        title(sprintf('ROI%d anovan logP',nr));

        saveas(hf,sprintf('ROI%d coef sigPlot',nr));
        saveas(hf,sprintf('ROI%d coef sigPlot',nr),'png');
        close(hf);
    end
    tline = fgetl(fid);
end

%%
m = 1;
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'\All BehavType Colorplot','\AnsTime_Align_plot');
    else
        SessPath = [tline,'\AnsTime_Align_plot'];
    end
    cd(SessPath);
    AnsRespfig = dir('*.png');
    AnspValuefig = dir('.\ROIsig_plot\*.png');
    if length(AnsRespfig) ~= length(AnspValuefig)
        error('ROI response plot figure is unequal with anovan plots number.');
    end
    
    if m == 1
        PPTname = input('Please input the pptx file name:\n','s');
        if isempty(strfind(PPTname,'.ppt')) || isempty(strfind(PPTname,'.pptx'))
            PPTname = [PPTname,'.pptx'];
        end
        SavePath = uigetdir(pwd,'Please select a path to save the ppt file');
    end
    pptfullname = fullfile(SavePath,PPTname);
    if ~exist(pptfullname,'file')
         exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of session aligned sort plots');
    else
        exportToPPTX('open',pptfullname);
    end
    
    nfiles = length(AnsRespfig);
    for nfile = 1 : nfiles
        RespName = AnsRespfig(nfile).name;
        PvalueName = AnspValuefig(nfile).name;
        Respfid = imread(RespName);
        pValuefid = imread([SessPath,'\ROIsig_plot\',PvalueName]);
        exportToPPTX('addslide');
        exportToPPTX('addtext',RespName(1:end-4),'Position',[0 0 4 1.5],'FontSize',24);
        exportToPPTX('addnote',SessPath);
        exportToPPTX('addpicture',Respfid,'Position',[5 1 11 7.875]);
        exportToPPTX('addpicture',pValuefid,'Position',[0 1.5 5 7.7]);
    end
    m = m + 1;
    SaveName = exportToPPTX('saveandclose',pptfullname);
    
    tline = fgetl(fid);
end
