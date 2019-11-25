function FieldCoefDataAlls = EventDataProcessFun(AnmPath)
% load All realated datas
AllFieldData_Strc = load(fullfile(AnmPath,'AllFieldDatasNew.mat'));
AllFieldData_cell = AllFieldData_Strc.FieldDatas_AllCell;
FieldNum = size(AllFieldData_cell,1);

FieldCoefDataAlls = cell(FieldNum,2);
FieldCoefDataAlls(:,1) = AllFieldData_cell(:,5);
for cfield = 1 : FieldNum
    cfName = AllFieldData_cell{cfield,2};
    cFieldROIInfo_strc = load(fullfile(AnmPath,cfName,'CorrCoefDataNew.mat'),'ROIdataStrc');
    ROITypes = arrayfun(@(x) x.ROItype,cFieldROIInfo_strc.ROIdataStrc.ROIInfoDatas,'uniformOutput',false);
    FieldframeTime = repmat(size(AllFieldData_cell{cfield,1},2)/1800,numel(ROITypes),1);
    
    FieldCoefDataAlls(cfield,2) = {ROITypes'};
    FieldCoefDataAlls(cfield,3) = {FieldframeTime};
    
    cFieldDatas = AllFieldData_cell{cfield,1};
    cFieldEventsData = AllFieldData_cell{cfield,5};
    
    NumROIs = size(cFieldDatas,1);
%     EventTimes = zeros(size(cFieldDatas));
%     for cR = 1 : NumROIs
%         cREvents = cFieldEventsData{cR};
%         if ~isempty(cREvents)
%             cEventNum = size(cREvents,1);
%             for cEvent = 1 : cEventNum
%                 cEventIndexs = cREvents(cEvent,:);
%                 EventTimes(cR,cEventIndexs(2):cEventIndexs(3)) = 1;
%             end
%         end
%     end
    
    nRep = 500;
%     ShufEventAllRepeat = zeros(nRep,NumROIs,size(EventTimes,2));
%     % generate shuffle indexs
%     parfor cRepeat = 1 : nRep
%         ShufEventIndexs = EventTimes;
%         for cR = 1 : NumROIs
%             ShufEventIndexs(cR,:) = Vshuffle(ShufEventIndexs(cR,:));
%         end
%         ShufEventAllRepeat(cRepeat,:,:) = ShufEventIndexs;
%     end
%     ShuffleEventIndex = prctile(squeeze(mean(ShufEventAllRepeat,2)),95);
    
    ShufRespAllRepeat = zeros(nRep,NumROIs,size(cFieldDatas,2));
    % generate shuffle indexs
    parfor cRepeat = 1 : nRep
        ShufEventIndexs = cFieldDatas;
        for cR = 1 : NumROIs
            ShufEventIndexs(cR,:) = Vshuffle(ShufEventIndexs(cR,:));
        end
        ShufRespAllRepeat(cRepeat,:,:) = ShufEventIndexs;
    end
    ShufResp_baseData = squeeze(prctile(ShufRespAllRepeat,95));
    EventTimes = double(cFieldDatas >= ShufResp_baseData);
    %%
    ShufEventAllRepeat = zeros(nRep,NumROIs,size(cFieldDatas,2));
    parfor cRepeat = 1 : nRep
        ShufEventIndexs = EventTimes;
        for cR = 1 : NumROIs
            ShufEventIndexs(cR,:) = Vshuffle(ShufEventIndexs(cR,:));
        end
        ShufEventAllRepeat(cRepeat,:,:) = ShufEventIndexs;
    end
    ShuffleEventIndex = prctile(squeeze(mean(ShufEventAllRepeat,2)),95);
    %%
    FieldCoefDataAlls{cfield,4} = EventTimes;
    FieldCoefDataAlls{cfield,5} = ShuffleEventIndex;
end
        