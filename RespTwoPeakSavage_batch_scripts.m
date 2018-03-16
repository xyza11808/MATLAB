clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end
%%
clearvars -except fn fp PassUsedInds
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
m = 1;
IsIndsExists = 1;
if ~exist('PassUsedInds','var')
    IsIndsExists = 0;
    PassUsedInds = {};
end

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    
    % passive tuning frequency colormap plot
    PassTunFPath = (fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    PassdataStrc = load(PassTunFPath,'PassTunningfun','PassFreqOctave');
    cd(tline);
    
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    
    TaskDatafpath = fullfile(tline,'CSessionData.mat');
    load(TaskDatafpath);
    
    TrFreqs = double(behavResults.Stim_toneFreq);
    TrOutcomes = behavResults.Action_choice == behavResults.Trial_Type;
    TrRespData = max(smooth_data(:,:,(start_frame+1):(start_frame+frame_rate)),[],3);
    CorrTrRespData = TrRespData(TrOutcomes,:);
    CorrTrFreqsAll = TrFreqs(TrOutcomes);
    nROIs = size(CorrTrRespData,2);
    %
    FreqTypes = unique(CorrTrFreqsAll);
    FreqNum = length(FreqTypes);
    FreqOcttypes = log2(FreqTypes/16000);
    nTrs = length(CorrTrFreqsAll);
    SampleTrNum = round(nTrs*0.8);
    nIters = 50;
    IterRespAll = zeros(nIters,FreqNum,nROIs);
    for cIters = 1 : nIters
        cIterSampleInds = CusRandSample(CorrTrFreqsAll,SampleTrNum);
        cSampleFreq = CorrTrFreqsAll(cIterSampleInds);
        cSampleSata = CorrTrRespData(cIterSampleInds,:);
        
        IterRespMean = zeros(FreqNum,nROIs);
        for cFreq = 1 : FreqNum
            IterRespMean(cFreq,:) = mean(cSampleSata(cSampleFreq == FreqTypes(cFreq),:));
        end
        IterRespAll(cIters,:,:) = IterRespMean;
    end
    ROIAvgRespDatas = squeeze(mean(IterRespAll,1));
    AllIterOcts = repmat(FreqOcttypes(:),1,nIters);
    %
    if ~isdir('./RespTwopeakFit/')
        mkdir('./RespTwopeakFit/');
    end
    cd('./RespTwopeakFit/');
    modelfunc = @(c1,c2,c3,c4,c5,c6,c7,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4+c5*exp((-1)*((x - c6).^2)./(2*(c7^2)));
    ROIfitData = cell(nROIs,1);
    OctaveData = FreqOcttypes;
    for cROI = 1 : nROIs
        cROIIterResp = (squeeze(IterRespAll(:,:,cROI)))';
        NorTundata = cROIIterResp(:);
        OctaveDataAll = AllIterOcts(:);
        AvgDatas = ROIAvgRespDatas(:,cROI);
        [Value,Inds] = sort(AvgDatas,'descend');
        [AmpV,AmpInds] = max(AvgDatas);
        c0 = [AmpV,OctaveData(AmpInds),mean(abs(diff(OctaveData))),min(NorTundata),Value(2),OctaveData(Inds(2)),mean(abs(diff(OctaveData)))];  % 0.4 is the octave step
        cUpper = [AmpV*2,max(OctaveData),max(OctaveData) - min(OctaveData),AmpV,AmpV*2,max(OctaveData),max(OctaveData) - min(OctaveData)];
        cLower = [min(NorTundata),min(OctaveData),0.05,-Inf,min(NorTundata),min(OctaveData),0.05];
        [ffit,gof] = fit(OctaveDataAll,NorTundata,modelfunc,...
           'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR','MaxIter',1000);  % 'Method','NonlinearLeastSquares',
        PassOctRange = linspace(min(OctaveData),max(OctaveData),500);
        RespFitData = feval(ffit,PassOctRange(:));
        PeakPosData = feval(ffit,[ffit.c2,ffit.c6]);
        ROIfitData{cROI} = ffit;
        hf = figure('position',[100 100 380 320]);
        hold on
        plot(PassOctRange,RespFitData,'r','Linewidth',1.6);
        plot(FreqOcttypes,AvgDatas,'bo','Linewidth',1.4,'MarkerSize',10);
        text(ffit.c2,PeakPosData(1)*1.05,sprintf('%.4f',ffit.c2),'Color',[1 0.7 0.2]);
        text(ffit.c6,PeakPosData(2)*1.05,sprintf('%.4f',ffit.c6),'Color','b');
        set(gca,'xlim',[-1 1],'xtick',[-1 0 1]);
        title(sprintf('ROI%d',cROI));
        
        saveas(hf,sprintf('ROI%d response fitting plot',cROI));
        saveas(hf,sprintf('ROI%d response fitting plot',cROI),'png');
        close(hf);
    end
    save RespMultiPeakFitData.mat ROIfitData -v7.3
    
    % plot the normalized population data
    cSessTunInds = find(BoundTunROIindex{m,7});
    cSessOtherTunIndex = cSessTunInds(BoundTunROIindex{m,2});
    if ~IsIndsExists
        disp(FreqOcttypes);
        disp(PassdataStrc.PassFreqOctave');
        PassIndsStr = input('Please input the passive octave used inds:\n','s');
        PassInds = str2num(PassIndsStr);
        if isempty(PassInds)
            tline = fgetl(fid);
            m = m + 1;
            continue;
        else
            PassUsedOct = PassdataStrc.PassFreqOctave(PassInds);
            PassUsedData = PassdataStrc.PassTunningfun(PassInds,:);
            PassUsedInds{m} = PassInds;
        end
    else
        PassInds = PassUsedInds{m};
        if isempty(PassInds)
            tline = fgetl(fid);
            m = m + 1;
            continue;
        else
            PassUsedOct = PassdataStrc.PassFreqOctave(PassInds);
            PassUsedData = PassdataStrc.PassTunningfun(PassInds,:);
%             PassUsedInds{m} = PassInds;
        end
    end
    TaskOthertnData = ROIAvgRespDatas(:,cSessOtherTunIndex);
    PassOthertnData = PassUsedData(:,cSessOtherTunIndex);
    TaskNorData = zeros(size(TaskOthertnData));
    PassNorData = zeros(size(PassOthertnData));
    for tROI = 1 : length(cSessOtherTunIndex)
        cTasktnData = TaskOthertnData(:,tROI);
        cPasstnData = PassOthertnData(:,tROI);
        TaskNorData(:,tROI) = (cTasktnData - min(cTasktnData))/(max(cTasktnData) - min(cTasktnData));
        PassNorData(:,tROI)  = (cPasstnData - min(cPasstnData))/(max(cPasstnData) - min(cPasstnData));
    end
    save OtherTunDataRespSave.mat TaskOthertnData PassOthertnData TaskNorData PassNorData PassUsedOct FreqOcttypes -v7.3
    
    TaskAvg = mean(TaskNorData,2);
    TaskSEM = std(TaskNorData,[],2)/sqrt(length(cSessOtherTunIndex));
    PassAvg = mean(PassNorData,2);
    PassSEM = std(PassNorData,[],2)/sqrt(length(cSessOtherTunIndex));
    h_f = figure('position',[2500 100 380 320]);
    hold on
    errorbar(PassUsedOct,PassAvg,PassSEM,'k','linewidth',1.6);
    errorbar(FreqOcttypes,TaskAvg,TaskSEM,'r','linewidth',1.6);
    line([BehavBoundData BehavBoundData],[0 1],'Color',[.7 .7 .7],'Linewidth',1.4,'Linestyle','--');
    set(gca,'xlim',[-1 1],'xtick',[-1 0 1],'ylim',[-0.1 1.1],'yTick',[0 0.5 1]);
    xlabel('Octaves');
    ylabel('Response(Nor.)');
    saveas(h_f,'Other Tun ROI popuAvg plot');
    saveas(h_f,'Other Tun ROI popuAvg plot','png');
    close(h_f);
    
    tline = fgetl(fid);
    m = m + 1;
end
        