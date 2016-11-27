function StimPairROC(varargin)
if nargin < 1
    [fn,fp,fi] = uigetfile('pairROCresult.mat','Please select your Paired ROC analysis data matrix');
    if fi
        xxx = load(fullfile(fp,fn));
        DataMatrix = xxx.PairedROCAll;
        SessionStim = xxx.StimTypesAll;
    end
elseif nargin == 1
    DataMatrix = varargin{1};
    SessionStim = varargin{2};
end

[~, nROIs] = size(DataMatrix);
StimStrs = cellstr(num2str(SessionStim(:)/1000,'%.2f'));

if ~isdir('./Stim_pair_ROCanalysis/')
    mkdir('./Stim_pair_ROCanalysis/');
end
cd('./Stim_pair_ROCanalysis/');
for nmnm = 1 : nROIs
    cData = DataMatrix(:,nmnm);
    MatrixData = squareform(cData);
    nStims = size(MatrixData,1);
    h_all = figure('position',[500 200 800 600]);
    imagesc(MatrixData,[0 1]);
    colorbar;
    set(gca,'xtick',1:nStims,'ytick',1:nStims,'xticklabel',StimStrs,'yticklabel',StimStrs);
    xlabel('Frequency (kHz)');
    ylabel('Frequency (kHz)');
    title(sprintf('ROI%d',nmnm));
    set(gca,'FontSize',20);
    saveas(h_all,'ROI%d Frequency pair ROC result');
    saveas(h_all,'ROI%d Frequency pair ROC result','png');
    close(h_all);
end
cd ..;
