function varargout=FluoChangeCal(varargin)
%this function is used for change the raw fluo data into the deltaF/F data
%form

if nargin<1
    disp('please input the 2afc ROIs analysis result file path.\n');
    filepath=uigetdir();
    cd(filepath);
    files=dir('*.mat');
    for n=1:length(files)
        load(files(n).name);
        if strncmp(files(n).name,'CaTrials',8)
            export_filename_raw=files(n).name(1:end-4);
        elseif strncmp(files(n).name,'CaSignal',8)
            export_filename_raw=files(n).name(1:end-4);
        end
        disp(['loading file ',files(n).name,'...']);
    end
    
    [fn2,file_path2]=uigetfile('*.*');
    filefullpath2=[file_path2,filesep,fn2];  %this can be achieved by the  fullfile function
    if ~exist(filefullpath2,'file')
        error('wrong file path for behavior result!');
    end
    load(filefullpath2);
else
    CaTrials=varargin{1};
    behavResults=varargin{2};
    behavSettings=varargin{3};
    MethodChoice=varargin{4};
    SessionType=varargin{5};
    ROIinfo=varargin{6};
end

if isempty(behavResults) || isempty(behavSettings)
    MethodChoice=2;
    SessionType='rf';
end

%exclude error trials from whole behavior data
exclude_trials = input('please inut the trials needed to be excluded.Seperated by '',''\n','s');
exclude_trials=strrep(exclude_trials,' ',',');
exclude_inds = str2num(exclude_trials);
% exclude_trials=[];
if length(CaTrials)>1
    if ~isempty(exclude_inds)
        CaTrials(exclude_inds)=[];
        eval(['CaSignal_',type,'(exclude_inds)','=','[];']);
    end
end
if length(CaTrials)>1
    TrialNum=length(CaTrials);
else
    TrialNum=CaTrials.TrialNum;
end

ROINum=CaTrials(1).nROIs;
TrialLen=CaTrials(1).nFrames;
FrameRate=floor(1000/CaTrials(1).FrameTime);

ROImasks=ROIinfo(1).ROImask;
EmptyROI=cellfun(@isempty,ROImasks);
if sum(EmptyROI)
    disp('Some of the ROIs have empty ROI mask, exclude these ROIs.\n');
end
save ExcludedROIs.mat EmptyROI -v7.3
ROINum=ROINum-sum(EmptyROI);

RawData=zeros(TrialNum,ROINum,TrialLen);
RawDataBU=zeros(TrialNum,ROINum,TrialLen);
RawRingData=zeros(TrialNum,ROINum,TrialLen);
FChangeData=zeros(TrialNum,ROINum,TrialLen);
PreOnsetData=cell(1,TrialNum);
FBaseline=zeros(TrialNum,ROINum);

if strcmpi(SessionType,'2afc')
    TrialOnsetTime=floor((double(behavResults.Time_stimOnset)/1000)*FrameRate);
    TrialAnswerTime=floor((double(behavResults.Time_answer)/1000)*FrameRate);
    TrialRewardTime=floor((double(behavResults.Time_reward)/1000)*FrameRate);
elseif strcmpi(SessionType,'rf')
    TrialOnsetTime=ones(1,TrialNum)*FrameRate;
end



% RawData(:,EmptyROI,:)=[];
% FBaseline(:,EmptyROI)=[];
IsNeuropilExtract=0;
baselineDataAll=[];  %the final result for this variable should be nROI by length(baseline data)

if length(CaTrials)>1
    if isfield(CaTrials(1),'RingF') && IsNeuropilExtract
        disp('Performing Neuropil extraction correction.\n');
        for n=1:TrialNum
            if size(CaTrials(n).f_raw,2)~=TrialLen
                %         CaTrials(i)=[];
                CaTrials(n).f_raw=NaN;
                exclude_trials=[exclude_trials n];
                disp(['Trial number ' num2str(n) ' have different frames length from trial 1.\n']);
                %         waitforbuttonpress;
                %         close(gcf);
                continue;
            end
            CaTrials(n).f_raw(EmptyROI,:)=[];
            RawData(n,:,:)=CaTrials(n).f_raw-0.7*CaTrials(n).RingF;  %need to do the correction to make avoid a over-correction
            RawDataBU(n,:,:)=CaTrials(n).f_raw;
            RawRingData(n,:,:)=CaTrials(n).RingF;
            PreOnsetData{n}=CaTrials(n).f_raw(:,1:TrialOnsetTime(n))-0.7*CaTrials(n).RingF(:,1:TrialOnsetTime(n));
            baselineDataAll=[baselineDataAll PreOnsetData{n}];
            FBaseline(n,:)=mean(CaTrials(n).f_raw(:,1:TrialOnsetTime(n)),2)-0.7*mean(CaTrials(n).RingF(:,1:TrialOnsetTime(n)),2);
        end
    else
        disp('No Neuropil data, do without neuropil extraction.\n');
        for n=1:TrialNum
            if size(CaTrials(n).f_raw,2)~=TrialLen
                %         CaTrials(i)=[];
                CaTrials(n).f_raw=NaN;
                exclude_trials=[exclude_trials n];
                disp(['Trial number ' num2str(n) ' have different frames length from trial 1.\n']);
                %         waitforbuttonpress;
                %         close(gcf);
                continue;
            end
            CaTrials(n).f_raw(EmptyROI,:)=[];
            RawData(n,:,:)=CaTrials(n).f_raw;
            PreOnsetData{n}=CaTrials(n).f_raw(:,1:TrialOnsetTime(n));
            baselineDataAll=[baselineDataAll PreOnsetData{n}];
            FBaseline(n,:)=mean(CaTrials(n).f_raw(:,1:TrialOnsetTime(n)),2);
        end
    end
else
    RawData=CaTrials.f_raw;
    if isfield(CaTrials(1),'RingF') && IsNeuropilExtract
        RawRingData=CaTrials.RingF;
        disp('Performing Neuropil extraction correction.\n');
        RawData(:,EmptyROI,:)=[];
        RawDataBU=RawData;
        RawData=RawData-0.7*RawRingData;  %need to do the correction to make avoid a over-correction
        for n=1:TrialNum
%             if size(RawData(n,:,:),3)~=TrialLen
%                 %         CaTrials(i)=[];
%                 RawData(n,:,:)=NaN;
%                 exclude_trials=[exclude_trials n];
%                 disp(['Trial number ' num2str(n) ' have different frames length from trial 1.\n']);
%                 %         waitforbuttonpress;
%                 %         close(gcf);
%                 continue;
%             end
            PreOnsetData{n}=squeeze(RawData(n,:,1:TrialOnsetTime(n)));
            %             PreOnsetData{n}=CaTrials(n).f_raw(:,1:TrialOnsetTime(n))-CaTrials(n).RingF(:,1:TrialOnsetTime(n));
            baselineDataAll=[baselineDataAll PreOnsetData{n}];
            FBaseline(n,:)=mean(squeeze(RawData(n,:,1:TrialOnsetTime(n))),2);
        end
    else
        RawData(:,EmptyROI,:)=[];
        RawDataBU=RawData;
        disp('No Neuropil data, do without neuropil extraction.\n');
        for n=1:TrialNum
%             if size(CaTrials(n).f_raw,2)~=TrialLen
%                 %         CaTrials(i)=[];
%                 CaTrials(n).f_raw=NaN;
%                 exclude_trials=[exclude_trials n];
%                 disp(['Trial number ' num2str(n) ' have different frames length from trial 1.\n']);
%                 %         waitforbuttonpress;
%                 %         close(gcf);
%                 continue;
%             end
            %             CaTrials(n).f_raw(EmptyROI,:)=[];
            %             RawData(n,:,:)=CaTrials(n).f_raw;
            PreOnsetData{n}=squeeze(RawData(n,:,1:TrialOnsetTime(n)));
            baselineDataAll=[baselineDataAll PreOnsetData{n}];
            FBaseline(n,:)=mean(squeeze(RawData(n,:,1:TrialOnsetTime(n))),2);
        end
    end
end

%######################################
%ROI threshold calculation
ROIThres=std(baselineDataAll');
save ROIStd.mat ROIThres -v7.3

if isfield(CaTrials(1),'RingF') && IsNeuropilExtract
    for n=1:ROINum
        TempROIData=squeeze(RawDataBU(:,n,:));
        Baseline=mean(reshape(RawRingData(:,n,:),[],1));
        %         Tempbaseline=mad(TempROIData(:))*1.4826;
        TempROIData(TempROIData<Baseline)=Baseline;
        RawData(:,n,:)=TempROIData;  %making correction of the over-correct data into baseline level
    end
    clearvars RawDataBU
end

if ~isempty(exclude_trials)
    if length(CaTrials)>1
        CaTrials(exclude_trials) = [];
        RawData(exclude_trials,:,:) = [];
        PreOnsetData(exclude_trials) = [];
        FBaseline(exclude_trials,:) = [];
        if strcmpi(SessionType,'2afc')
            TrialOnsetTime(exclude_trials) = [];
            TrialAnswerTime(exclude_trials) = [];
            TrialRewardTime(exclude_trials) = [];
        elseif strcmpi(SessionType,'rf')
            TrialOnsetTime(exclude_trials) = [];
        end
        TrialNum=length(CaTrials);
        FChangeData=zeros(TrialNum,ROINum,TrialLen);
    else
        CaTrials.f_raw(exclude_trials,:,:)=[];
        RawData(exclude_trials,:,:) = [];
        PreOnsetData(exclude_trials) = [];
        FBaseline(exclude_trials,:) = [];
        if strcmpi(SessionType,'2afc')
            TrialOnsetTime(exclude_trials) = [];
            TrialAnswerTime(exclude_trials) = [];
            TrialRewardTime(exclude_trials) = [];
        elseif strcmpi(SessionType,'rf')
            TrialOnsetTime(exclude_trials) = [];
        end
        TrialNum=TrialNum-length(exclude_trials);
        CaTrials.TrialNum=TrialNum;
        FChangeData=zeros(TrialNum,ROINum,TrialLen);
    end
end
    
    if isempty(MethodChoice)
        disp('Please select the f0 calculation method.\n 1 for mode f0 calculation.\n 2 for pure baseline calculation.\n 3 for block wise calculation.\n');
        MethodChoice=input('Please select your choice.\n','s');
        MethodChoice=str2double(MethodChoice);
    end
    switch MethodChoice
        case 1
            ModeF0=zeros(ROINum,1);
            if ~isdir('./f0_distribution/')
                mkdir('./f0_distribution/');
            end
            cd('./f0_distribution/');
            for n=1:ROINum
                a=reshape(RawData(:,n,:),[],1);
                [N,x]=hist(a,100);
                [~,I]=max(N);
                ModeF0(n)=x(I);
                
                %###########################################################
                h_raw=figure('visible','off');
                subplot(1,2,1);
                bar(x,N);
                hold on;
                temp_axis=axis;
                plot([x(I) x(I)],[temp_axis(3),temp_axis(4)],'color','r','LineWidth',1.5);
                text(x(I)*0.85,temp_axis(4)*1.02,'f_0 value');
                hold off;
                subplot(1,2,2);
                plot(a);
                set(gca,'xlim',[0 length(a)]);
                hold on;
                plot([0 length(a)],[x(I) x(I)],'color','r','LineWidth',2.5);
                hold off;
                suptitle(['Raw data distribution for ROI' num2str(n)]);
                saveas(h_raw,['Raw data distribution for ROI' num2str(n)],'png');
                close;
                %##############################################################
                
                for m=1:TrialNum
                    FChangeData(m,n,:) = ((RawData(m,n,:) - ModeF0(n))/ ModeF0(n))* 100;
                end
                
            end
            cd ..;
        case 2
            for n=1:ROINum
                for m=1:TrialNum
                    FChangeData(m,n,:) = ((RawData(m,n,:) - FBaseline(m,n))/FBaseline(m,n))*100;
                end
            end
        case 3
            BlockSize=30;
            BlockNum=ceil(TrialNum/BlockSize);
            BlockWiseF0=zeros(BlockNum,ROINum);
            if ~isdir('./Blockwise_diff/')
                mkdir('./Blockwise_diff/');
            end
            cd('./Blockwise_diff/');
            if ~isdir('./Raw_data_hist/')
                mkdir('./Raw_data_hist/');
            end
            for k=1:ROINum
                for n=1:BlockNum
                    FBase=[];
                    for m=((n-1)*BlockSize+1) : min(n*BlockSize,TrialNum)
                        TempData=PreOnsetData{m};
                        FBase=[FBase TempData(k,:)];
                    end
                    %######################################
                    %                 SectionRawData=squeeze(RawData(((n-1)*BlockSize+1) : min(n*BlockSize,TrialNum),k,:));
                    % %                 h_raw=figure;
                    % %                 hist(SectionRawData(:),50);
                    %                 [ncounts,ncenters]=hist(SectionRawData(:),50);
                    % %                 modeN=ncenters(ncounts==max(ncounts));
                    % %                 MedianN=median(SectionRawData(:));
                    %                 BelowHalfPercent=sum(SectionRawData(:)<median(ncenters))/length(SectionRawData(:));
                    % %                 title(sprintf('mode=%.1f,median=%.1f,Belowhalf=%.2f',modeN,MedianN,BelowHalfPercent));
                    % %                 saveas(h_raw,sprintf('./Raw_data_hist/RawDisROI%d_Block%d.png',k,n));
                    % %                 saveas(h_raw,sprintf('./Raw_data_hist/RawDisROI%d_Block%d.fig',k,n));
                    % %                 close(h_raw);
                    %
                    % % %                 %percentile f0 calculation
                    %                 if BelowHalfPercent>=0.95
                    %                     f0=prctile(SectionRawData(:),5);
                    %                 elseif BelowHalfPercent<=0.5
                    %                     f0=median(SectionRawData(:));
                    %                 else
                    %                     f0=prctile(SectionRawData(:),(1-BelowHalfPercent)*100);
                    %                 end
                    %                 BlockWiseF0(n,k)=f0;
                    
                    %######################################
                    %###########################
                    %old mode calculation
                    [N,x]=hist(FBase,50);
                    [~,I]=max(N);
                    BlockWiseF0(n,k)=min(x(I));
                    % %                 for m=((n-1)*BlockSize+1) : min(n*BlockSize,TrialNum)
                    % %                     FChangeData(m,k,:) = (RawData(m,k,:) -  BlockWiseF0(n,k))/ BlockWiseF0(n,k)*100;
                    % %                 end
                    %############################
                    LowerInds=((n-1)*BlockSize+1);
                    upperInds=min(n*BlockSize,TrialNum);
                    FChangeData(LowerInds:upperInds,k,:) = (RawData(LowerInds:upperInds,k,:) - BlockWiseF0(n,k))/BlockWiseF0(n,k)*100;
                    
                end
                h=figure;
                subplot(2,1,1)
                imagesc(squeeze(FChangeData(:,k,:)),[0 min(max(reshape(FChangeData(:,k,:),[],1)),300)]);
                title(['ROI num' num2str(k)]);
                set(gca,'xtick',(1:FrameRate:TrialLen),'xticklabel',floor((1:FrameRate:TrialLen)/FrameRate));
                colorbar;
                
                subplot(2,1,2)
                plot(BlockWiseF0(:,k),'-o','color','r','LineWidth',1.6);
                xlabel('Block number');
                ylabel('Block f_0 value');
                
                saveas(h,['ROI_num' num2str(k)],'png');
                close;
            end
            save Blockwiseresult.mat BlockWiseF0
            cd ..;
            
        case 4
            % 8th percentile baseline substraction
            SubRawData=zeros(size(RawData));
            for n=1:size(RawData,2)
                TempData=squeeze(RawData(:,n,:));
                [SubTempData,~]=BLSubStract(TempData',8,FrameRate*15);
                SubRawData(:,n,:)=SubTempData;
                [ncounts,ncenters]=hist(SubTempData(:),100);
                [~,I]=max(ncounts);
                f0=ncenters(I);
                TempSubChangeData=((SubRawData-f0)/f0)*100;
                FChangeData(:,n,:)=TempSubChangeData;
                
                h=figure;
                imagesc(squeeze(FChangeData(:,n,:)),[50,min(max(TempSubChangeData(:)),500)]);
                title(sprintf('Color Plot ROI%d.png',n));
                set(gca,'xtick',(1:FrameRate:TrialLen),'xticklabel',floor((1:FrameRate:TrialLen)/FrameRate));
                colorbar;
                saveas(h,sprintf('Color_Plot_ROI%d.png',n));
                saveas(h,sprintf('Color_Plot_ROI%d.fig',n));
                close(h);
            end
            save SubBaseData.mat RawData SubRawData -v7.3
            
        otherwise
            disp('Error input option, quit analysis.\n');
    end
    
    if isfield(CaTrials(1),'RingF') && IsNeuropilExtract
        save DiffFluoResult.mat behavResults behavSettings RawData FChangeData baselineDataAll -v7.3
    else
        save DiffFluoResult.mat behavResults behavSettings RawData FChangeData ...
            baselineDataAll RawRingData -v7.3
    end
    
    % if ~isdir('./Data_Points_Dis/')
    %     mkdir('./Data_Points_Dis/');
    % end
    % cd('./Data_Points_Dis/');
    % for n=1:ROINum
    %     SingleROITrace=reshape(FChangeData(:,n,:),[],1);
    %     h_ROI=figure;
    %     hist(SingleROITrace,100);
    %     title(['All time points value for ROI' num2str(n)]);
    %     saveas(h_ROI,['All value distribution for ROI' num2str(n)],'png');
    %     saveas(h_ROI,['All value distribution for ROI' num2str(n)]);
    %     close(h_ROI);
    % end
    % cd ..;
    
    if nargout==1
        varargout(1)={{RawData},{FChangeData},{exclude_trials}};
    elseif nargout==3
        varargout{1}=RawData;
        varargout{2}=FChangeData;
        varargout{3}=exclude_trials;
    end
