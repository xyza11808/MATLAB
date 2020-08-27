function DataStrc = MeanMaxSEMCal(Data,TrTypes,FrameScale,varargin)
% small function used to calculate the mean max value and corresponded sem
% using input data set
IsMinMaxOut = 0;
if nargin > 3
    if ~isempty(varargin{1})
        IsMinMaxOut = varargin{1};
    end
end

TrTypeAll = unique(TrTypes);
nTypes = length(TrTypeAll);
nROIs = size(Data,2);
DataMeanValues = zeros(nTypes,nROIs);
DataSEMValue = zeros(nTypes,nROIs);
DataSTDValue = zeros(nTypes,nROIs);
DataESValue = zeros(nTypes,nROIs); % effect size
ROITypeIndsData = cell(nTypes,nROIs);
TypeIndsNum = zeros(nTypes,1);
 for cType = 1 : nTypes
     cTypeInds = TrTypes == TrTypeAll(cType);
     TypeIndsNum(cType) = sum(cTypeInds);
     for cROI = 1 : nROIs
         cROItypeData = squeeze(Data(cTypeInds,cROI,:));
         if length(cROItypeData) == numel(cROItypeData)
             cROItypeData = cROItypeData';
             cROItypeMean = (smooth(cROItypeData,5))';
             cROItypeSEM = zeros(size(cROItypeData));
             cROItypeEffectSize = zeros(size(cROItypeData));
             cROItypeSTD = zeros(size(cROItypeData));
         else
            cROItypeMean = mean(cROItypeData);
            if size(cROItypeData,1) < 5
                cROItypeMean = (smooth(cROItypeMean,5))';
            end
            cROItypeSEM = std(cROItypeData)/sqrt(size(cROItypeData,1));
            cROItypeSTD = std(cROItypeData);
            cROItypeEffectSize = cROItypeMean/cROItypeSTD;
            if IsMinMaxOut
                SingleTrRespValue = mean(cROItypeData(:,FrameScale(1):FrameScale(2)),2);
                if length(SingleTrRespValue) > 9 % more than ten trials
                    LowHighBound = prctile(SingleTrRespValue,[10 90]);
                    UsedInds = SingleTrRespValue > LowHighBound(1) & SingleTrRespValue < LowHighBound(2);

                    cROItypeMean = mean(cROItypeData(UsedInds,:));
                    cROItypeSEM = std(cROItypeData(UsedInds,:))/sqrt(sum(UsedInds));
                    cROItypeSTD = std(cROItypeData(UsedInds,:));
                end
            end
         end
         
         [cMaxvalue,cMaxInds] = max(cROItypeMean(FrameScale(1):FrameScale(2)));
         cMaxSEM = cROItypeSEM(cMaxInds+FrameScale(1)-1);
         cMaxEffectSize = cROItypeEffectSize(cMaxInds+FrameScale(1)-1);
         DataMeanValues(cType,cROI) = cMaxvalue;
         DataSEMValue(cType,cROI) = cMaxSEM;
         DataESValue(cType,cROI) = cMaxEffectSize;
         DataSTDValue(cType,cROI) = cROItypeSTD(cMaxInds+FrameScale(1)-1);
         
         cROIMaxIndsData = cROItypeData(:,cMaxInds+FrameScale(1)-1);
         ROITypeIndsData{cType,cROI} = cROIMaxIndsData;
     end
 end
 DataStrc.MeanValue = DataMeanValues;
 DataStrc.SEMValue = DataSEMValue;
 DataStrc.STDData = DataSTDValue;
 DataStrc.MaxIndsDataAll = ROITypeIndsData;
 DataStrc.CurrentTypes = TrTypeAll;
 DataStrc.TypeNumber = TypeIndsNum;
 DataStrc.EffectSizeData = DataESValue;
%          
%      cTypedData = Data(cTypeInds,:,:);
%      cTypeMean = squeeze(mean(cTypedData));
%      [MaxMeanV,MaxMeanInds] = max(cTypeMean(:,FrameScale(1):FrameScale(2)),[],2);
%      cROISEM = zeros(nROIs,1);
%      for cROI = 1 : nROIs
%          cROIcFreqMaxIndsData = squeeze(cTypedData(:,cROI,MaxMeanInds(cROI)));
%          cROISEM(cROI) = 