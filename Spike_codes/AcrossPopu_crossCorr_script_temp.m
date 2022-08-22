
clearvars CalResults OutDataStrc ExistField_ClusIDs EventRespCalResults EventSpeciCCR

% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
% ksfolder = pwd;
% load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
Savepath = fullfile(ksfolder,'jeccAnA');
dataSavePath = fullfile(Savepath,'JeccDataNew.mat');
load(dataSavePath,'EventRespCalResults','OutDataStrc','ExistField_ClusIDs','NewAdd_ExistAreaNames',...
    'CalResults','EventStrs','EventDatas');
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
% BlockSectionInfo = Bev2blockinfoFun(behavResults);

%%
% NumCalculations = (Numfieldnames-1)*Numfieldnames/2;
% EventRespCalResults = cell(NumCalculations,3);
% EventRespCalAreaIndsANDName = cell(NumCalculations,4);
% ks = 1;
% for cAr = 1 : Numfieldnames
%     for cAr2 = cAr+1 : Numfieldnames
%         % baseline
%         Area1_binned_datas = BaselineResp(:,ExistField_ClusIDs{cAr,2});
%         Area2_binned_datas = BaselineResp(:,ExistField_ClusIDs{cAr2,2});
%         
%         [A_base,B_base,R_base] = canoncorr(Area1_binned_datas,Area2_binned_datas); % U = (X - mean(X))*A; V = (Y - mean(Y))*B; R(x) = corrcoef(U(:,1),V(:,1));
%         
%         % stimulus
%         Area1_binned_datas = StimOnResp(:,ExistField_ClusIDs{cAr,2});
%         Area2_binned_datas = StimOnResp(:,ExistField_ClusIDs{cAr2,2});
%         
%         [A_stim,B_stim,R_stim] = canoncorr(Area1_binned_datas,Area2_binned_datas); % U = (X - mean(X))*A; V = (Y - mean(Y))*B; R(1) = corrcoef(U(:,1),V(:,1));
%         
%         % choice1
%         Area1_binned_datas = ChoiceResps1(:,ExistField_ClusIDs{cAr,2});
%         Area2_binned_datas = ChoiceResps1(:,ExistField_ClusIDs{cAr2,2});
%         
%         [A_choice1,B_choice1,R_choice1] = canoncorr(Area1_binned_datas,Area2_binned_datas);
%         
% %         % choice 2
% %         Area1_binned_datas = ChoiceResps2(:,ExistField_ClusIDs{cAr,2});
% %         Area2_binned_datas = ChoiceResps2(:,ExistField_ClusIDs{cAr2,2});
% %         
% %         [A_choice2,B_choice2,R_choice2] = canoncorr(Area1_binned_datas,Area2_binned_datas);
%         
%         
%         EventRespCalResults(ks,:) = {{A_base,B_base,R_base},{A_stim,B_stim,R_stim},...
%             {A_choice1,B_choice1,R_choice1}}; %{A_choice2,B_choice2,R_choice2}
%         EventRespCalAreaIndsANDName(ks,:) = {ExistField_ClusIDs{cAr,2},ExistField_ClusIDs{cAr2,2},...
%             NewAdd_ExistAreaNames{cAr},NewAdd_ExistAreaNames{cAr2}};
%         ks = ks + 1;
%     end
% end
% 
% EventDatas = {BaselineResp,StimOnResp,ChoiceResps1}; %,ChoiceResps2
% EventStrs = {'Baseline','Stim','Choice1'}; %,'Choice2'


%% joint-correlation analysis
Numfieldnames = length(NewAdd_ExistAreaNames);
NumCalculations = (Numfieldnames-1)*Numfieldnames/2;
NumofCaledEvents = length(EventStrs);
NumofBins = size(NewBinnedDatas,3);
NumofTrials = size(NewBinnedDatas,1);
NumShufRepeats = 100;
EventRespCalAreaIndsANDName = cell(NumCalculations,4);
EventSpeciCCR = cell(NumCalculations,2);
MaxShiftAmounts = round(NumofBins/2)-5;

k = 1;
for cAr = 1 : Numfieldnames
    for cAr2 = cAr+1 : Numfieldnames
        EventBinCoefValues = zeros(NumofCaledEvents, NumofBins);
        EventShufCoefValues = zeros(NumofCaledEvents, NumofBins,NumShufRepeats);
        
        cAr1_data = NewBinnedDatas(:,ExistField_ClusIDs{cAr,2},:);
        cAr2_data = NewBinnedDatas(:,ExistField_ClusIDs{cAr2,2},:);
        ShufShiftsMtx = round((rand(NumofTrials,NumShufRepeats)-0.5)*2*MaxShiftAmounts);
        
       for cEvents = 1 : NumofCaledEvents
           cEvent_loadCeofData = EventRespCalResults{k,cEvents};
           cEvent_cAr_load = cEvent_loadCeofData{1};
           cEvent_cAr2_load = cEvent_loadCeofData{2};
           % real data calculation
           for cBin = 1 : NumofBins
               cBin_cAr1_Data = cAr1_data(:,:,cBin);
               cBin_cAr2_Data = cAr2_data(:,:,cBin);
               
               cBin_cAr1_U = (cBin_cAr1_Data - mean(cBin_cAr1_Data)) * cEvent_cAr_load;
               cBin_cAr2_V = (cBin_cAr2_Data - mean(cBin_cAr2_Data)) * cEvent_cAr2_load;
               
               EventBinCoefValues(cEvents,cBin) = corr(cBin_cAr1_U(:,1),cBin_cAr2_V(:,1));
           end
           
           % shuf matrix data anlysis
           ShufDataSize = size(NewBinnedDatas);
           parfor cRepeat = 1 : NumShufRepeats
               ShufBinDatas = zeros(ShufDataSize);
               cRepeatAmounts = ShufShiftsMtx(:,cRepeat);
               for cRow = 1 : NumofTrials
                   cRow_Realdata = NewBinnedDatas(cRow,:,:);
                   ShufBinDatas(cRow,:,:) = circshift(cRow_Realdata,cRepeatAmounts(cRow),3);
               end
               cAr1_data = ShufBinDatas(:,ExistField_ClusIDs{cAr,2},:);
               cAr2_data = ShufBinDatas(:,ExistField_ClusIDs{cAr2,2},:);
               for cBin = 1 : NumofBins
                   cBin_cAr1_Data = cAr1_data(:,:,cBin);
                   cBin_cAr2_Data = cAr2_data(:,:,cBin);

                   cBin_cAr1_U = (cBin_cAr1_Data - mean(cBin_cAr1_Data)) * cEvent_cAr_load;
                   cBin_cAr2_V = (cBin_cAr2_Data - mean(cBin_cAr2_Data)) * cEvent_cAr2_load;

                   EventShufCoefValues(cEvents,cBin,cRepeat) = corr(cBin_cAr1_U(:,1),cBin_cAr2_V(:,1));
               end

           end
       end
        
        EventSpeciCCR(k,:) = {EventBinCoefValues,EventShufCoefValues};
        EventRespCalAreaIndsANDName(k,:) = {ExistField_ClusIDs{cAr,2},ExistField_ClusIDs{cAr2,2},...
            NewAdd_ExistAreaNames{cAr},NewAdd_ExistAreaNames{cAr2}};
        k = k + 1;
    end
end
%%
% Savepath = fullfile(ksfolder,'jeccAnA');
% if ~isfolder(Savepath)
%     mkdir(Savepath);
% end
% dataSavePath = fullfile(Savepath,'JeccDataNew.mat');

save(dataSavePath,'CalResults','EventRespCalResults','OutDataStrc','EventDatas','EventStrs',...
    'ExistField_ClusIDs','NewAdd_ExistAreaNames','EventRespCalAreaIndsANDName','EventSpeciCCR','-v7.3')
%%
% CalTimeBinNums = [min(OutDataStrc.BinCenters),max(OutDataStrc.BinCenters)];
% StimOnBinTime = 0; %OutDataStrc.BinCenters(OutDataStrc.TriggerStartBin);
% cCalInds = 10;
% cCalIndsPopuSize = CalResults{cCalInds,5};
% 
% figure;
% hold on
% 
% imagesc(OutDataStrc.BinCenters,OutDataStrc.BinCenters, CalResults{cCalInds,1});
% line(CalTimeBinNums,CalTimeBinNums,'Color','w','linewidth',1.8);
% line(CalTimeBinNums,[StimOnBinTime StimOnBinTime],'Color','m','linewidth',1.5);
% line([StimOnBinTime StimOnBinTime],CalTimeBinNums,'Color','m','linewidth',1.5);
% xlabel(['Time(s) ',CalResults{cCalInds,3},num2str(cCalIndsPopuSize(1),', n = %d')]);
% ylabel(['Time(s) ',CalResults{cCalInds,4},num2str(cCalIndsPopuSize(2),', n = %d')]);


