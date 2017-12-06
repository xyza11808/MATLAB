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
    if isempty(strfind(UpperPath,'im_data_reg'))
        UpperPath = DataPath;
    end
else
    cellNum = length(DataPath);
    UpperPath = cell(cellNum,1);
    for cCell = 1 : cellNum
        cPath = DataPath{cCell};
        SlashInds = strfind(cPath,filesep);
%         SlashInds = SlashIndsCell{:};
        if SlashInds(end) == length(cPath)
            UpperPathUsed = cPath(1:SlashInds(end-1)-1); % excluded the last slash character
        else
            UpperPathUsed = cPath(1:SlashInds(end)-1);
        end
        if isempty(strfind(UpperPathUsed,'im_data_reg'))
            UpperPathUsed = cPath;
        end
        UpperPath{cCell} = UpperPathUsed;
    end
end