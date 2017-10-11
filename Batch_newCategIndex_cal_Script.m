clear
clc

% select the high response ROIs and extract the response profile into a ppt file
[fn,fp,fi] = uigetfile('*.txt','Please select the session path storage file');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
m = 1;

while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'\All BehavType Colorplot','\');
    else
        SessPath = tline;
    end
    clearvars data_aligned behavResults start_frame
    
%     if m == 1
%         PPTname = input('Please input the name for current PPT file:\n','s');
%         if isempty(strfind(PPTname,'.ppt'))
%             PPTname = [PPTname,'.pptx'];
%         end
%         pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
%     end
%     FullfilePath = fullfile(pptSavePath,PPTname);
%     if ~exist(FullfilePath,'file')
%         IsNewFile = 1;
%     else
%         IsNewFile = 0;
%     end
%     if IsNewFile
%         exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
%     else
%         exportToPPTX('open',FullfilePath);
%     end
%     
    load(fullfile(SessPath,'CSessionData.mat'));
    cd(SessPath);
    

    % Select inds calculation plot script
    [nTrs,nROIs,nFrames] = size(data_aligned);
    TimeWin = [0.2,1.2];
    FrameScales = round(TimeWin*frame_rate);
    FreqsAll = double(behavResults.Stim_toneFreq);
    TrOutcome = behavResults.Action_choice(:) == behavResults.Trial_Type(:);
    Freqtypes = unique(FreqsAll);
    nFreqs = length(Freqtypes);
    ROIfreqMeanResp = zeros(nROIs,nFreqs);
    for cROI = 1 : nROIs
        cROIdata = squeeze(data_aligned(:,cROI,:));
        cROIrespData = mean(cROIdata(:,(start_frame+FrameScales(1)):(start_frame+FrameScales(2))),2);
        for cfreq = 1 : nFreqs
            cFreqInds = FreqsAll == Freqtypes(cfreq);
            cFreqDataMean = cROIrespData(cFreqInds);
            cFreqCorrInds = TrOutcome(cFreqInds);
            cFreqCorrData = cFreqDataMean;%(cFreqCorrInds == 1);
            ROIfreqMeanResp(cROI,cfreq) = mean(cFreqCorrData);
        end
    end
    %
    if mod(nFreqs,2)
        nGrNum = floor(nFreqs/2);
        UsedFreqMeanResp = ROIfreqMeanResp;
        UsedFreqMeanResp(:,nGrNum+1) = [];
        FreqTypes = Freqtypes;
        FreqTypes(nGrNum+1) = [];
    else
        UsedFreqMeanResp = ROIfreqMeanResp;
        nGrNum = nFreqs/2;
        FreqTypes = Freqtypes;
    end
    OctaveTypes = log2(double(FreqTypes)/16000);
    ROIindsAll = zeros(nROIs,1);
    ROIindexMaxSum = zeros(nROIs,1);
    CategIndsMaxS = zeros(nROIs,1);
    for cROI = 1 : nROIs
        cROIResp = squeeze(UsedFreqMeanResp(cROI,:));
        [SortResp,RawInds] = sort(cROIResp);
        CategInds = [zeros(1,nGrNum),ones(1,nGrNum)];
        SortCategInds = CategInds(RawInds);
        Max2Values = SortResp(end-(nGrNum-1):end-1);
        MaxValue = SortResp(end);
        Min3Values = SortResp(1:nGrNum);
        Max3Inds = abs(diff(sort(RawInds(end-(nGrNum-1):end))));
        Max3CategInds = abs(diff(sort(SortCategInds(end-(nGrNum-1):end))));
        ROIindsAll(cROI) = (MaxValue - mean(Max2Values))/((MaxValue - mean(Min3Values)) + max(Min3Values) - min(Min3Values));
        ROIindexMaxSum(cROI) = sum(Max3Inds);
        CategIndsMaxS(cROI) = sum(Max3CategInds);
    end

    %
    SigRespROIs = double(ROIfreqMeanResp > 40);
    HighRespROIs = sum(SigRespROIs,2);
    SelectROIinds = find(HighRespROIs);
    nSelectROIs = length(SelectROIinds);
    ROItypeStr = {'Tuning ROI','Bound Tuning','Categorical','Multi Tuning','NoSig Tuning','Mixed Info'};
    ROItypestate = zeros(nSelectROIs,3); % the first column is the ROI number, second column is the ROI type
    % ROI type indication: 1,Tuning ROI; 2, Boundary tuning ROI; 3,
    % categorical ROIs; 4, Mixed Tuning ROI; 5, No Sig. Tuning; 6, Mixed
    % info. of category and tuning
    for CsROI = 1 : nSelectROIs
        cROIinds = SelectROIinds(CsROI);
        cROIindex = ROIindsAll(cROIinds);
        if cROIindex >= 0.6
            if ROIindexMaxSum(cROIinds) == 2 && CategIndsMaxS(cROIinds) == 1
                ROItypestate(CsROI,:) = [cROIinds,2,cROIindex];
            else
                ROItypestate(CsROI,:) = [cROIinds,1,cROIindex]; % tuning ROI type
            end
        elseif cROIindex <= 0.4
            if ROIindexMaxSum(cROIinds) == 2 && CategIndsMaxS(cROIinds) == 0
                ROItypestate(CsROI,:) = [cROIinds,3,cROIindex];
            elseif ROIindexMaxSum(cROIinds) == 2 && CategIndsMaxS(cROIinds) ~= 0
                ROItypestate(CsROI,:) = [cROIinds,2,cROIindex];
            else
                ROItypestate(CsROI,:) = [cROIinds,4,cROIindex];
            end
        elseif cROIindex > 0.4 && cROIindex < 0.6
            if ROIindexMaxSum(cROIinds) == 2 && CategIndsMaxS(cROIinds) == 0
                ROItypestate(CsROI,:) = [cROIinds,6,cROIindex];
            elseif ROIindexMaxSum(cROIinds) == 2 && CategIndsMaxS(cROIinds) == 1
                ROItypestate(CsROI,:) = [cROIinds,2,cROIindex];
            elseif ROIindexMaxSum(cROIinds) > 2 && CategIndsMaxS(cROIinds) > 0
                ROItypestate(CsROI,:) = [cROIinds,4,cROIindex];
            end
        else
            if ROIindexMaxSum(cROIinds) == 2 && CategIndsMaxS(cROIinds) == 1
                ROItypestate(CsROI,:) = [cROIinds,2,cROIindex];
            else
                ROItypestate(CsROI,:) = [cROIinds,5,cROIindex];
            end
        end
    end
    SelectROIMaxSum = ROIindexMaxSum(SelectROIinds);
    SelectCategROIinds = SelectROIMaxSum == 2;
    % SeqSelectROIs = find(HighRespROIs > 0 & ROIindexMaxSum == 2);
    % [IndsSort,IndsROI] = sort(ROIindsAll);
    % xlabels = 1:nROIs;
    [SigIndsSort,SigROIs] = sort(ROIindsAll(SelectROIinds));
    ROIseqs = SelectROIinds(SigROIs);
    xticks = 1 : length(ROIseqs);
    SelectCategROIinds = SelectCategROIinds(SigROIs);
    % figure;
    % hold on;
    % % scatter(xlabels,IndsSort,40,'ro');
    % scatter(xticks,SigIndsSort,40,'ko');
    % % text(xticks,SigIndsSort-0.04,cellstr(num2str(ROIseqs(SigROIs))))
    % scatter(xticks(SelectCategROIinds),SigIndsSort(SelectCategROIinds),40,'c*');
    % scatter(xlabels(SeqSelectROIs),IndsSort(SeqSelectROIs),50,'c*');
    hhhf = figure;
    hold on;
    plot(ROIindsAll)
    plot(SelectROIinds,ROIindsAll(SelectROIinds),'ro')
    text(SelectROIinds,ROIindsAll(SelectROIinds)+0.03,cellstr(num2str(ROIindexMaxSum(SelectROIinds))));
    text(SelectROIinds,ROIindsAll(SelectROIinds)+0.05,cellstr(num2str(CategIndsMaxS(SelectROIinds))),'Color','m');
    %
    if ~isdir('CDInds_calculation_CorrErro')
        mkdir('CDInds_calculation_CorrErro');
    end
    cd('CDInds_calculation_CorrErro');

    saveas(hhhf,'Calculated Index plot');
    saveas(hhhf,'Calculated Index plot','png');
    close(hhhf);
    
    % plot the response profile for each ROI
    for cROI = 1 : nROIs
        cROIresp = UsedFreqMeanResp(cROI,:);
        h_ROI = figure('Position',[680 670 550 430],'PaperPositionMode','auto');
        hold on;
        plot(OctaveTypes,cROIresp,'k-o','linewidth',1.8,'MarkerSize',12);
        plot(OctaveTypes,sort(cROIresp),'r-o','linewidth',1.8,'MarkerSize',12);
        set(gca,'xtick',OctaveTypes,'xticklabel',cellstr(num2str(OctaveTypes(:),'%.1f')));
        xlabel('Octaves');
        ylabel('\DeltaF/F_0(%)');
        title({sprintf('ROI%d',cROI),sprintf('Index = %.4f',ROIindsAll(cROI))});
        set(gca,'FontSize',20);
        saveas(h_ROI,sprintf('ROI%d response plot',cROI));
        saveas(h_ROI,sprintf('ROI%d response plot',cROI),'png');
        close(h_ROI);
    end
        %
    save NewROIindsSave.mat ROIindsAll ROIindexMaxSum SelectROIinds CategIndsMaxS UsedFreqMeanResp ROItypestate ROItypeStr -v7.3

    tline = fgetl(fid);
end

    %% methods 2
