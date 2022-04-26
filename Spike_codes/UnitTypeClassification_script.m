
load('NPClassHandleSaved.mat');
%%
% UsedClusterInds 
ProbNPSess.UsedClusinds;

% % survival cluster inds
% ProbNPSess.SurviveInds  % used to indexing other datas

% Frs
PassedUnitFrs = ProbNPSess.FRIncludeClusFRs(ProbNPSess.SurviveInds);
PassedUnitNum = length(PassedUnitFrs);

% waveform features
PassedUnitFeatures = ProbNPSess.UnitWaveFeatures(ProbNPSess.SurviveInds,:);

% raw waveform datas
PassedUnitWaves = cellfun(@mean,ProbNPSess.UnitWaves(ProbNPSess.SurviveInds,1),...
    'un',0);
PassUnitWaveproperties = zeros(PassedUnitNum,6);
for cU = 1 : PassedUnitNum
    cU_Wave = PassedUnitWaves{cU};
    [pks,locs,width,prominance] = findpeaks(cU_Wave,'MinPeakProminence',1);
    [Negpks,Neglocs,Negwidth,Negprominence] = findpeaks(-cU_Wave,'MinPeakProminence',5);
    
    if length(Negpks) > 1
        [~, UsedToughInds] = min(abs(Neglocs - 31));
    else
        UsedToughInds = 1;
    end
    if length(pks) == 1
        UsedPosPeakInds = 1;
    elseif length(pks) > 1
        UsedPosPeakInds = find(locs>Neglocs(UsedToughInds), 1, 'first');
    end
    
    if locs(UsedPosPeakInds) <= Neglocs(UsedToughInds)
        error('The positive peak could not happened ahead of the tough');
    end
    PassUnitWaveproperties(cU,:) = [Neglocs(UsedToughInds), locs(UsedPosPeakInds),...
        Negwidth(UsedToughInds), width(UsedPosPeakInds), ...
        Negprominence(UsedToughInds), prominance(UsedPosPeakInds)];
    
end
%%
Peak2ToughTimes = PassUnitWaveproperties(:,2) - PassUnitWaveproperties(:,1);
ToughWidth = PassUnitWaveproperties(:,3);
Peak2Tough_AmpRatio = PassUnitWaveproperties(:,5)/PassUnitWaveproperties(:,6);
UnitFRs = PassedUnitFrs;

%%
figure;
plot3(Peak2ToughTimes,UnitFRs,Peak2Tough_AmpRatio,'ko');
xlabel('p2t times (sample)');
ylabel('Fr (Hz)');
zlabel('AmpRatio (v/p)');


