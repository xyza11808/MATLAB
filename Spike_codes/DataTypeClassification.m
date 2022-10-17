function [GrDataAvgs,GrDataSEMs,GroupTrNums] = DataTypeClassification(Data, GrInds)
% classified data according to given group inds, calculate the mean and SEM
[GrType,~,SortedGrInds] = unique(GrInds);
NumGroups = length(GrType);
DataPoints = size(Data,2);

GrDataAvgs = zeros(NumGroups, DataPoints);
GrDataSEMs = zeros(NumGroups, DataPoints);
GroupTrNums = zeros(NumGroups, 1);
for cGr = 1 : NumGroups
    cGr_Inds = SortedGrInds == cGr;
    cGr_Num = sum(cGr_Inds);
    if cGr_Num == 1
        GrDataAvgs(cGr,:) = Data(cGr_Inds,:);
        GrDataSEMs(cGr,:) =  zeros(1,DataPoints);
    elseif cGr_Num > 1 && cGr_Num <= 3
        GrDataAvgs(cGr,:) = mean(Data(cGr_Inds,:),'omitnan');
        GrDataSEMs(cGr,:) =  zeros(1,DataPoints);
    elseif cGr_Num > 2
        GrDataAvgs(cGr,:) = mean(Data(cGr_Inds,:),'omitnan');
        GrDataSEMs(cGr,:) =  std(Data(cGr_Inds,:),'omitnan')/sqrt(cGr_Num);
    else
        GrDataAvgs(cGr,:) = zeros(1,DataPoints);
        GrDataSEMs(cGr,:) = zeros(1,DataPoints);
    end
    GroupTrNums(cGr) = cGr_Num;
end




