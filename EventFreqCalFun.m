function  [NeuEventFreq,AstEventFreq] = EventFreqCalFun(DataAlls)

DataEvents = DataAlls(:,1);
DataROITypes = DataAlls(:,2);
DataROITimes = DataAlls(:,3);
NumUsedSessions = size(DataAlls,1);
NeuEventFreq = cell(NumUsedSessions,1);
AstEventFreq = cell(NumUsedSessions,1);

for cSess = 1 : NumUsedSessions
    cSessROITypes = DataROITypes{cSess};
    WTSess_EventData_NeuInds = strcmpi(cSessROITypes,'Neu');
    SessEventNums = cellfun(@(x) size(x,1),DataEvents{cSess});
    
    SessEventFreq = SessEventNums(:) ./ DataROITimes{cSess};
    NeuEventFreq{cSess} = SessEventFreq(WTSess_EventData_NeuInds);
    AstEventFreq{cSess} = SessEventFreq(~WTSess_EventData_NeuInds);
    
end
    
    
    


