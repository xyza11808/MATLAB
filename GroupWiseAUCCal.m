function GroupWiseAUCCal(varargin)
% this fucntion is specifically used to calculation passive data auc
% related with frequency distance, to see whether there are any
% correlations between them
if nargin == 1
    if isstruct(varargin{1})
        fprintf('Structure formed data input.\n');
        Datastrc = varargin{1};
        if sum(isfield(Datastrc,{'nROIpairedAUC','nROIpairedAUCIsRev','ROIwisedAUC','StimulusTypes'})) == 4
            RawPairedAUC = Datastrc.nROIpairedAUC;
            RawPairedAUCisRev = Datastrc.nROIpairedAUCIsRev;
            MatrixWiseAUCAbs = Datastrc.ROIwisedAUC;
            cSessionStim = double(Datastrc.StimulusTypes);
        else
            error('Structure data within filed name(s) missing.');
        end
    else
        error('Single input must be in structure form.');
    end
elseif nargin >= 4
    [RawPairedAUC,RawPairedAUCisRev,MatrixWiseAUCAbs,cSessionStim] = deal(varargin{1:4});
end

%##########################################################
% for passive data analysis
% fprintf('Please select the currect stimulus inds that will used for summarized analysis.\n');
% disp((cSessionStim(:))');
% StimInds = input('Inds Seperated by , :\n','s');
% StimIndsNum = str2num(StimInds); %#ok<ST2NM>
% ##############################################################
% for taskdata analysis
StimIndsNum = 1 : length(cSessionStim);
% #############################################################

cSessionStim = cSessionStim(StimIndsNum);
StimNum = length(cSessionStim);
[BetGrMask,WithinGrMask,pixelDisMatrix] = GroupDataMask(StimNum);
MatrixWiseAUCSelect = MatrixWiseAUCAbs(:,StimIndsNum,StimIndsNum);
%%
if ~isdir('./DisTance_based_AUC/')
    mkdir('./DisTance_based_AUC/');
end
cd('./DisTance_based_AUC/');

MeanBetGrAUCAll = cell(size(MatrixWiseAUCSelect,1),1);
MeanWhnGrAUCAll = cell(size(MatrixWiseAUCSelect,1),1);
for nnroi = 1 : size(MatrixWiseAUCSelect,1)
    cROImatrix = squeeze(MatrixWiseAUCSelect(nnroi,:,:));
    BetGrDis = pixelDisMatrix(BetGrMask);
    BetGrValue = cROImatrix(BetGrMask);
    
    WhnGrDis = pixelDisMatrix(WithinGrMask);
    WhnGrValue = cROImatrix(WithinGrMask);
    
    [~,BetGrAUCmean] = DistanceBasedError(BetGrDis,BetGrValue);
    [~,WhnGrAUCmean] = DistanceBasedError(WhnGrDis,WhnGrValue);
    MeanBetGrAUCAll{nnroi} = BetGrAUCmean;
    MeanWhnGrAUCAll{nnroi} = WhnGrAUCmean;
%     save GroupDisMeanAuc.mat BetGrAUCmean BetGrAUCAll WhnGrAUCmean WhnGrAUCAll cSessionStim -v7.3
    %
    % plot section
    h_disAUC = figure('position',[200 200 1000 800]);
    hold on;
    AxBet = plot(BetGrAUCmean(:,2),BetGrAUCmean(:,1),'b-o','LineWidth',1.8);
    AxWhn = plot(WhnGrAUCmean(:,2),WhnGrAUCmean(:,1),'r-o','LineWidth',1.8);
    xlabel('Unit distance');
    ylabel('Mean AUC');
    title(sprintf('ROI%d Bet. and Win. group AUC comparation',nnroi));
    set(gca,'FontSize',16);
    legend([AxBet,AxWhn],{'Between Group','Within Group'},'FontSize',10);
    
    saveas(h_disAUC,sprintf('ROI%d group mean AUC plot',nnroi));
    saveas(h_disAUC,sprintf('ROI%d group mean AUC plot',nnroi),'png');
    close(h_disAUC);
    
    if nnroi == 1
        SumBetGrAUC = BetGrAUCmean(:,1);
        SumWhnGrAUC = WhnGrAUCmean(:,1);
        BetGeAUCDis = BetGrAUCmean(:,2);
        WhnGrAUCDis = WhnGrAUCmean(:,2);
    else
        SumBetGrAUC = [SumBetGrAUC , BetGrAUCmean(:,1)];
        SumWhnGrAUC = [SumWhnGrAUC , WhnGrAUCmean(:,1)];
    end 
end
%%
save DiffMeanAUC.mat SumBetGrAUC SumWhnGrAUC cSessionStim MeanBetGrAUCAll MeanWhnGrAUCAll -v7.3
% MeanAllBetGrAUC = SumBetGrAUC/nnroi;
% MeanAllWhnGrAUC = SumWhnGrAUC/nnroi;
% h_sum = figure;
[hf,~,hl1] = MeanSemPlot(SumBetGrAUC',[],[],'b-o','LineWidth',1.6);
[hfsum,~,hl2] = MeanSemPlot(SumWhnGrAUC',[],hf,'r-o','LineWidth',1.6);
xlabel('Unit Diff.');
ylabel('Mean AUC');
title('Session Mean AUC v.s. Oct. Diff.');
set(gca,'FontSize',16);
legend([hl1,hl2],{'BetGroup Mean','WhnGroup Mean'},'FontSize',10);
saveas(hfsum,'Session Mean AUC vs Octave Diff');
saveas(hfsum,'Session Mean AUC vs Octave Diff','png');
close(hfsum);

cd ..;