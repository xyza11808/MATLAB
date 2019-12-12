function FieldCoefDataAlls = EventDataProcessFun_EO(AnmPath,varargin)
MatfileName = 'AllFieldDatasNew.mat';
if nargin > 1
    if ~isempty(varargin{1})
        MatfileName = varargin{1};
    end
end
CorrCoefData = 'CorrCoefDataNew.mat';
if nargin > 2
    if ~isempty(varargin{2})
        CorrCoefData = varargin{2};
    end
end
Calculatetype = 'Neu';
if nargin > 3
    if ~isempty(varargin{3})
        Calculatetype = varargin{3};
    end
end
IsActiveNeuOnly = 0;
if nargin > 4
    if ~isempty(varargin{4})
        IsActiveNeuOnly = varargin{4};
    end
end

% load All realated datas
AllFieldData_Strc = load(fullfile(AnmPath,MatfileName));
AllFieldData_cell = AllFieldData_Strc.FieldDatas_AllCell;
FieldNum = size(AllFieldData_cell,1);
FieldEventOnlyDatas = EventOnlyTrace_fun(AnmPath,MatfileName);

FieldCoefDataAlls = cell(FieldNum,2);
FieldCoefDataAlls(:,1) = AllFieldData_cell(:,5);
for cfield = 1 : FieldNum
    cfName = AllFieldData_cell{cfield,2};
    cFieldROIInfo_strc = load(fullfile(AnmPath,cfName,CorrCoefData),'ROIdataStrc');
    ROITypes = arrayfun(@(x) x.ROItype,cFieldROIInfo_strc.ROIdataStrc.ROIInfoDatas,'uniformOutput',false);
    switch Calculatetype
        case 'Neu'
            UsedROIInds = cellfun(@(x) ~isempty(strfind(x,'Neu')),ROITypes);
        case 'Ast'
            UsedROIInds = cellfun(@(x) ~isempty(strfind(x,'Ast')),ROITypes); 
        case 'All'
            UsedROIInds = true(numel(ROITypes),1);
        otherwise
            error('Unkonwn input ROI type');
    end
    if IsActiveNeuOnly
        NeuEventsData = AllFieldData_cell{cfield,5};
        IsROIActive = cellfun(@(x) ~isempty(x),NeuEventsData);
        UsedROIInds = UsedROIInds(:) & IsROIActive(:);
    end
    
    cField_evenOnlyData = FieldEventOnlyDatas{cfield};
    FieldframeTime = repmat(size(cField_evenOnlyData,2)/1800,numel(ROITypes),1);
    
    FieldCoefDataAlls(cfield,2) = {ROITypes'};
    FieldCoefDataAlls(cfield,3) = {FieldframeTime};
    
    cFieldDatas = cField_evenOnlyData(UsedROIInds,:);
    
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