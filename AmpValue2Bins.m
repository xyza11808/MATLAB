function [SessEFData, EventBins, BinCenters] = AmpValue2Bins(Sess_EventData_all,BinSize,BinMax)

% script for binned event frequency cumulative plots
if isempty(BinSize)
    BinSize = 0.2;
end
if ~exist('BinMax','var')
    BinMax  = 5;
end

ROITypeStr = {'Neu','Ast'};
EventBins = [0,1e-5,BinSize:BinSize:BinMax,BinMax];
BinCenters = [0,BinSize/2:BinSize:(BinMax-BinSize/2),BinMax];
if size(Sess_EventData_all,2) > 1
    SessFieldNums = size(Sess_EventData_all,1);
    SessEFData = cell(SessFieldNums,6);
    for cf = 1 : SessFieldNums
        cfEventData = Sess_EventData_all{cf,1};
        cfDataType = Sess_EventData_all{cf,2};

        NumROIs = length(cfEventData);
        ROIEventFreq = zeros(NumROIs,1);
        ROITypes = zeros(NumROIs,1);
        for cR = 1 : NumROIs
            cREvent = cfEventData{cR};
            ROIEventFreq(cR) = size(cREvent,1) / Sess_EventData_all{cf,3}(cR);

            cRType = cfDataType{cR};
            if strcmpi(cRType,'Neu')
                ROITypes(cR) = 1;
            else
                ROITypes(cR) = 2;
            end
        end

        SessEFData{cf,1} = ROIEventFreq;
        SessEFData{cf,2} = ROITypes;

        % calculate the binned event freqs, separeted for Ast and Neu
        FieldNeuInds = ROITypes == 1;

        NeubinCount = histcounts(ROIEventFreq(FieldNeuInds),...
            EventBins)/sum(FieldNeuInds);
        AstbinCount = histcounts(ROIEventFreq(~FieldNeuInds),...
            EventBins)/sum(~FieldNeuInds);

        SessEFData{cf,3} = cumsum(NeubinCount);
        SessEFData{cf,4} = cumsum(AstbinCount);
        SessEFData{cf,5} = [sum(FieldNeuInds),sum(~FieldNeuInds)];
        SessEFData{cf,6} = [mean(ROIEventFreq(FieldNeuInds)),...
            mean(ROIEventFreq(~FieldNeuInds))];
    end
else
    SessFieldNums = size(Sess_EventData_all,1);
    SessEFData = cell(SessFieldNums,2);
    for cf = 1 : SessFieldNums
        cfEventData = Sess_EventData_all{cf,1};
        if ~isempty(cfEventData)
            cfbincount = histcounts(cfEventData,...
                EventBins)/sum(numel(cfEventData));
            SessEFData{cf,1} = cumsum(cfbincount);
            SessEFData{cf,2} = numel(cfEventData);
        else
            SessEFData{cf,1} = nan(1,length(BinCenters));
            SessEFData{cf,2} = NaN;
        end
        
    end
    
    
end


