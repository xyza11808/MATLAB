
cclr
load('TaskSessData.mat')

[NumUnits, NumEventtype1, NumEventtype2, ~] = size(BlockpsthAvgTrace{1,1});
NumBlocks = length(BlockSectionInfo.BlockTypes);

UnitWholeTraceCell = cell(1,NumUnits);
for cUnit = 1:NumUnits
    cUnitAllBData = cellfun(@(x) squeeze(x(cUnit,:,:,1)),BlockpsthAvgTrace(:,1),...
        'UniformOutput',false);
    EventMtx_Cells = cell(NumBlocks,1);
    BlockPSTHcells = cell(NumBlocks,1);
    for cB = 1 : NumBlocks
        cBlockAlignEvents = BlockAlignedEventTypes(cB,:);
        EventMtx = zeros(NumEventtype1*NumEventtype2,4);
        EventMtx(:,1) = repmat(cBlockAlignEvents{1},NumEventtype2,1);
        EventMtx(:,2) = reshape((repmat(cBlockAlignEvents{2},1,NumEventtype1))',[],1);
        EventMtx(:,3) = BlockSectionInfo.BlockTypes(cB)*ones(NumEventtype1*NumEventtype2,1);
        EventMtx(:,4) = cB*ones(NumEventtype1*NumEventtype2,1);


        cBpsthData = cUnitAllBData{cB}(:);
        EmptyBlockpsthTraces = cellfun(@(x) isempty(x) || isnan(x(1)),cBpsthData);

        EventMtx_Cells{cB} = EventMtx(~EmptyBlockpsthTraces,:);
        cBpsthData = cellfun(@(x) x',cBpsthData,'UniformOutput',false);
        BlockPSTHcells{cB} = cBpsthData(~EmptyBlockpsthTraces);

    end
    
    BlockTraceCellVec = cat(1,BlockPSTHcells{:});
    SingleTraceNumel = numel(BlockTraceCellVec{1});
    TraceTypes = cat(1,EventMtx_Cells{:});

    ALllTypeTraces = cell2mat(BlockTraceCellVec);
    
    UnitWholeTraceCell{cUnit} = smooth(ALllTypeTraces,7);
    
end
%%
UnitpsthTraceMtx = zscore(cell2mat(UnitWholeTraceCell));

%
[~,Score, ~, ~, explain, ~] = pca(UnitpsthTraceMtx);
fprintf('The first three PC explains %.4f...\n',sum(explain(1:3)));

%%
UsedPCNums = 3;
TraceNumbers = size(Score,1)/SingleTraceNumel;
rowDistVec = SingleTraceNumel*ones(TraceNumbers,1);
PSTHScore = mat2cell(Score(:,1:UsedPCNums),rowDistVec);
RevFreqs = [6350,6500,8000,10079];
hf = figure;
hold on
for cCell = 1 : length(PSTHScore)
    cPSTH_trace = PSTHScore{cCell};
    if any(TraceTypes(cCell,1) == RevFreqs)
        plot3(cPSTH_trace(:,1),cPSTH_trace(:,2),cPSTH_trace(:,3),...
                'linewidth',1.2,'Color',[.7 .7 .7]);
    else
        if TraceTypes(cCell,2) == 0 
            plot3(cPSTH_trace(:,1),cPSTH_trace(:,2),cPSTH_trace(:,3),...
                'linewidth',1.2,'Color','b');
        else
             plot3(cPSTH_trace(:,1),cPSTH_trace(:,2),cPSTH_trace(:,3),...
                'linewidth',1.2,'Color','R');
        end
    end
end

%% distance calculation

% calculate the distance according to block types and seperate plot for
% each frequency
UsedPCNums = 5;
TraceNumbers = size(Score,1)/SingleTraceNumel;
rowDistVec = SingleTraceNumel*ones(TraceNumbers,1);
PSTHScore_5pc = mat2cell(Score(:,1:UsedPCNums),rowDistVec);

MeanBlockType_low = TraceTypes(:,3) == 0;
lowBlockScores = PSTHScore_5pc(MeanBlockType_low);
lowBlockScores_mtx = cat(3,lowBlockScores{:});
lowBlockScores_AvgTrace = mean(lowBlockScores_mtx,3);

MeanBlockType_high = TraceTypes(:,3) == 1;
HighBlockScores = PSTHScore_5pc(MeanBlockType_high);
HighBlockScores_mtx = cat(3,HighBlockScores{:});
highBlockScores_AvgTrace = mean(HighBlockScores_mtx,3);

%
LowHighIndex = cell(length(PSTHScore_5pc),1);
for cPSTH = 1 : length(PSTHScore_5pc)
    cpsthDis2Low = sqrt(sum(((PSTHScore_5pc{cPSTH} - lowBlockScores_AvgTrace).^2),2));
    cpsthDis2High = sqrt(sum(((PSTHScore_5pc{cPSTH} - highBlockScores_AvgTrace).^2),2));
    LowHighIndex{cPSTH} = ...
        ((cpsthDis2Low - cpsthDis2High) ./ (cpsthDis2Low + cpsthDis2High))';
end

%% 
wholeDistance_mtx = cell2mat(LowHighIndex);
[~, AlignInds] = sort(TraceTypes(:,3));
figure;
% imagesc(wholeDistance_mtx(AlignInds,:))
imagesc(wholeDistance_mtx)






