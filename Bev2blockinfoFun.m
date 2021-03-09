function BlockSectionInfo = Bev2blockinfoFun(behavResults)
BlockSectionInfo = [];
if ~isfield(behavResults,'BlockType')
    warning('There is no block type filed in current behavior data');
    return;
end

TotalTrNum = numel(behavResults.BlockType);
BlocktypeIndex = double(behavResults.BlockType(:));
Typediffs = [0;diff(BlocktypeIndex)];
BlockStartInds = find(abs(Typediffs));
if BlockStartInds(end) == TotalTrNum
    BlockStartInds(end) = [];
end

TrFreqUseds = double(behavResults.Stim_toneFreq(:));
TrTypes = double(behavResults.Trial_Type(:));
TrChoicces = double(behavResults.Action_choice(:));
FreqTypes = unique(TrFreqUseds);


FullBlockTypes = [BlocktypeIndex(BlockStartInds-1);BlocktypeIndex(BlockStartInds(end))];
%%
BlockStartInds = [1;BlockStartInds]; % add the first trial as first block start trial

% exclude non-block switch blocks
BlockType_useds = FullBlockTypes;
BlockStartInds_useds = BlockStartInds;
BlockType_useds(FullBlockTypes < 0) = [];
BlockStartInds_useds(FullBlockTypes < 0) = [];

BlockLens = [diff(BlockStartInds_useds);TotalTrNum-BlockStartInds_useds(end)+1];
if BlockLens(end) < 100 % if the last block length is to short
    BlockType_useds(end) = [];
    BlockStartInds_useds(end) = [];
    BlockLens(end) = [];
end

BlockTrIndexs = [BlockStartInds_useds,BlockStartInds_useds+BlockLens-1];
NoMissTrBlockLens = nan(size(BlockTrIndexs,1),1);
for cb = 1 : size(BlockTrIndexs,1)
   BlockChoices =  TrChoicces(BlockTrIndexs(cb,1):BlockTrIndexs(cb,2));
   
   if sum(BlockChoices ~= 2) < 70 % non-miss trial should not less than 70
       BlockType_useds(cb) = [];
       BlockStartInds_useds(cb) = [];
       BlockLens(cb) = [];
       BlockTrIndexs(cb,:) = [];
   else
       NoMissTrBlockLens(cb) = sum(BlockChoices ~= 2);
   end
end

NoMissTrBlockLens(isnan(NoMissTrBlockLens)) = [];
UsedBlockNums = length(BlockLens);

%%
BlockSectionInfo = struct();

BlockSectionInfo.NumBlocks = UsedBlockNums;
BlockSectionInfo.BlockTrScales = BlockTrIndexs;
BlockSectionInfo.BlockLens = BlockLens;
BlockSectionInfo.BlockTypes = BlockType_useds;
BlockSectionInfo.BlockTypeStr = {{0,'LowBound'};{1,'HighBound'}};
BlockSectionInfo.NMBlockLens = NoMissTrBlockLens;
%%

BlockTr_TrTypes = [];
BlockTr_freqs = [];
BlockTr_inds = [];
for cb = 1 : UsedBlockNums
    BlockTr_TrTypes = [BlockTr_TrTypes;TrTypes(BlockTrIndexs(cb,1):BlockTrIndexs(cb,2))];
    BlockTr_freqs = [BlockTr_freqs;TrFreqUseds(BlockTrIndexs(cb,1):BlockTrIndexs(cb,2))];
    BlockTr_inds = [BlockTr_inds,(BlockTrIndexs(cb,1):BlockTrIndexs(cb,2))];
end

BlockFreqTypes = unique(BlockTr_freqs);
NumBlockfreqTypes = length(BlockFreqTypes);
IsFreq_asReverseFreq = zeros(NumBlockfreqTypes,1);
RevFreqTrInds = false(numel(TrFreqUseds),1);
for cf = 1 : NumBlockfreqTypes
    cfInds = BlockTr_freqs == BlockFreqTypes(cf);
    cfTrTypes = BlockTr_TrTypes(cfInds);
    if length(unique(cfTrTypes)) > 1
        IsFreq_asReverseFreq(cf) = 1;
        RevFreqTrInds(TrFreqUseds == BlockFreqTypes(cf)) = true;
    end
end

BlockSectionInfo.BlockFreqTypes = BlockFreqTypes;
BlockSectionInfo.IsFreq_asReverse = IsFreq_asReverseFreq;
BlockSectionInfo.TrInds = BlockTr_inds;
BlockSectionInfo.RevFreqTrInds = RevFreqTrInds;





