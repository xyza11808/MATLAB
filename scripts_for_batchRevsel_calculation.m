datafolders = 'G:\behaviro_data\batch103\anm04\data';
cd(datafolders);
sess_matfiles = dir(fullfile(datafolders,'*2021*.mat'));

NumMatfiles = length(sess_matfiles);

matfileBlockInfos = cell(NumMatfiles,5);

for cf = 1 : NumMatfiles
    cMatfile = sess_matfiles(cf).name;
    clearvars behavResults behavSettings
    load(fullfile(datafolders,cMatfile));
    
    BlockSectionInfo = Bev2blockinfoFun(behavResults);
    if isempty(BlockSectionInfo)
        continue;
    end
    
    matfileBlockInfos{cf,2} = BlockSectionInfo;
    matfileBlockInfos{cf,1} = fullfile(fullfile(datafolders,cMatfile));
    
    
    TrTypes = double(behavResults.Trial_Type(:));
    TrActionChoice = double(behavResults.Action_choice(:));
    TrFreqUseds = double(behavResults.Stim_toneFreq(:));
    TrStimOnsets = double(behavResults.Time_stimOnset(:));
    TrTimeAnswer = double(behavResults.Time_answer(:));
    TrTimeReward = double(behavResults.Time_reward(:));
    TrManWaters = double(behavResults.ManWater_choice(:));
    
    % calculate and plot
    IsBoundshiftSess = 0;
    matfileBlockInfos{cf,3} = 0;
    SessFreqTypes = BlockSectionInfo.BlockFreqTypes;
    if length(SessFreqTypes) > 5 && BlockSectionInfo.NumBlocks > 1
        IsBoundshiftSess = 1;
    end
    try
        SessFreqOcts = log2(SessFreqTypes/min(SessFreqTypes));
        NumFreqs = length(SessFreqTypes);
        BlockStartNotUsedTrs = 0; % number of trals not used after block switch
        if IsBoundshiftSess
            matfileBlockInfos{cf,3} = 1;
            hf = figure('position',[100 100 400 300]);
            hold on
            NumBlocks = length(BlockSectionInfo.BlockTypes);
            BlockPerfs = cell(NumBlocks,5);
            for cB = 1 : NumBlocks
                cBScales = BlockSectionInfo.BlockTrScales(cB,:) + [BlockStartNotUsedTrs,0];
                cBTrFreqs = TrFreqUseds(cBScales(1):cBScales(2));
                cBTrChoices = TrActionChoice(cBScales(1):cBScales(2));
                cBTrPerfs = TrTypes(cBScales(1):cBScales(2)) == cBTrChoices;

                cBNMInds = cBTrChoices~= 2;
                cBTrFreqsNM = cBTrFreqs(cBNMInds);
                cBTrChoiceNM = cBTrChoices(cBNMInds);
                cBTrPerfsNM = cBTrPerfs(cBNMInds);

                FreqChoiceANDperfs = zeros(NumFreqs,3);
                for ccf = 1 : NumFreqs
                    cfcBInds = cBTrFreqsNM == SessFreqTypes(ccf);
                    cfcBChoices = cBTrChoiceNM(cfcBInds);
                    cfcBPerfs = mean(cBTrPerfsNM(cfcBInds));

                    FreqChoiceANDperfs(ccf,:) = [mean(cfcBChoices),cfcBPerfs,numel(cfcBChoices)];
                end
                BlockPerfs{cB,1} = FreqChoiceANDperfs;

                ChoiceProbs = FreqChoiceANDperfs(:,1);
                UL = [0.5, 0.5, max(SessFreqOcts), 100];
                SP = [min(ChoiceProbs),1 - max(ChoiceProbs)-min(ChoiceProbs), mean(SessFreqOcts), 1];
                LM = [0, 0, min(SessFreqOcts), 0];
                ParaBoundLim = ([UL;SP;LM]);
                cBTrFreqOcts = log2(cBTrFreqsNM/min(SessFreqTypes));
                fit_curveAll = FitPsycheCurveWH_nx(cBTrFreqOcts,cBTrChoiceNM,ParaBoundLim);
                fit_curveAvg = FitPsycheCurveWH_nx(SessFreqOcts,ChoiceProbs,ParaBoundLim);

                if ~BlockSectionInfo.BlockTypes(cB) % low bound session
                    plot(fit_curveAvg.curve(:,1),fit_curveAvg.curve(:,2),'color',[.45 .8 0.4],'LineWidth',1.6);
                    plot(SessFreqOcts,ChoiceProbs,'o','Color',[.45 .8 0.4],'MarkerSize',5,'linewidth',1.2);
                else
                    plot(fit_curveAvg.curve(:,1),fit_curveAvg.curve(:,2),'color',[0.94 0.72 0.2],'LineWidth',1.6);
                    plot(SessFreqOcts,ChoiceProbs,'d','Color',[0.94 0.72 0.2],'MarkerSize',5,'linewidth',1.2);
                end
                CurveBounds = fit_curveAll.ffit.u;
                BlockPerfs{cB,2} = fit_curveAll;
                BlockPerfs{cB,3} = CurveBounds;
                BlockPerfs{cB,4} = fit_curveAvg;
                BlockPerfs{cB,5} = fit_curveAvg.ffit.u;
            end
            text(median(SessFreqOcts)+0.1,0.4,num2str(abs(BlockPerfs{1,3}-BlockPerfs{2,3}),'First2BoundDiff=%.3f'));
            LowBoundInds = BlockSectionInfo.BlockTypes == 0;
            MeanLowBound = mean(cell2mat(BlockPerfs(LowBoundInds,3)));
            MeanHighBound = mean(cell2mat(BlockPerfs(~LowBoundInds,3)));
            text(median(SessFreqOcts)+0.1,0.2,num2str(MeanHighBound-MeanLowBound,'AvgBoundDiff=%.3f'));
            xlabel('Octaves');
            ylabel('Rightward prob.');
            set(gca,'ylim',[-0.05 1.05]);
            title(strrep(fn(1:end-4),'_','\_'));
            matfileBlockInfos{cf,4} = MeanHighBound-MeanLowBound;
            matfileBlockInfos{cf,5} = BlockPerfs;
        end
        saveas(hf,fullfile(datafolders,[cMatfile(1:end-4),'_Boundshift_plot']));
        saveas(hf,fullfile(datafolders,[cMatfile(1:end-4),'_Boundshift_plot']),'png');
        close(hf);
        
        
    catch ME
        % do nothing
    end
    
end

save summariedBlockRevPerfs.mat matfileBlockInfos -v7.3
%%
EmptyMatcCells = cellfun(@isempty, matfileBlockInfos(:,1));
UsedBlockMats = matfileBlockInfos(~EmptyMatcCells,:);
StartIndsCell = cellfun(@(x) regexp(x,'2021\d{4}'),UsedBlockMats(:,1),'UniformOutput',false);
CelldateStrs = cellfun(@(x,y) x(y:(y+7)),UsedBlockMats(:,1),StartIndsCell,'UniformOutput',false);
OneMatfilestrs = UsedBlockMats{1,1};
AnminfoStartInds = regexp(OneMatfilestrs,'\d{3}a\d{2}');
AnminfoStrs = OneMatfilestrs(AnminfoStartInds:(AnminfoStartInds+5));

RevSessMatInds = logical(cell2mat(UsedBlockMats(:,3)));
RevSessMats = UsedBlockMats(RevSessMatInds,:);
RevSess_dateStrs = CelldateStrs(RevSessMatInds);
[SortedDateS,SortInds] = sort(RevSess_dateStrs);

BlockBoundDiffs = cell2mat(RevSessMats(SortInds,4));

% load to tony labe date from current folder path, one file named "ToTonylabDate.txt"
ToTonyDatePath = fullfile(datafolders,'ToTonylabDate.txt');
fid = fopen(ToTonyDatePath);
tline = fgetl(fid);
fclose(fid);
DateInds = find(strcmpi(SortedDateS, tline));

huf = figure;
plot(BlockBoundDiffs,'r-o','linewidth',1.5);
ylabel('Boundary difference');
xlabel('Date')
title(AnminfoStrs);
set(gca,'box','off');
yscales = get(gca,'ylim');
line([DateInds DateInds]-0.4, yscales,'Color','k','linewidth',1.5);
text(DateInds,yscales(2)-0.2,'ChangeEnvDate','FontSize',10,'Color','k');

savename = fullfile(datafolders,'Across days boundary shift values plot');
saveas(huf,savename);
saveas(huf,savename,'png');
close(huf);







