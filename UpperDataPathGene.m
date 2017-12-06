function UpperPath = UpperDataPathGene(DataPath)
% sued for extract upper layer folder path for given input path
if ~iscell(DataPath)
    SlashInds = strfind(DataPath,filesep);
%     SlashInds = SlashIndsCell{:};
    if SlashInds(end) == length(DataPath)
        UpperPath = DataPath(1:SlashInds(end-1)-1); % excluded the last slash character
    else
        UpperPath = DataPath(1:SlashInds(end)-1);
    end
else
    cellNum = length(DataPath);
    UpperPath = cell(cellNum,1);
    for cCell = 1 : cellNum
        cPath = DataPath{cCell};
        SlashInds = strfind(cPath,filesep);
%         SlashInds = SlashIndsCell{:};
        if SlashInds(end) == length(cPath)
            UpperPath{cCell} = cPath(1:SlashInds(end-1)-1); % excluded the last slash character
        else
            UpperPath{cCell} = cPath(1:SlashInds(end-1));
        end
    end
end