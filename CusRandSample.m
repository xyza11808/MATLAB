function RandIns = CusRandSample(n,k,varargin)
% this customized function is used for two purpose
% The normal usage is the same as built-in function randsample
% The Second uasge is to performing class-wised sampling, sampling K number
% of trials for different weights from different classes based the number
% of fraction for each class, under that case, the n will be a
% class-indicator vector.

if ~isnumeric(n) || ~isnumeric(k)
    error('Input must be numeric variables.');
end

if length(n) == 1
    RandIns = randsample(n,k,varargin{:});
else
    Classvalue = unique(n);
    ClassNum = length(Classvalue);
    ClassFracNum = zeros(ClassNum,2);
    if k < 1  % if k is input as fraction, convert into real number of sampling
        k = ceil(length(n)*k);
    end
    for nclass = 1 : ClassNum
        ClassFracNum(nclass,:) = [mean(n == Classvalue(nclass)),sum(n == Classvalue(nclass))];
    end
    ClassSampleNum = round(ClassFracNum(:,1) * k);
    [~,Inds] = max(ClassSampleNum);
    if sum(ClassSampleNum == 0)
        ZerosInds = ClassSampleNum == 0;
        ClassSampleNum(ZerosInds) = 1;
        ClassSampleNum(Inds) = ClassSampleNum(Inds) - sum(ZerosInds);
    end
    if sum(ClassSampleNum) ~= k
        ClassSampleNum(Inds) = ClassSampleNum(Inds) + k - sum(ClassSampleNum);
    end
    ClassInds = cell(ClassNum,1);
    for nclass = 1 : ClassNum
        DataInds = find(n == Classvalue(nclass));
        FracSampleNum = randsample(ClassFracNum(nclass,2),ClassSampleNum(nclass),varargin{:});
        SamInds = false(length(DataInds),1);
        SamInds(FracSampleNum) = true;
        sampleInds = DataInds(SamInds);
        ClassInds(nclass) = {sampleInds(:)};
    end
    RandIns = sort(cell2mat(ClassInds));
end