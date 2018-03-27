function DataStrc = MeanMaxSEMCal(Data,TrTypes,FrameScale)
% small function used to calculate the mean max value and corresponded sem
% using input data set
TrTypeAll = unique(TrTypes);
nTypes = length(TrTypeAll);
nROIs = size(Data,2);
DataMeanValues = zeros(nTypes,nROIs);
DataSEMValue = zeros(nTypes,nROIs);
 for cType = 1 : nTypes
     cTypeInds = TrTypes == TrTypeAll(cType);
     
     for cROI = 1 : nROIs
         cROItypeData = squeeze(Data(cTypeInds,cROI,:));
         if length(cROItypeData) == numel(cROItypeData)
             cROItypeMean = cROItypeData;
             cROItypeSEM = zeros(size(cROItypeData));
         else
            cROItypeMean = mean(cROItypeData);
            cROItypeSEM = std(cROItypeData)/sqrt(size(cROItypeData,1));
         end
         
         [cMaxvalue,cMaxInds] = max(cROItypeMean(FrameScale(1):FrameScale(2)));
         cMaxSEM = cROItypeSEM(cMaxInds+FrameScale(1)-1);
         DataMeanValues(cType,cROI) = cMaxvalue;
         DataSEMValue(cType,cROI) = cMaxSEM;
     end
 end
 DataStrc.MeanValue = DataMeanValues;
 DataStrc.SEMValue = DataSEMValue;
%          
%      cTypedData = Data(cTypeInds,:,:);
%      cTypeMean = squeeze(mean(cTypedData));
%      [MaxMeanV,MaxMeanInds] = max(cTypeMean(:,FrameScale(1):FrameScale(2)),[],2);
%      cROISEM = zeros(nROIs,1);
%      for cROI = 1 : nROIs
%          cROIcFreqMaxIndsData = squeeze(cTypedData(:,cROI,MaxMeanInds(cROI)));
%          cROISEM(cROI) = 