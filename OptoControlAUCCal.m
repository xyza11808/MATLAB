function OptoControlAUCCal(AlignedData,TrType,TrModu,TrOutcome,AlignF,Frate,varargin)
% this function is specifically used for calculating the AUC value and
% threshold for control trials and optical trials, and save the result for
% further analysis
% no plot will be done, using saved data for future analysis

TimeLength = 1.5; %
if nargin > 6
    if ~isempty(varargin{1})
       TimeLength =  varargin{1};
    end
end
TrOutcomeUsed = 2;
if nargin > 7
    if ~isempty(varargin{2})
        TrOutcomeUsed = varargin{2};
    end
end

switch TrOutcomeUsed
    case 0
      TrTypeUsed = TrOutcome ~= 2;
    case 1
      TrTypeUsed = TrOutcome == 1;
    case 2
      TrTypeUsed = true(size(AlignedData,1),1);
    otherwise
        warning('Error input trial outcome selection type.Using all input trials.');
        TrTypeUsed = true(size(AlignedData,1),1);
end
AlignedData = AlignedData(TrTypeUsed,:,:);

if length(TimeLength) == 1
    FrameScale = sort([(AlignF+1),floor(AlignF+Frate*TimeLength)]);
elseif length(TimeLength) == 2
    FrameScale = sort([(AlignF+round(Frate*TimeLength(1))),(AlignF+round(Frate*TimeLength(2)))]);
else
    warning('Input TimeLength variable have a length of %d, but it have to be 1 or 2',length(TimeLength));
    return;
end
if FrameScale(1) < 1
    warning('Time Selection excceed matrix index, correct to 1');
    FrameScale(1) = 1;
    if FrameScale(2) < 1
        error('ErrorTimeScaleInput');
    end
end
if FrameScale(2) > size(AlignedData,3)
    warning('Time Selection excceed matrix index, correct to %d',DataSize(3));
    FrameScale(2) = size(AlignedData,3);
    if FrameScale(2) > size(AlignedData,3)
        error('ErrorTimeScaleInput');
    end
end

nROIs = size(AlignedData,2);
DataSelect = AlignedData(:,:,FrameScale(1):FrameScale(2));
DataResp = squeeze(mean(DataSelect,3));

OptoTrInds = TrModu == 1;
OptoTrTrTypes = TrType(OptoTrInds);
OptoAlignData = DataResp(OptoTrInds,:);
ContTrTypes = TrType(~OptoTrInds);
ContAlignData = DataResp(~OptoTrInds,:);

OptoAUCData = struct('ROCarea',zeros(nROIs,1),'ROCrevert',zeros(nROIs,1),'ROCshuffle',zeros(nROIs,1));
ContAUCData = struct('ROCarea',zeros(nROIs,1),'ROCrevert',zeros(nROIs,1),'ROCshuffle',zeros(nROIs,1));

for nROI = 1 : nROIs
    % control trial AUC calculation
    ContInputTrTypes = ContTrTypes(:);
    ContInputRespData = ContAlignData(:,nROI);
    [ROCSummary,IsRevert] = rocOnlineFoff([ContInputRespData,ContInputTrTypes]);
    ContAUCData.ROCarea(nROI) = ROCSummary;
    ContAUCData.ROCrevert(nROI) = double(IsRevert);
    
    TrTypeShuf = Vshuffle(ContInputTrTypes);
    [~,~,sigvalue]=ROCSiglevelGene([ContInputRespData,TrTypeShuf(:)],1000,1,0.05);
    ContAUCData.ROCshuffle(nROI) = sigvalue;
    
    % optal trial AUC calculation
    OptoInputTrTypes = OptoTrTrTypes(:);
    OptoInputRespData = OptoAlignData(:,nROI);
    [ROCSummary,IsRevert] = rocOnlineFoff([OptoInputRespData,OptoInputTrTypes]);
    OptoAUCData.ROCarea(nROI) = ROCSummary;
    OptoAUCData.ROCrevert(nROI) = double(IsRevert);
    
    TrTypeShuf = Vshuffle(OptoInputTrTypes);
    [~,~,sigvalue]=ROCSiglevelGene([OptoInputRespData,TrTypeShuf(:)],1000,1,0.05);
    OptoAUCData.ROCshuffle(nROI) = sigvalue;
    
end

ContAUCData.ROCareaABS = ContAUCData.ROCarea;
OptoAUCData.ROCareaABS = OptoAUCData.ROCarea;
ContAUCData.ROCareaABS(logical(ContAUCData.ROCrevert)) = 1 - ContAUCData.ROCareaABS(logical(ContAUCData.ROCrevert));
OptoAUCData.ROCareaABS(logical(OptoAUCData.ROCrevert)) = 1 - OptoAUCData.ROCareaABS(logical(OptoAUCData.ROCrevert));

if ~isdir('./Opto_Cont_AUCsave/')
    mkdir('./Opto_Cont_AUCsave/');
end
cd('./Opto_Cont_AUCsave/');

save OptoContAUCSave.mat ContAUCData OptoAUCData -v7.3

cd ..;