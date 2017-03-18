function [cNCdataL,cNCdataR,cNCdataLR,cSCDataL,cSCDataR,cSCDataLR] = BinAlignFun(nBinLen,cNCdata,cSCData)
% this function is specifically used for scripts Group_DisCoef_linePlot,
% called by a cellfun within
if size(cNCdata,1) ~= nBinLen
    if size(cNCdata,1) < nBinLen
        CNCsizerow = size(cNCdata,1);
        cNCdata((CNCsizerow+1):nBinLen,:) = zeros((nBinLen - CNCsizerow),3);
    else
        cNCdata = cNCdata(1:nBinLen,:);
    end
end
cNCdataL = (cNCdata(:,1));
cNCdataR = (cNCdata(:,2));
cNCdataLR = (cNCdata(:,3));
if size(cSCData,1) ~= nBinLen
    if size(cSCData,1) < nBinLen
        CSCsizerow = size(cSCData,1);
        cSCData((CSCsizerow+1):nBinLen,:) = zeros((nBinLen - CSCsizerow),3);
    else
        cSCData = cSCData(1:nBinLen,:);
    end
end
cSCDataL = (cSCData(:,1));
cSCDataR = (cSCData(:,2));
cSCDataLR = (cSCData(:,3));