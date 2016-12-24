function p_cGivenf = NBCGeneAndTest(TrainingSet,TrainingC,TestingSet,varargin)
% TrainingC is a two columns matrix, first column corresponded to left-right trial
% types, second column corresponded to trial stimulus
% For single observation analysis, density function can be modified for
% better estimation of real distribution. The availuable function is as
% following: 
    % normal: variable value following normal distribuion, using mean and
    %         std value for probability calculation
    % ProbKernal: using a custom kernal to fit real data value, more useful
    %         when only a small amount of data is availuable, using ksdensity function
    % ProbKernalCdf: cumulaive probability calculation for customized
    % kernal function, using ksdensity function as well
% the default probability function for single observation is normal
% distribution
% XIN Yu, 2016

TrialChoice = TrainingC(:,2);
TrialStim = TrainingC(:,1);
NumFreq = unique(TrialStim); % frequency types number
numChoice = unique(TrialChoice); %animal choice type, basically just left or right
nROIs = size(TrainingSet,2);
if nROIs > 1
    fprintf('Mult-observation exits, using multivaruate guassian distribution to calculate probability distribution.\n');
    isSingleObs = 0;
else
    isSingleObs = 1;
    fprintf('Single input observation, using given method to calculate probability density.\n');
    DensityFun = 'normal';
    if nargin < 4 || isempty(varargin{1})
        warning('No input option of probability function, using default nromal distrition.');
    else
        DensityFun = varargin{1};
    end
    if ~strcmpi(DensityFun,'normal')
        % using kernal function for calculation
        iskernalFun = 1;
    end
end
%%
% pre-processing
% population response prob
% PopuRespPara = ([mean(TrainingSet);std(TrainingSet)])'; % nROI by 2 matrix, first column is summarized mean, second column is summarized std
if ~isSingleObs
    PopuCovMatrix = cov(TrainingSet); % nROI-by-nROI covariance matrix
end

% Choice type probability
ChoiceInds = cell(length(numChoice),1);
CHoiceProb = zeros(1,length(numChoice));
ChoiceProbPara = cell(length(numChoice),1);
ChoiceMu = zeros(length(numChoice),nROIs);
ChoiceSigma = zeros(length(numChoice),nROIs);
for nn = 1 : length(numChoice)
    ChoiceInds{nn} = TrialChoice == numChoice(nn);
    CHoiceProb(nn) = sum(ChoiceInds{nn})/length(TrialChoice);
    ChoiceData = TrainingSet(ChoiceInds{nn},:);
    ChoiceRespMean = mean(ChoiceData);
    ChoiceRespstd = std(ChoiceData);
    ChoiceProbPara{nn} = [ChoiceRespMean;ChoiceRespstd];
    ChoiceMu(nn,:) = ChoiceRespMean;
    ChoiceSigma(nn,:) = ChoiceRespstd;
end
% MatrixForPopuMean = repmat(ChoiceMu,nROIs,1);
% MatrixForPopuStd = repmat(ChoiceSigma,nROIs,1);
% p_MatrixClass = repmat(CHoiceProb,nROIs,1);
%%
% frequency type probability
FreqInds = cell(length(NumFreq),1);
FreqProb = zeros(length(NumFreq),1);
% DataDisParameter = cell(length(NumFreq),1);  % assuming a gaussian distribution for cell response
FreqClassMean = zeros(length(NumFreq),nROIs);
FreqClassStd = zeros(length(NumFreq),nROIs);
for nm = 1 : length(NumFreq)
    FreqInds{nm} = TrialStim == NumFreq(nm);
    FreqProb(nm) = sum(FreqInds{nm})/length(TrialStim);
    AllROIResp = TrainingSet(FreqInds{nm},:); % two dimensional matrix, with only mean and std meaningful for distribution analysis
    AllROIMean = mean(AllROIResp);
    FreqClassStd(nm,:) = std(AllROIResp);
%     DataDisParameter{nm} = [AllROIMean;AllROIstd]; %parameters for gaussian distribution, each column corresponded to a ROI
    FreqClassMean(nm,:) = AllROIMean;
    
end

%%
if ~isSingleObs
    % calculate the population probability using multivariate gaussian
    % distribution
    % calculate p(c|x) = p(x|c) * p(c)/p(x)
    % p(x) = sum(p(x,ci)) = p(x|c1)*p(c1) + p(x|c2)*p(c2) + ...
    % p(x|f) and p(x|c) will all be considered as multivariate gaussian
    % distribution
    nTTr = size(TestingSet,1);
    % TestingSet = TestingSet'; % nROI by nTrials
    ProbSummaryTypeClass = zeros(nTTr,length(numChoice));
    ProbSummaryFreqClass = zeros(nTTr,length(NumFreq));
    p_cGivenf = zeros(nTTr,length(numChoice),length(NumFreq));
    % p_cGivenfNor = zeros(nTTr,length(numChoice),length(NumFreq));
    % p_cGivenfSumNor = zeros(nTTr,length(numChoice),length(NumFreq));
    p_cGivenx_all = zeros(nTTr,length(numChoice));
    for nttr = 1 : nTTr
        % for each test trial, calculate following values
        cTestTrial = TestingSet(nttr,:);

        % calculate p(x)
        for nnh = 1 : length(numChoice)
            p_xGivenC = mvncdf(cTestTrial,ChoiceMu(nnh,:),PopuCovMatrix);
            ProbSummaryTypeClass(nttr,nnh) = p_xGivenC * CHoiceProb(nnh);  % p_xGivenC * p_c
        end
        p_cGivenx_all(nttr,:) = ProbSummaryTypeClass(nttr,:)/sum(ProbSummaryTypeClass(nttr,:));

        % calculate p(x|f)
        for nfreqs = 1 : length(NumFreq)
            p_xGivenf = mvncdf(cTestTrial,FreqClassMean(nfreqs,:),PopuCovMatrix);
            ProbSummaryFreqClass(nttr,nfreqs) = p_xGivenf;
        end

        % calculate p(c|f)
        for njk = 1 : length(numChoice)
            cClassProb = p_cGivenx_all(nttr,njk);
            p_cGivenf(nttr,njk,:) = cClassProb .* ProbSummaryFreqClass(nttr,:);
    %         p_cGivenfNor(nttr,njk,:) = p_cGivenf(nttr,njk,:)/max(p_cGivenf(nttr,njk,:));
    %         p_cGivenfSumNor(nttr,njk,:) = p_cGivenf(nttr,njk,:)/sum(p_cGivenf(nttr,njk,:));
        end

    end
else
    nTTr = size(TestingSet,1);
    switch DensityFun
        case {'normal','gaussian'}
            fprintf('Using normal distribution as probability density function.\n');
           %%
            % calculate p(x|f) value using normal distribution
            % may need to normalized to summation equals to 1
            FreqProbTestAll = zeros(nTTr,length(NumFreq));
            for nf = 1 : length(NumFreq)
                cfDisFuncProb = normcdf(TestingSet,FreqClassMean(nf),FreqClassStd(nf));
                FreqProbTestAll(:,nf) = cfDisFuncProb(:);
            end
            
            %%
            % calculate the p(x|c) value using same distribution
            % may need to normalized to summation equals to 1
            ClassProbTestAll = zeros(nTTr,length(numChoice));
            for nc = 1 : length(numChoice)
                ccDisFuncProb = normcdf(TestingSet,ChoiceMu(nc),ChoiceSigma(nc));
                ClassProbTestAll(:,nc) = ccDisFuncProb(:);
            end
            
            %%
            classPAll = (CHoiceProb(:))';
            p_xGivenc_pc = ClassProbTestAll .* repmat(classPAll,nTTr,1);
            p_cGivenx = p_xGivenc_pc ./ repmat(sum(p_xGivenc_pc,2),1,length(numChoice)); % nTestTrials-by-numberClass
%             p_cGivenf = p_cGivenx' * FreqProbTestAll;
            p_cGivenf = zeros(nTTr,length(numChoice),length(NumFreq));
            for nnn = 1 : nTTr
                p_cGivenf(nnn,:,:) = p_cGivenx(nnn,:)' * FreqProbTestAll(nnn,:);
            end
            
        case 'ProbKernal'
            fptintf('Using kernal distribution as probability density function.\n');
            
            % calculate p(x|f) using kernal density function
            FreqProbTestAll = zeros(nTTr,length(NumFreq));
            for nf = 1 : length(NumFreq)
                cfDisFuncProb = ksdensity(TestingSet,TrainingSet(FreqInds{nf}));
                FreqProbTestAll(:,nf) = cfDisFuncProb(:);
            end
            
            % calculate the p(x|c) value using same distribution
            ClassProbTestAll = zeros(nTTr,length(numChoice));
            for nc = 1 : length(numChoice)
                ccDisFuncProb = normcdf(TestingSet,TrainingSet(ChoiceInds{nc}));
                ClassProbTestAll(:,nc) = ccDisFuncProb(:);
            end
            classPAll = (CHoiceProb(:))';
            p_xGivenc_pc = ClassProbTestAll .* repmat(classPAll,nTTr,1);
            p_cGivenx = p_xGivenc_pc ./ repmat(sum(p_xGivenc_pc,2),1,length(numChoice)); % nTestTrials-by-numberClass
%             p_cGivenf = p_cGivenx' * FreqProbTestAll;
            p_cGivenf = zeros(nTTr,length(numChoice),length(NumFreq));
            for nnn = 1 : nTTr
                p_cGivenf(nnn,:,:) = p_cGivenx(nnn,:)' * FreqProbTestAll(nnn,:);
            end
        case 'ProbKernalCdf'
            fptintf('Using kernal distribution as probability density function, but using cdf function.\n');
            
            % calculate p(x|f) using kernal density function
            FreqProbTestAll = zeros(nTTr,length(NumFreq));
            for nf = 1 : length(NumFreq)
                cfDisFuncProb = ksdensity(TestingSet,TrainingSet(FreqInds{nf}),'function','cdf');
                FreqProbTestAll(:,nf) = cfDisFuncProb(:);
            end
            
            % calculate the p(x|c) value using same distribution
            ClassProbTestAll = zeros(nTTr,length(numChoice));
            for nc = 1 : length(numChoice)
                ccDisFuncProb = normcdf(TestingSet,TrainingSet(ChoiceInds{nc}),'function','cdf');
                ClassProbTestAll(:,nc) = ccDisFuncProb(:);
            end
            classPAll = (CHoiceProb(:))';
            p_xGivenc_pc = ClassProbTestAll .* repmat(classPAll,nTTr,1);
            p_cGivenx = p_xGivenc_pc ./ repmat(sum(p_xGivenc_pc,2),1,length(numChoice)); % nTestTrials-by-numberClass
%             p_cGivenf = p_cGivenx' * FreqProbTestAll;
            p_cGivenf = zeros(nTTr,length(numChoice),length(NumFreq));
            for nnn = 1 : nTTr
                p_cGivenf(nnn,:,:) = p_cGivenx(nnn,:)' * FreqProbTestAll(nnn,:);
            end
        otherwise
            error('Error Input probability density function.');
    end
    
end

% %%
% %calculate the posterior probability for test data set
% % calculate p(c|x) = p(x|c) * p(c)/p(x)
% nTTr = size(TestingSet,1);
% TestingSet = TestingSet'; % nROI by nTrials
% pSummary = zeros(nTTr,length(numChoice),length(NumFreq));
% for nh = 1 : length(numChoice)
%     cChoiceDis = (ChoiceProbPara{nh})'; % two columns matrix
%     for nt = 1 : nTTr
%         p_xGivenc = normcdf(TestingSet(:,nt),cChoiceDis(:,1),cChoiceDis(:,2)); %supposed to be a nROI by 1 vector of probability
%         p_c = CHoiceProb(nh);
%         p_x = sum(normcdf(repmat(TestingSet(:,nt),1,length(numChoice)),ChoiceMu,ChoiceSigma).*p_MatrixClass,2);
%         p_cGivenx = p_xGivenc * p_c./ p_x;
%         % calculate the posterior prob p(x|f)
%         for nf = 1 : length(NumFreq)
%             cFreqDisPara = (DataDisParameter{nf})';
%             p_xGivenf = normcdf(TestingSet(:,nt),cFreqDisPara(:,1),cFreqDisPara(:,2));
%             p_cGivenf = sum(p_cGivenx .* p_xGivenf);
%             pSummary(nt,nh,nf) = p_cGivenf;
%         end
%     end
% end