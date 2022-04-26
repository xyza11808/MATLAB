
% CalUnitInds

% CombinedUnitInds

% AllPairedUnit_CCGs
PairedCCG_Values_cell = cellfun(@(x,y) (mean(x-y,3))',...
    AllPairedUnit_CCGs(:,2),AllPairedUnit_CCGs(:,3),'un',0);
PairedUnitInds = cell2mat(AllPairedUnit_CCGs(:,1));

PairedCCG_ValueMtx = cell2mat(PairedCCG_Values_cell);
tauValueNum = size(PairedCCG_ValueMtx,2);
BaselineSTDs = std(PairedCCG_ValueMtx(:,[1:100,(tauValueNum-99):tauValueNum]),[],2);
baselineMean = mean(PairedCCG_ValueMtx(:,[1:100,(tauValueNum-99):tauValueNum]),2);
[PairedCCG_PeakValue, PeakInds] = max(PairedCCG_ValueMtx,[],2);
AbovePeakInds = PairedCCG_PeakValue > baselineMean + BaselineSTDs*4;
AbovePeak_position = PeakInds(AbovePeakInds);
PeakLagPosition = AbovePeak_position - ceil(tauValueNum/2);
PeakLagSign = sign(PeakLagPosition);
%%
CalUnitInds = ExistField_ClusIDs(:,2);
SigCCGPeakInds = CombinedUnitInds(AbovePeakInds,:);
SigCCGPeakSTD_values = (PairedCCG_PeakValue(AbovePeakInds) - baselineMean(AbovePeakInds))...
    ./BaselineSTDs(AbovePeakInds);
NumUsedInds = numel(CalUnitInds);
fusionMtxInds = sub2ind([NumUsedInds NumUsedInds],SigCCGPeakInds(:,1),SigCCGPeakInds(:,2));
UnitCCG_fusionMtx = zeros(NumUsedInds);
UnitCCG_fusionMtx(fusionMtxInds) = PeakLagSign .* PairedCCG_PeakValue(AbovePeakInds);
UnitCCGSTD_fusionMtx = zeros(NumUsedInds);
UnitCCGSTD_fusionMtx(fusionMtxInds) = PeakLagSign .* SigCCGPeakSTD_values;

hf = figure('position',[100 200 840 380]);
ax1 = subplot(121);
imagesc(UnitCCG_fusionMtx);

axesPos1 = get(ax1,'position');
hbar1 = colorbar;
barPos1 = get(hbar1,'position');
set(hbar1,'position',barPos1.*[1 1 0.6 0.5]+[0.06 0.02 0 0]);
set(ax1,'position',axesPos1);
title('Real CCG values');

ax2 = subplot(122);
imagesc(UnitCCGSTD_fusionMtx,[-5 5]);

hbar2 = colorbar;
axesPos = get(ax2,'position');
barPos = get(hbar2,'position');
set(hbar2,'position',barPos.*[1 1 0.6 0.5]+[0.08 0.02 0 0]);
set(ax2,'position',axesPos);
title('Zscored CCG peak')



