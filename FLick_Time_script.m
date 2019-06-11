% test with first like time distribution
load('CSessionData.mat','behavResults','trial_outcome');

[lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,9);
%%
OnsetStruct=struct('StimOnset',behavResults.Time_stimOnset,'StimDuration',300);
[FLickT,FRewardLickT,FlickInds]=FirstLickTime(lick_time_struct,behavResults.Action_choice,trial_outcome,OnsetStruct,behavResults.Time_answer);

%%
NMFLickTimeInds = FLickT > 10;
NMFLickTime = FLickT(NMFLickTimeInds);

%%
AfterSoundFrac = mean(NMFLickTime > 1300);
AfterDelayFrac = mean(NMFLickTime > 1800);
[Count,Center] = hist(NMFLickTime,50);
hf = figure('position',[100 100 380 300]);
plot(Center/1000,Count/numel(NMFLickTime),'k','linewidth',1.5);
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
set(gca,'box','off','xlim',[0 xscales(2)],'xtick',0:xscales(2));
line([1 1],yscales,'Color',[.7 .7 .7],'Linewidth',1.4,'linestyle','--');
patch([1 1.3 1.3 1],[yscales(1) yscales(1) yscales(2) yscales(2)],1,'FaceColor',[.8 .8 .8],...
    'edgeColor','none','facealpha',0.6);
patch([1.3 1.8 1.8 1.3],[yscales(1) yscales(1) yscales(2) yscales(2)],1,'FaceColor',[.6 1 .6],...
    'edgeColor','none','facealpha',0.4);
set(gca,'ylim',yscales);
title(sprintf('ASFrac %.3f%%, ADFrac %.3f%%',AfterSoundFrac*100,AfterDelayFrac*100));
set(gca,'FontSize',10)
ylabel('Fraction');

%% batched first lick time plots

cclr

[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
%%
fids = fopen(fPath);
tline = fgetl(fids);
k = 1;
ErrorMess = {};
DataSavagePath = 'E:\DataToGo\NewDataForXU\FlickTime\Summary';
FLickTimeAll = [];

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fids);
        continue;
    end
    
    % load task datas
    clearvars behavResults trial_outcome
    cd(tline);
    load('CSessionData.mat','behavResults','trial_outcome');
    
    if ~isdir('FirstLick_Time_dis')
        mkdir('FirstLick_Time_dis');
    end
    cd('FirstLick_Time_dis');
    
    [lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,9);
    %
    OnsetStruct=struct('StimOnset',behavResults.Time_stimOnset,'StimDuration',300);
    [FLickT,FRewardLickT,FlickInds]=FirstLickTime(lick_time_struct,behavResults.Action_choice,trial_outcome,OnsetStruct,behavResults.Time_answer);

    %
    NMFLickTimeInds = FLickT > 10; % exclude zero values
    NMFLickTime = FLickT(NMFLickTimeInds);
    
    AfterSoundFrac = mean(NMFLickTime > 1300);
    AfterDelayFrac = mean(NMFLickTime > 1800);
    [Count,Center] = hist(NMFLickTime,25);
    hf = figure('position',[100 100 380 300]);
    plot(Center/1000,Count/numel(NMFLickTime),'k','linewidth',1.5);
    xscales = get(gca,'xlim');
    yscales = get(gca,'ylim');
    set(gca,'box','off','xlim',[0 xscales(2)],'xtick',0:xscales(2));
    line([1 1],yscales,'Color',[.7 .7 .7],'Linewidth',1.4,'linestyle','--');
    patch([1 1.3 1.3 1],[yscales(1) yscales(1) yscales(2) yscales(2)],1,'FaceColor',[.8 .8 .8],...
        'edgeColor','none','facealpha',0.6);
    patch([1.3 1.8 1.8 1.3],[yscales(1) yscales(1) yscales(2) yscales(2)],1,'FaceColor',[0.6 1 0.6],...
        'edgeColor','none','facealpha',0.4);
    set(gca,'ylim',yscales);
    title(sprintf('ASFrac %.3f%%, ADFrac %.3f%%',AfterSoundFrac*100,AfterDelayFrac*100));
    set(gca,'FontSize',10)
    ylabel('Fraction');
    saveas(hf,'FLickTime distribution plot save');
    saveas(hf,'FLickTime distribution plot save','pdf');
    saveas(hf,'FLickTime distribution plot save','png');
    
    close(hf);
    
    save FLickTimeData.mat FLickT Lick_bias_side FRewardLickT FlickInds -v7.3
    
    FLickTimeAll{k} = FLickT;
    k = k + 1;
    tline = fgetl(fids);
end
fclose(fids);

cd(DataSavagePath);

%%
save FLickT_All.mat FLickTimeAll -v7.3

%%




