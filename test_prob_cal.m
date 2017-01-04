
singletestData = TestingSet(1,:);

%%
            % calculate p(x|f) value using normal distribution
            
            cfFuncProbVa = zeros(length(NumFreq),1);
            for nf = 1 : length(NumFreq)
                cfFuncProbVa(nf) = normcdf(singletestData,FreqClassMean(nf),FreqClassStd(nf));
            end
            p_xGivenF = cfFuncProbVa/sum(cfFuncProbVa);
 %%
            % calculate the p(x|c) value using same distribution

            ccFuncProbVa = zeros(length(numChoice),1);
            for nc = 1 : length(numChoice)
                ccFuncProbVa(nc) = normcdf(singletestData,ChoiceMu(nc),ChoiceSigma(nc));
            end
            
%%
            p_xgivenc_p_c = ccFuncProbVa' .* CHoiceProb;
            p_c_givenX = p_xgivenc_p_c/sum(p_xgivenc_p_c);
            
%%
            p_cGivenF = p_c_givenX' * p_xGivenF';