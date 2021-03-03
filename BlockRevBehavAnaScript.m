function BlockSectionInfo = Bev2blockinfoFun(behavResults)


TotalTrNum = numel(behavResults.BlockType);
BlocktypeIndex = double(behavResults.BlockType(:));
Typediffs = [0;diff(BlocktypeIndex)];
BlockStartInds = find(abs(Typediffs));
if BlockStartInds(end) == TotalTrNum
    BlockStartInds(end) = [];
end

FullBlockTypes = [BlocktypeIndex(BlockStartInds-1);BlocktypeIndex(BlockStartInds(end))];
%%
BlockStartInds = [1;BlockStartInds]; % add the first trial as first block start trial

% exclude non-block switch blocks
BlockType_useds = FullBlockTypes;
BlockStartInds_useds = BlockStartInds;
BlockType_useds(FullBlockTypes < 0) = [];
BlockStartInds_useds(FullBlockTypes < 0) = [];

BlockLens = [diff(BlockStartInds_useds);TotalTrNum-BlockStartInds_useds(end)];
if BlockLens(end) < 50 % if the last block length is to short
    BlockType_useds(end) = [];
    BlockStartInds_useds(end) = [];
    BlockLens(end) = [];
end
UsedBlockNums = length(BlockLens);
%%
BlockSectionInfo = struct();
BlockTrIndexs = [BlockStartInds_useds,BlockStartInds_useds+BlockLens-1];
BlockSectionInfo.NumBlocks = UsedBlockNums;
BlockSectionInfo.BlockTrScales = BlockTrIndexs;
BlockSectionInfo.BlockLens = BlockLens;
BlockSectionInfo.BlockTypes = BlockType_useds;
BlockSectionInfo.BlockTypeStr = {{0,'LowBound'};{1,'HighBound'}};






