% scripts used for all ROI neurometric curve plot
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the random puretone session data path');

if ~fi
    return;
end
Filepath = fullfile(fp,fn);
fid = fopen(Filepath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    cSessPath = strrep(tline,'\NeuroM_test\AfterTimeLength-1500ms\NMDataSummry.mat;','\');
    try
        cd(cSessPath);
        load('CSessionData.mat');
        SingleNeuROCSfun(data_aligned,behavResults,frame_rate,start_frame,trial_outcome);
    catch ME
        fprintf('Session ##%s## share following error.\n',cSessPath);
        fprintf('%s.\n',ME.message);
    end
    tline = fgetl(fid);
end

%%
% scripts used for all ROI neurometric curve plot
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the random puretone session data path');
if ~fi
    return;
end
PPTname = input('Please input the name for current PPT file:\n','s');
if isempty(strfind(PPTname,'.ppt'))
    PPTname = [PPTname,'.pptx'];
end
pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');

if exist(fullfile(pptSavePath,PPTname),'file')
    delete(fullfile(pptSavePath,PPTname));
end
exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
% IsNewPPt = 0;
Filepath = fullfile(fp,fn);
fid = fopen(Filepath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    cSessPath = strrep(tline,'\NeuroM_test\AfterTimeLength-1500ms\NMDataSummry.mat;','\Single_ROI_neurometric');
%     if IsNewPPt
%         exportToPPTX('open',fullfile(pptSavePath,PPTname));
%     else
%         
%          IsNewPPt = 1;
%     end
    try
        cd(cSessPath);
        AUCDataStrc = load('ROIpairedAUCsave.mat');
        %
        nROIs = size(AUCDataStrc.ROIpairedAUcValue,1);
        GroupPairNum = floor(size(AUCDataStrc.ROIpairedAUcValue,2)/2);
        PerferAUC = zeros(size(AUCDataStrc.ROIpairedAUcValue));
        isROIsig = zeros(nROIs,1);
        for cROI = 1 : nROIs
            cROIAUC = AUCDataStrc.ROIpairedAUcValue(cROI,:);
            if cROIAUC(1:GroupPairNum) >= cROIAUC(end-GroupPairNum+1:end)
                PerferAUC(cROI,:) = fliplr(cROIAUC);
            else
                PerferAUC(cROI,:) = cROIAUC;
            end
            if (mean(PerferAUC(cROI,end-GroupPairNum+1:end)) - mean(PerferAUC(cROI,1:GroupPairNum))) > 0.5
                isROIsig(cROI) = 1;
            end
        end
        %
        BehavPath = strrep(tline,'\NeuroM_test\AfterTimeLength-1500ms\NMDataSummry.mat;','\RandP_data_plots');
        BehavDataStrc = load(fullfile(BehavPath,'boundary_result.mat'));
        %
        BehavCorrAll = BehavDataStrc.boundary_result.StimCorr;
        BehavCorrAll(1:GroupPairNum) = 1 - BehavCorrAll(1:GroupPairNum);
        SessStimOctave = log2(double(BehavDataStrc.boundary_result.StimType)/16000);
        if mod(length(SessStimOctave),2)
            SessStimOctave(ceil(length(SessStimOctave)/2)) = [];
            BehavCorrAll(ceil(length(SessStimOctave)/2)) = [];
        end
        hsum = figure;
        hold on;
        plot(SessStimOctave(:),PerferAUC','color',[.7 .7 .7],'linewidth',1.5);
        plot(SessStimOctave,mean(PerferAUC),'k','linewidth',1.8);
        plot(SessStimOctave,BehavCorrAll,'r-o','linewidth',1.8);
        xlabel('Octave Index');
        ylabel('Mean AUC');
        title('Mean ROI AUC of all ROIs');
        xscales = get(gca,'xlim');
        set(gca,'xtick',xscales+[0.1,-0.1],'xticklabel',{'Null','Perfer'},'ytick',[0 0.5 1]);
        set(gca,'FontSize',16);
        saveas(hsum,'Averaged AUC value for all ROIs UsingCorr only');
        saveas(hsum,'Averaged AUC value for all ROIs UsingCorr only','png');
        saveas(hsum,'Averaged AUC value for all ROIs UsingCorr only','pdf');
        
         exportToPPTX('addslide');
         exportToPPTX('addnote',pwd);
         exportToPPTX('addpicture',hsum,'Position',[0 2 8 6]);
         close(hsum);
         
        if sum(isROIsig)
            SigROIAUCAll = PerferAUC(logical(isROIsig),:);
            SigROIs = sum(isROIsig);
            hSig = figure;
            hold on;
            plot(SessStimOctave(:),SigROIAUCAll','color',[.7 .7 .7],'linewidth',1.5);
            plot(SessStimOctave,mean(SigROIAUCAll),'k','linewidth',1.8);
            plot(SessStimOctave,BehavCorrAll,'r-o','linewidth',1.8);
            xlabel('Octave Index');
            ylabel('Mean AUC');
            title('Sig ROI mean AUC');
            xscales = get(gca,'xlim');
            set(gca,'xtick',xscales+[0.1,-0.1],'xticklabel',{'Null','Perfer'},'ytick',[0 0.5 1]);
            set(gca,'FontSize',16);
            saveas(hSig,'Sig ROI AUC mean plots UsingCorr only');
            saveas(hSig,'Sig ROI AUC mean plots UsingCorr only','png');
            saveas(hSig,'Sig ROI AUC mean plots UsingCorr only','pdf');
            exportToPPTX('addpicture',hSig,'Position',[8 2 8 6]);
            close(hSig);
            save SigROIinds.mat isROIsig SigROIAUCAll SessStimOctave BehavCorrAll -v7.3
        end
            %
    catch ME
        fprintf('Session ##%s## share following error.\n',cSessPath);
        fprintf('%s.\n',ME.message);
    end
    tline = fgetl(fid);
end
 saveName = exportToPPTX('saveandclose',fullfile(pptSavePath,PPTname));
 disp(saveName);
 %% 
 % summary the single neuron AUC plots across multiple session, and then
 % performing the fitting using the same nlinearfitting methods
 clear
 clc
 
 SigROIIAUCAll = {};
 SigROUAUCmean = [];
 BehavPerfAll = [];
 addchar = 'y';
 m = 0;
 while ~strcmpi(addchar,'n')
     [fn,fp,fi] = uigetfile('SigROIinds.mat','Please select one session ROI auc curve data');
     if fi
         filepath = fullfile(fp,fn);
         SessData = load(filepath);
         SessionStim = SessData.SessStimOctave;
         disp(SessionStim);

         m = m + 1;
         SigROIIAUCAll{m} = SessData.SigROIAUCAll;
         SigROUAUCmean(m,:) = mean(SessData.SigROIAUCAll);
         BehavPerfAll(m,:) = SessData.BehavCorrAll;

         addchar = input('Would you like to add another session data?\n','s');
     end
 end
 
 %%
 MeanBehavData = mean(BehavPerfAll);
 SemBehavData = std(BehavPerfAll)/sqrt(size(BehavPerfAll,1));
 MeanROIData = mean(SigROUAUCmean);
 SemROIData = std(SigROUAUCmean)/sqrt(size(SigROUAUCmean,1));
 OctaveData = SessionStim;
 
 OctaveRange = linspace(min(OctaveData),max(OctaveData),500);
 opts = statset('nlinfit');
 opts.RobustWgtFun = 'bisquare';
 modelfunb = @(b,x) (b(1)+ b(2)./(1+exp(-(x - b(3))./b(4))));
 b0 = [min(OctaveData); max(OctaveData); mean([min(OctaveData),max(OctaveData)]); 0.1];
 [bBehavfit,BehavR,BehavJ,BehavCovB,behavMSE,~] = nlinfit(OctaveData,MeanBehavData,modelfunb,b0,opts);
 [BehavPred,behavDelta] = nlpredci(modelfunb,OctaveRange,bBehavfit,BehavR,'Covar',BehavCovB,...
     'MSE',behavMSE,'Simopt','on');
 BehavLower = BehavPred - behavDelta;
 BehavUpper = BehavPred + behavDelta;
 
 [bROIfit,ROIR,ROIJ,ROICovB,ROIMSE,~] = nlinfit(OctaveData,MeanROIData,modelfunb,b0,opts);
 [ROIpred,ROIDelta] = nlpredci(modelfunb,OctaveRange,bROIfit,ROIR,'Covar',ROICovB,...
     'MSE',ROIMSE,'Simopt','on');
 ROIlower = ROIpred - ROIDelta;
 ROIupper = ROIpred + ROIDelta;
 
%  BehavCurve = modelfunb(bBehavfit,OctaveRange);
%  ROICurve = modelfunb(bROIfit,OctaveRange);
%  
  hf = figure;
 hold on
 h1 = errorbar(OctaveData,MeanBehavData,SemBehavData,'ro','linewidth',1.6,'MarkerSize',14);
 h2 = errorbar(OctaveData,MeanROIData,SemROIData,'ko','linewidth',1.6,'MarkerSize',14);
 plot(OctaveRange,BehavPred,'r','linewidth',1.6);
 plot(OctaveRange,ROIpred,'k','linewidth',1.6);
 plot(OctaveRange,BehavLower,'color',[1,0.3,0.3],'linewidth',1.4,'linestyle','--');
 plot(OctaveRange,BehavUpper,'color',[1,0.3,0.3],'linewidth',1.4,'linestyle','--');
 plot(OctaveRange,ROIlower,'color',[.4 .4 .4],'linewidth',1.4,'linestyle','--');
 plot(OctaveRange,ROIupper,'color',[.4 .4 .4],'linewidth',1.4,'linestyle','--');
 
 set(gca,'xtick',OctaveData,'xticklabel',cellstr(num2str(OctaveData(:),'%.1f')));
 xlabel('Octave');
 ylabel('Rightward Frac.');
 set(gca,'FontSize',16);
 legend([h1,h2],{'Behav','ROI AUC'},'location','northwest','FontSize',14);
 saveas(hf,'Behav and ROIAUC compare plot');
 saveas(hf,'Behav and ROIAUC compare plot','png');
 saveas(hf,'Behav and ROIAUC compare plot','pdf');
 

%%
BehavCI = abs(mean(BehavPerfAll(:,1:3),2) - mean(BehavPerfAll(:,4:6),2));
ROICI = abs(mean(SigROUAUCmean(:,1:3),2) - mean(SigROUAUCmean(:,4:6),2));
[~,p] = ttest(BehavCI,ROICI);
hs = figure;
scatter(BehavCI,ROICI,40,'ko');
% xscales = get(gca,'xlim');
set(gca,'xtick',[0.5,0.75,1],'ytick',[0.5,0.75,1],'xlim',[0.5,1],'ylim',[0.5,1]);
line([0.5,1],[0.5,1],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
xlabel('Behav. CI');
ylabel('ROI AUC');
title(sprintf('CI comparison, p = %.2e',p));
set(gca,'FontSize',16);
saveas(hs,'Behav ROIAUC CI scater plot');
saveas(hs,'Behav ROIAUC CI scater plot','png');
saveas(hs,'Behav ROIAUC CI scater plot','pdf');