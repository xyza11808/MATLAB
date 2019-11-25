function plotRNNcorr(R2data,whichTask,N,post_post,ant_post)

% plotRNNcorr
% requires: R2data, a N x T x trial matrix
%           whichTask, a 1 x trial matrix with task ID (1: towers, 2: target)
% alternatively two separate N x T x trial matrices, one for each trial,
% pulsesR and detectR

%% plot config
cfg.clustCl       = [60 179 113; 10 35 140]./255;
cfg.histBins      = -1:.1:1;
cfg.withinClustCl = [230 186 0]./255;%[.4 .4 .4];
cfg.xClustCl      = [.6 .6 .6];
cfg.towersCl      = [0 0 0]; %widefieldParams.darkgray; %[0 0 0];
cfg.ctrlCl        = [.6 .6 .6]; %widefieldParams.darkgreen; %[.6 .6 .6];

%% compute correlations, average across trials
visIdx      = post_post;
frontIdx    = ant_post;

pulsesR     = R2data([visIdx frontIdx],:,whichTask == 1);
detectR     = R2data([visIdx frontIdx],:,whichTask == 2);

nPulseTrial = size(pulsesR,3);
EA_corr     = zeros(N,N,nPulseTrial);
for iTrial = 1:nPulseTrial
    EA_corr(:,:,iTrial) = corr(pulsesR(:,:,iTrial)');
end

nDetectTrial = size(detectR,3);
detect_corr  = zeros(N,N,nDetectTrial);
for iTrial = 1:nDetectTrial
    detect_corr(:,:,iTrial) = corr(detectR(:,:,iTrial)');
end

EA_corr     = mean(EA_corr,3);
detect_corr = mean(detect_corr,3);
corrDiff    = EA_corr - detect_corr;
corrMagDiff = abs(EA_corr) - abs(detect_corr);

%% within vs across cluster stats
front       = corrMagDiff(frontIdx,frontIdx);
vis         = corrMagDiff(visIdx,visIdx);
xClust      = corrMagDiff(visIdx,frontIdx);

front(logical(eye(size(front))))     = nan;
vis(logical(eye(size(vis))))         = nan;
xClust(logical(eye(size(xClust))))   = nan;

xClust      = nanmean(xClust,2);
withinClust = mean([nanmean(front,2) nanmean(vis,2)],2);

RNNdata.rates.accumulTask = pulsesR;
RNNdata.rates.ctrlTask    = detectR;
RNNdata.rates.visIdx      = visIdx;
RNNdata.rates.frontIdx    = frontIdx;
RNNdata.rates.absCCdiff   = corrMagDiff;
RNNdata.rates.CCdiff      = corrDiff;

% corr stats
cc                              = abs(EA_corr);
cc(logical(eye(size(cc))))      = nan;
RNNdata.rates.avgCCunit_accumul = nanmean(cc,2);
cc                              = abs(detect_corr);
cc(logical(eye(size(cc))))      = nan;
RNNdata.rates.avgCCunit_ctrl    = nanmean(cc,2);
RNNdata.rates.avgCCunit_pval    = signrank(RNNdata.rates.avgCCunit_accumul,RNNdata.rates.avgCCunit_ctrl);
RNNdata.rates.p_ccDelta_withinVSacrossModule = signrank(withinClust,xClust);

%% plot

figure;

% corr matrices
visIdx      = [.5 500.5];
frontIdx    = [500.5 1000.5];

subplot(1,3,1); axs = gca;
hold(axs, 'on')
imagesc(abs(EA_corr),[0 1]); colormap gray; axis ij; axis tight
plot([visIdx(1) visIdx(end) visIdx(end) visIdx(1)   visIdx(1)], ...
    [visIdx(1) visIdx(1)   visIdx(end) visIdx(end) visIdx(1)], ...
    '-','color',cfg.clustCl(1,:),'linewidth',2  );
plot([frontIdx(1) frontIdx(end) frontIdx(end) frontIdx(1)   frontIdx(1)], ...
    [frontIdx(1) frontIdx(1)   frontIdx(end) frontIdx(end) frontIdx(1)], ...
    '-','color',cfg.clustCl(2,:),'linewidth',2 );
set(axs,'xtick',[],'ytick',[])
ylabel ('RNN units'); xlabel('RNN units'); title('Accumulation')

subplot(1,3,2); axs = gca;
hold(axs, 'on')
imagesc(abs(detect_corr),[0 1]); colormap gray; axis off; axis ij; axis tight
plot([visIdx(1) visIdx(end) visIdx(end) visIdx(1)   visIdx(1)], ...
    [visIdx(1) visIdx(1)   visIdx(end) visIdx(end) visIdx(1)], ...
    '-','color',cfg.clustCl(1,:),'linewidth',2  );
plot([frontIdx(1) frontIdx(end) frontIdx(end) frontIdx(1)   frontIdx(1)], ...
    [frontIdx(1) frontIdx(1)   frontIdx(end) frontIdx(end) frontIdx(1)], ...
    '-','color',cfg.clustCl(2,:),'linewidth',2  );
set(axs,'xtick',[],'ytick',[])
ylabel ('RNN units'); xlabel('RNN units'); title('Target')

% histogram
subplot(1,3,3); axs = gca;
hold(axs, 'on')

plot([0 0],[0 .5],'--','color',[.7 .7 .7])
xaxis                   = cfg.histBins(1:end-1) + mode(diff(cfg.histBins))/2;
countsWithin            = histcounts(withinClust,cfg.histBins)./numel(withinClust);
countsAcross            = histcounts(xClust,cfg.histBins)./numel(xClust);
hHisto                  = gobjects(0);
hHisto(end+1)           = bar ( axs, xaxis, countsWithin, .96              ...
    , 'EdgeColor'     , 'none'                   ...
    , 'FaceColor'     , cfg.withinClustCl        ...
    );


hHisto(end+1)           = bar ( axs, xaxis, countsAcross, .96              ...
    , 'EdgeColor'     , 'none'                   ...
    , 'FaceColor'     , cfg.xClustCl             ...
    );

% Simulate transparency (actual transparency has PDF output issues)
colors                  = [cfg.withinClustCl; cfg.xClustCl];
bar ( axs, xaxis, min([countsWithin; countsAcross],[],1), .96     ...
    , 'EdgeColor'     , 'none'                                    ...
    , 'FaceColor'     , mean(colors,1)                            ...
    );

legend(axs,hHisto([1 2]),{'within module','across module'})
xlabel(['\Delta abs(corr)' sprintf('\n(accumul - ctrl)')])
ylabel('Prop. units')

text(.3,.25,sprintf('P = %1.2g',RNNdata.rates.p_ccDelta_withinVSacrossModule))
xlim([-1 1]); ylim([0 .5])

set(gcf,'position',[100 100 900 300])

end