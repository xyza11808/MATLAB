classdef DataAnalysisSum
    properties
        SmoothData
        TrialStims
        AlignedF
        FrameRate
        TimeWin = 1.5
        RespCalFun = 'Mean'
        ZscoreMethod = 'Modified'
        
        %additional properties for classification analysis
        TrialOutcome
        NeuroCLFStrc = struct();
%         ChoiceCLFstrc = struct();

        AUCvalueABS
    end
    properties(Access = 'private')
        RespMatData
        FrameRange
        
        %additional private properties for classification analysis
    end
    
    methods
        function this = DataAnalysisSum(varargin)
            if nargin < 4
                error('Not enough input.');
            end
            [this.SmoothData,this.TrialStims,this.AlignedF,this.FrameRate] = deal(varargin{1:4});
            this.TrialStims = double(this.TrialStims);
            if nargin > 4
                if ~isempty(varargin{5})
                    this.TimeWin = varargin{5};
                end
            end
            if nargin > 5
                if ~isempty(varargin{6})
                    this.RespCalFun = varargin{6};
                end
            end
            if nargin > 6
                if ~isempty(varargin{7})
                    this.ZscoreMethod = varargin{7};
                end
            end
        end
        %         DataPreProcessing(this.TimeWin,this.RespCalFun);
        
        % population noise correlation coefficience calculation
        function popuZscoredCorr(this,varargin)
            TimeWind = this.TimeWin;
            if nargin > 1
                if ~isempty(varargin{1})
                    TimeWind = varargin{1};
                end
            end
            
            RespCallFunction = this.RespCalFun;
            if nargin > 2
                if ~isempty(varargin{2})
                    RespCallFunction = varargin{2};
                end
            end
            
            ZSmethod = this.ZscoreMethod;
            if nargin > 3
                if ~isempty(varargin{3})
                    ZSmethod = varargin{3};
                end
            end
            this = this.DataPreProcessing(TimeWind,RespCallFunction);
            
            cTrStimsall = this.TrialStims;
            cSessiondata = this.RespMatData;
            
%             TrialStim = double(cTrStimsall);
            StimTypes = unique(cTrStimsall);
            nStimtype = length(StimTypes);
            zNormData = zeros(size(cSessiondata));
            k = 1;
            for nST = 1 : nStimtype
                cStim = StimTypes(nST);
                cStimTrInds = cTrStimsall == cStim;
                nTrials = sum(cStimTrInds);
                cStimTrData = cSessiondata(cStimTrInds,:);   %nTrials-by-nROI matrix
                
                switch ZSmethod
                    case 'Modified'
                        % normalization using modified z-score
                        ROImean = mean(cStimTrData);
                        ROImad = mad(cStimTrData,1);
                        ROIstdEstimate = repmat((ROImad*1.4826),nTrials,1);
                        if sum(ROImad == 0)
                            ZerosMADInds = ROImad == 0;
                            ROIextraMAD = 1.253*mad(cStimTrData(:,ZerosMADInds));
                            ROIstdEstimate(:,ZerosMADInds) = repmat(ROIextraMAD,nTrials,1);
                        end
                        zerosInds = ROIstdEstimate == 0;
                        ROIstdEstimate(zerosInds) = 1;
                        ZscoredData = (cStimTrData - repmat(ROImean,nTrials,1)) ./ ROIstdEstimate;
                    case 'normal'
                        ZscoredData = zscore(cStimTrData);
                    otherwise
                        error('Undefined zscore calculation method');
                end
                zNormData(k:(k+nTrials-1),:) = ZscoredData;
                k = k + nTrials;
            end
            [ROIcorrlation,NCp] = corrcoef(zNormData);
            MatrixmaskRaw = ones(size(ROIcorrlation));
            Matrixmask = logical(tril(MatrixmaskRaw,-1));
            PairedROIcorr = ROIcorrlation(Matrixmask);
            PairedNCpvalue = NCp(Matrixmask);
            
            if ~isdir('./Popu_Corrcoef_save_NOS/')
                mkdir('./Popu_Corrcoef_save_NOS/');
            end
            cd('./Popu_Corrcoef_save_NOS/');
            
            if length(TimeWind) == 1
                folderStr = sprintf('TimeScale %d_%dms noise correlation',0,TimeWind*1000);
            elseif length(TimeWind) == 2
                folderStr = sprintf('TimeScale %d_%dms noise correlation',TimeWind(1)*1000,TimeWind(2)*1000);
            end
            if ~isdir(folderStr)
                mkdir(folderStr);
            end
            cd(folderStr);
            
            [Count,Center] = hist(PairedROIcorr,30);
            SigInds = PairedNCpvalue < 0.05;
            [CountSig,CenterSig] = hist(PairedROIcorr(SigInds),30);
            
            h_PairedCorr = figure('position',[200 200 800 600]);
            hold on
            bar(Center,Count/sum(Count),'k');
            alpha(0.3);
            bar(CenterSig,CountSig/sum(Count),'k');
            
            xlabel('Coef value');
            ylabel('Pair Fraction');
            title(sprintf('Mean Corrcoef value = %.4f',mean(PairedROIcorr)));
            set(gca,'FontSize',20);
            saveas(h_PairedCorr,sprintf('Population %s zscored %s corrcoef distribution',ZSmethod,RespCallFunction));
            saveas(h_PairedCorr,sprintf('Population %s zscored %s corrcoef distribution',ZSmethod,RespCallFunction),'png');
            close(h_PairedCorr);

            save(sprintf('ROI%s_coefSave%s.mat',ZSmethod,RespCallFunction), 'PairedROIcorr','PairedNCpvalue', '-v7.3');
            cd ..;
            cd ..;
        end
        
        % function to calculate the signal correlation of neuron pairs
        function popuSignalCorr(this,varargin)
            TimeWind = this.TimeWin;
            if nargin > 1
                if ~isempty(varargin{1})
                    TimeWind = varargin{1};
                end
            end
            
            RespCallFunction = this.RespCalFun;
            if nargin > 2
                if ~isempty(varargin{2})
                    RespCallFunction = varargin{2};
                end
            end
            
            IsBoostrap = 0;
            if nargin > 3
                if ~isempty(varargin{3})
                    IsBoostrap = varargin{3};
                end
            end
            
            IsStdCorrect = 1;
            if nargin > 4
                if ~isempty(varargin{4})
                    IsStdCorrect = varargin{4};
                end
            end
            
            this = this.DataPreProcessing(TimeWind,RespCallFunction);
            StimAll = this.TrialStims;
            RespDataMatrix = this.RespMatData; % nTrials-by-nROI matrix
            StimTypes = unique(StimAll);
            nStims = length(StimTypes);
            nROIs = size(RespDataMatrix,2);
            ROIStimRespMatrix = zeros(nStims,nROIs);
            if IsStdCorrect
                ROIstdss = this.RawDataStd(this.SmoothData,'mad');
            end
            
            if IsBoostrap
                %
                nIters = 1000;
                BootStimRespMatrix = zeros(nIters,nROIs,nROIs); % data matrix for corrcoef value storage
                BootStimRespValue = zeros(nIters,nStims,nROIs);
                PopuStd = mean(ROIstdss);  % using the population mean for data transfer load saving
                parfor nIt = 1 : nIters
                    RandInds = CusRandSample(StimAll,0.8);
                    IterStims = StimAll(RandInds);
                    IterData = RespDataMatrix(RandInds,:); %#ok<PFBNS>
                    BootStimRespData = zeros(nStims,nROIs);
                    for nxnx = 1 : nStims
                        cStim = StimTypes(nxnx); %#ok<PFBNS>
                        cStimInds = IterStims == cStim;
                        BootStimRespData(nxnx,:) = mean(IterData(cStimInds,:));
                    end
                    if IsStdCorrect
                        RespDataVector = reshape(BootStimRespData,[],1);
                        LowRespVectorInds = RespDataVector < PopuStd;
                        LowRespData = RespDataVector(LowRespVectorInds);
                        ShufLowRespData = Vshuffle(LowRespData);
                        NewShufRespData = RespDataVector;
                        NewShufRespData(LowRespVectorInds) = ShufLowRespData;
                        NewShufRespData = reshape(NewShufRespData,nStims,nROIs);
                        BootStimRespData = NewShufRespData;
%                         % ######################
%                         % another method is to use random Assignment of a
%                         % gaussian distribution data set to replace old
%                         % data
%                         RespDataVector = reshape(BootStimRespData,[],1);
%                         LowRespVectorInds = RespDataVector < PopuStd;
%                         RandLowRespValue = ((rand(sum(LowRespVectorInds),1) - 0.5)*2)*PopuStd;
%                         NewRandAssData = RespDataVector;
%                         NewRandAssData(LowRespVectorInds) = RandLowRespValue;
%                         BootStimRespData = NewRandAssData;
%                         % #######################
                    end
                    BootStimRespValue(nIt,:,:) = BootStimRespData;
                    IterSigCorr = corrcoef(BootStimRespData);
                    BootStimRespMatrix(nIt,:,:) = IterSigCorr;
                end
                %
                BootMeanSignalCoef = squeeze(mean(BootStimRespMatrix));
                PopuSignalCorr = BootMeanSignalCoef;
                SCp = ones(size(PopuSignalCorr));
            else
                %
                for nmnm = 1 : nStims
                    cStims = StimTypes(nmnm);
                    cStimInds = StimAll == cStims;
                    ROIStimRespMatrix(nmnm,:) = mean(RespDataMatrix(cStimInds,:));
                end
                ROIlowRespInds = zeros(size(ROIStimRespMatrix));
                if IsStdCorrect
                   for  nnrr = 1 : nROIs
                       ROIlowRespInds(:,nnrr) = double(ROIStimRespMatrix(:,nnrr) < ROIstdss(nnrr));
                   end
                end
                
                nmShufCoef = zeros(100,nROIs,nROIs);
                SCpShuf = zeros(100,nROIs,nROIs);
                for nmnm = 1 : 100
                    ROIlowRespInds = logical(ROIlowRespInds(:));
                    VectorData = reshape(ROIStimRespMatrix,[],1);
                    LowRespData = VectorData(ROIlowRespInds);
                    ShufLowRespdata = Vshuffle(LowRespData);
                    NewShufDataMatrix = VectorData;
                    NewShufDataMatrix(ROIlowRespInds) = ShufLowRespdata;
                    NewShufDataMatrix = reshape(NewShufDataMatrix,nStims,nROIs);
                    ROIStimRespMatrix = NewShufDataMatrix;
                    %%
    %                 % ######################
    %                 % another method is to use random Assignment of a
    %                 % gaussian distribution data set to replace old
    %                 % data
    %                 RespDataVector = reshape(ROIStimRespMatrix,[],1);
    %                 LowRespVectorInds =  logical(ROIlowRespInds(:));
    %                 PopuStd = mean(ROIstdss);
    %                 RandLowRespValue = ((rand(sum(LowRespVectorInds),1) - 0.5)*2)*PopuStd;
    %                 NewRandAssData = RespDataVector;
    %                 NewRandAssData(LowRespVectorInds) = RandLowRespValue;
    %                 NewRandAssData = reshape(NewRandAssData,nStims,nROIs);
    %                 ROIStimRespMatrix = NewRandAssData;
    %                 % #######################

                    % calculate the signal correlation
                    [PopuSignalCorr,SCp] = corrcoef(ROIStimRespMatrix);
                    nmShufCoef(nmnm,:,:) = PopuSignalCorr;
                    SCpShuf(nmnm,:,:) = SCp;
                end
                PopuSignalCorr = squeeze(mean(nmShufCoef));
                SCp = squeeze(mean(SCpShuf));
            end
            
            MatrixmaskRaw = ones(size(PopuSignalCorr));
            Matrixmask = logical(tril(MatrixmaskRaw,-1));
            PairedROISigcorr = PopuSignalCorr(Matrixmask);
            PairedSCpvalue = SCp(Matrixmask);
            
            if ~isdir('./Popu_signalCorr_Plot/')
                mkdir('./Popu_signalCorr_Plot/');
            end
            cd('./Popu_signalCorr_Plot/');
            
            [SCCount,SCCenter] = hist(PairedROISigcorr,30);
            SCSigInds = PairedSCpvalue < 0.05;
            PairedSigCoef = PairedROISigcorr(SCSigInds);
            if ~isempty(PairedSigCoef)
                [SCCountSig,SCCenterSig] = hist(PairedSigCoef,30);
            end
            h_signalCorr = figure('position',[200 200 800 600]);
            hold on
            bar(SCCenter,SCCount/sum(SCCount),'k');
            alpha(0.3);
             if ~isempty(PairedSigCoef)
                bar(SCCenterSig,SCCountSig/sum(SCCount),'k');
             end
            xlabel('Coef value');
            ylabel('Pair Fraction');
            title(sprintf('Mean Corrcoef value = %.4f',mean(PairedROISigcorr)));
            set(gca,'FontSize',20);
            if IsBoostrap
                saveas(h_signalCorr,'Signal_correlation_of_current_session_Boot');
                saveas(h_signalCorr,'Signal_correlation_of_current_session_Boot','png');
            else
                saveas(h_signalCorr,'Signal_correlation_of_current_session');
                saveas(h_signalCorr,'Signal_correlation_of_current_session','png');
            end
            close(h_signalCorr);
            
            if ~IsBoostrap
                save SignalCorrSave.mat PairedROISigcorr PairedSCpvalue ROIStimRespMatrix -v7.3
            else
                save SignalCorrSaveBoot.mat PairedROISigcorr PairedSCpvalue BootStimRespMatrix BootStimRespValue -v7.3
            end
            cd ..;
        end
        % Paired stimulus ROC analysis
        function varargout = PairedAUCCal(this,varargin)
            TimeWind = this.TimeWin;
            if nargin > 1
                if ~isempty(varargin{1})
                    TimeWind = varargin{1};
                end
            end
            
            RespCallFunction = this.RespCalFun;
            if nargin > 2
                if ~isempty(varargin{2})
                    RespCallFunction = varargin{2};
                end
            end
            this = this.DataPreProcessing(TimeWind,RespCallFunction);
            
            nROIs = size(this.RespMatData,2);
            StimulusTypes = unique(this.TrialStims);
            StimNumber = length(StimulusTypes);
            PairedNum = StimNumber*(StimNumber - 1)/2;
            nROIpairedAUC = zeros(nROIs,PairedNum);
            nROIpairedAUCIsRev = zeros(nROIs,PairedNum);
            %%
            k = 1;
           for nStimNeg = 1 : StimNumber
               for nStimPos = (nStimNeg+1) : StimNumber
                   RespDatas = this.RespMatData;
                   StimsAll = this.TrialStims;
                    parfor nROI = 1 : nROIs
                        nROIData = RespDatas(:,nROI);
                        
                        nStimNegInds = StimsAll == StimulusTypes(nStimNeg);
                        nStimPosInds = StimsAll == StimulusTypes(nStimPos);
                        NegInputData = [nROIData(nStimNegInds),zeros(length(nROIData(nStimNegInds)),1)];
                        PosInputData = [nROIData(nStimPosInds),ones(length(nROIData(nStimPosInds)),1)];
                        [ROCSummary,LabelMeanS]=rocOnlineFoff([NegInputData;PosInputData]);
                        
                        nROIpairedAUC(nROI,k) = ROCSummary;
                        nROIpairedAUCIsRev(nROI,k) = double(LabelMeanS);
                    end
                    k = k + 1;
                end
           end
            %%
%             save PairedROIAuc.mat nROIpairedAUC nROIpairedAUCIsRev -v7.3
            
            % plot each ROI's paired AUC value using private function
            ROIwisedAUC = this.PairedAUCplot(nROIpairedAUC,nROIpairedAUCIsRev,StimNumber);
            Tickstr = cellstr(num2str(StimulusTypes(:)/1000,'%.2f'));
            if ~isdir('./ROI_pairedWiseAUC_plot/')
                mkdir('./ROI_pairedWiseAUC_plot/');
            end
            cd('./ROI_pairedWiseAUC_plot/');
            for nROI = 1 : nROIs
                cROImatrix = squeeze(ROIwisedAUC(nROI,:,:));
                h = figure;
                imagesc(cROImatrix,[0.5,1]);
                set(gca,'xtick',1:StimNumber,'xticklabel',Tickstr,'ytick',1:StimNumber,'yticklabel',Tickstr);
                title(sprintf('ROI%d StumPaired AUC',nROI));
                set(gca,'FontSize',16);
                Ac = colorbar;
                set(Ac,'ytick',[0.5,0.7,0.9,1]);
                saveas(h,sprintf('ROI%d pairedwise ROC analysis',nROI));
                saveas(h,sprintf('ROI%d pairedwise ROC analysis',nROI),'png');
                close(h);
            end
            save StimPairedAUC.mat StimulusTypes nROIpairedAUC nROIpairedAUCIsRev ROIwisedAUC -v7.3
            GroupWiseAUCCal(nROIpairedAUC,nROIpairedAUCIsRev,ROIwisedAUC,StimulusTypes);
            cd ..;
            
            if nargout > 0
                varargout{1} = ROIwisedAUC;
            end
        end
        
        function TbyTAllROIclf(this,Troutcome,varargin)
            % Trial by trial result
            this = ClfParaParser(this,varargin{:});
            this.TrialOutcome = Troutcome; %vector indicates the trial outcomes for each trial
            TbyTAllROIclfIPForclass(this);
        end
        
        function FracROIclf(this,isLoadROIAUC,TrOutcomes,varargin)
            if length(unique(this.TrialStims)) > 2
                        StimTypes = unique(this.TrialStims);
                        StimBoundary = StimTypes(length(StimTypes)/2);
                        TrTypes = this.TrialStims > StimBoundary;
            else
                TrTypes = this.TrialStims;
            end
            this.TrialOutcome = TrOutcomes;
            if isempty(this.AUCvalueABS)
                if isLoadROIAUC
                    [fn,fp,~] = uigetfile('AUCClassData.mat','Please select your ROI auc data file');
                    xx = load(fullfile(fp,fn));
                    AUCvalue = xx.AUCDataAS;
                else
                    fprintf('ROI auc data file unavailuable, calculate it first...\n');
                    
                    AUCvalue = ROC_check(this.SmoothData,TrTypes,this.AlignedF,this.FrameRate,this.TimeWin,'Stim_time_Align');
                end
                this.AUCvalueABS = AUCvalue;
            end
            TrOutOption = 1;
            if nargin > 3
                if ~isempty(varargin{1})
                    TrOutOption = varargin{1};
                end
            end
            FracTbyTPlot(this.SmoothData,TrTypes,TrOutcomes,this.AlignedF,this.FrameRate,AUCvalue,this.TimeWin,TrOutOption);
        end
        
        function MultiClfCal(this,TrOutcomes,TimeStep,varargin)
            if isempty(TimeStep)
                TimeStep = 0.1;
            end
            this = ClfParaParser(this,varargin{:});
            MultiTimeWinClf(this.SmoothData,this.TrialStims,TrOutcomes,this.AlignedF,this.FrameRate,this.NeuroCLFStrc,TimeStep);
        end
         
         
    end
    methods(Access = 'private')
        function this = DataPreProcessing(this,TimeWin,RespCalFun)
            % preprocessing of input data
            nFrame = size(this.SmoothData,3);
            if length(TimeWin) == 1
                FrameScale = sort([(this.AlignedF+1),(this.AlignedF + round(TimeWin*this.FrameRate))]);
            elseif length(TimeWin) == 2
                FrameScale = sort([(this.AlignedF+round(TimeWin(1)*this.FrameRate)),(this.AlignedF + round(TimeWin(2)*this.FrameRate))]);
            end
            if FrameScale(1) < 1
                if FrameScale(2) < 1
                    error('Error trial selection range.');
                end
                fprintf('Select frame scale lower bound less than 1, reset to 1.\n');
                FrameScale(1) = 1;
            end
            if FrameScale(2) > nFrame
                if FrameScale(1) > nFrame
                    error('Error Triasl selection range.');
                end
                fprintf('Select frame scale upper bound larger than %d, reset to %d.\n',nFrame,nFrame);
                FrameScale(2) = nFrame;
            end
            this.FrameRange = FrameScale;
            
            switch RespCalFun
                case 'Mean'
                    RespMatrix = mean(this.SmoothData(:,:,FrameScale(1):FrameScale(2)),3);
                    RespMatrix = squeeze(RespMatrix);
                case 'Max'
                    RespMatrix = max(this.SmoothData(:,:,FrameScale(1):FrameScale(2)),[],3);
                otherwise
                    error('Error response calculation function.');
            end
            this.RespMatData = RespMatrix;
        end
        
        function ROIwisedAUC = PairedAUCplot(this,RawAUC,ROCRevert,NumStim)
%             nROIpairedAUC = zeros(nROIs,PairedNum);
                ROCABS = RawAUC;
                ROCABS(logical(ROCRevert)) = 1 - ROCABS(logical(ROCRevert));
                ROIwisedAUC = zeros(size(ROCABS,1),NumStim,NumStim);
                for nnn = 1 : size(ROCABS,1)
                    cROIPairAUC = ROCABS(nnn,:);
                    MatrixAUC = squareform(cROIPairAUC);
                    MatrixAUC(MatrixAUC == 0) = 0.5;  % set the diag value into chance level
                    ROIwisedAUC(nnn,:,:) = MatrixAUC;
                end
        end
        function ROIstds = RawDataStd(this,RawData,Method)
            nROIs = size(RawData,2);
            ROIstds = zeros(nROIs,1);
            for nr = 1 : nROIs
                cROIdata = reshape(squeeze(RawData(:,nr,:))',[],1); % vector format
                switch Method
                    case {'Std','std','STD'}
                        ROIstds(nr) = std(cROIdata);
                    case {'Mad','mad','MAD'}
                        ROIstds(nr) = mad(cROIdata,1)*1.4826;
                    case {'MadMean','madmean','MADMEAN'}
                        ROIstds(nr) = mad(cROIdata)*1.253;
                    otherwise
                        error('Unknown method, please check your input.');
                end
                if ROIstds(nr) < 1
                    ROIstds(nr) = 1; % for spike data correction
                end
            end
                
        end
        function this = ClfParaParser(this,varargin)
            % this function is specifically used for parsing of
            % classification input parameters
            p = inputParser;
            addRequired(p,'this',@isobject);
            defaultIsshuffle = 0;
            defaultIsmodelload = 0;
            defaultIspartialROI = true(size(this.SmoothData,2),1);
            defaultTroutcome = 1;
            defaultisDataOutput = 0;
            defaultisErrorCal = 0;
            defaultisDisLogiFit = 0;
            defaultisWeightsave = 0;
            defaultTimeWin = this.TimeWin;
            
            addParameter(p,'isShuffle',defaultIsshuffle);
            addParameter(p,'isLoadModel',defaultIsmodelload);
            addParameter(p,'PartialROIInds',defaultIspartialROI);
            addParameter(p,'TrOutcomeOp',defaultTroutcome);
            addParameter(p,'isDataOutput',defaultisDataOutput);
            addParameter(p,'isErCal',defaultisErrorCal);
            addParameter(p,'isDisLogisFit',defaultisDisLogiFit);
            addParameter(p,'isWeightsave',defaultisWeightsave);
            addParameter(p,'TimeWinLen',defaultTimeWin);
            p.KeepUnmatched = true;
            parse(p,this,varargin{:});
            
            this.NeuroCLFStrc = p.Results;
            this.NeuroCLFStrc = rmfield(this.NeuroCLFStrc,'this');
            this.NeuroCLFStrc.TimeLen = this.TimeWin;
        end
        
    end
end
