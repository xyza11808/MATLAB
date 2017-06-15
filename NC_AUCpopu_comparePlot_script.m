% calculate the noise for left and right selective populations
clear
clc
[fn,fp,fi] = uigetfile('GroupWiseNC_path.txt','Please select the file contains task data sessions');
%%
if fi
    fpath = fullfile(fp,fn);
    fid = fopen(fpath);
    tline = fgetl(fid);
    while ischar(tline)
        if isempty(strfind(tline,'Group_NC_cumulativePlot\RespGroupNCData.mat'))
            tline = fgetl(fid);
            continue;
        end
        ROCPath = strrep(tline,'Group_NC_cumulativePlot\RespGroupNCData.mat;','Stim_time_Align\ROC_Left2Right_result');
        BaseSessionPath = strrep(tline,'\Group_NC_cumulativePlot\RespGroupNCData.mat;','\');
        AUCFilePath = fullfile(ROCPath,'ROC_score.mat');
        % % loading the AUC data, using to define left or right selectivity
        % [fn,fp,fi] = uigetfile('ROC_score.mat','Please select your AUC saved data');
        % if ~fi
        %     return;
        % else
        %     FilePath = fullfile(fp,fn);
        AUCDataStrc = load(AUCFilePath);
        ROCData = AUCDataStrc.ROCarea;
        ROCIsRevert = AUCDataStrc.ROCRevert;
        ROCABS = ROCData;
        ROCABS(ROCIsRevert == 1) = 1 - ROCABS(ROCIsRevert == 1);
        SigROIInds = find(ROCABS > AUCDataStrc.ROCShufflearea);
        AllSigROIAUCs = ROCData(SigROIInds);
        LeftSigROIAUCs = AllSigROIAUCs < 0.5;
        RightSigROIAUCs = AllSigROIAUCs > 0.5;
        % ROI index for left and right population
        LeftSigROIAUCIndex = SigROIInds(LeftSigROIAUCs);
        RightSigROIAUCIndex = SigROIInds(RightSigROIAUCs);
        
        NoiseRespROIInds = find(ROCABS <= AUCDataStrc.ROCShufflearea);
        cd(BaseSessionPath);
        CoefDisDataPath = fullfile(BaseSessionPath,'Correlation_distance_coefPlot\CoefDisSave.mat');
        cFilePath = CoefDisDataPath;
        %
        % % load the noise correlation data
        % [NCfn,NCfp,NCfi] = uigetfile('CoefDisSave.mat','Please select the correponded Noise correlation data save file');
        % if ~NCfi
        %     return;
        % else
        %     cFilePath = fullfile(NCfp,NCfn);
        NCDataStrc = load(cFilePath);
        NoiseCorrData = NCDataStrc.PairedNoiseCoef;
        NCMatrix = squareform(NoiseCorrData);
        
        % calculate the correlation matrix for left and right population
        LeftROINCmatrix = NCMatrix(LeftSigROIAUCIndex,LeftSigROIAUCIndex);
        RightROINCmatrix = NCMatrix(RightSigROIAUCIndex,RightSigROIAUCIndex);
        NosRespNCmatrix = NCMatrix(NoiseRespROIInds,NoiseRespROIInds);
        
        LeftMaskRaw = ones(size(LeftROINCmatrix));
        LeftMask = logical(tril(LeftMaskRaw,-1));
        LeftROINCVector = LeftROINCmatrix(LeftMask);
        
        RightMaskRaw = ones(size(RightROINCmatrix));
        RightMask = logical(tril(RightMaskRaw,-1));
        RightROINCvector = RightROINCmatrix(RightMask);
        
        betLRNoiseCorr = NCMatrix(LeftSigROIAUCIndex,RightSigROIAUCIndex);
        betLRNoiseCorrVector = betLRNoiseCorr(:);
        
        NosRespSigNoiseCorr = NCMatrix([LeftSigROIAUCIndex(:);RightSigROIAUCIndex(:)],NoiseRespROIInds);
        NosRespSigNCvec = NosRespSigNoiseCorr(:);
        
        NosRespMaskRaw = ones(size(NosRespNCmatrix));
        NosRespMask = logical(tril(NosRespMaskRaw,-1));
        NosRespNCvector = NosRespNCmatrix(NosRespMask);
        
        %
        cd(BaseSessionPath);
        % cumulative plot and comparasion of different Noise correlation
        % populations
%         [LeftCumFrac,Leftx] = ecdf(LeftROINCVector);
%         [RightCumFrac,Rightx] = ecdf(RightROINCvector);
%         [LRCumFrac,LRx] = ecdf(betLRNoiseCorrVector);
%         [NosRespSigNCFrac,NosRespSigNCx] = ecdf(NosRespSigNCvec);
        
%         h_all = figure('position',[200 200 1000 800]);
%         hold on;
%         plot(Leftx,LeftCumFrac,'b','LineWidth',1.8);
%         plot(Rightx,RightCumFrac,'r','LineWidth',1.8);
%         plot(LRx,LRCumFrac,'k','LineWidth',1.8);
%         plot(NosRespSigNCx,NosRespSigNCFrac,'c','LineWidth',1.8)
%         set(gca,'xlim',[-1 1]);
%         p_L2R = ranksum(LeftROINCVector,RightROINCvector);
%         p_L2Betn = ranksum(LeftROINCVector,betLRNoiseCorrVector);
%         p_R2Betn = ranksum(RightROINCvector,betLRNoiseCorrVector);
%         xlabel('Noise correlation coefficient');
%         ylabel('Cumulative fraction');
%         title('Group wise Noise correlation distribution');
%         set(gca,'FontSize',18);
%         text(0.6,0.3,sprintf('L2R pValue = %.3e',p_L2R),'Color','k','FontSize',12);
%         text(0.6,0.2,sprintf('L2Betn pValue = %.3e',p_L2Betn),'Color','k','FontSize',12);
%         text(0.6,0.1,sprintf('R2Betn pValue = %.3e',p_R2Betn),'Color','k','FontSize',12);
%         text(-0.8,0.9,sprintf('Mean LeftPopu NC = %.3f',mean(LeftROINCVector)),'FontSize',10,'Color','b');
%         text(-0.8,0.8,sprintf('Mean RightPopu NC = %.3f',mean(RightROINCvector)),'FontSize',10,'Color','r');
%         text(-0.8,0.7,sprintf('Mean L2RPopu NC = %.3f',mean(betLRNoiseCorrVector)),'FontSize',10,'Color','k');
%         text(-0.8,0.6,sprintf('Mean NorResp2Sig= %.3f',mean(NosRespSigNCvec)),'FontSize',10,'Color','c');
        %
        
        if ~isdir('./Group_NC_cumulativePlot/')
            mkdir('./Group_NC_cumulativePlot/');
        end
        cd('./Group_NC_cumulativePlot/');
        %
%         saveas(h_all,'Different Popu Noise correlation distribution');
%         saveas(h_all,'Different Popu Noise correlation distribution','png');
%         close(h_all);
        save RespGroupNCData.mat LeftSigROIAUCIndex RightSigROIAUCIndex LeftROINCVector RightROINCvector NosRespSigNCvec ...
            betLRNoiseCorrVector NCDataStrc NosRespNCvector NoiseRespROIInds -v7.3
        cd ..;
        tline = fgetl(fid);
        % clear
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% summarize multisession data together
addchar = 'y';
DataPath = {};
DataSum = {};
LeftROINCall = [];
RightROINCall = [];
BetLRROINCall = [];
NosRespSigNCall = [];
NoiseRespNCAll = [];
m = 1;

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('RespGroupNCData.mat','please select your Groupwised Noise correlation data');
    if ~fi
        break;
    end
    cFpath = fullfile(fp,fn);
    DataPath{m} = cFpath;
    xx = load(cFpath);
    DataSum{m} = xx;
    LeftROINCall = [LeftROINCall;xx.LeftROINCVector];
    RightROINCall = [RightROINCall;xx.RightROINCvector];
    BetLRROINCall = [BetLRROINCall;xx.betLRNoiseCorrVector];
    NosRespSigNCall = [NosRespSigNCall;xx.NosRespSigNCvec];
    NoiseRespNCAll = [NoiseRespNCAll;xx.NosRespNCvector];
    addchar = input('Would you like to add another session data?\n','s');
    m = m + 1;
end

%%
SavePath = uigetdir(pwd,'Please select your data save path');
cd(SavePath);
fid = fopen('GroupWiseNC_path.txt','w');
fprintf(fid,'Data Path for Groupwised NC data:\r\n');
fFormat = '%s;\r\n';
for nSession = 1 : (m - 1)
    fprintf(fid,fFormat,DataPath{nSession});
end
fclose(fid);
save GroupWise_NCsave.mat DataPath DataSum LeftROINCall RightROINCall BetLRROINCall NosRespSigNCall NoiseRespNCAll -v7.3

%%
% cumulative plot and comparasion of different Noise correlation
% populations
[LeftCumFrac,Leftx] = ecdf(LeftROINCall);
[RightCumFrac,Rightx] = ecdf(RightROINCall);
[LRCumFrac,LRx] = ecdf(BetLRROINCall);
[NoiRespSigFrac,NoiRespSigx] = ecdf(NosRespSigNCall);
[NosRespNCFrac,NosRespNCx] = ecdf(NoiseRespNCAll);


h_all = figure('position',[200 200 1000 800]);
hold on;
plot(Leftx,LeftCumFrac,'b','LineWidth',1.8);
plot(Rightx,RightCumFrac,'r','LineWidth',1.8);
plot(LRx,LRCumFrac,'k','LineWidth',1.8);
plot(NoiRespSigx,NoiRespSigFrac,'c','LineWidth',1.8);
plot(NosRespNCx,NosRespNCFrac,'m','LineWidth',1.8);
set(gca,'xlim',[-1 1]);
p_L2R = ranksum(LeftROINCall,RightROINCall);
p_L2Betn = ranksum(LeftROINCall,BetLRROINCall);
p_R2Betn = ranksum(RightROINCall,BetLRROINCall);
xlabel('Noise correlation coefficient');
ylabel('Cumulative fraction');
title('Group wise Noise correlation distribution');
set(gca,'FontSize',18);
text(0.6,0.3,sprintf('L2R pValue = %.3e',p_L2R),'Color','k','FontSize',12);
text(0.6,0.2,sprintf('L2Betn pValue = %.3e',p_L2Betn),'Color','k','FontSize',12);
text(0.6,0.1,sprintf('R2Betn pValue = %.3e',p_R2Betn),'Color','k','FontSize',12);
text(-0.8,0.9,sprintf('Mean LeftPopu NC = %.3f, nPairs = %d',mean(LeftROINCall),length(LeftROINCall)),'FontSize',10,'Color','b');
text(-0.8,0.8,sprintf('Mean RightPopu NC = %.3f, nPairs = %d',mean(RightROINCall),length(RightROINCall)),'FontSize',10,'Color','r');
text(-0.8,0.7,sprintf('Mean L2RPopu NC = %.3f, nPairs = %d',mean(BetLRROINCall),length(BetLRROINCall)),'FontSize',10,'Color','k');
text(-0.8,0.6,sprintf('Mean NResp2Sig NC = %.3f, nPairs = %d',mean(NosRespSigNCall),length(NosRespSigNCall)),'FontSize',10,'Color','c');
text(-0.8,0.5,sprintf('Mean NosResp NC = %.3f, nPairs = %d',mean(NoiseRespNCAll),length(NoiseRespNCAll)),'FontSize',10,'Color','m');
saveas(h_all,'Summarized Groupwise NC cumulative plot');
saveas(h_all,'Summarized Groupwise NC cumulative plot','png');
% closoe(h_all);

%% merge same and between group data noise correlation coefficient distribution
WinthinGrNC = [LeftROINCall;RightROINCall];
BetGrNC = BetLRROINCall;
[WithinFuny,WithinFunx] = ecdf(WinthinGrNC);
[BetFuny,BetFunx] = ecdf(BetGrNC);
p = ranksum(WinthinGrNC,BetGrNC);
 
h = figure;
hold on
hl1 = plot(WithinFunx,WithinFuny,'b','LineWidth',3);
hl2 = plot(BetFunx,BetFuny,'m','LineWidth',3);
set(gca,'xlim',[-1 1],'xtick',[-1 0 1],'ytick',[0,0.5,1]);
xlabel('Noise correlation coefficient');
ylabel('Cumulative fraction');
title({'Comparesion of between and within group NC',sprintf('BetNC mean = %.3f, WinNC = %.3f',mean(BetGrNC),mean(WinthinGrNC))});
set(gca,'FontSize',16);
text(0.7,0.3,sprintf('p = %.2e',p),'FontSize',12);
legend([hl1,hl2],{'WithinGR NC','BetGr NC'},'FontSize',12,'location','Northwest');
saveas(h,'Cumulative distribution of BetGr and WinGr NC');
saveas(h,'Cumulative distribution of BetGr and WinGr NC','png');
saveas(h,'Cumulative distribution of BetGr and WinGr NC','pdf');