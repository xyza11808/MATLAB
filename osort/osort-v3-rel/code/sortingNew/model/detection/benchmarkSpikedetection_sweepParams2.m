%
%
% sweep over a secondary parameter, for each of which a sweep of a primary
% parameter is done (to explore all combinations of 2 parameter values)
%
% paramNr1, paramValues1   : the primary parameter
% paramNr2, paramValues2   : the secondary parameter
%
%
%
%
%urut/aug11
%
function [TPall,FPall,AUCs,thresholds, nrSpikesFound, nrSpikesExist,labels] = benchmarkSpikedetection_sweepParams2 ( dataOfChannel, Hd, tollerance, params, spiketimes, paramNr1, paramValues1, paramNr2, paramValues2 );

oneTPs = [];
oneFPs = [];

tstart1=tic;
parfor k=1:length(paramValues2)
    
    paramsNew=[];
    paramStr='';
    [paramsNew, paramStr] = benchmarkSpikedetection_sweepParams_assignParam( params, paramNr2, paramValues2(k) );
    
    disp(['running: ' paramStr]);
    
    [oneTPs, oneFPs, thisNrSpikesFound, thisNrSpikesExist] = benchmarkSpikedetection_sweepParams ( dataOfChannel, Hd, tollerance, paramsNew, spiketimes, paramNr1, paramValues1 );
    
    [thisAUC] = calcROC_AUC( oneTPs(end:-1:1), oneFPs(end:-1:1) );
    
    AUCs(k) = thisAUC;
    TPall{k} = oneTPs;
    FPall{k} = oneFPs;
    thresholds{k} = paramValues1;
    
    nrSpikesFound(k,:) = thisNrSpikesFound;
    nrSpikesExist(k,:) = thisNrSpikesExist;
    
    labels{k} = [paramStr ' AUC=' num2str(thisAUC)] ;
    
end

tocWithMsg( 'time for _sweepParams2: ', tstart1);
