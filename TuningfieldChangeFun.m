function varargout = TuningfieldChangeFun(cSessPath,nROIs,CommonInds,varargin)
% #######################################################
IsBoundGiven = 0;
if nargin > 3
    if ~isempty(varargin{1})
        BehavBound = varargin{1};
        IsBoundGiven = 1;
    end
end

cSessSelectROIStrc = load(fullfile(cSessPath,'SigSelectiveROIInds.mat'));
% cSessTaskTunROIs = cSessSelectROIStrc.SigROIInds;
[~,EndInds] = regexp(cSessPath,'test\d{2,3}');
cPassDataPath = fullfile(sprintf('%srf',cSessPath(1:EndInds)),'im_data_reg_cpu','result_save','plot_save','NO_Correction');
PassiveTunROIStrc = load(fullfile(cPassDataPath,'PassCoefMtxSave.mat')); % load passive fitting data
nFreqTypes = size(cSessSelectROIStrc.SigROICoefMtx,2);

TPCommonInds = zeros(nROIs,1);
TPCommonInds(unique([PassiveTunROIStrc.PassRespROIInds;cSessSelectROIStrc.SigROIInds])) = 1; % merge all task and passive inds
nCommonInds = numel(CommonInds);
TPCommonInds(nCommonInds+1:end) = false;
TPCommonInds(1:nCommonInds) = TPCommonInds(1:nCommonInds) & CommonInds(:);

TaskAndPassiveCoefMtx = zeros(numel(TPCommonInds),nFreqTypes,2); % the third dimension indicates task and passive
TaskAndPassiveCoefMtx(cSessSelectROIStrc.SigROIInds,:,1) = cSessSelectROIStrc.SigROICoefMtx;
TaskAndPassiveCoefMtx(PassiveTunROIStrc.PassRespROIInds,:,2) = PassiveTunROIStrc.PassRespCoefMtx;
TaskAndPassiveCoefMtx(~TPCommonInds,:,:) = 0;


%% calculate the response field difference, ignoring the coef value
% difference
TaskRespField = squeeze(TaskAndPassiveCoefMtx(:,:,1)) > 0;
PassRespField = squeeze(TaskAndPassiveCoefMtx(:,:,2)) > 0;
EitherRespFields = (TaskRespField | PassRespField);
[EitherRespFieldIndexR, EitherRespFieldIndexC] = find(EitherRespFields);
RespROIs = find(sum(EitherRespFields,2) > 0);
RespFieldMtx = TaskRespField(RespROIs,:) - PassRespField(RespROIs,:);
RespFieldMask = EitherRespFields(RespROIs,:);
RespFieldStrc.RespFieldMtx = RespFieldMtx;
RespFieldStrc.RespFieldMask = RespFieldMask;
RespFieldStrc.TaskRespField = squeeze(TaskAndPassiveCoefMtx(RespROIs,:,1));
RespFieldStrc.PassRespField = squeeze(TaskAndPassiveCoefMtx(RespROIs,:,2));
RespFieldStrc.TotalNumROIs = sum(TPCommonInds);
RespFieldStrc.RespROIIndex = RespROIs;

RespFieldDiff = double(TaskRespField(EitherRespFields)) - double(PassRespField(EitherRespFields));

FieldFiffAndInds = [RespFieldDiff,EitherRespFieldIndexC];

NoChangeIndex = RespFieldDiff == 0;
NoChangeSubIndex = sub2ind(size(EitherRespFields),EitherRespFieldIndexR(NoChangeIndex),EitherRespFieldIndexC(NoChangeIndex));

PassRespCoef = squeeze(TaskAndPassiveCoefMtx(:,:,2));
PassNoChangeCoef = PassRespCoef(NoChangeSubIndex);
TaskRespCoef = squeeze(TaskAndPassiveCoefMtx(:,:,1));
TaskNoChangeCoef = TaskRespCoef(NoChangeSubIndex);
[~,NoChangeCols] = ind2sub(size(EitherRespFields),NoChangeSubIndex);

TPNochangeCoef = [TaskNoChangeCoef(:),PassNoChangeCoef(:),NoChangeCols(:)];
%%
FieldIndsDataChange = cell(nFreqTypes,3);
hf = figure('position',[20 100 650 320]);
hold on
for cFie = 1 : nFreqTypes
    FieldIndsDataChange{cFie,1} = RespFieldDiff(EitherRespFieldIndexC == cFie);
    nDatas = numel(FieldIndsDataChange{cFie,1});
    if ~isempty(FieldIndsDataChange{cFie,1})
        FieldIndsDataChange{cFie,2} = mean(FieldIndsDataChange{cFie,1});
        if numel(FieldIndsDataChange{cFie,1}) > 2
            FieldIndsDataChange{cFie,3} = std(FieldIndsDataChange{cFie,1})/sqrt(numel(FieldIndsDataChange{cFie,1}));
        else
            FieldIndsDataChange{cFie,3} = 0;
        end
    end
    plot(cFie*ones(nDatas,1)+(rand(nDatas,1)-0.5)*0.2,FieldIndsDataChange{cFie,1},'*','Color',[.7 .7 .7]);
    if ~isempty(FieldIndsDataChange{cFie,1})
        errorbar(cFie,FieldIndsDataChange{cFie,2},FieldIndsDataChange{cFie,3},'ko','linewidth',1.8);
    end
end
if IsBoundGiven
    line([BehavBound BehavBound],[-1 1],'Color','m','linewidth',1.5,'linestyle','--');
end
set(gca,'xlim',[0.5 nFreqTypes+0.5],'ylim',[-1.05 1.05],'xtick',1:nFreqTypes,'ytick',-1:1,'yticklabel',...
    {'Inhibit','NoChange','Enhance'});
xlabel('Freq Inds');
ylabel('Change Direction');
title('Session tuning position change');
set(gca,'FontSize',12)
%%
saveas(hf,'Tuning frequency change direction plots save');
saveas(hf,'Tuning frequency change direction plots save','png');
close(hf);
save TuningfieldCHangeSave.mat FieldIndsDataChange TaskAndPassiveCoefMtx TPNochangeCoef FieldFiffAndInds -v7.3

if nargout > 0
    varargout{1} = FieldIndsDataChange;
    varargout{2} = FieldFiffAndInds;
    varargout{3} = TPNochangeCoef;
    if nargout >3
        varargout{4} = RespFieldStrc;
    end
end