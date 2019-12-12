
cField = 1;
cFieldData = AllFieldData_cell{cField,1};
cFieldEvents = AllFieldData_cell{cField,5};
cFieldROIs = length(cFieldEvents);

%%
% RearrangedData = zeros(size(cFieldData));
RearrangedData_2 = zeros(size(cFieldData));
NumFrames = size(cFieldData,2);
% close
% cROI = 234;
for cROI = 1 : cFieldROIs
    cROIEvent = cFieldEvents{cROI};
    cROITrace = cFieldData(cROI,:);
%     NoiseLevel = std(cROITrace' - smooth(cROITrace,10));
    StdCalRange = prctile(cROITrace,[10 90 40]);
    Noise_2 = std(cROITrace(cROITrace > StdCalRange(1) & cROITrace < StdCalRange(2)));
    NoiseLevel = Noise_2;
    Mean_2 = StdCalRange(3);
%     NoiseLevel = sqrt(NoiseLevel);
    
%     cEmpTrace = RearrangedData(cROI,:);
    cEmpTrace_2 = RearrangedData_2(cROI,:);
    NumEvents = length(cROIEvent);
    if ~NumEvents
%         cEmpTrace = (rand(NumFrames,1)*2 - 1)*NoiseLevel + mean(cROITrace);
        cEmpTrace_2 = (rand(NumFrames,1)*2 - 1)*Noise_2 + Mean_2;
    else
        NumEvents = size(cROIEvent,1);
        for cEven = 1 : NumEvents
            cEveStart = cROIEvent(cEven,2);
            cEveEnd = cROIEvent(cEven,3);
            if cEven == 1
                BaseStartInds = 1;
            else
                BaseStartInds = cROIEvent(cEven-1,3);
            end
            NewBaselineData = mean(cROITrace(BaseStartInds:(cEveStart-1))) + (rand(cEveStart-BaseStartInds,1)*2 - 1)*NoiseLevel;
            NewBaselineData_2 = Mean_2 + (rand(cEveStart-BaseStartInds,1)*2 - 1)*Noise_2;
            
%             cEmpTrace(cEveStart:cEveEnd) = cROITrace(cEveStart:cEveEnd);
%             cEmpTrace(BaseStartInds:(cEveStart-1)) = NewBaselineData;
            cEmpTrace_2(BaseStartInds:(cEveStart-1)) = NewBaselineData_2;
            cEmpTrace_2(cEveStart:cEveEnd) = cROITrace(cEveStart:cEveEnd);
        end
        if cEveEnd ~= NumFrames && NumEvents
%             cEmpTrace((cEveEnd+1):NumFrames) = mean(cROITrace((cEveEnd+1):NumFrames)) + ...
%                 (rand(NumFrames-cEveEnd,1)*2 - 1)*NoiseLevel;
            cEmpTrace_2((cEveEnd+1):NumFrames) = Mean_2 + (rand(NumFrames-cEveEnd,1)*2 - 1)*Noise_2;
        end
    end
%     figure('position',[2000 500 1500 400])
%     hold on
%     plot(cROITrace,'r')
%     plot(cEmpTrace,'Color',[.7 .7 .7]);
%     plot(cEmpTrace_2,'c')
    RearrangedData_2(cROI,:) = cEmpTrace_2;
end 
        
            
    
