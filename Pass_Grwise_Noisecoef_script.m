% calculate the noise for left and right selective populations
clear
clc
[fn,fp,fi] = uigetfile('GroupWiseNC_path.txt','Please select the file contains task data sessions');
[PassPathfn,PassPathfp,PassPathfi] = uigetfile('*.txt','Please select the passive data path');
%%
if fi
    fpath = fullfile(fp,fn);
    fid = fopen(fpath);
    fPassid = fopen(fullfile(PassPathfp,PassPathfn));
    tline = fgetl(fid);
    Passtline = fgetl(fPassid);
    while ischar(tline)
        if isempty(strfind(tline,'Group_NC_cumulativePlot\RespGroupNCData.mat'))
            tline = fgetl(fid);
            Passtline = fgetl(fPassid);
            continue;
        end
        TaskCoefDataPath = strrep(tline,'Group_NC_cumulativePlot\RespGroupNCData.mat;','Group_NC_cumulativePlot\RespGroupNCData.mat');
        BaseSessionPath = strrep(Passtline,'\Correlation_distance_coefPlot\DisNCData.mat;','\');
        TaskIndexStrc = load(TaskCoefDataPath);
        
        PassCoefDataPath = strrep(Passtline,';','');
        PassDataStrc = load(PassCoefDataPath);
        PassNCdata = PassDataStrc.NCDataStrc.PairedNoiseCoef;
        PassNCdataMtx = squareform(PassNCdata);
        TaskLeftIndex = TaskIndexStrc.LeftSigROIAUCIndex;
        TaskRightIndex = TaskIndexStrc.RightSigROIAUCIndex;
        TaskNosRespROIindex = TaskIndexStrc.NoiseRespROIInds;
        
        PassLeftNC = PassNCdataMtx(TaskLeftIndex,TaskLeftIndex);
        PassRightNC = PassNCdataMtx(TaskRightIndex,TaskRightIndex);
        PassBetNC = PassNCdataMtx(TaskLeftIndex,TaskRightIndex);
        PassNosRespNC = PassNCdataMtx(TaskNosRespROIindex,TaskNosRespROIindex);
        PassNosRespBetSigNC = PassNCdataMtx([TaskLeftIndex(:);TaskRightIndex(:)],TaskNosRespROIindex);
        
        PassLeftNCVec = PassLeftNC(logical(tril(ones(size(PassLeftNC)),-1)));
        PassRightVec = PassRightNC(logical(tril(ones(size(PassRightNC)),-1)));
        PassNosRespNCVec = PassNosRespNC(logical(tril(ones(size(PassNosRespNC)),-1)));
        PassBetNCVec = PassBetNC(:);
        PassNosRespBetSigNC = PassNosRespBetSigNC(:);
        
        cd(BaseSessionPath);
        if ~isdir('./GrWise_NC_data/')
            mkdir('./GrWise_NC_data/');
        end
        cd('./GrWise_NC_data/');
        save PassGrwiseDatasave.mat PassLeftNCVec PassRightVec PassNosRespNCVec PassBetNCVec PassNosRespBetSigNC -v7.3
        cd ..;
%         save RespGroupNCData.mat LeftSigROIAUCIndex RightSigROIAUCIndex LeftROINCVector RightROINCvector NosRespSigNCvec ...
%             betLRNoiseCorrVector NCDataStrc NosRespNCvector NoiseRespROIInds -v7.3
        
        tline = fgetl(fid);
        Passtline = fgetl(fPassid);
        % clear
    end
end
fclose(fid);
fclose(fPassid);

%%
clear
clc
[PassPathfn,PassPathfp,PassPathfi] = uigetfile('*.txt','Please select the passive data path');
if PassPathfi
    PassLeftNCAll = [];
    PassRightNCAll = [];
    PassBetNCAll = [];
    PassNosRespNCAll = [];
    PassNosRespBetSigAll = [];
    Passfid = fopen(fullfile(PassPathfp,PassPathfn));
    tline = fgetl(Passfid);
    while ischar(tline)
        if isempty(strfind(tline,'Correlation_distance_coefPlot\DisNCData.mat;'))
            tline = fgetl(Passfid);
            continue;
        end
        PassDatapath = strrep(tline,'Correlation_distance_coefPlot\DisNCData.mat;','GrWise_NC_data\PassGrwiseDatasave.mat');
        PassDataStrc = load(PassDatapath);
        PassLeftNCAll = [PassLeftNCAll;PassDataStrc.PassLeftNCVec];
        PassRightNCAll = [PassRightNCAll;PassDataStrc.PassRightVec];
        PassBetNCAll = [PassBetNCAll;PassDataStrc.PassBetNCVec];
        PassNosRespNCAll = [PassNosRespNCAll;PassDataStrc.PassNosRespNCVec];
        PassNosRespBetSigAll = [PassNosRespBetSigAll;PassDataStrc.PassNosRespBetSigNC];
        tline = fgetl(Passfid);
    end
end

%% save passive summary data
savedir = uigetdir(pwd,'Please select the passive summary data save path');
cd(savedir);
save PassDataSummary.mat PassLeftNCAll PassRightNCAll PassBetNCAll PassNosRespNCAll PassNosRespBetSigAll -v7.3

%% compare plot between passive and task data
clear
clc
[fn,fp,fi] = uigetfile('*.mat','Please select the task data savage file');
TaskDataSum = load(fullfile(fp,fn));
[fn,fp,fi] = uigetfile('*.mat','Please select the passive data savage file');
PassDataSum = load(fullfile(fp,fn));
%%
TaskMeanAll = [mean([TaskDataSum.LeftROINCall;TaskDataSum.RightROINCall]),mean(TaskDataSum.BetLRROINCall),mean(TaskDataSum.NoiseRespNCAll),...
    mean(TaskDataSum.NosRespSigNCall)];
PassMeanAll = [mean([PassDataSum.PassLeftNCAll;PassDataSum.PassRightNCAll]),mean(PassDataSum.PassBetNCAll),mean(PassDataSum.PassNosRespNCAll),...
    mean(PassDataSum.PassNosRespBetSigAll)];
habr = figure('position',[250 300 900 600]);
hold on;
bar([0.8,1.8,2.8,3.8],TaskMeanAll,0.4,'FaceColor','k','EdgeColor','none');
bar([1.2,2.2,3.2,4.2],PassMeanAll,0.4,'FaceColor',[.7 .7 .7],'EdgeColor','none');
text([0.8,1.8,2.8,3.8],TaskMeanAll*1.05,cellstr(num2str(TaskMeanAll(:),'%.3f')),'FontSize',12,'HorizontalAlignment','center');
text([1.2,2.2,3.2,4.2],PassMeanAll*1.05,cellstr(num2str(PassMeanAll(:),'%.3f')),'FontSize',12,'HorizontalAlignment','center','color',[.5 .5 .5]);
set(gca,'xtick',[1,2,3,4],'xticklabel',{'Win','Bet','NonSelc','Non2Sig'});
xlabel('Group');
ylabel('Noise correlation');
title('Task(k) and passive(gray) NC comparison');
set(gca,'FontSize',16);
p_Win_TaskPass = ranksum([TaskDataSum.LeftROINCall;TaskDataSum.RightROINCall],[PassDataSum.PassLeftNCAll;PassDataSum.PassRightNCAll]);
p_Bet_TaskPass = ranksum(TaskDataSum.BetLRROINCall,PassDataSum.PassBetNCAll);
p_NonResp_TaskPass = ranksum(TaskDataSum.NoiseRespNCAll,PassDataSum.PassNosRespNCAll);
p_NonR2Sig = ranksum(PassDataSum.PassNosRespBetSigAll,TaskDataSum.NosRespSigNCall);
hbarf = GroupSigIndication([0.8,1.2],[TaskMeanAll(1),PassMeanAll(1)],p_Win_TaskPass,habr,[],0.3);
hbarf = GroupSigIndication([1.8,2.2],[TaskMeanAll(2),PassMeanAll(2)],p_Bet_TaskPass,hbarf,1.2);
hbarf = GroupSigIndication([2.8,3.2],[TaskMeanAll(3),PassMeanAll(3)],p_NonResp_TaskPass,hbarf,1.2);
hbarf = GroupSigIndication([3.8,4.2],[TaskMeanAll(4),PassMeanAll(4)],p_NonR2Sig,hbarf,1.2);
saveas(hbarf,'Task and passive compare plot');
saveas(hbarf,'Task and passive compare plot','png');
saveas(hbarf,'Task and passive compare plot','pdf');
close(hbarf);