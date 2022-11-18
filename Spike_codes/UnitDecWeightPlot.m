function [hf, BetaValuesAll, BetaRespIndsAll] = ...
    UnitDecWeightPlot(AllRepeatBetas_Sub, BlockShufDecsSub, hf)
% function used to visualize the decoding weights change in different
% blocks
NumofBlocks = size(AllRepeatBetas_Sub,1);

BetaValuesAll = cell(1, NumofBlocks);
BetaRespIndsAll = cell(1, NumofBlocks);
for cB = 1 : NumofBlocks
    cB_realBetas = cat(2,AllRepeatBetas_Sub{cB,:}); % repeats of real betas, NumUnit by repeats
    cB_betaThres = BlockShufDecsSub{cB,3}; % 95 CI for shuf betas
    
    LowThresMtx = repmat(cB_betaThres(:,1),1,size(cB_realBetas,2));
    HighThresMtx = repmat(cB_betaThres(:,2),1,size(cB_realBetas,2));
    
    SigcontriUnitInds = cB_realBetas > HighThresMtx | cB_realBetas < LowThresMtx;
    ConsiderSigUnitInds = mean(SigcontriUnitInds,2) > 0.95; % the values is significantly different
    
    RealBetaValues = median(cB_realBetas,2);
    
    BetaValuesAll(cB) = {RealBetaValues(:)};
    BetaRespIndsAll(cB) = {ConsiderSigUnitInds(:)};
end

% construct the beta mtx
BetaValuesMtx = cat(2,BetaValuesAll{:});
BetaRespIndsMtx = cat(2,BetaRespIndsAll{:});
NumofUnit = size(BetaValuesMtx,1);

IsUnitResp = sum(BetaRespIndsMtx,2) > 0;
%%
BetaValues2Size = 1./(1+exp(-10.*(abs(BetaValuesMtx)-1)))*50+10;
BetaValues2Colors = linearValue2colorFun(BetaValuesMtx,[],0);

BetaValues2ColorInds = BetaValues2Colors{1};
BetaValues2ColorTypes = BetaValues2Colors{2};
BetaValuescLim = BetaValues2Colors{3};
%
[BlockBetaInds, UnitInds] = meshgrid(1:NumofBlocks,1:NumofUnit);

if ~exist('hf','var') || isempty(hf)
    hf = figure('position',[50 50 320 540]);
elseif isgraphics(hf,'axes')
    axes(hf);
elseif isgraphics(hf,'figure')
    figure(hf);
else
    error('Unkown variable hf in the input.');
end
 
hold on
scatter(BlockBetaInds(~BetaRespIndsMtx),UnitInds(~BetaRespIndsMtx),...
    BetaValues2Size(~BetaRespIndsMtx),'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
SigColorIndex = BetaValues2ColorInds(BetaRespIndsMtx);
scatter(BlockBetaInds(BetaRespIndsMtx),UnitInds(BetaRespIndsMtx),...
    BetaValues2Size(BetaRespIndsMtx),BetaValues2ColorTypes(SigColorIndex,:),'filled');
set(gca,'xlim',[0.3 NumofBlocks+0.3],'ylim',[0 NumofUnit+1],'xtick',1:NumofBlocks,...
    'xticklabel',cellstr(num2str((1:NumofBlocks)','Block%d')));
set(gca,'clim',BetaValuescLim);
ylabel('# Units');
title(sprintf('SigWeightsUnit %d/%d',sum(IsUnitResp),numel(IsUnitResp)));
AxsPos = get(gca,'position');

colormap(BetaValues2ColorTypes);
hbar = colorbar;
set(get(hbar,'title'),'String','Weights');
barPos = get(hbar,'position');
set(hbar,'position',barPos.*[1 1 0.8 0.3]+[0.05 0 0 0]);
set(gca,'position',AxsPos.*[1 1 0.85 1]);





