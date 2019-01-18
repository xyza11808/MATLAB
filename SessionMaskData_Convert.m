function MaskCorrRate = SessionMaskData_Convert(SessData,SessMask,SessTrNum)
% calculate the correct rate according to input mask

[nDBTypes, nFreqTypes] = size(SessData);
switch nFreqTypes
    case 6
        UsedMask = SessMask{1};
    case 8
        UsedMask = SessMask{2};
    otherwise
        error('Unknown mask type.');
end

MaskNum = size(UsedMask,1);

MaskCorrRate = zeros(nDBTypes,MaskNum);
for cDBs = 1 : nDBTypes
    for cMask = 1 : MaskNum
        cSessData = SessData(cDBs,:);
        cSessMask = UsedMask(cMask,:);
        if isempty(SessTrNum)
            MaskCorrRate(cDBs,cMask) = mean(cSessData(cSessMask));
        else
            cSessTrNum = SessTrNum(cDBs,cSessMask);
            MaskCorrRate(cDBs,cMask) = sum((cSessData(cSessMask).*cSessTrNum)/sum(cSessTrNum));
        end
    end
end

