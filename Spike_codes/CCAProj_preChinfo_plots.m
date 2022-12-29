% AllPairInfos(cPairInds,:) = {TypeDataCalInfo_BT_A1,TypeDataCalInfo_BT_A2...
%         TypeDataCalInfo_Choice_A1,TypeDataCalInfo_Choice_A2}; % A1_info_BT,A2_info_BT,A1_info_choice,A2_info_choice

ResidueFolder = fullfile(ksfolder,'jeccAnA','ResidueInfo_preCh');
if ~isfolder(ResidueFolder)
    mkdir(ResidueFolder);
end

dataSavePath = fullfile(ResidueFolder,'AreaResidue_preChinfo.mat');

if exist(dataSavePath,'file')
    return;
end

load(fullfile(ksfolder,'jeccAnA','ProjDataInfo_PrechoiceInfo.mat'));

CalDataTypeStrs = {'Base_BVar','Base_TrVar','Af_BVar','Af_TrVar'};
BaseValidTimeCents = -0.95:0.1:1;
AfValidTimeCents = -0.95:0.1:2;

NumPairs  = size(PairAreaInds,1);
AllPairInfoDatas_preCh = cell(NumPairs, 4, 2);
AllPair_AreaStrs = cell(NumPairs,4);
for cPair = 1 : NumPairs
    cPairInds = PairAreaInds(cPair,:);
    cPairStrs = ExistField_ClusIDs(cPairInds,4);
    cPairedAreaStr = [cPairStrs{1},'-',cPairStrs{2}];
    AllPair_AreaStrs(cPair,1:2) = cPairStrs;

    A1_Choice_InfoDatas = cat(1,AllPairInfos{:,1});
    A2_Choice_InfoDatas = cat(1,AllPairInfos{:,2});

    [huf_Choice, ChoiceInfoDatas] = CCAPorjInfo_plot_fun([600 100 380 480],A1_Choice_InfoDatas,...
        A2_Choice_InfoDatas,cPair,cPairStrs,'Choiceinfo');

    FigsavePath2 = fullfile(ResidueFolder,sprintf('Pair %s Residues_preChInfoPlot',cPairedAreaStr));

    saveas(huf_Choice,FigsavePath2);
    print(huf_Choice,FigsavePath2,'-dpng','-r350');
    close(huf_Choice);
    
    AllPairInfoDatas_preCh(cPair,:,1) = ChoiceInfoDatas.A1Datas;
    AllPairInfoDatas_preCh(cPair,:,2) = ChoiceInfoDatas.A2Datas;
    
    AllPair_AreaStrs(cPair,3:4) = {ChoiceInfoDatas.BaselineTimes,ChoiceInfoDatas.AfterTimes};
    
end
%%

save(dataSavePath,'AllPairInfoDatas_preCh','AllPair_AreaStrs',...
    'PairAreaInds','ExistField_ClusIDs','CalDataTypeStrs','-v7.3');
