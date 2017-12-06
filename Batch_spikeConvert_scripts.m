% batch scripts for spike data convertion
clear
clc

[Pfn,Pfp,Pfi] = uigetfile('*.txt','Please select the file contains all session paths to be analysized');
if ~Pfi
    return;
end
ErrorSessPath = {};
ErrorSessNum = 0;
ErrorSessMessage = {};
ffullpath = fullfile(Pfp,Pfn);
%
ffid = fopen(ffullpath);
tline = fgetl(ffid);
%parameter struc

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ffid);
        continue;
    end
    cPath = tline;
    cd(cPath);
    
    if ~exist('CSessionData.mat','file')
        ErrorSessNum = ErrorSessNum + 1;
        ErrorSessPath{ErrorSessNum} = pwd;
    else
        clearvars data
        load('CSessionData.mat');
        
%         V.Ncells = 1;
%         V.T = size(data_aligned,3);
%         V.Npixels = 1;
%         V.dt = 1/frame_rate;
%         P.lam = 10;
%         nTau = 1.8; %based on  Tsai-Wen Chen's paper
%         P.gam = 1 - V.dt/nTau;
        
%         if  ~(exist('./SpikeDataSave/EstimateSPsave.mat','file') || exist('EstimateSPsave.mat','file'))
%              nnspike = DataFluo2Spike(data_aligned,V,P); % estimated spike
%              save EstimateSPsave.mat data_aligned nnspike behavResults start_frame frame_rate -v7.3
%         end
        if exist('ROIstate','var')
            AlignedSortPlotAll(data,behavResults,frame_rate,FRewardLickT,frame_lickAllTrials,[],ROIstate); % plot lick frames
        else
            AlignedSortPlotAll(data,behavResults,frame_rate,FRewardLickT,frame_lickAllTrials);
        end
%         try
%             AnsTimeAlignPlot(data_aligned,behavResults,1,frame_rate,trial_outcome,1); 
%             LRAlignedStrc = AlignedSortPLot(data_aligned(NormalTrialInds,:,:),behavResults.Time_reward(NormalTrialInds),...
%              behavResults.Time_answer(NormalTrialInds),align_time_point,TrialTypes(NormalTrialInds),...
%              frame_rate,onset_time(NormalTrialInds),0);
%              TimeCourseStrc = TimeCorseROC(data_aligned(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,[],2);   
%              %
%              AUCDataAS = ROC_check(smooth_data(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,1.5,'Stim_time_Align');
%              save AUCClassData.mat AUCDataAS -v7.3
%              %
%              AnsAlignData=Reward_Get_TimeAlign(data,lick_time_struct,behavResults,trial_outcome,frame_rate,imaging_time,0);
%              if RandomSession
%                  FreqAlignedStrc = AlignedSortPLot(data_aligned(NormalTrialInds,:,:),behavResults.Time_reward(NormalTrialInds),...
%                  behavResults.Time_answer(NormalTrialInds),align_time_point,behavResults.Stim_toneFreq(NormalTrialInds),...
%                  frame_rate,onset_time(NormalTrialInds),0);
%                  FreqMeanTrace = FreqRespCallFun(data_aligned(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),...
%                  trial_outcome(radom_inds),2,{1},frame_rate,start_frame,0);
%                  [ChoiceDataValue,ChoiceDataNumber] = ChoiceProbCal(smooth_data(NormalTrialInds,:,:),behavResults.Stim_toneFreq(NormalTrialInds),...
%                      behavResults.Action_choice(NormalTrialInds),1.5,start_frame,frame_rate,16000,0);
%              end
%              ROIAUCcolorp(TimeCourseStrc,start_frame/frame_rate);
%              script_for_summarizedPlot;
%         catch ME
%             ErrorSessNum = ErrorSessNum + 1;
%             ErrorSessPath{ErrorSessNum} = pwd;
%             ErrorSessMessage{ErrorSessNum} = ME;
%         end
    end
    tline = fgetl(ffid);
end

%%
% batch scripts for spike data convertion
clear
clc

[Pfn,Pfp,Pfi] = uigetfile('*.txt','Please select the file contains all session paths to be analysized');
if ~Pfi
    return;
end
ErrorSessPath = {};
ErrorSessNum = 0;
ErrorSessMessage = {};
ffullpath = fullfile(Pfp,Pfn);
%
ffid = fopen(ffullpath);
tline = fgetl(ffid);
%parameter struc

while ischar(tline)
    if isempty(strfind(tline,'plot_save\NO_Correction'))
        tline = fgetl(ffid);
        continue;
    end
    cPath = tline;
    cd(cPath);
    
    if ~exist('rfSelectDataSet.mat','file')
        ErrorSessNum = ErrorSessNum + 1;
        ErrorSessPath{ErrorSessNum} = pwd;
    else
        clearvars f_percent_change
        load('rfSelectDataSet.mat');
        
%         V.Ncells = 1;
%         V.T = size(data_aligned,3);
%         V.Npixels = 1;
%         V.dt = 1/frame_rate;
%         P.lam = 10;
%         nTau = 1.8; %based on  Tsai-Wen Chen's paper
%         P.gam = 1 - V.dt/nTau;
        
%         if  ~(exist('./SpikeDataSave/EstimateSPsave.mat','file') || exist('EstimateSPsave.mat','file'))
%              nnspike = DataFluo2Spike(data_aligned,V,P); % estimated spike
%              save EstimateSPsave.mat data_aligned nnspike behavResults start_frame frame_rate -v7.3
%         end
         PassRespPlot(f_percent_change,sound_array(:,2),sound_array(:,1),frame_rate);  % performing color plot
%         try
%             AnsTimeAlignPlot(data_aligned,behavResults,1,frame_rate,trial_outcome,1); 
%             LRAlignedStrc = AlignedSortPLot(data_aligned(NormalTrialInds,:,:),behavResults.Time_reward(NormalTrialInds),...
%              behavResults.Time_answer(NormalTrialInds),align_time_point,TrialTypes(NormalTrialInds),...
%              frame_rate,onset_time(NormalTrialInds),0);
%              TimeCourseStrc = TimeCorseROC(data_aligned(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,[],2);   
%              %
%              AUCDataAS = ROC_check(smooth_data(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,1.5,'Stim_time_Align');
%              save AUCClassData.mat AUCDataAS -v7.3
%              %
%              AnsAlignData=Reward_Get_TimeAlign(data,lick_time_struct,behavResults,trial_outcome,frame_rate,imaging_time,0);
%              if RandomSession
%                  FreqAlignedStrc = AlignedSortPLot(data_aligned(NormalTrialInds,:,:),behavResults.Time_reward(NormalTrialInds),...
%                  behavResults.Time_answer(NormalTrialInds),align_time_point,behavResults.Stim_toneFreq(NormalTrialInds),...
%                  frame_rate,onset_time(NormalTrialInds),0);
%                  FreqMeanTrace = FreqRespCallFun(data_aligned(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),...
%                  trial_outcome(radom_inds),2,{1},frame_rate,start_frame,0);
%                  [ChoiceDataValue,ChoiceDataNumber] = ChoiceProbCal(smooth_data(NormalTrialInds,:,:),behavResults.Stim_toneFreq(NormalTrialInds),...
%                      behavResults.Action_choice(NormalTrialInds),1.5,start_frame,frame_rate,16000,0);
%              end
%              ROIAUCcolorp(TimeCourseStrc,start_frame/frame_rate);
%              script_for_summarizedPlot;
%         catch ME
%             ErrorSessNum = ErrorSessNum + 1;
%             ErrorSessPath{ErrorSessNum} = pwd;
%             ErrorSessMessage{ErrorSessNum} = ME;
%         end
    end
    tline = fgetl(ffid);
end

%%
% batch scripts for factor analysis data plot
clear
clc

[Pfn,Pfp,Pfi] = uigetfile('*.txt','Please select the file contains all session paths to be analysized');
if ~Pfi
    return;
end
ErrorSessPath = {};
ErrorSessNum = 0;
ErrorSessMessage = {};
ffullpath = fullfile(Pfp,Pfn);
%
ffid = fopen(ffullpath);
tline = fgetl(ffid);
%parameter struc

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ffid);
        continue;
    end
    cPath = tline;
    cd(cPath);
    
    if ~exist('./DimRed_Resplot_smooth/FactorAnaData.mat','file')
        ErrorSessNum = ErrorSessNum + 1;
        ErrorSessPath{ErrorSessNum} = pwd;
        ErrorSessMessage{ErrorSessNum} = 'Nacessary file was missing';
    else
        clearvars cLRIndexSum
        try
            load('./DimRed_Resplot_smooth/FactorAnaData.mat');
            load('./DimRed_Resplot_smooth/MeanPlotData.mat');
            load('./RandP_data_plots/boundary_result.mat');
            cd('DimRed_Resplot_smooth');
            Freqwise_maxValue_factorAScript;
        catch ME
             ErrorSessNum = ErrorSessNum + 1;
             ErrorSessPath{ErrorSessNum} = pwd;
             ErrorSessMessage{ErrorSessNum} = ME.message;
        end
    end
    tline = fgetl(ffid);
end
