function varargout=FluoChangeCa2NPl(varargin)
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
    filefullpath2=fullfile(file_path2,filesep,fn2);  %this can be achieved by the  fullfile function
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
%     IsNeuropilExtract=varargin{7};
end

if isempty(behavResults) || isempty(behavSettings)
    MethodChoice=2;
    SessionType='rf';
end

choice=questdlg('Would you want to do neuropil correction?','Choice Selection','Ring NP','SegMental NP','No','No');
switch choice
    case 'Ring NP'
        IsNeuropilExtract=1;
    case 'SegMental NP'
        IsNeuropilExtract=2;
    case 'No'
        IsNeuropilExtract=0;
    otherwise
        disp('Quit Selection.');
        return;
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
PreOnsetRingF=cell(1,TrialNum);
FBaseline=zeros(TrialNum,ROINum);

if strcmpi(SessionType,'2afc')
    TrialOnsetTime=floor((double(behavResults.Time_stimOnset)/1000)*FrameRate);
    TrialAnswerTime=floor((double(behavResults.Time_answer)/1000)*FrameRate);
    TrialRewardTime=floor((double(behavResults.Time_reward)/1000)*FrameRate);
elseif strcmpi(SessionType,'rf')
    TrialOnsetTime=ones(1,TrialNum)*FrameRate;
end

exclude_trials=[];
baselineDataAll=[];
baselineDataRing=[];
if length(CaTrials)>1
    for n=1:TrialNum
        if size(CaTrials(n).f_raw,2)~=TrialLen  %check whether there are some frame drops during acqsition
            CaTrials(n).f_raw=NaN;
            exclude_trials=[exclude_trials n];
            fprintf(['Trial number ' num2str(n) ' have some frames dropped during acqusition.\n']);
            continue;
        end
        RawData(n,:,:)=CaTrials(n).f_raw;
        PreOnsetData{n}=CaTrials(n).f_raw(:,1:TrialOnsetTime(n));
        
        if isfield(CaTrials(n),'RingF')
            PreOnsetRingF{n}=CaTrials(n).RingF(:,1:TrialOnsetTime(n));
            RawRingData(n,:,:)=CaTrials(n).RingF;
            baselineDataRing=[baselineDataRing PreOnsetRingF{n}];
        end
        baselineDataAll=[baselineDataAll PreOnsetData{n}];
    end
else
    if isfield(CaTrials(1),'RingF')
        RawRingData=CaTrials.RingF;
    end
        RawData=CaTrials.f_raw;
        for n=1:TrialNum
            PreOnsetData{n}=squeeze(RawData(n,:,1:TrialOnsetTime(n)));
            baselineDataAll=[baselineDataAll PreOnsetData{n}];
            FBaseline(n,:)=mean(squeeze(RawData(n,:,1:TrialOnsetTime(n))),2);
            if isfield(CaTrials(1),'RingF')
                baselineDataRing=[baselineDataRing PreOnsetRingF{n}];
                PreOnsetRingF{n}=squeeze(RawRingData(n,:,1:TrialOnsetTime(n)));
            end
        end
end

RingFbase=zeros(ROINum,1);

if isfield(CaTrials(1),'RingF') && IsNeuropilExtract == 1
    FCorrectData=zeros(TrialNum,ROINum,TrialLen);
    CorrePreOnsetData=cell(1,TrialNum);
    for n=1:ROINum
        CROIdata=squeeze(RawData(:,n,:));
        CRingdata=squeeze(RawRingData(:,n,:));
        RingFbase(n)=mean(CRingdata(:));
%         [N,C]=hist(CRingdata(:),80);
%         [~,I]=max(N);
%         RingFbase(n)=C(I);
        FCorrectData(:,n,:)=(CROIdata-CRingdata)+RingFbase(n);
    end
    clearvars CROIdata CRingdata n
    
    
    for m=1:TrialNum
        RawOnsetData=PreOnsetData{m};
        NPOnsetData=PreOnsetRingF{m};
        CurrentdDataSize=size(RawOnsetData);
        SavedNPbase=repmat(RingFbase,1,CurrentdDataSize(2));
        CorrePreOnsetData(m)={RawOnsetData-NPOnsetData+SavedNPbase};
    end
    
elseif isfield(CaTrials(1),'SegNPdataAll') && IsNeuropilExtract == 2
    SegmentalData=CaTrials.SegNPdataAll;
    ROISegLabel=CaTrials.ROISegLabel;
    SegROINPdata=zeros(size(RawData));
    ROISegTypes=unique(ROISegLabel);
    %generating all ROI's corresponded NP data
    for LabelType=1:length(ROISegTypes)
        CurrentLabelInds=ROISegLabel==ROISegTypes(LabelType);
        CSegROINum=sum(CurrentLabelInds);
        CSegNPdata=SegmentalData(:,ROISegTypes(LabelType),:);
        ROIAllSegNPData=repmat(CSegNPdata,1,CSegROINum,1);
        SegROINPdata(:,CurrentLabelInds,:)=ROIAllSegNPData;
    end
    TempNPData=reshape(permute(SegROINPdata,[2,3,1]),ROINum,[]);   %first dimension is ROI number, second dimension is All ROI data
    SegNPbase=mean(TempNPData,2);   %SegNP value used for correction baseline correction
    
%     PreOnsetSegNPData=cell(1,TrialNum);
    for TrialNum=1:TrialNum
        TempRawData=PreOnsetData{TrialNum}-squeeze(SegROINPdata(TrialNum,:,1:TrialOnsetTime(TrialNum)));
        TempSize=size(TempRawData);
        BaseComp=repmat(SegNPbase,1,TempSize(2));
        CorrePreOnsetData{TrialNum}=TempRawData+BaseComp;  %after SegMental correction data
    end
    FCorrectData = RawData - SegROINPdata + repmat(SegNPbase',TrialNum,1,TrialLen);
else
    FCorrectData=RawData;
    CorrePreOnsetData=PreOnsetData;
end


%######################################
%ROI threshold calculation
ROIThres=std(baselineDataAll');
save ROIStd.mat ROIThres -v7.3

if strcmpi(SessionType,'rf')
    FBaseline = mean(FCorrectData(:,:,1:FrameRate),3);
end
    
if ~isempty(exclude_trials)
    if length(CaTrials)>1
        CaTrials(exclude_trials) = [];
        RawData(exclude_trials,:,:) = [];
        FCorrectData(exclude_trials,:,:) = [];
        PreOnsetData(exclude_trials) = [];
        CorrePreOnsetData(exclude_trials) = [];
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
        FCorrectData(exclude_trials,:,:) = [];
        PreOnsetData(exclude_trials) = [];
        CorrePreOnsetData(exclude_trials) = [];
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
            a=reshape(FCorrectData(:,n,:),[],1);
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
                FChangeData(m,n,:) = ((FCorrectData(m,n,:) - ModeF0(n))/ ModeF0(n))* 100;
            end

        end
        cd ..;
    case 2
        for n=1:ROINum
            for m=1:TrialNum
                FChangeData(m,n,:) = ((FCorrectData(m,n,:) - FBaseline(m,n))/FBaseline(m,n))*100;
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
                    TempData=CorrePreOnsetData{m};
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
                FChangeData(LowerInds:upperInds,k,:) = (FCorrectData(LowerInds:upperInds,k,:) - BlockWiseF0(n,k))/BlockWiseF0(n,k)*100;

            end
%             h=figure;
%             subplot(2,1,1)
%             imagesc(squeeze(FChangeData(:,k,:)),[0 min(max(reshape(FChangeData(:,k,:),[],1)),300)]);
%             title(['ROI num' num2str(k)]);
%             set(gca,'xtick',(1:FrameRate:TrialLen),'xticklabel',floor((1:FrameRate:TrialLen)/FrameRate));
%             colorbar;
% 
%             subplot(2,1,2)
%             plot(BlockWiseF0(:,k),'-o','color','r','LineWidth',1.6);
%             xlabel('Block number');
%             ylabel('Block f_0 value');
% 
%             saveas(h,['ROI_num' num2str(k)],'png');
%             close;
        end
        save Blockwiseresult.mat BlockWiseF0
        cd ..;

    case 4
        % 8th percentile baseline substraction
        SubRawData=zeros(size(FCorrectData));
        for n=1:size(FCorrectData,2)
            TempData=squeeze(FCorrectData(:,n,:));
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
        save SubBaseData.mat FCorrectData SubRawData -v7.3

    otherwise
        disp('Error input option, quit analysis.\n');
end

if isfield(CaTrials(1),'RingF') && IsNeuropilExtract
    save DiffFluoResult.mat behavResults behavSettings RawData FChangeData baselineDataAll -v7.3
else
    save DiffFluoResult.mat behavResults behavSettings RawData FChangeData ...
        baselineDataAll RawRingData -v7.3
end

if nargout==1
    varargout(1)={{FCorrectData},{FChangeData},{exclude_trials}};
elseif nargout==3
    varargout{1}=FCorrectData;
    varargout{2}=FChangeData;
    varargout{3}=exclude_trials;
end