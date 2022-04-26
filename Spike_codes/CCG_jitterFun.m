function jitterSPMtx = CCG_jitterFun(SPTrain, jitterWindow)
% function used to jitter the spike times for calculation
% the default jitter window is 25ms
% Default spike bin time is 1ms, across a span of around 1s sacle

% jitter window should be the number of bins corresponded to spike train
% bin size

if ismatrix(SPTrain)
    [TrNums, SPtrainLen] = size(SPTrain);
    if issparse(SPTrain)
        jitterSPMtx = sparse(TrNums, SPtrainLen); 
    else
        jitterSPMtx = zeros(TrNums, SPtrainLen);
    end
    JitterWinNums = ceil(SPtrainLen/jitterWindow);
    % jitterSPTrain = cellfun(@gpuArray,cell(1,gather(JitterWinNums)),'uniformOutput',false); %zeros(TrNums, SPtrainLen);
    for cWin = 1 : JitterWinNums
        cWinStartInds = (cWin-1)*jitterWindow + 1;
        cWinEndInds = min(cWin*jitterWindow,SPtrainLen);
        cWin_binDataAll = SPTrain(:,cWinStartInds:cWinEndInds);
        cWinBinNum = size(cWin_binDataAll,2);
        [PosTrInds, cWinAllSpikeBinPos] = find(cWin_binDataAll);
        RandSampleTimes = randsample(cWinAllSpikeBinPos,numel(cWinAllSpikeBinPos),true);
        if issparse(SPTrain)
           cWinJitterDatas = sparse(PosTrInds,RandSampleTimes,ones(numel(RandSampleTimes),1),...
               TrNums,cWinBinNum); 
        else
           cWinJitterDatas = zeros(size(cWin_binDataAll));
           sampleInds = sub2ind(size(cWin_binDataAll),PosTrInds,RandSampleTimes);
           cWinJitterDatas(sampleInds) = 1;
        end
%         SPTrial = find(sum(cWin_binDataAll,2));
%         NumSPTrs = length(SPTrial);
%         for cTr = 1 : NumSPTrs
%             ccTr = SPTrial(cTr);
% %             if sum(cWin_binDataAll(ccTr,:)) > 0
%                 cWinPosBinNum = sum(cWin_binDataAll(ccTr,:));
%                 SampleBinPos = cWinAllSpikeBinPos(randsample(numel(cWinAllSpikeBinPos),cWinPosBinNum));
%                 if numel(unique(SampleBinPos)) == 1 && cWinPosBinNum > 1 % resample again if same spike position was sampled 
%                     SampleBinPos = cWinAllSpikeBinPos(randsample(numel(cWinAllSpikeBinPos),cWinPosBinNum));
%                 end
%                 cWinJitterDatas(ccTr,SampleBinPos) = 1;
% %             end 
%         end
    %     jitterSPTrain(cWin) = {gpuArray(cWinJitterDatas)};
%         jitterSPTrain(cWin) = {cWinJitterDatas};
        jitterSPMtx(:,cWinStartInds:cWinEndInds) = cWinJitterDatas;
    end
    
elseif ndims(SPTrain) == 3
    
    [nBatch, TrNums, SPtrainLen] = size(SPTrain);
    
    JitterWinNums = ceil(SPtrainLen/jitterWindow);
    AvoidSqueezeData = permute(SPTrain,[2,3,1]);
    jitterSPMtx = zeros(TrNums, SPtrainLen, nBatch);
    % jitterSPTrain = cellfun(@gpuArray,cell(1,gather(JitterWinNums)),'uniformOutput',false); %zeros(TrNums, SPtrainLen);
%     jitterSPTrain = cell(1,JitterWinNums);
    for cWin = 1 : JitterWinNums
        cWinStartInds = (cWin-1)*jitterWindow + 1;
        cWinEndInds = min(cWin*jitterWindow,SPtrainLen);
        cWin_binDataAll = AvoidSqueezeData(:,cWinStartInds:cWinEndInds,:);
        cWinBinNum = size(cWin_binDataAll,2);
        cWinJitterDatas = zeros(size(cWin_binDataAll));
        
        for cB = 1 : nBatch
            cBWin_datas = cWin_binDataAll(:,:,cB);
            [ExistTrInds, cWinAllSpikeBinPos] = find(cBWin_datas);
            RandSampleTimes = randsample(cWinAllSpikeBinPos,numel(cWinAllSpikeBinPos),true);
            ZerosDatas = zeros(TrNums,cWinBinNum);
            sampleInds = sub2ind(size(cBWin_datas),ExistTrInds, RandSampleTimes);
            ZerosDatas(sampleInds) = 1;
            cWinJitterDatas(:,:,cB) = ZerosDatas; % full(sparse(ExistTrInds, RandSampleTimes,ones(numel(RandSampleTimes),1),...
                % TrNums,cWinBinNum));
%             ExistTrTypes = unique(ExistTrInds);
%             ExistTrNum = length(ExistTrTypes);
%             for cTr = 1 : ExistTrNum
% %                 if sum(cBWin_datas(cTr,:)) > 0
%                     ccTr = ExistTrTypes(cTr);
%                     cWinPosBinNum = sum(cBWin_datas(ccTr,:));
%                     SampleBinPos = cWinAllSpikeBinPos(randsample(numel(cWinAllSpikeBinPos),cWinPosBinNum));
%                     if numel(unique(SampleBinPos)) == 1 && cWinPosBinNum > 1 % resample again if same spike position was sampled 
%                         SampleBinPos = cWinAllSpikeBinPos(randsample(numel(cWinAllSpikeBinPos),cWinPosBinNum));
%                     end
%                     cWinJitterDatas(cB,ccTr,SampleBinPos) = 1;
% %                 end 
%             end
        end
    %     jitterSPTrain(cWin) = {gpuArray(cWinJitterDatas)};
%         jitterSPTrain(cWin) = {cWinJitterDatas};
        jitterSPMtx(:,cWinStartInds:cWinEndInds,:) = cWinJitterDatas;
    end
%     jitterSPMtx = cat(3, jitterSPTrain{:});
    jitterSPMtx = permute(jitterSPMtx,[3,1,2]);
end



