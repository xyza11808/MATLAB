
RespWin = 0.5;
cR = 2;

% cRData = squeeze(SelectData(:,cR,:));
cRData = squeeze(nnspike(:,cR,:));

cRRespData = mean(cRData(:, (frame_rate+1):(frame_rate + round(RespWin*frame_rate))), 2);

FreqTypes = unique(SelectSArray);
FreqNums = length(FreqTypes);
FreqTrInds = cell(FreqNums, 1);
FreqData = cell(FreqNums, 1);
for cf = 1 : FreqNums
    FreqTrInds{cf} = SelectSArray == FreqTypes(cf);
    FreqData{cf} = cRRespData(FreqTrInds{cf});
end
figure;
plot(SelectSArray, cRRespData, 'ro')
%%
nShufRepeat = 100;
ShufDataAll = cell(nShufRepeat, 1);
for cShuf = 1 : nShufRepeat
%     TempRespData = cRRespData;
    TempRespData = Vshuffle(cRRespData);
    TempAvgResp = zeros(1, FreqNums);
    for cf = 1 : FreqNums
        TempAvgResp(cf) = mean(TempRespData(FreqTrInds{cf}));
    end
    ShufDataAll{cShuf} = TempAvgResp;
end

%%
hold on
ShufRespMtx = cell2mat(ShufDataAll);
CompareP = zeros(FreqNums, 1);
for cf = 1 : FreqNums
    plot(FreqTypes(cf), ShufRespMtx(:, cf), 'bo');
    [~, CompareP(cf)] = ttest2(FreqData{cf}, ShufRespMtx(:, cf),'Tail','right');
end



