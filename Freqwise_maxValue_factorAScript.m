
TrFreqs = double(behavResults.Stim_toneFreq);
MissInds = trial_outcome == 2;
NMtrFactorData = cLRIndexSum(~MissInds,:);
NMStimTone = TrFreqs(~MissInds);
NMoutcome = trial_outcome(~MissInds);
TypeFreqs = unique(NMStimTone);
nFreqs = length(TypeFreqs);

FrameScale = [start_frame+1,start_frame+frame_rate]; % within 1s time window
FreqMaxIndex = zeros(nFreqs,1);
FreqMaxIndexAll = cell(nFreqs,1);

for cFreq = 1 : nFreqs
    cTone = TypeFreqs(cFreq);
    cToneInds = NMStimTone == cTone;
    cToneData = NMtrFactorData(cToneInds,:);
    MeanTrace = mean(cToneData);
    AbsTrace = abs(MeanTrace);
    [~,MaxInds] = max(AbsTrace(FrameScale(1):FrameScale(2)));
    FreqMaxIndex(cFreq) = MeanTrace(start_frame+MaxInds);
    FreqMaxIndexAll{cFreq} = cToneData(:,start_frame+MaxInds);
end
%%
BoundTone = 16000;
FreqOctave = log2(TypeFreqs/BoundTone);
Frestr = cellstr(num2str(TypeFreqs(:)/1000,'%.1f'));
NorFreqIndex = (FreqMaxIndex - min(FreqMaxIndex))/(max(FreqMaxIndex) - min(FreqMaxIndex));
IsBoundToneExist = 0;
if mod(length(FreqOctave),2)
    fprintf('Not using Boundary frequency.\n');
    BoundTone = FreqOctave(ceil(length(FreqOctave)/2));
    BoundNorFA = NorFreqIndex(ceil(length(FreqOctave)/2));
    FreqOctave(ceil(length(FreqOctave)/2)) = [];
    NorFreqIndex(ceil(length(FreqOctave)/2)) = [];
    IsBoundToneExist = 1;
end
% figure;
% plot(FreqOctave,FreqMaxIndex,'k-o','Markersize',12,'linewidth',2);
% set(gca,'xtick',FreqOctave,'xticklabel',Frestr);
% xlabel('Freq (kHz)');
% ylabel('Mean Selection index');
% set(gca,'FontSize',20);

%%

% figure;
% plot(FreqOctave,NorFreqIndex,'r-o','Markersize',12,'linewidth',2);
% set(gca,'xtick',FreqOctave,'xticklabel',Frestr);
% xlabel('Freq (kHz)');
% ylabel('Mean Selection index');
% set(gca,'FontSize',20);

%%
% [fn,fp,fi] = uigetfile('boundary_result.mat','Please select the PsC fitting result');
% if ~fi
%     return;
% end
% load(fullfile(fp,fn));
BehavRes = boundary_result.StimCorr;
BehavRes(1:floor(length(BehavRes)/2)) = 1 - BehavRes(1:floor(length(BehavRes)/2));
octave_dist = FreqOctave;
reward_type = BehavRes;
SP_FA = [NorFreqIndex(1),1 - NorFreqIndex(end)-NorFreqIndex(1), mean(octave_dist), 1];
%%
UL = [0.5, 0.5, max(octave_dist), 100];
SP = [reward_type(1),1 - reward_type(end)-reward_type(1), mean(octave_dist), 1];
LM = [0, 0, min(octave_dist), 0];
ParaBoundLim = ([UL;SP;LM]);
ParaBoundLimFA = ([UL;SP_FA;LM]);
fit_ReNew = FitPsycheCurveWH_nx(octave_dist, reward_type, ParaBoundLim);
fit_ReNew_FA = FitPsycheCurveWH_nx(octave_dist, NorFreqIndex, ParaBoundLimFA);
hf = figure('position',[560 500 500 400]);
hold on
plot(octave_dist,reward_type,'ro','MarkerSize',12,'linewidth',1.8);
plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'Color','r','linewidth',2);
plot(octave_dist,NorFreqIndex,'ko','MarkerSize',12,'linewidth',1.8);
plot(fit_ReNew_FA.curve(:,1),fit_ReNew_FA.curve(:,2),'Color','k','linewidth',2);
if IsBoundToneExist
    plot(BoundTone,BoundNorFA,'bo','MarkerSize',10,'linewidth',1.5);
end
% legend(plot(0,0,'r-o','visible','off'),'Behav');
legend([plot(0,0,'r-o','visible','off'),plot(0,0,'k-o','visible','off')],{'Behav','FAPeak'},'Location','NorthWest','FontSize',12);
set(gca,'xtick',FreqOctave,'xticklabel',Frestr);
xlabel('Freq (kHz)');
set(gca,'FontSize',20);
saveas(hf,'Factor and behavior compare plot');
saveas(hf,'Factor and behavior compare plot','png');
close(hf);
%%
% summarize all figures into one ppt file
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end
% clearvars -except fn fp
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
            PPTname = 'Freqwise_FA_SelectionIndex';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
%                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
            pptSavePath = 'E:\DataToGo\data_for_xu\Factor_new_smooth\New_correct_factorAna\SessionSummary';
            %
        end
            Anminfo = SessInfoExtraction(tline);
            cTunDataPath = [tline,filesep,'Tunning_fun_plot_New1s',filesep,'Uncertainty_plot'];
            UncertaintyResp = fullfile(cTunDataPath,'ROI response against Distance level plot.png');
            UncertaintyModu = fullfile(cTunDataPath,'Distance against moduindex plot.png');
            RespCompareFile = fullfile(cTunDataPath,'BoundDis response compare plot all.png');
            if exist(UncertaintyModu,'file')
                IsModeLoad = 1;
            else
                IsModeLoad = 0;
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
            cBehavPlotPath = fullfile(tline,filesep,'Tunning_fun_plot_New1s',filesep,...
                'Tuned freq colormap plot',filesep,'Behavior and uncertainty curve plot.png');
            BehavPlotf = imread(cBehavPlotPath);
            exportToPPTX('addslide');

            UncertaintyRespIm = imread(UncertaintyResp);
%             UncertaintyModuIM = imread(UncertaintyModu);

            % Anminfo
            exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 1],'FontSize',24);
            exportToPPTX('addnote',tline);
            exportToPPTX('addpicture',UncertaintyRespIm,'Position',[0.1 1.5 8.05 6]);
            if IsModeLoad
                exportToPPTX('addpicture',imread(UncertaintyModu),'Position',[9.5 1 3.8 3]);
            end
            exportToPPTX('addpicture',imread(RespCompareFile),'Position',[9.5 4 5.68 4.5]);
%                 exportToPPTX('addpicture',TaskRespMapIM,'Position',[6 0.2 5 4.19]);
%                 exportToPPTX('addtext','Task','Position',[11 2 1 2],'FontSize',22);
%                 exportToPPTX('addpicture',PassRespMapIM,'Position',[6 4.5 5 4.19]);
%                 exportToPPTX('addtext','Passive','Position',[11 5.5 3 2],'FontSize',22);
%                 exportToPPTX('addpicture',BoundDiffIM,'Position',[12 4.5 4 3.35]);
% %                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
            exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                'Position',[14 0.5 2 3],'FontSize',22);
    end
     m = m + 1;
     nSession = nSession + 1;
     saveName = exportToPPTX('saveandclose',pptFullfile);
     tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);

