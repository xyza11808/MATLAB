
load(behavfilepath,'behavResults');

%%
BlockSectionInfo = Bev2blockinfoFun(behavResults);

RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
TrialAnmChoice = double(behavResults.Action_choice(:));
TrialAnmChoice(TrialAnmChoice == 2) = NaN;
RevFreqInds = find(ismember(TrialFreqsAll,RevFreqs));
RevFreqChoices = TrialAnmChoice(RevFreqInds);

NMRevfreqInds = ~isnan(RevFreqChoices);
NMRevFreqIndedx = RevFreqInds(NMRevfreqInds);
NMRevFreqChoice = RevFreqChoices(NMRevfreqInds);

%% check block numbers
SwitchFunction = @(a,tau,x) a*exp(-x/tau);
ft = fittype('a*exp(-x/tau)');
if BlockSectionInfo.NumBlocks == 2
    BlockSwitchTrInds = BlockSectionInfo.BlockTrScales(1,2)+1; % the first trial after switch
    if BlockSectionInfo.BlockTypes(1) == 0 % low boundary block starts
        LowBlock_RealRevfreqInds = NMRevFreqIndedx(NMRevFreqIndedx >= BlockSectionInfo.BlockTrScales(1,1) & ...
            NMRevFreqIndedx < BlockSectionInfo.BlockTrScales(1,2));
        HighBlock_RealRevfreqInds = NMRevFreqIndedx(NMRevFreqIndedx >= BlockSectionInfo.BlockTrScales(2,1) & ...
            NMRevFreqIndedx < BlockSectionInfo.BlockTrScales(2,2));
        H2L_choiceprob_diff = mean(TrialAnmChoice(LowBlock_RealRevfreqInds)) - ...
            mean(TrialAnmChoice(HighBlock_RealRevfreqInds)); % choice prob difference between low and high block for reversed frequencies
        
%         AllRevfreqChoice = TrialAnmChoice([LowBlock_RealRevfreqInds;HighBlock_RealRevfreqInds]);
%         Relative_switchInds = length(LowBlock_RealRevfreqInds);
        fit_data_y = [TrialAnmChoice(LowBlock_RealRevfreqInds(end));TrialAnmChoice(HighBlock_RealRevfreqInds)];
        fit_data_x = [0;(1:length(HighBlock_RealRevfreqInds))'];
        
    else
        LowBlock_RealRevfreqInds = NMRevFreqIndedx(NMRevFreqIndedx >= BlockSectionInfo.BlockTrScales(2,1) & ...
            NMRevFreqIndedx < BlockSectionInfo.BlockTrScales(2,2));
        HighBlock_RealRevfreqInds = NMRevFreqIndedx(NMRevFreqIndedx >= BlockSectionInfo.BlockTrScales(1,1) & ...
            NMRevFreqIndedx < BlockSectionInfo.BlockTrScales(1,2));
        H2L_choiceprob_diff = mean(TrialAnmChoice(LowBlock_RealRevfreqInds)) - ...
            mean(TrialAnmChoice(HighBlock_RealRevfreqInds)); % choice prob difference between low and high block for reversed frequencies
        
%         AllRevfreqChoice = TrialAnmChoice([LowBlock_RealRevfreqInds;HighBlock_RealRevfreqInds]);
%         Relative_switchInds = length(LowBlock_RealRevfreqInds);
        fit_data_y = [1 - TrialAnmChoice(HighBlock_RealRevfreqInds(end));1 - TrialAnmChoice(LowBlock_RealRevfreqInds)];
        fit_data_x = [0;(1:length(LowBlock_RealRevfreqInds))'];
        
    end
    
    SwitchBlockChoices_rightward = {fit_data_y};
    startPoints = [1,1];
    md = fit(fit_data_x,fit_data_y,ft,'StartPoint',startPoints);

    hf = figure('position',[100 100 480 360]);
    hold on
    plot(fit_data_x,smooth(fit_data_y,5),'k-o','linewidth',0.8);
    fitcurve = feval(md,fit_data_x);
    plot(fit_data_x,fitcurve,'r','linewidth',1.4);
    xlabel('Trials after switch');
    ylabel('Rightward choice prob');
    syms x
    s = solve(md.a*exp(-x/md.tau) == 0.5);
    HalfPeakTrial = double(s);
    if HalfPeakTrial<0 || HalfPeakTrial > 50
       HalfPeakTrial = NaN;
    end
    title(sprintf('Tau = %.2f, HalfPeakTr = %.2f',md.tau, HalfPeakTrial));
    AllFitMd = md;
    
elseif BlockSectionInfo.NumBlocks > 2 % if multiple switch exists
    % normally only the first switch performance is good
    LowBlock_RealRevfreqInds = [];
    HighBlock_RealRevfreqInds = [];
    SwitchBlockChoices_rightward = cell(BlockSectionInfo.NumBlocks-1,1);
    formerBlockLastChoice = NaN;
    for cB = 1 : BlockSectionInfo.NumBlocks
        BlockTrInds = BlockSectionInfo.BlockTrScales(cB,:);
        cBlockRevfreqInds = NMRevFreqIndedx(NMRevFreqIndedx >= BlockTrInds(1) & ...
                NMRevFreqIndedx < BlockTrInds(2));
        if BlockSectionInfo.BlockTypes(cB) == 0 % in case of a low boundary block
            LowBlock_RealRevfreqInds = [LowBlock_RealRevfreqInds;...
                cBlockRevfreqInds];
            if cB > 1 % current block is a reverse block
                SwitchBlockChoices_rightward{cB-1} = [formerBlockLastChoice;1 - TrialAnmChoice(cBlockRevfreqInds)];
            end
            formerBlockLastChoice = 1 - TrialAnmChoice(cBlockRevfreqInds(end));
        else
            HighBlock_RealRevfreqInds = [HighBlock_RealRevfreqInds;...
                cBlockRevfreqInds];
            if cB > 1 % current block is a reverse block
                SwitchBlockChoices_rightward{cB-1} = [formerBlockLastChoice;TrialAnmChoice(cBlockRevfreqInds)];
            end
            formerBlockLastChoice = TrialAnmChoice(cBlockRevfreqInds(end));
        end
        
    end
    H2L_choiceprob_diff = mean(TrialAnmChoice(LowBlock_RealRevfreqInds)) - ...
            mean(TrialAnmChoice(HighBlock_RealRevfreqInds)); % choice prob difference between low and high block for reversed frequencies
    
    linecolors = jet(BlockSectionInfo.NumBlocks-1);
    AllFitMd = cell(BlockSectionInfo.NumBlocks-1,2);
    HalfPeakTrial = zeros(BlockSectionInfo.NumBlocks-1,1);
    startPoints = [1,1];
    hf = figure('position',[100 100 480 360]);
    hold on
    for cswitch = 1 : BlockSectionInfo.NumBlocks-1
        fit_data_y = SwitchBlockChoices_rightward{cswitch};
        fit_data_x = (1:numel(fit_data_y))'-1;
        
        md = fit(fit_data_x,fit_data_y,ft,'StartPoint',startPoints);
        plot(fit_data_x,smooth(fit_data_y,5),'-o','linewidth',0.8,'color',linecolors(cswitch,:));
        fitcurve = feval(md,fit_data_x);
        plot(fit_data_x,fitcurve,'r','linewidth',1.4); %'color',linecolors(cswitch,:)
        syms x
        s = solve(md.a*exp(-x/md.tau) == 0.5);
        HalfPeakTrial(cswitch) = double(s);
        if HalfPeakTrial(cswitch) <0 || HalfPeakTrial(cswitch) > 50
           HalfPeakTrial(cswitch) = NaN;
        end
        text(40,1-0.05*cswitch,sprintf('Tau = %.2f, HalfPeakTr = %.2f',md.tau, HalfPeakTrial),...
            'Color',linecolors(cswitch,:));
        
        AllFitMd{cswitch} = md;
    end
    xlabel('Trials after switch');
    ylabel('Rightward choice prob');
    
    
end
%%
SwitchInBlockType = BlockSectionInfo.BlockTypes(2:end); % switch into what kind of the block

% SavePlotFolder = fullfile(cfFolder,'BehavSwitchPlot'); % for behavior data processing
% SavePlotFolder = fullfile(cfFolder,'ks2_5'); % for spike session data processing
if ~exist('cF_prefix','var')
    figsavePath = fullfile(SavePlotFolder,'BehavSwitchPlot');
    matfileSavePath = fullfile(SavePlotFolder,'BehavSwitchData.mat');
else
    figsavePath = fullfile(SavePlotFolder,sprintf('%s_BSPlot',cF_prefix));
    matfileSavePath = fullfile(SavePlotFolder,sprintf('%s_BSData.mat',cF_prefix));
end

saveas(hf,figsavePath);
saveas(hf,figsavePath,'png');
close(hf);

save(matfileSavePath,'SwitchBlockChoices_rightward','AllFitMd', 'H2L_choiceprob_diff',...
    'SwitchBlockChoices_rightward', 'ft', 'HalfPeakTrial','SwitchInBlockType','-v7.3');

% clearvars SwitchBlockChoices_rightward AllFitMd H2L_choiceprob_diff ...
%   SwitchBlockChoices_rightward ft HalfPeakTrial SwitchInBlockType


%%
% cclr
% 
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% 
% SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
%         'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
% NumUsedSess = length(SessionFolders);
% 
% for cf = 1 : NumUsedSess
%    cfFolder = SessionFolders{cf}(2:end-1);
%    if ~exist(fullfile(cfFolder,'ks2_5','BehavSwitchPlot.png'),'file')
%        fprintf('Processing Session %d...\n',cf);
%        behavfilepath = fullfile(cfFolder,'ks2_5','NPClassHandleSaved.mat');
%        clearvars behavResults fit_data_x fit_data_y md
%        behavSwitchplot_script;
%    end
% end



    
    
    