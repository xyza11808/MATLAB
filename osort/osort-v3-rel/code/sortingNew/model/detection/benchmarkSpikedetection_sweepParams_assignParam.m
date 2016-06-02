%
%helper function used by benchmarkSpikedetection_sweepParams and
%benchmarkSpikedetection_sweepParams2
%
function [params,paramStr] = benchmarkSpikedetection_sweepParams_assignParam( params, paramNr, paramValue )
paramStr = '';

switch(paramNr)
    case 1
        params.extractionThreshold = paramValue;
        paramStr = 'T=';
    case 2 %kernel size
        
        params.detectionParams.kernelSize = paramValue;
        paramStr = 'k=';
        
    otherwise
        error('invalid param nr');
end

paramStr=[paramStr num2str(paramValue) ];
