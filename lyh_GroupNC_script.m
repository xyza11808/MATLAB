ContrilAUCCell = AUC_nonOpto;
OptoAUCCell = AUC_Opto;
ContrilAUCCell(2) = [];
OptoAUCCell(2) = [];
SessionROInum = cellfun(@length,ContrilAUCCell);
ROIthres = Threshold_temp;
%%
SessionROIThres = cell(length(ContrilAUCCell),1);
k = 1;
for nmnm = 1 : length(ContrilAUCCell)
    SessionROIThres{nmnm} = ROIthres(k:k+SessionROInum(nmnm)-1);
    k = k + SessionROInum(nmnm);
end

%%
NCdataAllStrc = load('OFC_ipsiInhibition_NoiseCorrelation_ModifiedZscore_9sessions.mat');
NC_nonopto = NCdataAllStrc.Rnoise_nonOpto;
NC_opto = NCdataAllStrc.Rnoise_Opto;
%%
AUCDataAllStrc = load('OFC_IpsiInhibition_AUC_Summary_9sessions_2s_SbySession_bfRev.mat');
IsAUCRevertOpto = AUCDataAllStrc.rev_Opto;
IsAUCRevNonopto = AUCDataAllStrc.rev_nonOpto;

%%
NC_nonopto(2)=[];
NC_opto(2)=[];
IsAUCRevertOpto(2)=[];
IsAUCRevNonopto(2)=[];
%%
nSess = length(NC_opto);
LeftSessNCCellOpto = cell(nSess,1);
RightSessNCCellOpto = cell(nSess,1);
LRSessNCCellOpto = cell(nSess,1);
LeftSessNCCellCont = cell(nSess,1);
RightSessNCCellCont = cell(nSess,1);
LRSessNCCellCont = cell(nSess,1);
SigLeftAUCIndex = cell(nSess,1);
SigRightAUCIndex = cell(nSess,1);

for nmnm = 1 : nSess
    cOptoNC = NC_opto{nmnm};
    cNonoptoNC = NC_nonopto{nmnm};
    cOptoAUC = ContrilAUCCell{nmnm};
    cNonoptoAUC = OptoAUCCell{nmnm};
    cAUCThres = SessionROIThres{nmnm};
    cSessAUCIsRevertOpto = logical(IsAUCRevertOpto{nmnm});
    cSessAUCIsRevNonopto = logical(IsAUCRevNonopto{nmnm});
    
    SigNonOptoAUCInds = find(cNonoptoAUC > cAUCThres);
    SigNonOptoAUCIsRev = cSessAUCIsRevNonopto(SigNonOptoAUCInds);
    SigNonOptoLeftAUC = SigNonOptoAUCInds(SigNonOptoAUCIsRev);
    SigNonOptoRightAUC = SigNonOptoAUCInds(~SigNonOptoAUCIsRev);
    SigLeftAUCIndex{nmnm} = SigNonOptoLeftAUC;
    SigRightAUCIndex{nmnm} = SigNonOptoRightAUC;
    
    cOptoNCMtx = squareform(cOptoNC);
    cNonoptoNCMtx = squareform(cNonoptoNC); % fffff
    OptoLeftNCdataMtx = cOptoNCMtx(SigNonOptoLeftAUC,SigNonOptoLeftAUC);
    OptoRightNCdataMtx = cOptoNCMtx(SigNonOptoRightAUC,SigNonOptoRightAUC);
    OptoLeftNCVec = OptoLeftNCdataMtx(logical(tril(ones(size(OptoLeftNCdataMtx)),-1)));
    OptoRightNCVec = OptoRightNCdataMtx(logical(tril(ones(size(OptoRightNCdataMtx)),-1)));
    OptoLRNCVec = reshape(cOptoNCMtx(SigNonOptoLeftAUC,SigNonOptoRightAUC),[],1);
    
    ContLeftNCdataMtx = cNonoptoNCMtx(SigNonOptoLeftAUC,SigNonOptoLeftAUC);
    ContRightNCdataMtx = cNonoptoNCMtx(SigNonOptoRightAUC,SigNonOptoRightAUC);
    ContLeftNCVec = ContLeftNCdataMtx(logical(tril(ones(size(ContLeftNCdataMtx)),-1)));
    ContRightNCVec = ContRightNCdataMtx(logical(tril(ones(size(ContRightNCdataMtx)),-1)));
    ContLRNVVec = reshape(cNonoptoNCMtx(SigNonOptoLeftAUC,SigNonOptoRightAUC),[],1);
    
    LeftSessNCCellOpto{nmnm} = OptoLeftNCVec;
    RightSessNCCellOpto{nmnm} = OptoRightNCVec;
    LRSessNCCellOpto{nmnm} = OptoLRNCVec;
    LeftSessNCCellCont{nmnm} = ContLeftNCVec;
    RightSessNCCellCont{nmnm} = ContRightNCVec;
    LRSessNCCellCont{nmnm} = ContLRNVVec;
end

%%
LeftOptoNCAll = cell2mat(LeftSessNCCellOpto);
RightOptoNCAll = cell2mat(RightSessNCCellOpto);
LROptoNCAll = cell2mat(LRSessNCCellOpto);
LeftContNCAll = cell2mat(LeftSessNCCellCont);
RightContNCAll = cell2mat(RightSessNCCellCont);
LRContNCAll = cell2mat(LRSessNCCellCont);

OptoWinNC = [LeftOptoNCAll;RightOptoNCAll];
ContWinNC = [LeftContNCAll;RightContNCAll];
OptoBetNC = LROptoNCAll;
ContBetNC = LRContNCAll;

save GrWisedNCdataDe.mat LeftOptoNCAll RightOptoNCAll LeftContNCAll RightContNCAll LROptoNCAll LRContNCAll LeftSessNCCellOpto ...
    RightSessNCCellOpto LRSessNCCellOpto LeftSessNCCellCont RightSessNCCellCont LRSessNCCellCont -v7.3
save GrWisedNCdata.mat OptoWinNC ContWinNC OptoBetNC ContBetNC SigLeftAUCIndex SigRightAUCIndex -v7.3
%%
TaskNCdataBet = ContBetNC;
TaskNCdataWin = ContWinNC;
PassNCdataBet = OptoBetNC;
PassNCdataWin = OptoWinNC;

%%
MeanNCData = [mean(TaskNCdataBet),mean(TaskNCdataWin),mean(PassNCdataBet),mean(PassNCdataWin)];
hBarPlot = figure('position',[500 300 980 800]);
hold on
hTaskNCBet = bar(1,mean(TaskNCdataBet),0.3,'FaceColor',[.8 .8 1],'EdgeColor','none');
hTaskNCWin = bar(2,mean(TaskNCdataWin),0.3,'FaceColor',[.2 .2 1],'EdgeColor','none');
hPassNCBet = bar(3,mean(PassNCdataBet),0.3,'FaceColor',[.7 .7 .7],'EdgeColor','none');
hPassNCWin = bar(4,mean(PassNCdataWin),0.3,'FaceColor',[.2 .2 .2],'EdgeColor','none');
p_TaskBet_PassBet = ranksum(TaskNCdataBet,PassNCdataBet);
p_TaskBet_TaskWin = ranksum(TaskNCdataBet,TaskNCdataWin);
p_TaskWin_PassWin = ranksum(TaskNCdataWin,PassNCdataWin);
p_PassBet_PassWin = ranksum(PassNCdataBet,PassNCdataWin);
hhf = GroupSigIndication([1,3],[mean(TaskNCdataBet),mean(PassNCdataBet)],p_TaskBet_PassBet,hBarPlot,[],mean(TaskNCdataWin));
hhf = GroupSigIndication([1,2],[mean(TaskNCdataBet),mean(TaskNCdataWin)],p_TaskBet_TaskWin,hhf,1.2);
hhf = GroupSigIndication([2,4],[mean(TaskNCdataWin),mean(PassNCdataWin)],p_TaskWin_PassWin,hhf,1.25);
hhf = GroupSigIndication([3,4],[mean(PassNCdataBet),mean(PassNCdataWin)],p_PassBet_PassWin,hhf,1.4);
text([1,2,3,4],MeanNCData*1.01,cellstr(num2str(MeanNCData(:),'%.3f')),'HorizontalAlignment','center','FontSize',16);
set(gca,'xtick',[1,2,3,4],'xticklabel',{'Bet','Win','Bet','Win'});
yscales = get(gca,'ylim');
set(gca,'ytick',yscales(1):0.1:yscales(2));
ylabel({'Mean';'Noise correlation coeficient value'});
set(gca,'FontSize',18);
text(1.5,-0.02,'Contol','FontSize',14,'HorizontalAlignment','center');
text(3.5,-0.02,'Opto','FontSize',14,'HorizontalAlignment','center');
saveas(hhf,'Control opto compare bar plot');
saveas(hhf,'Control opto compare bar plot','png');
saveas(hhf,'Control opto compare bar plot','pdf'); % saved in pdf and then will be able to open in illustrator directlly
