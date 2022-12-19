% AllPairInfos(cPairInds,:) = {TypeDataCalInfo_BT_A1,TypeDataCalInfo_BT_A2...
%         TypeDataCalInfo_Choice_A1,TypeDataCalInfo_Choice_A2}; % A1_info_BT,A2_info_BT,A1_info_choice,A2_info_choice
load(fullfile(ksfolder,'jeccAnA','ProjDataInfo.mat'));

CalDataTypeStrs = {'Base_BVar','Base_TrVar','Af_BVar','Af_TrVar'};
BaseValidTimeCents = -0.95:0.1:1;
AfValidTimeCents = -0.95:0.1:2;
ResidueFolder = fullfile(ksfolder,'jeccAnA','ResidueInfo');
if ~isfolder(ResidueFolder)
    mkdir(ResidueFolder);
end

NumPairs  = size(PairAreaInds,1);
AllPairInfoDatas = cell(NumPairs, 2);
AllPair_AreaStrs = cell(NumPairs,2);
for cPair = 1 : NumPairs
    cPairInds = PairAreaInds(cPair,:);
    cPairStrs = ExistField_ClusIDs(cPairInds,4);
    cPairedAreaStr = [cPairStrs{1},'-',cPairStrs{2}];
    AllPair_AreaStrs(cPair,:) = cPairStrs;
    
    A1_BT_InfoDatas = cat(1,AllPairInfos{:,1});
    A2_BT_InfoDatas = cat(1,AllPairInfos{:,2});

    A1_Choice_InfoDatas = cat(1,AllPairInfos{:,3});
    A2_Choice_InfoDatas = cat(1,AllPairInfos{:,4});

    [huf_BT, BTInfoDatas] = CCAPorjInfo_plot_fun([100 100 380 480],A1_BT_InfoDatas,...
        A2_BT_InfoDatas,cPair,cPairStrs,'BTinfo');
    %
    [huf_Choice, ChoiceInfoDatas] = CCAPorjInfo_plot_fun([600 100 380 480],A1_Choice_InfoDatas,...
        A2_Choice_InfoDatas,cPair,cPairStrs,'Choiceinfo');
    
%

    FigsavePath1 = fullfile(ResidueFolder,sprintf('Pair %s Residues_BTInfoPlot',cPairedAreaStr));
    FigsavePath2 = fullfile(ResidueFolder,sprintf('Pair %s Residues_ChInfoPlot',cPairedAreaStr));

    saveas(huf_BT,FigsavePath1);
    print(huf_BT,FigsavePath1,'-dpng','-r350');

    saveas(huf_Choice,FigsavePath2);
    print(huf_Choice,FigsavePath2,'-dpng','-r350');
    close([huf_BT huf_Choice]);
    
    AllPairInfoDatas(cPair,:) = {BTInfoDatas, ChoiceInfoDatas};
end

dataSavePath = fullfile(ResidueFolder,'AreaResidue_info.mat');
save(dataSavePath,'AllPairInfoDatas','AllPair_AreaStrs','PairAreaInds','ExistField_ClusIDs','-v7.3');




