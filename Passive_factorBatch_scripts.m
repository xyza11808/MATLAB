% batch processing for passive session factor analysis 
clear;
clc;

[fn,fp,fi] = uigetfile('*.txt','Please select the passive session path saved file');
if ~fi
    return;
end
%%
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'plot_save\NO_Correction'))
        tline = fgetl(fid);
        continue;
    end
    fDatapath = fullfile(tline,'rfSelectDataSet.mat');
    cd(tline);
    clearvars SelectData SelectSArray
    load(fDatapath);
    
     Passive_factroAna_scripts
     
     tline = fgetl(fid);
end

%% Plot each session factor analysis results according to frequencies
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
cSess = 1;
SummarySavePath = 'E:\DataToGo\data_for_xu\Factor_new_smooth\New_correct_factorAna\Passive';
PassFactorDataSum = {};
PassFreqSum = {};
UsfulDataSum = {};
while ischar(tline)
    if isempty(strfind(tline,'plot_save\NO_Correction'))
        tline = fgetl(fid);
        continue;
    end
    cd(tline);
    fDatapath = [tline,filesep,'DimRed_Resplot'];
    
    cSessFreqStrc = load(fullfile(fDatapath,'FactorAnaData.mat'),'SelectSArray');
    cIndexStrc = load(fullfile(fDatapath,'MeanPlotData.mat'),'cLRIndexSum','xTimes','start_frame','frame_rate');
    cIndexStrc.FreqArray = cSessFreqStrc.SelectSArray;
    
    cSessFreqs = unique(cSessFreqStrc.SelectSArray);
    disp((cSessFreqs(:))');
    Inds = input('Pease input the frequency inds that gona be used:\n','s');
    Inds = str2num(Inds);
    try
        UsedFreq = cSessFreqs(Inds);
        if length(UsedFreq) < 6
            error('Too less frequencies being used.');
        end
    catch ME
        fprintf('Error occurs within session:\n%s\n%s\n',tline,ME.message);
        tline = fgetl(fid);
        cSess = cSess + 1;
        continue;
    end
    UsedFreq = sort(UsedFreq);
    nFreqs = length(UsedFreq);
    Opt.t_eventOn = cIndexStrc.start_frame/cIndexStrc.frame_rate;
    Opt.eventDur = 0.3;
    eventOff = Opt.t_eventOn + Opt.eventDur;
    cstimes = cIndexStrc.xTimes;
    CMap = [(linspace(0,1,nFreqs))',zeros(nFreqs,1)+0.1,(linspace(1,0,nFreqs))'];
    Opt.isPatchPlot = 0;
    lineMemoStrs = cellstr(num2str(UsedFreq(:)/1000,'%.1fKHz'));
    lineobj = [];
    hhf = figure('position',[500 300 1050 750]);
    hold on
    for cfreq = 1 : nFreqs
        cFreqInds = UsedFreq(cfreq) == cSessFreqStrc.SelectSArray;
        cFreqData = cIndexStrc.cLRIndexSum(cFreqInds,:);
        
        H = plot_meanCaTrace(mean(cFreqData),std(cFreqData)/sqrt(size(cFreqData,1)),cstimes,hhf,Opt);
        set(H.meanPlot,'color',CMap(cfreq,:));
        set(H.ep,'facecolor',CMap(cfreq,:),'facealpha',0.4);
        lineobj = [lineobj,H.meanPlot];
    end
    yscales = get(gca,'ylim');
    patch([Opt.t_eventOn Opt.t_eventOn eventOff eventOff],[yscales(1) yscales(2) yscales(2) yscales(1)],1,...
        'Edgecolor','none','facecolor',[.8 .8 .8] ,'facealpha',0.6);
    legend(lineobj,lineMemoStrs,'FontSize',12)
    legend('boxoff')
    title(sprintf('Sess #%d',cSess))
    xlabel('Time (s)');
    ylabel('Nor. selction index');
    set(gca,'FontSize',16);
    saveName = sprintf('Passive Sess%d FactorIndex SumPlot',cSess);
    saveas(hhf,fullfile(SummarySavePath,saveName));
    saveas(hhf,fullfile(SummarySavePath,saveName),'png');
    close(hhf);
    
    PassFactorDataSum{cSess} = cIndexStrc.cLRIndexSum;
    PassFreqSum{cSess} = UsedFreq;
    UsfulDataSum{cSess} = cIndexStrc;
    
    tline = fgetl(fid);
    cSess = cSess + 1;
end
cd(SummarySavePath);
save SummaryDataSave.mat PassFactorDataSum PassFreqSum UsfulDataSum -v7.3