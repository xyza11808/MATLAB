function [UsedBinCenter,UsedNCbinData,UsedSCbinData] = MinBinnumberDataExtrac(Bincenter, NCbinData, SCbinData, binNum)
% this function is call by cellfun in script: SCNC_dissumary_scripts
if ~isempty(Bincenter)
    UsedBinCenter = Bincenter(1 : binNum);
else
    UsedBinCenter = [];
end
if ~isempty(NCbinData)
    UsedNCbinData = NCbinData(1 : binNum,:);
else
    UsedNCbinData = [];
end
if ~isempty(SCbinData)
    UsedSCbinData = SCbinData(1 : binNum,:);
else
    UsedSCbinData = [];
end