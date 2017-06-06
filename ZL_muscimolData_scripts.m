Datapath = uigetdir(pwd,'Please select your data path');
cd(Datapath);
Datafiles = dir('ZL*.mat');
nFile = length(Datafiles);
AllfileDatacell = cell(nFile,1);
AllfileOverCorrect = zeros(nFile,3);  % non-miss correct, include-miss correct, miss rate
TrialResultCell = cell(nFile,3);
BootDataAll = zeros(nFile,1000,2);
for nnfile = 1 : nFile
    nfname = Datafiles(nnfile).name;
    behavStrc = load(nfname);
    [behavResults,behavSettings] = behav_cell2struct(behavStrc.SessionResults,behavStrc.SessionSettings);
    TrialTypesAll = behavResults.Trial_Type;
    TrialChoiceAll = behavResults.Action_choice;
    TrialFreq = behavResults.Stim_toneFreq;
    FreqType = unique(TrialFreq);
    if length(FreqType) == 2
        fprintf('Current session is a normal two-tone 2AFC session.\n');
        SessionDesp = 'Norm2afc';
    elseif length(FreqType) >= 4
        fprintf('Current session is a random puretone session.\n');
        SessionDesp = 'RandomTone';
    else
        error('Undefined session type, please update the code for current session');
    end
    %
    TrialCorrInds = TrialTypesAll == TrialChoiceAll;
    TrialMissInds = TrialChoiceAll == 2;
    AllfileOverCorrect(nnfile,:) = [mean(TrialCorrInds(~TrialMissInds)),mean(TrialCorrInds),mean(TrialMissInds)];
    FreqTypeDataCell = zeros(length(FreqType),3);
    for nff = 1 : length(FreqType)
        cFreq = FreqType(nff);
        cFreqInds = TrialFreq == cFreq;
        cfMissTrial = TrialMissInds(cFreqInds);
        cfTrialOutcome = TrialCorrInds(cFreqInds);
        cfTrialNonmissOut = cfTrialOutcome(~cfMissTrial);
        FreqTypeDataCell(nff,:) = [mean(cfMissTrial),mean(cfTrialNonmissOut),mean(cfTrialOutcome)]; % Miss rate, non-miss correct rate, overall correct rate
    end
    AllfileDatacell{nnfile} = FreqTypeDataCell;
    TrialResultCell{nnfile,1} = TrialCorrInds;
    TrialResultCell{nnfile,2} = TrialMissInds;
    TrialResultCell{nnfile,3} = TrialFreq;
    BootCorrIM = bootstrp(1000,@mean,double(TrialCorrInds));
    BootCorrNM = bootstrp(1000,@mean,double(TrialCorrInds(~TrialMissInds)));
    BootDataAll(nnfile,:,1) = BootCorrIM; % included miss trials
    BootDataAll(nnfile,:,2) = BootCorrNM; % non-miss trials
end
%
save SessionBehavdata.mat AllfileDatacell AllfileOverCorrect TrialResultCell BootDataAll -v7.3
%
hhf = figure;
imagesc(AllfileOverCorrect),
colorbar
set(gca,'xtick',[1 2 3],'xTicklabel',{'NMCorr','ImCorr','MissR'},'ytick',1:nFile);
ylabel(gca,'# Sessions');
xlabel(gca,'Analysis types');
saveas(hhf,'Session Sum Correct rate color plot');
saveas(hhf,'Session Sum Correct rate color plot','png');
saveas(hhf,'Session Sum Correct rate color plot','pdf');
close(hhf);

%%
clear;
clc
A1dataPath = uigetdir(pwd,'Please select your target brain area folder');
cd(A1dataPath);
CBdataStrc = load('./CB/SessionBehavdata.mat');
ControlDataStrc = load('./control/SessionBehavdata.mat');
MuscimolDataStrc = load('./musimol/SessionBehavdata.mat');
CBdata = CBdataStrc.AllfileOverCorrect;  % for columns: non-miss correct, include-miss correct, miss rate
ControlData = ControlDataStrc.AllfileOverCorrect;
MuscimolData = MuscimolDataStrc.AllfileOverCorrect;
CBBootdata = CBdataStrc.BootDataAll;
ControlBootData = ControlDataStrc.BootDataAll;
MuscimolBootData = MuscimolDataStrc.BootDataAll;

OverAlldataStrc = struct();
OverAlldataStrc.CBBootMean = squeeze(mean(CBBootdata,2)); % for columns: non-miss correct, include-miss correct, miss rate
OverAlldataStrc.CBBootStd = squeeze(std(CBBootdata,[],2));
OverAlldataStrc.ContMean = squeeze(mean(ControlBootData,2));
OverAlldataStrc.ContStd = squeeze(std(ControlBootData,[],2));
OverAlldataStrc.MusMean = squeeze(mean(MuscimolBootData,2));
OverAlldataStrc.MusStd = squeeze(std(MuscimolBootData,[],2));
save OverAlldataSave.mat OverAlldataStrc CBdata ControlData MuscimolData CBBootdata ControlBootData MuscimolBootData -v7.3

%%
% non-miss trials accuracy, using bootstrp method
NMCBBootdata = reshape(CBBootdata(:,:,2),[],1);
IMCBBootdata = reshape(CBBootdata(:,:,1),[],1);
NMContBootData = reshape(ControlBootData(:,:,2),[],1);
IMContBootData = reshape(ControlBootData(:,:,1),[],1);
NMMusBootData = reshape(MuscimolBootData(:,:,2),[],1);
IMMusBootData = reshape(MuscimolBootData(:,:,1),[],1);

h_cumu = figure('position',[200 200 1400 800]);
axNM = subplot(1,2,1);
hold on
[NMCBCumuy,NMCBCumux] = ecdf(NMCBBootdata);
[NMContCumuy,NMContCumux] = ecdf(NMContBootData);
[NMMusCumuy,NMMusCumux] = ecdf(NMMusBootData);

hl1 = plot(NMCBCumux,NMCBCumuy,'b','linewidth',1.6);
hl2 = plot(NMContCumux,NMContCumuy,'k','linewidth',1.6);
hl3 = plot(NMMusCumux,NMMusCumuy,'r','linewidth',1.6);
legend([hl2,hl1,hl3],{'Control','CB','Muscimol'},'location','southeast','FontSize',12);
title('Excluded miss trials');
set(gca,'FontSize',16);

axIM = subplot(1,2,2);
hold on
[IMCBCumuy,IMCBCumux] = ecdf(IMCBBootdata);
[IMContCumuy,IMContCumux] = ecdf(IMContBootData);
[IMMusCumuy,IMMusCumux] = ecdf(IMMusBootData);

hl1 = plot(IMCBCumux,IMCBCumuy,'b','linewidth',1.6);
hl2 = plot(IMContCumux,IMContCumuy,'k','linewidth',1.6);
hl3 = plot(IMMusCumux,IMMusCumuy,'r','linewidth',1.6);
legend([hl2,hl1,hl3],{'Control','CB','Muscimol'},'location','southeast','FontSize',12);
title('Included miss trials');
set(gca,'FontSize',16);

saveas(h_cumu,'Boot data savage for current session');
saveas(h_cumu,'Boot data savage for current session','pdf');
saveas(h_cumu,'Boot data savage for current session','png');
close(h_cumu);
%%
[~,p_CB_Cont] = ttest(CBdata(:,1),ControlData(:,1));
[~,p_CB_Mus] = ttest(CBdata(:,1),MuscimolData(:,1));
[~,p_Cont_Mus] = ttest(ControlData(:,1),MuscimolData(:,1));
PlotDataNM = ([ControlData(:,1),CBdata(:,1),MuscimolData(:,1)])';
PLotNMSEM = std(PlotDataNM,[],2)/sqrt(size(PlotDataNM,2));

[~,p_CB_ContIM] = ttest(CBdata(:,2),ControlData(:,2));
[~,p_CB_MusIM] = ttest(CBdata(:,2),MuscimolData(:,2));
[~,p_Cont_MusIM] = ttest(CBdata(:,2),MuscimolData(:,2));
PlotDataIM = ([ControlData(:,2),CBdata(:,2),MuscimolData(:,2)])';
PLotIMSEM = std(PlotDataIM,[],2)/sqrt(size(PlotDataIM,2));

MeanNMData = [mean(ControlData(:,1)),mean(CBdata(:,1)),mean(MuscimolData(:,1))];
h_bar = figure('position',[200 200 1400 800]);
axNM2 = subplot(1,2,1);
hold on
bar(1,MeanNMData(1),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
bar(2,MeanNMData(2),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
bar(3,MeanNMData(3),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
axNM2 = GroupSigIndication([1,2],MeanNMData([1,2]),p_CB_Cont,axNM2,1.1);
axNM2 = GroupSigIndication([1,3],MeanNMData([1,3]),p_Cont_Mus,axNM2,1.25);
axNM2 = GroupSigIndication([2,3],MeanNMData([2,3]),p_CB_Mus,axNM2,1.4);
plot(PlotDataNM,'Color',[.7 .7 .7],'LineWidth',1.4);
errorbar([1,2,3],MeanNMData,PLotNMSEM,'.','Color','k','LineWidth',1.4);
text([1,2,3],MeanNMData*1.03,cellstr(num2str(MeanNMData(:),'%.3f')),'HorizontalAlignment','center','FontSize',16);
set(gca,'xtick',[1,2,3],'xticklabel',{'Control','CB','Muscimol'});
ylabel('Mean accuracy');
xlabel('Non-missing Trials Accuracy');
% title('Non-miss trials accuracy');
set(gca,'FontSize',16);

MeanNMDataIM = [mean(ControlData(:,2)),mean(CBdata(:,2)),mean(MuscimolData(:,2))];
axNM2IM = subplot(1,2,2);
hold on
bar(1,MeanNMDataIM(1),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
bar(2,MeanNMDataIM(2),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
bar(3,MeanNMDataIM(3),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
axNM2IM = GroupSigIndication([1,2],MeanNMDataIM([1,2]),p_CB_ContIM,axNM2IM,1.1);
axNM2IM = GroupSigIndication([1,3],MeanNMDataIM([1,3]),p_Cont_MusIM,axNM2IM,1.25); 
axNM2IM = GroupSigIndication([2,3],MeanNMDataIM([2,3]),p_CB_MusIM,axNM2IM,1.4); 
plot(PlotDataIM,'Color',[.7 .7 .7],'LineWidth',1.4);
errorbar([1,2,3],MeanNMDataIM,PLotIMSEM,'.','Color','k','LineWidth',1.4);
text([1,2,3],MeanNMDataIM*1.03,cellstr(num2str(MeanNMDataIM(:),'%.3f')),'HorizontalAlignment','center','FontSize',16);
set(gca,'xtick',[1,2,3],'xticklabel',{'Control','CB','Muscimol'});
ylabel('Mean accuracy');
xlabel('Include miss Trials Accuracy');
% title('Include miss trials accuracy');
set(gca,'FontSize',16);

saveas(h_bar,'Real data savage for current session');
saveas(h_bar,'Real data savage for current session','pdf');
saveas(h_bar,'Real data savage for current session','png');
close(h_bar);

%% Miss rate plot
[~,p_CB_ContMR] = ttest(CBdata(:,3),ControlData(:,3));
[~,p_CB_MusMR] = ttest(CBdata(:,3),MuscimolData(:,3));
[~,p_Cont_MusMR] = ttest(ControlData(:,3),MuscimolData(:,3));
PlotDataMR = ([ControlData(:,3),CBdata(:,3),MuscimolData(:,3)])';
PLotMRSEM = std(PlotDataMR,[],2)/sqrt(size(PlotDataMR,2));
MeanMRData = [mean(ControlData(:,3)),mean(CBdata(:,3)),mean(MuscimolData(:,3))];
h_bar = figure('position',[200 200 900 800]);
hold on;
bar(1,MeanMRData(1),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
bar(2,MeanMRData(2),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
bar(3,MeanMRData(3),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','k');
h_bar = GroupSigIndication([1,2],MeanMRData([1,2]),p_CB_ContMR,h_bar,1.1);
h_bar = GroupSigIndication([1,3],MeanMRData([1,3]),p_Cont_MusMR,h_bar,1.25); 
h_bar = GroupSigIndication([2,3],MeanMRData([2,3]),p_CB_MusMR,h_bar,1.4);
plot(PlotDataMR,'Color',[.7 .7 .7],'LineWidth',1.4);
errorbar([1,2,3],MeanMRData,PLotIMSEM,'.','Color','k','LineWidth',1.4);
text([1,2,3],MeanMRData*1.03,cellstr(num2str(MeanMRData(:),'%.3f')),'HorizontalAlignment','center','FontSize',16);
set(gca,'xtick',[1,2,3],'xticklabel',{'Control','CB','Muscimol'});
ylabel('Mean accuracy');
xlabel('Session Miss Rate');
% title('Include miss trials accuracy');
set(gca,'FontSize',16);
saveas(h_bar,'Miss Rate savage for current session');
saveas(h_bar,'Miss Rate savage for current session','pdf');
saveas(h_bar,'Miss Rate savage for current session','png');
close(h_bar);

PValueStrc.p_CB_ContNM = p_CB_Cont; 
PValueStrc.p_CB_MusNM = p_CB_Mus; 
PValueStrc.p_Cont_MusNM = p_Cont_Mus;
PValueStrc.p_CB_ContIM = p_CB_ContIM;
PValueStrc.p_CB_MusIM = p_CB_MusIM;
PValueStrc.p_Cont_MusIM = p_Cont_MusIM;
PValueStrc.p_CB_ContMR = p_CB_ContMR;
PValueStrc.p_CB_MusMR = p_CB_MusMR;
PValueStrc.p_Cont_MusMR = p_Cont_MusMR;
save PValueData.mat PValueStrc -v7.3 