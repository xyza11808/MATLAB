function post_ROI_calculation
%this script is used for post analysis of ROI analysis result, need the
%result mat file of TIFF figure analysis

dbstop if error % stop if error occurs

clc;
type=input('please input the analysis type.\nRF for receptive field analysis and 2AFC for behavior data analysis.\n','s');

if (strcmpi(type,'RF')||strcmpi(type,'2AFC'))==0
    warning('Wrong analysis type input. quit analysis...');
    return;
end
  
%%
%load ROI analysis result
disp(['please input the ',type,' ROIs analysis result file path.\n']);
[filename,SessPath,Findex]=uigetfile('*.mat','Select your 2p analysis storage data','MultiSelect','on');
if ~Findex
    disp('Quit analysis...\n');
    return;
end
cd(SessPath);
% files=dir('*.mat');
for i=1:length(filename)
    RealFileName=filename{i};
    x=load(RealFileName);
    if (isfield(x,'CaTrials') || isfield(x,'CaSignal'))
%     if strncmp(RealFileName,'CaTrials',8)
        export_filename_raw=RealFileName(1:end-4);
        fieldN=fieldnames(x);
        CaTrials=x.(fieldN{1});
        SimpleDataStore=0;
%     elseif strncmp(RealFileName,'CaSignal',8)
%         export_filename_raw=RealFileName(1:end-4);
    end
    if isfield(x,'SavedCaTrials')
        export_filename_raw=RealFileName(1:end-4);
        fieldN=fieldnames(x);
        CaTrials=x.(fieldN{1});
        SimpleDataStore=1;
    end
    if isfield(x,'ROIinfo')
        ROIinfo=x.ROIinfo;
        SimpleROIinfo=0;
    elseif isfield(x,'ROIinfoBU')
        ROIinfo=x.ROIinfoBU;
        SimpleROIinfo=1;
    end
    
    disp(['loading file ',RealFileName,'...']);
end
Ca_string=whos('CaTri*');
eval(['CaSignal_',type,'=',Ca_string.name,';']);
if exist('cSessionExcludeInds.mat','file')
    fprintf('Trial inds excluded from analysis exists, loading as trial excluded files.\n');
    xx = load('cSessionExcludeInds.mat');
    TrExcludedInds = xx.ExcludedTrInds;
    fprintf('Totally Number of %d trials excluded from analsis.\n',sum(TrExcludedInds));
else
    TrExcludedInds = [];
end

% %exclude error trials from whole behavior data
% exclude_trials = input('please inut the trials needed to be excluded.Seperated by '',''\n','s');
% exclude_trials=strrep(exclude_trials,' ',',');
% exclude_inds = str2num(exclude_trials);

%should be the name of result containing file
if SimpleDataStore
    trial_num=CaTrials.TrialNum;
else
    trial_num=length(CaTrials);
end

frame_rate=floor(1000/CaTrials(1).FrameTime);
nROIs=CaTrials(1).nROIs;
if ~iscell(CaTrials(1).f_raw)
    nFrames=CaTrials(1).nFrames;
    TimeLen = ceil(nFrames/frame_rate);
else
    nTrFrames = cellfun(@(x) size(x,2),CaTrials(1).f_raw);
    nFrames = prctile(nTrFrames,80);
    TimeLen = ceil(nFrames/frame_rate);
end
% ROI_frame_size=size(CaTrials(1).f_raw);
result_size=[trial_num,nROIs,nFrames];  % this should be a three elements vector indicates the length of three dimensions
%this place should be modified
session_date=CaTrials(1).FileName_prefix(:);

if strcmpi(type,'rf')
    triger_time=input('please input the triger time before sound stimulus deliverying, with default value is 1s.\n');
    if isempty(triger_time)
        triger_time=1;
    end
    triger_inds=floor(triger_time*frame_rate);
else
    disp('please select the full data path for behavior file(*.beh) analysis result.\n');
    [fn2,file_path2]=uigetfile('*.*');
    filefullpath2=[file_path2,filesep,fn2];  %this can be achieved by the  fullfile function
    if ~exist(filefullpath2,'file')
        error('wrong file path for behavior result!');
    end
    load(filefullpath2);
    if ~(strcmpi(file_path2,pwd) || strcmpi(file_path2(1:end-1),pwd)) % exclude the last \ character
        copyfile(filefullpath2,pwd);
    end
    if exist('behavResults','var') && exist('behavSettings','var')
        [UserChoice,sessiontype]=behavScore_prob(behavResults,behavSettings,fn2,1);  %plot the animal behavior trace for select session
    elseif exist('SessionResults','var') && exist('SessionSettings','var')
        [behavResults,behavSettings] = behav_cell2struct(SessionResults,SessionSettings);
        [UserChoice,sessiontype]=behavScore_prob(behavResults,behavSettings,fn2,1);  %plot the animal behavior trace for select session
    else
       UserChoice = 1;
    end
    if min(behavResults.Time_stimOnset) < 100
        BugStimOnInds = (behavResults.Time_stimOnset) < 100;
        if isfield(behavResults,'Setted_TimeOnset')
            behavResults.Time_stimOnset(BugStimOnInds) = behavResults.Setted_TimeOnset(BugStimOnInds)+1;
        else
            error('Behavior data have bad stimulus onset time records, please check the raw data.\n');
        end
    end
    cpath = pwd;
    try
        BehavLickPlot(behavResults,behavSettings,TimeLen);
    catch 
        warning('Unable to plot the lick rate for now');
        cd(cpath);
    end
    if UserChoice
        return;
    end
    stim_onset_time=behavResults.Time_stimOnset;
    stim_onset_frame=floor((double(stim_onset_time)/1000)*frame_rate);
%     stim_onset_frame(exclude_inds)=[];
end


% %######################################################################
% %exclude ROIs with significantly uneven fo distribution
% excluded_ROIs = input('please inut the ROIs needed to be excluded.Seperated by '',''\n','s');
% exclude_Rois=strrep(excluded_ROIs,' ',',');
% exclude_RoIs = str2num(exclude_Rois);
% if ~isempty(exclude_RoIs)
%     f_percent_change(:,exclude_RoIs,:)=[];
%     f_baseline_change(:,exclude_RoIs,:)=[];
%     save exslude_ROInds.mat exclude_RoIs -v7.3;
%     ROI_position_stru=ROIinfo(1);
%     ROI_position_stru.ROImask(exclude_RoIs)=[];
%     ROI_position_stru.ROIpos(exclude_RoIs)=[];
%     ROI_position_stru.ROItype(exclude_RoIs)=[];
%     ROI_position_stru.ROI_def_trialNo(exclude_RoIs)=[];
%     save New_ROIinfos.mat ROI_position_stru -v7.3;
% end
% 

%plot the percent result
%temp_f_percent=zeros(size_raw_trials(1),size_raw_trials(3));
SessfilePath = pwd;
if isdir('./plot_save/')==0
    mkdir('./plot_save/');
end
cd('./plot_save/');

if strcmpi(type,'RF')
    [f_raw_trials,f_percent_change,exclude_inds]=FluoChangeCa2NPl(CaTrials,[],[],2,type,ROIinfo,TrExcludedInds);
    if iscell(f_percent_change)  % if continued-acquisition session
        FrameLen = cellfun(@(x) size(x,2),f_percent_change);
        UsedLen = min(FrameLen);
        CutData = zeros(length(FrameLen),size(f_percent_change{1},1),UsedLen);
        for cTr = 1 : length(FrameLen)
            CutData(cTr,:,:) = f_percent_change{cTr}(:,1:UsedLen);
        end
        f_percent_change = CutData;
        result_size = size(CutData);
    end
    NoiseRFStd=NoiseExtraction(f_percent_change);
    save ROINoise.mat NoiseRFStd -v7.3
%     %ROI response towards given sounds
%     Sound_response_check(f_percent_change,triger_time,frame_rate)

%     %load sound stimulus file
%     RF_choice=input('Would you like to continue with RF analysis?\n','s');
%     if ~strcmpi(RF_choice,'y')
%         disp('Do not performing following RF analysis, quitting...');
%         return;
%     end
    disp('please input the RF stimulus file position.\n');
    [fn,fn_path]=uigetfile('*.*');
    if ~(strcmpi(fn_path,SessfilePath) || strcmpi(fn_path(1:end-1),SessfilePath)) % exclude the last \ character
        copyfile(fullfile(fn_path,fn),SessfilePath);
    end
    sound_array=textread([fn_path,'/',fn]);
    sound_array(exclude_inds,:)=[];
    size_raw_trials=size(f_percent_change);
    if exist(fullfile(SessPath,'SessionFrameProj.mat'),'file')
        Image2P_ROIlabeling_Infun
    end
%     ROI_insite_label(ROIinfo(1));
    %     in_site_freTuning(sound_array,type,CaTrials,'simple_fit');
    %this should be two columns num, the first column contains frequency and
    %the second contains corresponded intensity
    DB_array=unique(sound_array(:,2));
    FreqArray = unique(sound_array(:,1));
    size_freq = length(FreqArray);
    size_DB=length(DB_array);
    if mod(result_size(1),(size_DB*size_freq))
       fprintf('Trial number cannot be fully divided by freqIntensity product, saved in cell format.\n');
       IsFullyDived = 0;
    else
        IsFullyDived = 1;
        freq_rep_times=result_size(1)/(size_DB*size_freq);
        re_organized_data=zeros(size_DB,freq_rep_times*size_freq,result_size(3));
        StimRespMeanData = zeros(size_raw_trials(2),size_DB,size_freq,result_size(3));
        StimRespAllData = zeros(size_raw_trials(2),size_DB,size_freq,freq_rep_times,result_size(3));
        RF_fit_data=struct('AvaFitPara',[]);
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extract data for 2afc comparation
    SelectDb = 70;
    SelectInds = sound_array(:,2) >= SelectDb;
    SelectData = f_percent_change(SelectInds,:,:);
    SelectSArray = sound_array(SelectInds,1);
    PassOutcome = ones(length(SelectSArray),1);
    save rfSelectDataSet.mat SelectData SelectSArray frame_rate SelectInds f_percent_change sound_array -v7.3
    SoundFreqs = double(sound_array(:,1) > 16000);
    SessionBoundary = FreqArray(ceil(length(FreqArray)/2));
    TrialTypes = SelectSArray > SessionBoundary;
    Passive_factroAna_scripts
%%
    DataAnaObj = DataAnalysisSum(SelectData,SelectSArray,frame_rate,frame_rate,1);
%     DataAnaObj.PairedAUCCal(1.5,'Max');
    DataAnaObj.popuZscoredCorr(1.5,'Mean'); % first response peak response noise correlation
%     DataAnaObj.popuZscoredCorr([1.5,3],'Mean'); % second response preak noise correlation
%     DataAnaObj.popuSignalCorr(1,'Mean',1);  % bootstrap method signal correlation
%     DataAnaObj.popuSignalCorr(1,'Mean'); % normal method of signal correlation
    %%
    
%     TimeCourseStrcSP = TimeCorseROC(SelectData,TrialTypes,frame_rate,frame_rate,[],2,0); 
%      ROIAUCcolorp(TimeCourseStrcSP,1);
    
     %parameter struc
    V.Ncells = 1;
    
    V.T = size(f_percent_change,3);
    V.Npixels = 1;
    V.dt = 1/frame_rate;
    P.lam = 10;
    P.gam = 1 - V.dt/3; % Tau = 3, decay time for calcium event 
     nnspike = DataFluo2Spike(SelectData,V,P); % estimated spike
     if ~isdir('./SpikeData_analysis/')
         mkdir('./SpikeData_analysis/');
     end
     cd('./SpikeData_analysis/');
     save EsSpikeSave.mat nnspike SelectSArray frame_rate SelectInds SelectData -v7.3
     %
     DataSPObj = DataAnalysisSum(nnspike,SelectSArray,frame_rate,frame_rate,1);
     DataSPObj.popuZscoredCorr(0.5,'Mean'); % first response peak response noise correlation
     DataSPObj.popuSignalCorr(1,'Mean'); % normal method of signal correlation
     cd ..
%      UnevenRFrespPlot(f_percent_change,sound_array(:,2),sound_array(:,1),frame_rate);  % performing color plot
     %%
     TimeCourseStrcSipke = TimeCorseROC(nnspike,TrialTypes,frame_rate,frame_rate,[],2,0); 
     ROIAUCcolorp(TimeCourseStrcSipke,1);
     MultiTimeWinClass(nnspike,SelectSArray,PassOutcome,frame_rate,frame_rate,1,0.1);
     
     cd ..;
     
     %%
     ROC_check(f_percent_change,SoundFreqs,frame_rate,frame_rate,1.5,'Stim_time_Align');
     ROC_check(SelectData,SelectSArray>16000,frame_rate,frame_rate,1.5,'Stim_time_Align_select');
      %%
     RF2afcClassScorePlot(SelectData,SelectSArray,16000,frame_rate,frame_rate,1.5,1);
     FreqRespCallFun(SelectData,SelectSArray,ones(sum(SelectInds),1),2,{1},frame_rate,frame_rate);
     MultiTimeWinClass(SelectData,SelectSArray,PassOutcome,frame_rate,frame_rate,1,0.1);
     RFTaskclf_accuracy_plot
     
     %%
%     FreqRespCallFun(f_percent_change(SelectInds,:,:),sound_array(SelectInds,1),ones(sum(SelectInds),1),2,{1},frame_rate,frame_rate,1);
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %RF resp neuron test
%     TrialFreq = sound_array(:,1);
%     StimOnFrame = frame_rate;
%     ConsiderScale = frame_rate;
%     rfRespInds = RF_resp_check(f_percent_change,TrialFreq,StimOnFrame,ConsiderScale);
%     ResprfInds = sum(rfRespInds,2) > 0;
%     save RFRespInds.mat ResprfInds -v7.3
%     in_site_freTuning_update(f_percent_change,sound_array,export_filename_raw,frame_rate,'simple_fit',CaTrials);
    
 %% 
    if isdir('./v_shape_plot/')==0
        mkdir('./v_shape_plot/');
    end
    cd('./v_shape_plot/');
    %     in_site_freTuning(sound_array,type,CaTrials,'simple_fit');
%     in_site_freTuning_update(f_percent_change,sound_array,export_filename_raw,frame_rate,'simple_fit',CaTrials);
    [~,VSDataStrc] = in_site_freTuning_update(f_percent_change,sound_array,export_filename_raw,frame_rate,'simple_fit',CaTrials,0);
   
%     in_site_freTuning(sound_array,type,CaTrials,'simple_fit',triger_inds);
    %      ROI_CF=in_site_freTuning(sound_Stim,type,'fit');
    cd ..;
    
    %%
%     if ~IsFullyDived
        % if the total trial number can not be fully divided by freq and
        % intensity product, using extra plot
        RFTunData = NewVshapePlot(f_percent_change,sound_array,frame_rate,frame_rate);
        save RFtunDataSave.mat RFTunData -v7.3
        %%
        UnevenRFrespPlot(f_percent_change,sound_array,frame_rate);  % performing color plot
        PassRespPlot(f_percent_change,sound_array(:,2),sound_array(:,1),frame_rate);
%         UnevenRFrespPlot(f_percent_change,sound_array(:,2),sound_array(:,1),frame_rate,[],0); % not performing color plot
%     end
    %%
    %#########################################################################
    %start of mode percent change plot
    %#########################################################################
    if ~isdir('./ROI_color+plot')
        mkdir('./ROI_color+plot');
    end
    cd('./ROI_color+plot');
    AllRFPeak = zeros(size_raw_trials(2),size_DB,length(FreqArray));
    AllRFMean = zeros(size_raw_trials(2),size_DB,length(FreqArray),size_raw_trials(3));
    for i=1:size_raw_trials(2)
        temp_f_percent=squeeze(f_percent_change(:,i,:));
        if (sum(temp_f_percent(:))==0) || (sum(isnan(temp_f_percent(:)))~=0)
            f_percent_change(:,i,:)=[];
            f_raw_trials(:,i,:)=[];
            continue;
        end
        %size(temp_f_percent);
        %size of temp_f_percent
        %the temp_f_percent now should be a two dimension matrix with rows
        %number euqals tiral number and columns number equals frames number
        %for a customized way, this function can be performed as:
        %for j=1:size_raw_trials(1)
        %  temp_f_percent(i,:)=f_percent_change(j,i,:);
        %end
        
        %sort trial result with sound stimulus result
        for j=1:size_DB
            temp_inds = sound_array(:,2)==DB_array(j);
            temp_f_percent_DB = temp_f_percent(temp_inds,:);
            [FreqValue,I]=sort(sound_array(temp_inds,1));
            temp_f_percent_sort=temp_f_percent_DB(I,:);
            re_organized_data(j,:,:)=temp_f_percent_sort;
            for nFreqTe = 1 : length(FreqArray)
                cFreqValue = FreqArray(nFreqTe);
                cFreqData = temp_f_percent_sort(FreqValue == cFreqValue,:);
                StimRespAllData(i,j,nFreqTe,:,:) = cFreqData;
                StimRespMeanData(i,j,nFreqTe,:) = mean(cFreqData);
            end
                
        end
        triger_position=floor(triger_time*frame_rate);
        %use unique() function to delete the repeated numbers inside vectory
        if ~isdir('./MeanTrace_Plot/')
            mkdir('./MeanTrace_Plot/');
        end
        cd('./MeanTrace_Plot/');
        [PeakResp,fMeanData]=RFDAtaPlot(re_organized_data,FreqArray,triger_position,frame_rate);
        AllRFPeak(i,:,:) = PeakResp;
        AllRFMean(i,:,:,:) = fMeanData;
        cd ..;
        
        yTick_lable=unique(sound_array(:,1));
        yTick_lable=yTick_lable/1000;
        %     length(yTick_lable)
        Tick_step=size_raw_trials(1)/length(yTick_lable);
        ytick=Tick_step:Tick_step:size_raw_trials(1);
        ytick_sort_step=Tick_step/size_DB;
        ytick_sort_tick=ytick_sort_step:ytick_sort_step:(size_raw_trials(1)/size_DB);
        xtick=frame_rate:frame_rate:size_raw_trials(3);
        xTick_lable=1:floor(size_raw_trials(3)/frame_rate);
        
        total_plot_index=1:3:(size_DB*3-1);
        h=figure;
        set(gcf,'position',[303 150 1000 700]);
        %         clims=[0 300];
        clims=[max([0,min(temp_f_percent(:))]),max(temp_f_percent(:))];
        subplot(size_DB,3,total_plot_index);
        if sum(isnan(clims))~=0
            imagesc(temp_f_percent);
        else
            imagesc(temp_f_percent,clims);
        end
        title('Before sorted','FontSize',20);
        xlabel('time(s)');
        set(gca,'XTick',xtick);
        set(gca,'XTickLabel',xTick_lable);
        hold on;
        hh1=axis;
%         triger_position=triger_time*frame_rate;
        plot([triger_position,triger_position],[hh1(3),hh1(4)],'color','y','LineWidth',2);
        hold off;
        
        h2=colorbar('location','WestOutside');
        position=get(h2,'position');
        position_shift=position.*[0.35,1,0.3,1];
        set(h2,'position',position_shift);
        for j=1:size_DB
            subplot(size_DB,3,j*3-1);
            imagesc(squeeze(re_organized_data(j,:,:)),clims);
            
            if j==size_DB
                xlabel('time(s)');
            end
            set(gca,'XTick',xtick);
            set(gca,'XTickLabel',xTick_lable);
            set(gca,'YTick',ytick_sort_tick);
            set(gca,'YTickLabel',cellstr(num2str(yTick_lable(:),'%.1f')),'FontSize',6);
            ylabel('Freq(KHz)');
            title(['After sorted---',num2str(DB_array(j)),'DB'],'FontSize',15);
            hold on;
            hh2=axis;
%             triger_position=triger_time*frame_rate;
            plot([triger_position,triger_position],[hh2(3),hh2(4)],'color','y','LineWidth',2);
            hold off;
            
            
            subplot(size_DB,3,j*3);
            temp_data=squeeze(re_organized_data(j,:,:));%two dimensional matrix, with rows in frequency and column in frames
            freq_response=mean(temp_data);
            plot(1:size_raw_trials(3),freq_response,'color','g','LineWidth',0.8);
            hold on;
            title(['After sorted---',num2str(DB_array(j)),'DB'],'FontSize',15);
            %             xlabel('Time(s)');
            smooth_freq_response=smooth(freq_response);
            freq_gaussian_fit = fit((1:size_raw_trials(3))',smooth_freq_response,'gauss4');
            plot(freq_gaussian_fit,1:size_raw_trials(3),smooth_freq_response);
            if j==size_DB
                xlabel('time(s)');
            end
            set(gca,'XTick',xtick);
            set(gca,'XTickLabel',xTick_lable);
            ylabel('\DeltaF/F_0');
            legend('off');
            RF_fit_data(i).AvaFitPara(j,:) = [freq_gaussian_fit.a1,freq_gaussian_fit.b1,freq_gaussian_fit.c1,freq_gaussian_fit.a2,freq_gaussian_fit.b2,freq_gaussian_fit.c2,...
                freq_gaussian_fit.a3,freq_gaussian_fit.b3,freq_gaussian_fit.c3,freq_gaussian_fit.a4,freq_gaussian_fit.b4,freq_gaussian_fit.c4];
            hh3=axis;
%             triger_position=triger_time*frame_rate;
            plot([triger_position,triger_position],[hh3(3),hh3(4)],'color','y','LineWidth',2);
            hold off;
            
        end
        
        filename=['ROI',num2str(i)];
        export_filename = [export_filename_raw filename];
        %set(gcf,'title',filename);
        suptitle(filename);
        saveas(h,export_filename,'png');
        saveas(h,export_filename,'fig');
        %print(h,'-dbitmap',export_filename);
        %imwrite(h,[export_filename '.png'],'png')
        close;
        %     [sort_stimulus,Index]=sortrows(sound_array,[1 2]);
        %     sort_temp_f_percent=temp_f_percent(Index,:);
        %################################
        %maybe at this place should added with a total ava plot of ROI response
        %to sound
        total_mean_trace=mean(temp_f_percent);
        h_total_mean=figure;
        hold on;
        plot(1:size_raw_trials(3),total_mean_trace,'color','g','LineWidth',0.8);
        xlabel('time(s)');
        set(gca,'XTick',xtick);
        set(gca,'XTickLabel',xTick_lable);
        ylabel('\DeltaF/F_0');
        xlabel('Time(s)');
        
        smooth_total_trace=smooth(total_mean_trace);
        freq_gaussian_fit = fit((1:size_raw_trials(3))',smooth_total_trace,'gauss3');
        plot(freq_gaussian_fit,1:size_raw_trials(3),smooth_total_trace);
        hh4=axis;
%         triger_position=triger_time*frame_rate;
        plot([triger_position,triger_position],[hh4(3),hh4(4)],'color','y','LineWidth',2);
        hold off;
        saveas(h_total_mean,[export_filename_raw 'ROI' num2str(i) '_TotalMean'],'png');
        saveas(h_total_mean,[export_filename_raw 'ROI' num2str(i) '_TotalMean'],'fig');
        close(h_total_mean);
    end
    save RFsummaryData.mat AllRFPeak AllRFMean -v7.3
    save gaussian_fit_para.mat RF_fit_data -v7.3
    save AllRespDat.mat StimRespAllData StimRespMeanData -v7.3
    cd ..;
    %#########################################################################
    %end of mode percent change plot
    %#########################################################################
    %%
    % calculate the signal and noise correlation between ROIs
    % reshape the high dimensional data into low dimensional data, but
    % first should change the last dimension into column dimension so that
    % the trials will be connected one by one
    
    % calculate the signal correlations
    ShiftData = permute(StimRespMeanData,[1,4,2,3]); % into column-wise order
    ReshapedData = reshape(ShiftData,size_raw_trials(2),[]); % ROI by all
    SigCorrMatrix = corrcoef(ReshapedData');
    SigCoCoefSum = sum(SigCorrMatrix);
    [~,SigInds] = sort(SigCoCoefSum);
    h_sigCorr = figure;
    imagesc(SigCorrMatrix(SigInds,SigInds));
    colormap jet
    title('Signal correlation matrix');
    xlabel('# ROIs');
    ylabel('# ROIs');
    set(gca,'FontSize',20);
    colorbar;
    saveas(h_sigCorr,'Signal Correlation RF data');
    saveas(h_sigCorr,'Signal Correlation RF data','png');
    close(h_sigCorr);
    CoefValue = triu(SigCorrMatrix,1);
    INDS = [size_raw_trials(2),size_raw_trials(2)];
    TargetInds = find(CoefValue > 0.6 | CoefValue < -0.3);
    TargetIndsValue = SigCorrMatrix(TargetInds);
    [LargeRespValueX,LargeRespValueY] = ind2sub(INDS,TargetInds);
    SigRespROIpairs = [LargeRespValueX,LargeRespValueY,TargetIndsValue];
    
    % calculate the noise correlations
    ShiftDataNC = permute(StimRespAllData,[1,5,2,3,4]);
    ReshapedDataNC = reshape(ShiftDataNC,size_raw_trials(2),[]);
    NoiCorrMatrix = corrcoef(ReshapedDataNC');
    NoiCorrcoefSum = sum(NoiCorrMatrix);
    [~,Inds] = sort(NoiCorrcoefSum);
    h_NoiCorr = figure;
    imagesc(NoiCorrMatrix(Inds,Inds));
    colormap jet
    colorbar;
    title('Noise correlation matrix');
    xlabel('# ROIs');
    ylabel('# ROIs');
    set(gca,'FontSize',20);
    saveas(h_NoiCorr,'Noise correlation RF data');
    saveas(h_NoiCorr,'Noise correlation RF data','png');
    close(h_NoiCorr);
    CoefValue = triu(NoiCorrMatrix,1);
    INDS = [size_raw_trials(2),size_raw_trials(2)];
    TargetInds = find(CoefValue > 0.6 | CoefValue < -0.3);
    TargetIndsValue = NoiCorrMatrix(TargetInds);
    [LargeRespValueX,LargeRespValueY] = ind2sub(INDS,TargetInds);
    NoiRespROIpairs = [LargeRespValueX,LargeRespValueY,TargetIndsValue];
    
    h_hist = figure;
    h1 = histogram(SigRespROIpairs(:,3),30,'FaceColor','r');
    hold on;
    h2 = histogram(NoiRespROIpairs(:,3),30,'FaceColor','b');
    h1.Normalization = 'probability';
    h2.Normalization = 'probability';
    legend('Signal corrcoef','Noise corrcoef','position','northeastoutside');
    xlabel('Corr Coef');
    ylabel('ROI fraction');
    title('Paired ROI corrcoef distribution (part)');
    set(gca,'FontSize',15);
    saveas(h_hist,'Target ROI pairs Corrcoef distribution');
    saveas(h_hist,'Target ROI pairs Corrcoef distribution','png');
    close(h_hist);
    
    save CorrMatrixData.mat SigCorrMatrix NoiCorrMatrix SigInds Inds SigRespROIpairs NoiRespROIpairs -v7.3
    
    %%
    ContChoice=questdlg('Do you wants to try with fluo change based on time before stim onset?','Select your choice',...
        'Yes','No','Yes');
    switch ContChoice
        case 'Yes'
            [f_raw_trials,f_percent_change,exclude_inds]=FluoChangeCa2NPl(CaTrials,behavResults,behavSettings,2,type,ROIinfo,TrExcludedInds);
            %#########################################################################
            %start of baseline percent change plot
            %#########################################################################
            if ~isdir('./baseline_plot_save/')
                mkdir('./baseline_plot_save/')
            end
            cd('./baseline_plot_save/');
            RF_fit_data=struct('AvaFitPara',[]);
            for i=1:size_raw_trials(2)
                temp_f_percent=squeeze(f_baseline_change(:,i,:));
                if (sum(temp_f_percent)==0) || (sum(isnan(temp_f_percent))~=0)
                    f_raw_trials(:,i,:)=[];
                    continue;
                end
                %size(temp_f_percent);
                %size of temp_f_percent
                %the temp_f_percent now should be a two dimension matrix with rows
                %number euqals tiral number and columns number equals frames number
                %for a customized way, this function can be performed as:
                %for j=1:size_raw_trials(1)
                %  temp_f_percent(i,:)=f_percent_change(j,i,:);
                %end

                %sort trial result with sound stimulus result
                for j=1:size_DB
                    temp_inds = sound_array(:,2)==DB_array(j);
                    temp_f_percent_DB = temp_f_percent(temp_inds,:);
                    [~,I]=sort(sound_array(temp_inds,1));
                    temp_f_percent_sort=temp_f_percent_DB(I,:);
                    re_organized_data(j,:,:)=temp_f_percent_sort;
                end

                %use unique() function to delete the repeated numbers inside vectory

                yTick_lable=unique(sound_array(:,1));
                yTick_lable=yTick_lable/1000;
                %     length(yTick_lable)
                Tick_step=size_raw_trials(1)/length(yTick_lable);
                ytick=Tick_step:Tick_step:size_raw_trials(1);
                ytick_sort_step=Tick_step/size_DB;
                ytick_sort_tick=ytick_sort_step:ytick_sort_step:(size_raw_trials(1)/size_DB);
                xtick=frame_rate:frame_rate:size_raw_trials(3);
                xTick_lable=1:floor(size_raw_trials(3)/frame_rate);

                total_plot_index=1:3:(size_DB*3-1);
                h=figure;
                set(gcf,'position',[303 150 1000 700]);
                %         clims=[0 300];
                clims=[min(temp_f_percent(:)),max(temp_f_percent(:))];
                subplot(size_DB,3,total_plot_index);
                if sum(isnan(clims))~=0
                    imagesc(temp_f_percent);
                else
                    imagesc(temp_f_percent,clims);
                end
                title('Before sorted');
                xlabel('time(s)');
                set(gca,'XTick',xtick);
                set(gca,'XTickLabel',xTick_lable);
                hold on;
                hh1=axis;
%                 triger_position=triger_time*frame_rate;
                plot([triger_position,triger_position],[hh1(3),hh1(4)],'color','y','LineWidth',2);
                hold off;

                h2=colorbar('location','WestOutside');
                position=get(h2,'position');
                position_shift=position.*[0.35,1,0.3,1];
                set(h2,'position',position_shift);
                for j=1:size_DB
                    subplot(size_DB,3,j*3-1);
                    imagesc(squeeze(re_organized_data(j,:,:)),clims);
                    title(['After sorted---',num2str(DB_array(j)),'DB']);
                    if j==size_DB
                        xlabel('time(s)');
                    end
                    set(gca,'XTick',xtick);
                    set(gca,'XTickLabel',xTick_lable);
                    set(gca,'YTick',ytick_sort_tick);
                    set(gca,'YTickLabel',cellstr(num2str(yTick_lable(:),'%.1f')),'FontSize',6);
                    ylabel('Freq(KHz)');
                    hold on;
                    hh2=axis;
%                     triger_position=triger_time*frame_rate;
                    plot([triger_position,triger_position],[hh2(3),hh2(4)],'color','y','LineWidth',2);
                    hold off;


                    subplot(size_DB,3,j*3);
                    temp_data=squeeze(re_organized_data(j,:,:));%two dimensional matrix, with rows in frequency and column in frames
                    freq_response=mean(temp_data);
                    plot(1:size_raw_trials(3),freq_response,'color','g','LineWidth',0.8);
                    hold on;
                    title(['After sorted---',num2str(DB_array(j)),'DB']);
                    %             xlabel('Time(s)');
                    smooth_freq_response=smooth(freq_response);
                    freq_gaussian_fit = fit((1:size_raw_trials(3))',smooth_freq_response,'gauss4');
                    plot(freq_gaussian_fit,1:size_raw_trials(3),smooth_freq_response);
                    if j==size_DB
                        xlabel('time(s)');
                    end
                    set(gca,'XTick',xtick);
                    set(gca,'XTickLabel',xTick_lable);
                    ylabel('\DeltaF/F_0');
                    legend('off');
                    RF_fit_data(i).AvaFitPara(j,:) = [freq_gaussian_fit.a1,freq_gaussian_fit.b1,freq_gaussian_fit.c1,freq_gaussian_fit.a2,freq_gaussian_fit.b2,freq_gaussian_fit.c2,...
                        freq_gaussian_fit.a3,freq_gaussian_fit.b3,freq_gaussian_fit.c3,freq_gaussian_fit.a4,freq_gaussian_fit.b4,freq_gaussian_fit.c4];
                    hh3=axis;
%                     triger_position=triger_time*frame_rate;
                    plot([triger_position,triger_position],[hh3(3),hh3(4)],'color','y','LineWidth',2);
                    hold off;

                end

                filename=['ROI',num2str(i)];
                export_filename = [export_filename_raw filename];
                %set(gcf,'title',filename);
                suptitle(filename);
                saveas(h,export_filename,'png');
                saveas(h,export_filename,'fig');
                %print(h,'-dbitmap',export_filename);
                %imwrite(h,[export_filename '.png'],'png')
                close;
                %     [sort_stimulus,Index]=sortrows(sound_array,[1 2]);
                %     sort_temp_f_percent=temp_f_percent(Index,:);
                %################################
                %maybe at this place should added with a total ava plot of ROI response
                %to sound
                total_mean_trace=mean(temp_f_percent);
                h_total_mean=figure;
                plot(1:size_raw_trials(3),total_mean_trace,'color','g','LineWidth',0.8);
                xlabel('time(s)');
                set(gca,'XTick',xtick);
                set(gca,'XTickLabel',xTick_lable);
                ylabel('\DeltaF/F_0');
                xlabel('Time(s)');
                hold on;
                smooth_total_trace=smooth(total_mean_trace);
                freq_gaussian_fit = fit((1:size_raw_trials(3))',smooth_total_trace,'gauss3');
                plot(freq_gaussian_fit,1:size_raw_trials(3),smooth_total_trace);
                hh4=axis;
%                 triger_position=triger_time*frame_rate;
                plot([triger_position,triger_position],[hh4(3),hh4(4)],'color','y','LineWidth',2);
                hold off;
                saveas(h_total_mean,[export_filename_raw 'ROI' num2str(i) '_TotalMean'],'png');
                saveas(h_total_mean,[export_filename_raw 'ROI' num2str(i) '_TotalMean'],'fig');
                close;
            end

            save gaussian_fit_para.mat RF_fit_data -v7.3
            cd ..;
        case 'No'
            disp('Quit baseline based fluo change calculation.\n');
    end
    
    %#########################################################################
    %end of baseline percent change plot
    %#########################################################################
    
   
    %%
elseif strcmpi(type,'2AFC')
    if exist(fullfile(SessPath,'SessionFrameProj.mat'),'file')
        Image2P_ROIlabeling_Infun;
    end
    fprintf(['Please select the f0 calculation method.\n 1 for mode f0 calculation.\n 2 for pure baseline calculation.\n 3 for block wise calculation.\n',...
        ' 4 for 8th substraction.\n 5 for mode after baseline correction.\n']);
    MethodChoice=input('Please select your choice.\n','s');
    BaselineMethod=str2double(MethodChoice);
    if isnan(BaselineMethod)
        BaselineMethod = [];
    end
    NewFoldName = sprintf('Type%d_f0_calculation',BaselineMethod);
    if ~isdir(NewFoldName)
        mkdir(NewFoldName);
    end
    cd(NewFoldName);
    [f_raw_trials,f_percent_change,exclude_inds,IsBaselineE]=FluoChangeCa2NPl(CaTrials,behavResults,behavSettings,BaselineMethod,type,ROIinfo,TrExcludedInds);
    if IsBaselineE
        fprintf('Please select your choice again without using the same background substraction method.\n');
        [f_raw_trials,f_percent_change,exclude_inds]=FluoChangeCa2NPl(CaTrials,behavResults,behavSettings,BaselineMethod,type,ROIinfo,TrExcludedInds);
    end
%     save RawMatricData.mat f_raw_trials f_percent_change -v7.3
%     cd('.\plot_save\');
    %AFC_ROI_analysis(f_percent_change,export_filename_raw)
    choice=0;
    while ~choice
        %     disp('''performing 2AFC analysis, you should do the in site ROI''s tuning analysis first.\n Go on?(y/n)\n');
        continue_char=input('Before performing 2AFC analysis, would you like to do the in site ROI''s tuning poanalysis first.\n Go on?(y/n)\n','s');
        
        if strcmpi(continue_char,'y')
            choice=1;
        elseif strcmpi(continue_char,'n')
            choice=2;
            disp('performing only population analysis for 2AFC data');
            continue;
        else
            disp('error input, try it again.\n');
        end
    end
    
    if choice==1
        cWorkingPath = pwd;
        fprintf('Loading RF ROI analysis files...\n');
        [filename,SessPath,Findex]=uigetfile('*.mat','Select your 2p analysis storage data','MultiSelect','on');
        if ~Findex
            disp('Quit analysis...\n');
            return;
        end
        cd(SessPath);
        % files=dir('*.mat');
        for i=1:length(filename)
            RealFileName=filename{i};
            x=load(RealFileName);
            if (isfield(x,'CaTrials') || isfield(x,'CaSignal'))
        %     if strncmp(RealFileName,'CaTrials',8)
                export_filename_raw=RealFileName(1:end-4);
                fieldN=fieldnames(x);
                CaTrials_RF=x.(fieldN{1});
            end
            if isfield(x,'SavedCaTrials')
                export_filename_raw=RealFileName(1:end-4);
                fieldN=fieldnames(x);
                CaTrials_RF=x.(fieldN{1});
               
            end
            if isfield(x,'ROIinfo')
                ROIinfo_RF=x.ROIinfo;
                
            elseif isfield(x,'ROIinfoBU')
                ROIinfo_RF=x.ROIinfoBU;
                
            end

            disp(['loading file ',RealFileName,'...']);
        end
        
        disp('please input the RF stimulus file position.\n');
        [fn,fn_path]=uigetfile('*.*');
        sound_Stim=textread([fn_path,filesep,fn]);
        
        [f_raw_trialsRF,f_percent_changeRF,exclude_indsRF]=FluoChangeCa2NPl(CaTrials_RF,[],[],2,'RF',ROIinfo_RF,TrExcludedInds);
        %         sound_Stim(exclude_inds,:)=[];
        [ROI_CF,VSDataStrc] = in_site_freTuning_update(f_percent_changeRF,sound_Stim,export_filename_raw,frame_rate,'simple_fit',CaTrials_RF,0);
        
        %###############################################temp_block#####################
%         disp('performing mode fluo change analysis.\n');
%         if isdir('./mode_f_change/')==0
%             mkdir('./mode_f_change/');
%         end
%         cd('./mode_f_change/');
%         AFC_ROI_analysis(f_percent_change,session_date,exclude_inds,eval(['CaSignal_',type]),ROI_CF,1,'mode',behavResults,behavSettings,sessiontype);
%         cd ..;
        cd(cWorkingPath);
        disp('performing baseline fluo change analysis.\n');
        if isdir('./mode_f_change/')==0
            mkdir('./mode_f_change/');
        end
        cd('./mode_f_change/');
        AFC_ROI_analysis(f_percent_change,session_date,exclude_inds,eval(['CaSignal_',type]),ROI_CF,1,'baseline',behavResults,behavSettings,sessiontype,VSDataStrc);
        cd ..;
    elseif choice==2
                disp('performing mode fluo change analysis.\n');
                if isdir('./mode_f_change/')==0
                    mkdir('./mode_f_change/');
                end
                cd('./mode_f_change/');
                 AFC_ROI_analysis(f_percent_change,session_date,exclude_inds,eval(['CaSignal_',type]),[],1,'mode',behavResults,behavSettings,sessiontype);
                 cd ..;
        %
%         disp('performing baseline fluo change analysis.\n');
%         if isdir('./base_f_change/')==0
%             mkdir('./base_f_change/');
%         end
%         cd('./base_f_change/');
%         AFC_ROI_analysis(f_baseline_change,session_date,exclude_inds,eval(['CaSignal_',type]),[],1,'baseline',behavResults,behavSettings,sessiontype);
%         cd ..;
    end
    
    cd ..;
    cd ..;
end
%%
% %pca analysis performed later
%
% if isdir('./pca_save/')==0
%     mkdir('./pca_save/');
% end
% cd('./pca_save/');
% ROI_pca_ana(f_raw_trials,export_filename_raw);
% cd ..;

%%
% %2AFC pca analysis
% if isdir('./2AFC_pca_save/')==0
%     mkdir('./2AFC_pca_save/');
% end
% cd('./2AFC_pca_save/');
% AFC_ROI_analysis(f_raw_trials,export_filename_raw);
% cd ..;

% %%
% %making sequence analysis of the raw data
% if isdir('./sequence_save/')==0
%     mkdir('./sequence_save/');
% end
% cd('./sequence_save/');
% ROI_sequence_ana(f_raw_trials,export_filename_raw);
% cd ..;
%



