function EventPeaksData = EventPeaks_Fun(EventIndex,RawData)
% extract event data peak from raw data matrix

nROIs = length(EventIndex);
if nROIs ~= size(RawData,1)
    error('Unequal size of input datas');
end
ww = gausswin(7,0.5);
EventPeaksData = cell(nROIs,1);
for cR = 1 : nROIs
    cRTrace = RawData(cR,:);
    SmTrace = (conv(cRTrace,ww,'same')/sum(ww))';
    
    cR_EventMtx = EventIndex{cR};
    if isempty(cR_EventMtx)
        cR_Peak = [];
    else
        Ev_PeakIndex = cR_EventMtx(:,1);
        cR_Peak = SmTrace(Ev_PeakIndex);
    end
    EventPeaksData{cR} = cR_Peak;
end
    
