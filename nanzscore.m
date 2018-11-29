function zsData = nanzscore(data,varargin)
% performing columnwise zscore, return the zscore data 
% for each columns using Non-nan data. if no nan data was find, the
% function works just the same as built-in function 'zscore'
if size(data,1) == 1 || size(data,2) == 1
    data = data(:);
end
if ~sum(any(isnan(data)))
    zsData = zscore(data,varargin{:}); % if no nan data was found
else
    [~,Cols] = size(data);
    zsData = nan(size(data));
    for cCol = 1 : Cols
        cColData = data(:,cCol);
        NanDataInds = isnan(cColData);
        NotNanDatas = cColData(~NanDataInds);
        cZsDatas = zscore(NotNanDatas(:));
        zsData(~NanDataInds,cCol) = cZsDatas;
    end
end
