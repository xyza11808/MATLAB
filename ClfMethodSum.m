classdef ClfMethodSum < handle
    properties
        PopuData
        TrialStim
        TrialOutcome
        AlignF
        FrameRate
        TimeWin
        isShuffle
        isModelLoad
        isPartialROI
        TrialOutcomeOption % 1 for correct trials only, 0 for non-missing trials, 
                            % 2 for all trials
        isDataOutput
        FeatureMethod  % 1 stands for max method, 2 stands for mean method, using max function as default
        
    end
    
    properties(Access = 'private')
        PopuTestset
        TrialStimTest
        PopuTrainset
        TrialStimTrain
        ROIFraction
        nROIs
        StartTime
        TimeScale
        SessionDataMatrix
        TrialsUsing
        TrialTypesAll
        TrialTypesTest
        TrialTypesTrain
    end
    
    methods 
        function this = ClfMethodSum(varargin)  % partial data into class variable
            if length(varargin) < 6
                error('Not enough input.');
            end
            [SessionData,SessionStim,SessionTrResult,Alignfr,frame_rate,TimeWin] = ...
                deal(varargin{1:6});
            Shuffle = [];
            if length(varargin) > 6
                Shuffle = varargin{7};
            end
            ROIfraction = [];
            if length(varargin) > 7
                ROIfraction = varargin{8};
            end
            TrialOutcome = [];
            if length(varargin) > 8
                TrialOutcome = varargin{9};
            end
            DataOutput = [];
            if length(varargin) > 9
                DataOutput = varargin{10};
            end
            FeatureSel = [];
            if length(varargin) > 10
                FeatureSel = varargin{11};
            end
            ModelLoad = [];
            if length(varargin) > 11
                ModelLoad = varargin{12};
            end
           
            % value assignment
            this.PopuData = SessionData;
            this.TrialStim = SessionStim;
            this.TrialOutcome = SessionTrResult;
            this.AlignF = Alignfr;
            this.FrameRate = frame_rate;
            this.TimeWin = TimeWin;
%             this.ClassfMethod = cfMethod;  % classification method will
%             be determinded by input function name
            this.isShuffle = Shuffle;
            this.isPartialROI = ROIfraction;
            this.TrialOutcomeOption  = TrialOutcome;
            this.isDataOutput = DataOutput;
            this.FeatureMethod = FeatureSel;
            this.isModelLoad = ModelLoad;
        end
        
        function varargout = TbyTClfsvm(this,varargin)  % Trial by trial classification function
            %  support for binary classification of trial types and
            %  multi-class classification of trial stims
            isplot = 1;
            if isempty(varargin)
                isplot = varargin{1};
            end
            nIters = 1000;
            if length(varargin) > 1
                if ~isempty(varargin{2})
                    nIters = varargin{2};
                end
            end
            ClfMethod = 'SingleBinaryClf';
            if length(varargin) > 2
                if ~isempty(varargin{3})
                    ClfMethod = varargin{3};
                end
            end
            
            if strcmpi(ClfMethod,'SingleBinaryClf')
                TestErrorrate = zeros(nIters,1);
                parfor nmnm = 1 : nIters
                    ClfMethodSum.DataPartionfun();
                    TrainM = fitcsvm(this.PopuTrainset,this.TrialTypesTrain);
                    ModelPred = predict(TrainM,this.PopuTestset);
                    TestErro = sum(abs(ModelPred - double(this.TrialTypesTest(:))))/length(ModelPred);
                    TestErrorrate(nmnm) = TestErro;
                end
                varargout{1} = TestErrorrate;
                fprintf('Mean test data set error is %.3f',mean(TestErrorrate));
                if isplot
                    h_plot = figure;
                    hist(TestErrorrate,20);
                    xlabel('Test data error');
                    ylabel('Data count');
                    title('Test dataset error distribution');
                    varargout{2} = h_plot;
                end
            elseif strcmpi(ClfMethod,'MultiClassClf')
                MulErrorRate = zeros(nIters,1);
                option = statset('UseParallel',1,'Display','final');
                t = templateSVM('Solver','SMO','SaveSupportVectors',true,'KernelFunction','linear');
                
                for nmnm = 1 : nIters
                    ClfMethodSum.DataPartionfun();
                    tbl = fitcecoc(this.PopuTrainset,this.TrialStimTrain,'Coding','onevsone','Learners',t,...
                        'Prior','uniform','options',option);
                    TestResult = predict(tbl,this.PopuTestset);
                    PredAccuracy = TestResult == this.TrialStimTest(:);
                    MulErrorRate(nmnm) = sum(PredAccuracy)/length(PredAccuracy); 
                end
                varargout{1} = MulErrorRate;
                
                StimTypes = unique(this.TrialStim);
                NumStims = length(StimTypes);
                ClassPairedNum = NumStims*(NumStims-1)/2;
                m = 1;
                nIters = 100;
                ClassPairError = zeros(ClassPairedNum,nIters);
                for nmnm = 1 : NumStims
                    for nxnx = (nmnm+1) : NumStims
                        cPositiveInds = this.TrialStim == StimTypes(nmnm);
                        cNegtiveInds = this.TrialStim == StimTypes(nxnx);
                        AllInds = logical(cPositiveInds + cNegtiveInds);
                        cDataAll = this.SessionDataMatrix(AllInds);
                        cStimaAll = this.TrialStim(AllInds);
                        cStimaAll = cStimaAll(:);
                        parfor npnp = 1 : nIters
                            TrainInds = false(length(cStimaAll),1);
                            TrainIndex = randsample(length(cStimaAll),round(length(cStimaAll)*0.7));
                            TrainInds(TrainIndex) = true;
                            TestInds = ~TrainInds;
                            
                            IterM = fitcsvm(cDataAll(TrainInds,:),cStimaAll(TrainInds));
                            PredStimC = predict(IterM,cDataAll(TestInds,:));
                            PredAccuracy = sum(PredStimC == cStimaAll(TestInds))/length(PredStimC);
                            ClassPairError(m,npnp) = PredAccuracy;
                        end
                        m = m + 1;
                    end
                end
                varargout{2} = ClassPairError;
                if isplot
                    h_mul = figure('position',[200 200 1300 850]);
                    subplot(1,2,1)
                    hist(MulErrorRate,20);
                    xlabel('Multi-class classfication error rate');
                    ylabel('Error count');
                    
                    subplot(1,2,2)
                    TypeErrorALlc = mean(ClassPairError,2);
                    MatrixData = squareform(TypeErrorALlc);
                    imagesc(MatrixData);
                    xlabel('Stim Class');
                    ylabel('Stim Class');
                    title('Paired class error rate');
                    colorbar;
                    varargout{3} = h_mul;
                end
            else
                error('Input method is not predefined.');
            end
        end
    end
    
    methods(Access = 'private')
        function ParaDismantle(this)
            % Process input data for further analysis
            if isempty(this.PopuData) || isempty(this.TrialStim) || isempty(this.TrialOutcome)
                error('Input data error, empty input.');
            end
            if isempty(this.AlignF) || isempty(this.FrameRate) || isempty(this.TimeWin)
                error('Time selection error, empty input.');
            end
            if ~isempty(this.isShuffle)
                if this.isShuffle
                    NormVector = this.TrialStim;
                    ShuffleVec = Vshuffle(NormVector);
                    this.TrialStim = ShuffleVec;
                end
            end
            this.nROIs = size(this.PopuData,2);
            this.ROIFraction = true(this.nROIs,1);
            RawData = this.PopuData;
            if ~isempty(this.isPartialROI)
                ROIFracs = this.isPartialROI;
                UsingData = RawData(:,ROIFracs,:);
            end
            Frame_Rate = this.FrameRate;
            AlignFrame = this.AlignF;
            TimeLength = this.TimeScale;
            if length(TimeLength) == 1
                FrameScale = sort([AlignFrame,AlignFrame+round(TimeLength*Frame_Rate)]);
            elseif length(TimeLength) == 2
                FrameScale = sort([AlignFrame+round(TimeLength(1)*Frame_Rate),AlignFrame+round(TimeLength(2)*Frame_Rate)]);
                this.StartTime = min(TimeLength);
                this.TimeScale = max(TimeLength) - min(TimeLength);
            else
                warning('Input TimeLength variable have a length of %d, but it have to be 1 or 2',length(TimeLength));
                return;
            end
            if FrameScale(1) < 1
                warning('Time Selection excceed matrix index, correct to 1');
                FrameScale(1) = 1;
                if FrameScale(2) < 1
                    error('ErrorTimeScaleInput');
                end
            end
            if FrameScale(2) > size(RawDataAll,3)
                warning('Time Selection excceed matrix index, correct to %d',size(RawData,3));
                FrameScale(2) = size(RawData,3);
                if FrameScale(2) > size(RawData,3)
                    error('ErrorTimeScaleInput');
                end
            end
            if isempty(this.FeatureMethod)
                FeatFun = 1;
            else
                FeatFun = this.FeatureMethod;
            end
            if FeatFun == 1
                UsingDataMatrix = max(UsingData(:,:,FrameScale(1):FrameScale(2),[],3));
            elseif FeatFun == 2
                UsingDataMatrix = squeeze(mean(UsingData(:,:,FrameScale(1):FrameScale(2),3)));
            else
                error('Error input method for response feature calculation.');
            end
            this.SessionDataMatrix = UsingDataMatrix;
            TrialOutOp = 1;
            if ~isempty(this.TrialOutcomeOption)
                TrialOutOp = this.TrialOutcomeOption;
            end
            switch TrialOutOp 
                case 0
                    TrialSelect = this.TrialOutcome ~= 2;
                case 1
                    TrialSelect = this.TrialOutcome == 1;
                case 2
                    TrialSelect = true(length(this.TrialOutcome),1);
                otherwise
                    error('Error input trial outcomes option.');
            end
            this.TrialsUsing = TrialSelect;
            ClfMethodSum.TrialStim2Type();
        end
        
        function DataPartionfun(this)
            % partion data set into train and test set
            Trialused = this.TrialsUsing;
            
            DataMatrix = this.SessionDataMatrix(Trialused,:);
            TrialStimAll = this.TrialStim(Trialused);
            TrainingInds = false(length(TrialStimAll),1);
            TrainIndex = randsample(length(TrialStimAll),round(length(TrialStimAll)*0.8));
            TrainingInds(TrainIndex) = true;
            TestInds = ~TrainingInds;
            
            this.PopuTestset = DataMatrix(TestInds,:);
            this.TrialStimTest = TrialStimAll(TestInds);
            this.PopuTrainset = DataMatrix(TrainingInds,:);
            this.TrialStimTrain = TrialStimAll(TrainingInds);
            this.TrialTypesTest = this.TrialTypesAll(TestInds);
            this.TrialTypesTrain = this.TrialTypesAll(TrainingInds);
        end
        
        function TrialStim2Type(this)
            % convert stim vector into trial type vector
            StimType = unique(this.TrialStim);
            StimThres = StimType(length(StimType)/2);
            TrialTypes = this.TrialStim > StimThres;
            this.TrialTypesAll = TrialTypes;
        end
    end
end
        