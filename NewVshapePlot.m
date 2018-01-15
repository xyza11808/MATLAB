function varargout = NewVshapePlot(RawData,SoundArray,Framerate,StartInds,varargin)
% new function for simplified v-shape tuning colormap plot

TimeScales = [0,1]; % time after stimulus onset
if nargin > 4
    if ~isempty(varargin{1})
        TimeScales = varargin{1};
    end
end
FrameScale = round(TimeScales*Framerate);
[nTrs,nROIs,nFrames] = size(RawData);
if FrameScale(2) > (nFrames - StartInds - 1)
    warning('Time range outof frame index.');
    FrameScale(2) = (nFrames - StartInds - 1);
end

RespData = squeeze(mean(RawData(:,:,(StartInds+FrameScale(1)):(StartInds+FrameScale(2))),3));

FreqsAll = double(SoundArray(:,1));
DBAll = double(SoundArray(:,2));
if length(FreqsAll) ~= nTrs
    error('Unequal trial number for 2p and behavior data');
end

FreqTypes = unique(FreqsAll);
DBTypes = unique(DBAll);
nFreq = length(FreqTypes);
nDB = length(DBTypes);
Tickxlabel = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
TickyLabel = cellstr(num2str(DBTypes(:),'%d'));

if ~isdir('./New_vshapePlot/')
    mkdir('./New_vshapePlot/');
end
cd('./New_vshapePlot/');
TuningData = cell(nROIs,1);
for cROI = 1 : nROIs
    cROIrespData = RespData(:,cROI);
    cColorlim = [0 prctile(cROIrespData,95)];
    
    %
    cRespData = zeros(nFreq,nDB);
    for cFreq = 1 : nFreq
        for cDB = 1 : nDB
            cRespData(cFreq,cDB) = mean(cROIrespData(FreqsAll == FreqTypes(cFreq) & DBAll == DBTypes(cDB)));
        end
    end
    TuningData(cROI) = {cRespData};
    %
    hf = figure('position',[3000 200 480 300]);
    imagesc(1:nFreq,1:nDB,cRespData',cColorlim);
    colormap((hot));
    set(gca,'xtick',1:nFreq,'ytick',1:nDB,'xticklabel',Tickxlabel,'yticklabel',TickyLabel,'TickLength',[0 0]);
    xlabel('Frequency (kHz)');
    ylabel('DB');
    title(sprintf('ROI%d',cROI));
    set(gca,'yDir','Normal');
    set(gca,'FontSize',12);
    hbar = colorbar;
    set(hbar,'position',get(hbar,'position').*[1 1 0.4 0.8] + [0.11 0.05 0 0]);
    set(hbar,'ytick',cColorlim);
    title(hbar,'\DeltaF/F_0','FOntSize',5);
    %
    saveas(hf,sprintf('ROI%d vshape tuning plot',cROI));
    saveas(hf,sprintf('ROI%d vshape tuning plot',cROI),'png');
    close(hf);
end
cd ..

if nargout > 0
    if nargout == 1
        varargout{1} = TuningData;
    end
end
        