%% get data folder path
folderPath = uigetdir(pwd,'Select Data folder path');
cd(folderPath);
%%
datafilenames = dir(fullfile(folderPath,'*ZL_*.mat'));
Numfiles = length(datafilenames);
SessDataMerged = cell(Numfiles,6);
SessDataString = {'TrTypes','TrFreqs','TrChoices','CorrRate','MissRate','FirstLickTime'};
for cf = 1 : Numfiles
    
    cfName = datafilenames(cf).name;
    
    load(fullfile(folderPath,cfName));
    %
    [behavResults,behavSettings] = behav_cell2struct(SessionResults,SessionSettings);

    %
    TrFreqs = double(behavResults.Stim_toneFreq(:));
    TrTypes = double(behavResults.Trial_Type(:));
    TrChoices = double(behavResults.Action_choice(:));
    numTrNum = length(TrTypes);
    TrCorrectPerf = double(TrTypes == TrChoices);

    LeftTrInds = find(TrTypes == 0);
    RightTrInds = find(TrTypes == 1);
    MissTrInds = find(TrChoices == 2);

    IsMissTrials = zeros(numel(TrChoices),1);
    IsMissTrials(MissTrInds) = 1;

%     MissRateMaxTrNum = 400;
%     CaledMissRate = mean(IsMissTrials(MissRateMaxTrNum));

    % plot behavior results

    hf = figure('position',[100 100 1200 320]);
    subplot(1,4,[1,2])
    hold on

    plot(LeftTrInds,smooth(TrCorrectPerf(LeftTrInds),17),'Color',[0.1 0.1 0.8],'linewidth',1.8);
    plot(RightTrInds,smooth(TrCorrectPerf(RightTrInds),17),'Color',[0.8 0.1 0.1],'linewidth',1.8);
    plot(smooth(TrCorrectPerf,17),'Color','k','linewidth',1.8)
    plot(smooth(IsMissTrials,17),'Color',[0.3 0.3 0.3],'linewidth',1.2)

    set(gca,'ylim',[-0.05 1.05],'ytick',0:0.5:1);
    ylabel('Correct / Prob.');
    xlabel('# Trials');
    title('Perf plot')
    % lick time analysis
    [Lick_time_data,Lick_bias_side]=beha_lickTime_data(behavResults,10);
    FrlickTimesCell = arrayfun(@(x) x.FirstLickTime,Lick_time_data,'UniformOutput',false);
    FrlickTimes = cell2mat(FrlickTimesCell');

    LeftFlickTimes = FrlickTimes(FrlickTimes(:,1) > 0 & FrlickTimes(:,2) == 0,:);
    RightFlickTimes = FrlickTimes(FrlickTimes(:,1) > 0 & FrlickTimes(:,2) == 1,:);

    [LFTy,LFTx] = ecdf(LeftFlickTimes(:,1));
    [RFTy,RFTx] = ecdf(RightFlickTimes(:,1));

    ax2 = subplot(1,4,3);
    hold on
    hl2_1 = plot(LFTx,LFTy,'Color',[0.1 0.1 0.8],'linewidth',1.2);
    hl2_2 = plot(RFTx,RFTy,'Color',[0.8 0.1 0.1],'linewidth',1.2);
    xscales = get(ax2,'xlim');
    set(ax2,'xlim',[-500,xscales(2)],'ylim',[-0.02 1.02],'ytick',0:0.5:1);
    xlabel(ax2,'StimOnTime (ms)');
    ylabel(ax2,'Fraction');
    title('Fisrt lick time');
    legend([hl2_1,hl2_2],{'Left','Right'},'box','off','location','Southeast');

    SessDataMerged(cf,:) = {TrTypes,TrFreqs,TrChoices,TrCorrectPerf,IsMissTrials,FrlickTimes};
    
    saveas(hf,cfName(1:end-4));
    saveas(hf,cfName(1:end-4),'png');
    close(hf);
end


