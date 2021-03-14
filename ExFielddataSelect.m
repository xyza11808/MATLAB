function [TypeOutputs,TypeDataNotUsed] = ExFielddataSelect(TypeNames,TypeDatas,TypefieldNums,ExFieldDatas,TypeUsedDis)

NumFolders = length(TypeNames);
Cumfieldnum = cumsum(TypefieldNums);
TypeDataNotUsed = zeros(size(TypeDatas,1),1);
for cf = 1 : NumFolders
    cfoldName = TypeNames{cf};
    IsfolderNamein = ~cellfun(@isempty,strfind(ExFieldDatas(:,1),cfoldName(1:8)));
    if sum(IsfolderNamein)
        % field excluded should exists
        Exfields = ExFieldDatas{IsfolderNamein,2};
        if cf > 1
            TypeDataNotUsed(Cumfieldnum(cf-1)+Exfields) = 1;
        end
    end
    
end

TypeUsedDatas = TypeDatas;
if sum(TypeDataNotUsed)
    TypeUsedDatas(TypeDataNotUsed > 0,:) = [];
    if ~isempty(TypeUsedDis)
        TypeUsedDis(TypeDataNotUsed > 0) = [];
    end
end
if ~isempty(TypeUsedDis)
    TypeOutputs = [TypeUsedDatas,TypeUsedDis];
else
    TypeOutputs = TypeUsedDatas;
end


