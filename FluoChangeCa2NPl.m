function varargout=FluoChangeCa2NPl(varargin)
%this function is used for change the raw fluo data into the deltaF/F data
%form
% p = inputParser;
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
    TrialsExcluded = [];
else
    CaTrials=varargin{1};
    behavResults=varargin{2};
    behavSettings=varargin{3};
    MethodChoice=varargin{4};
    SessionType=varargin{5};
    ROIinfo=varargin{6};
    TrialsExcluded = varargin{7};
%     IsNeuropilExtract=varargin{7};
end

if isempty(behavResults) || isempty(behavSettings)
    if isempty(MethodChoice)
        MethodChoice=2;
        SessionType='rf';
    end
end

choice=questdlg('Would you want to do neuropil correction?','Choice Selection','Ring NP','SegMental NP','No','No');
switch choice
    case 'Ring NP'
        IsNeuropilExtract=1;
        if ~isdir('./RingNP_Correction/')
            mkdir('./RingNP_Correction/');
        end
        cd('./RingNP_Correction/');
        
    case 'SegMental NP'
        IsNeuropilExtract=2;
        if ~isdir('./SegMentNP_Correction/')
            mkdir('./SegMentNP_Correction/');
        end
        cd('./SegMentNP_Correction/');
        
    case 'No'
        if ~isdir('./NO_Correction/')
            mkdir('./NO_Correction/');
        end
        cd('./NO_Correction/');
        IsNeuropilExtract=0;
    otherwise
        disp('Quit Selection.');
        return;
end
ExCludedInds = find(TrialsExcluded);
%exclude error trials from whole behavior data
exclude_trials = input('please inut the trials needed to be excluded.Seperated by '',''\n','s');
exclude_trials=strrep(exclude_trials,' ',',');
exclude_inds = str2num(exclude_trials);
exclude_inds = [exclude_inds(:);ExCludedInds(:)];
% exclude_inds = logical([exclude_inds;TrialsExcluded(:)]);
% if ~isempty(exclude_inds)
%     % exclude_trials=[];
%     if length(CaTrials)>1
%         if ~isempty(exclude_inds)
%             CaTrials(exclude_inds)=[];
% %             eval(['CaSignal_',SessionType,'(exclude_inds)','=','[];']);
%         end
%     else
%         CaTrials.f_raw(exclude_inds,:,:) = [];
% %         eval(['CaSignal_',SessionType,'.f_raw(exclude_inds,:,:)','=','[];']);
%     end
% end
if length(CaTrials)>1
    TrialNum=length(CaTrials);
else
    TrialNum=CaTrials.TrialNum;
end

ROINum=CaTrials(1).nROIs;
if iscell(CaTrials(1).f_raw)
   TrDataNumVec =  cellfun(@(x) size(x,2),CaTrials(1).f_raw);
   TrialLen = max(TrDataNumVec);
   IsContiAcq = 1;
else
    IsContiAcq = 0;
    TrialLen=CaTrials(1).nFrames;
end
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
% PreOnsetDataROI = []
% PreOnsetRingFROI = [];
FBaseline=zeros(TrialNum,ROINum);

if strcmpi(SessionType,'2afc')
    TrialOnsetTime=floor((double(behavResults.Time_stimOnset)/1000)*FrameRate);
    TrialAnswerTime=floor((double(behavResults.Time_answer)/1000)*FrameRate);
    TrialRewardTime=floor((double(behavResults.Time_reward)/1000)*FrameRate);
else
    TrialOnsetTime=ones(1,TrialNum)*FrameRate;
end

% exclude_trials=[];
baselineDataAll=[];
baselineDataRing=[];
if length(CaTrials)>1
    for n=1:TrialNum
        if size(CaTrials(n).f_raw,2)~=TrialLen  %check whether there are some frame drops during acqsition
            CaTrials(n).f_raw=NaN;
            exclude_inds=[exclude_inds;n];
            fprintf(['Trial number ' num2str(n) ' have some frames dropped during acqusition.\n']);
            continue;
        end
        RawData(n,:,:)=CaTrials(n).f_raw;
        PreOnsetData{n}=CaTrials(n).f_raw(:,1:TrialOnsetTime(n));
        FBaseline(n,:) = mean(CaTrials(n).f_raw(:,1:TrialOnsetTime(n)),2);
%         PreOnsetDataROI = [PreOnsetDataROI,PreOnsetData{n}];
        
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
    if ~iscell(CaTrials.f_raw)
        RawData = CaTrials.f_raw;
        for n=1:TrialNum
            PreOnsetData{n}=squeeze(RawData(n,:,1:TrialOnsetTime(n)));
            baselineDataAll=[baselineDataAll PreOnsetData{n}];
            FBaseline(n,:)=mean(squeeze(RawData(n,:,1:TrialOnsetTime(n))),2);
            if isfield(CaTrials(1),'RingF')
                PreOnsetRingF{n}=squeeze(RawRingData(n,:,1:TrialOnsetTime(n)));
                baselineDataRing=[baselineDataRing PreOnsetRingF{n}];
            end
        end
    else
        %%
        for n=1:TrialNum
            cRawData = CaTrials.f_raw{n};
            cRawEndData = cRawData(:,end-5:end);
            if mean(cRawEndData(:)) < 20
                warning('Empty frames exists at trial %d',n);
                cRawData(:,end-9:end) = [];
                TrDataNumVec(n) = TrDataNumVec(n) - 10;
            end
            RawData(n,:,1:TrDataNumVec(n)) = cRawData;
            PreOnsetData{n}=squeeze(cRawData(:,1:TrialOnsetTime(n)));
            baselineDataAll=[baselineDataAll PreOnsetData{n}];
            FBaseline(n,:)=mean(squeeze(cRawData(:,1:TrialOnsetTime(n))),2);
            if isfield(CaTrials(1),'RingF')
                cRawRingData =  CaTrials.RingF{n};
                PreOnsetRingF{n}=squeeze(cRawRingData(:,1:TrialOnsetTime(n)));
                baselineDataRing=[baselineDataRing PreOnsetRingF{n}];
            end
        end
        %%
    end
end

RingFbase=zeros(ROINum,1);
BaselineSubE = 0;
if IsNeuropilExtract == 1 && ~isfield(CaTrials(1),'RingF')
    BaselineSubE = 1;
    fprintf('Request of Ring-shaped neuropil extraction, but no such field exists.\n');
end
if IsNeuropilExtract == 2 && ~isfield(CaTrials(1),'SegNPdataAll')
    BaselineSubE = 2;
    fprintf('Request of segmental neuropil extraction, but no such field exists.\n');
end
if BaselineSubE
    if nargout > 3
%         varargout{1:3} = [];
        varargout{4} = BaselineSubE;
    end
    return;
end

CorrePreOnsetData=cell(1,TrialNum);
if isfield(CaTrials(1),'RingF') && IsNeuropilExtract == 1
    FCorrectData=zeros(TrialNum,ROINum,TrialLen);
    NPSubFactors = zeros(ROINum,1);
%     for n=1:ROINum
%         CROIdata=squeeze(RawData(:,n,:));
%         CRingdata=squeeze(RawRingData(:,n,:));
%         RingFbase(n)=mean(CRingdata(:));
% %         [N,C]=hist(CRingdata(:),80);
% %         [~,I]=max(N);
% %         RingFbase(n)=C(I);
%         FCorrectData(:,n,:)=(CROIdata-CRingdata)+RingFbase(n);
%     end
%     clearvars CROIdata CRingdata n
    
    for nRoi = 1 : ROINum
        cROIbase = baselineDataAll(nRoi,:);
        cROIring = baselineDataRing(nRoi,:);
        if mean(cROIbase) > 1.05 * mean(cROIring)
            NPSubFactor = 0.7;
%             BaseSubValue = cROIbase - cROIring * NPSubFactor;
        else
            NPSubFactor = 0;
        end
        CROIdata=squeeze(RawData(:,nRoi,:));
        CRingdata=squeeze(RawRingData(:,nRoi,:));
        FCorrectData(:,nRoi,:) = (CROIdata - NPSubFactor*CRingdata);
        NPSubFactors(nRoi) = NPSubFactor;
    end
    save ROISubFactor.mat NPSubFactors -v7.3
    for m=1:TrialNum
        RawOnsetData=PreOnsetData{m};
        NPOnsetData=PreOnsetRingF{m};
        CurrentdDataSize=size(RawOnsetData);
        SavedNPbase=repmat(NPSubFactors,1,CurrentdDataSize(2));
        CorrePreOnsetData(m)={RawOnsetData - SavedNPbase.*NPOnsetData};
        FBaseline(m,:) = mean(CorrePreOnsetData{m},2);
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
    for TrialN=1:TrialNum
        TempRawData=PreOnsetData{TrialN}-squeeze(SegROINPdata(TrialN,:,1:TrialOnsetTime(TrialN)));
        TempSize=size(TempRawData);
        BaseComp=repmat(SegNPbase,1,TempSize(2));
        CorrePreOnsetData{TrialN}=TempRawData+BaseComp;  %after SegMental correction data
        FBaseline(TrialN,:) = mean(CorrePreOnsetData{TrialN},2);
    end
    FCorrectData = RawData - SegROINPdata + repmat(SegNPbase',TrialN,1,TrialLen);
else
    FCorrectData=RawData;
    CorrePreOnsetData=PreOnsetData;
end

% 
% %######################################
% %ROI threshold calculation
% ROIThres=std(baselineDataAll');
% save ROIStd.mat ROIThres -v7.3

if strcmpi(SessionType,'rf')
    FBaseline = mean(FCorrectData(:,:,1:FrameRate),3);
end
exclude_trials = unique(exclude_inds);
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
        if ~iscell(CaTrials.f_raw)
            CaTrials.f_raw(exclude_trials,:,:)=[];
        else
            CaTrials.f_raw(exclude_trials) = [];
             TrDataNumVec(exclude_trials) = [];
            TrialLen = max(TrDataNumVec);
        end
        RawData(exclude_trials,:,:) = [];
        RawData = RawData(:,:,1:TrialLen);  % correct the maxium trial frame length
        FCorrectData(exclude_trials,:,:) = [];
        FCorrectData = FCorrectData(:,:,1:TrialLen); % correct the maxium trial frame length
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
        % havent correct for continues recording method
        ModeF0=zeros(ROINum,1);
        if ~isdir('./Mode_f0_all/')
            mkdir('./Mode_f0_all/');
        end
        cd('./Mode_f0_all/');
        %%
        for n=1:ROINum
            cROIdata = squeeze(FCorrectData(:,n,:));
            cTraceData = zeros(sum(TrDataNumVec),1);
            k = 1;
            for cTr = 1 : TrialNum
                cTraceData(k:k+TrDataNumVec(cTr)-1) = cROIdata(cTr,1:TrDataNumVec(cTr));
                k = k + TrDataNumVec(cTr);
            end
            a=reshape(cTraceData,[],1);
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
                FChangeData(m,n,1:TrDataNumVec(m)) = ((FCorrectData(m,n,1:TrDataNumVec(m)) - ModeF0(n))/ ModeF0(n))* 100;
            end

        end
        %%
        cd ..;
    case 2
        for n=1:ROINum
            for m=1:TrialNum
                FChangeData(m,n,:) = ((FCorrectData(m,n,:) - FBaseline(m,n))/FBaseline(m,n))*100;
                if IsContiAcq
                    FChangeData(m,n,TrDataNumVec(m)+1:end) = 0;
                end
            end
        end
        save ROIf0save.mat FBaseline -v7.3
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
                if IsContiAcq
                    FChangeData(LowerInds:upperInds,k,(TrDataNumVec(m)+1):end) = 0;
                end
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
        % using all data mode for calculate the f baseline
        SubRawData=zeros(size(FCorrectData));
        for n=1:size(FCorrectData,2)
            TempData=squeeze(FCorrectData(:,n,:));
            if IsContiAcq
                [SubTempData,~]=BLSubStract(TempData',8,FrameRate*30,TrDataNumVec);
            else
                [SubTempData,~]=BLSubStract(TempData',8,FrameRate*30);
            end
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
    
    case 5
        %
        SubRawData=zeros(size(FCorrectData));
        for n=1:size(FCorrectData,2)
            TempData=squeeze(FCorrectData(:,n,:));
            if IsContiAcq
                [SubTempData,~]=BLSubStract(TempData',8,FrameRate*30,TrDataNumVec);
            else
                [SubTempData,~]=BLSubStract(TempData',8,FrameRate*30);
            end
            SubRawData(:,n,:)=SubTempData';
        end
        %%
        BaseSubPreOnsetData = cell(1,TrialNum);
        for nTrs = 1 : TrialNum
            BaseSubPreOnsetData{nTrs} = squeeze(SubRawData(nTrs,:,1:TrialOnsetTime(nTrs)));
        end
        AllBasePreOnsetData = cell2mat(BaseSubPreOnsetData);
        %%
        ROIf0 = zeros(size(FCorrectData,2),1);
        for nROI = 1 : size(FCorrectData,2)
            cROIpreData = AllBasePreOnsetData(nROI,:);
            [cCount,cCenters] = hist(cROIpreData,100);
            [~,inds] = max(cCount);
            ROIf0(nROI) = cCenters(inds);
            if ~IsContiAcq
                FChangeData(:,nROI,:) = (SubRawData(:,nROI,:) - ROIf0(nROI))./ROIf0(nROI)*100;
            else
                for cTr = 1 : TrialNum
                    FChangeData(cTr,nROI,1:TrDataNumVec(cTr)) = (SubRawData(cTr,nROI,1:TrDataNumVec(cTr)) - ROIf0(nROI))./ROIf0(nROI)*100;
                end
            end
        end
        
        %%
    otherwise
        disp('Error input option, quit analysis.\n');
end
if IsContiAcq
    CellFchangeData = cell(length(TrDataNumVec),1);
    for cTr = 1 : length(TrDataNumVec)
        CellFchangeData{cTr} = squeeze(FChangeData(cTr,:,1:TrDataNumVec(cTr)));
    end
     FChangeData = CellFchangeData;
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
elseif nargout==4
    varargout{1}=FCorrectData;
    varargout{2}=FChangeData;
    varargout{3}=exclude_trials;
    varargout{4} = BaselineSubE;
end