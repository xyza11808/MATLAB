function [hf, PeakDataStrc] = CusLocalPeakSearchxnn(RawData,PeakThres,PeakDur,varargin)
% this function is used for peak detection for calcium data, in order to
% find significant calcium transients

if length(RawData) ~= numel(RawData)
    error('Input should be a vector data');
end
nFrames = numel(RawData);
 if size(RawData,2) ~= 1
     RawData = RawData(:);
 end
 StdFactor = 3;
 if isempty(PeakThres)
     PeakThres = (mad(RawData,1) * 1.4826) * StdFactor;  % 2 times std value
 end
 PeakWidth = 30;
 if nargin > 3
     if ~isempty(varargin{1})
         PeakWidth = varargin{1};
     end
 end
 
 if isempty(PeakDur)
     PeakDur = 14; % frame numbers
 end
 
 FrameDiffs = diff(RawData);
 FrameDiffThres = mad(FrameDiffs)*1.4826;
 
 [Count,Cen] = hist(RawData,100);
 [~,MaxInds] = max(Count);
Baseline = max(Cen(MaxInds),0) + (mad(RawData,1) * 1.4826)*1.5; % above baseline of 1.5 s.t.d.
StartBase = max(Cen(MaxInds),0) + (mad(RawData,1) * 1.4826) * 2; % above baseline of 2 s.t.d.
EndBase = max(Cen(MaxInds),0) + (mad(RawData,1) * 1.4826); % above baseline of 2 s.t.d.
PeakThres = PeakThres + Cen(MaxInds);
BeforePeakF = round(PeakDur/3);
AfterPeakF = round(PeakDur/3*2);
AboveThresIndex = find(RawData > PeakThres);
AboveThresInds = RawData > PeakThres;

AboveThresData = RawData;
AboveThresData(~AboveThresInds) = PeakThres;
[ppks,loccs] = findpeaks(AboveThresData,'MinPeakDistance',PeakDur/2,...
    'MinPeakHeight',max(Cen(MaxInds),0) + (mad(RawData,1) * 1.4826)*4);

nInds = length(loccs);

%%

hf = figure;
hold on
plot(RawData,'k','linewidth',0.8);

AllPeakInds = zeros(nInds,1);
AllPeakRange = zeros(nInds,2);
PeakArea = zeros(nInds,1);
if isempty(loccs)
    PeakDataStrc = [];
    return;
end
LastEndInds = loccs(1);
LastPeakSeqInds = 1;
for cInd = 1 : nInds
    cPeakRealInds = loccs(cInd);
    if cPeakRealInds < LastEndInds
        if ppks(cInd) > ppks(LastPeakSeqInds)
            AllPeakInds(LastPeakSeqInds) = 0;
            AllPeakInds(cInd) = 1;
            AllPeakRange(cInd,:) = AllPeakRange(LastPeakSeqInds,:);
            AllPeakRange(LastPeakSeqInds,:) = [0 0];
            LastPeakSeqInds = cInd;
        end
        continue;
    end
%     cPeakRange = cPosInds + [-floor(PeakDur/2),ceil(PeakDur/2)];
%     [~,cPeakTempInds] = max(RawData(cPeakRange));
%     cPeakRealInds = cPeakTempInds + cPosInds - floor(PeakDur/2);
    
    cStartInds = max(1,find(RawData(1:cPeakRealInds) <= StartBase,1,'last') - 1);
    cEndInds = find(RawData(1+cPeakRealInds:end) < EndBase,1,'first') - 1+cPeakRealInds;
    
    if isempty(cStartInds)
        cStartInds = 1;
    end
        
    MaxFrameDiff = max(FrameDiffs(max(1,cPeakRealInds-5):cPeakRealInds));
    if MaxFrameDiff < FrameDiffThres
        
        plot(cPeakRealInds,RawData(cPeakRealInds),'b*');
        continue;
    end
    if isempty(cEndInds)
        %if all rest frames were significantly higher that threshold
        AllPeakInds(cInd) = 1;
        AllPeakRange(cInd,:) = [cStartInds,numel(RawData)];
        PeakArea(cInd) = sum(RawData(cStartInds:end));
%         plot(cPeakRealInds,RawData(cPeakRealInds),'co','linewidth',2);
%         plot(cStartInds:numel(RawData),RawData(cStartInds:numel(RawData)),'r','linewidth',1.4)
        LastEndInds = numel(RawData);
        LastPeakSeqInds = cInd;
        continue;
    end
    if (cEndInds - cStartInds) < PeakWidth
        continue;
    end
    AllPeakInds (cInd) = 1;
    AllPeakRange(cInd,:) = [cStartInds,cEndInds];
%     PeakArea(cInd) = sum(RawData(cStartInds:cEndInds));
%     plot(cPeakRealInds,RawData(cPeakRealInds),'co','linewidth',2);
%     
%     plot(cStartInds:cEndInds,RawData(cStartInds:cEndInds),'r','linewidth',1.4)
    LastEndInds = cEndInds;
    LastPeakSeqInds = cInd;
end
PeakIndexInds = loccs(logical(AllPeakInds));
PeakIndexRange = AllPeakRange(logical(AllPeakInds),:);
PeakArea = zeros(length(PeakIndexInds),1);
for cPeak = 1 : length(PeakIndexInds)
    plot(PeakIndexInds(cPeak),RawData(PeakIndexInds(cPeak)),'co','linewidth',2);
    plot(PeakIndexRange(cPeak,1):PeakIndexRange(cPeak,2),RawData(PeakIndexRange(cPeak,1):PeakIndexRange(cPeak,2)),'r','linewidth',1.4);
    PeakArea(cPeak) = sum(RawData(PeakIndexRange(cPeak,1):PeakIndexRange(cPeak,2)));
end

PeakDataStrc.PeakIndex = PeakIndexInds;
PeakDataStrc.PeakIndexRange = PeakIndexRange;
PeakDataStrc.PeakHalfWidth = (PeakIndexRange(:,2) - PeakIndexRange(:,1))/2;
PeakDataStrc.Area = PeakArea;
PeakDataStrc.PeakAmp = ppks(logical(AllPeakInds));

%%

% if ~isdir('Peak_ROI_plots')
%     mkdir('Peak_ROI_plots');
% end
% cd('Peak_ROI_plots');
% %
% nROIs = size(DeltaFROIData,1);
% ROIPeakDataAll = cell(nROIs,1);
% for cROI = 1 : nROIs
%     %
% %     cROI = 2;
% %     close
%     cROIdata = DeltaFROIData(cROI,:);
%     [hhf,PeakStrc] = CusLocalPeakSearchxnn(cROIdata,[],[],5);
%     title(sprintf('ROI%d Trace',cROI));
%     saveas(hhf,sprintf('ROI%d events finding plots',cROI));
%     saveas(hhf,sprintf('ROI%d events finding plots',cROI),'png');
%     close(hhf);
%     
%     ROIPeakDataAll{cROI} = PeakStrc;
%     %%=
% end
    
