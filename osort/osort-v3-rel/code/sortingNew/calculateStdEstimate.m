function theEstimate = calculateStdEstimate(stdEstimates)

theEstimate = mean ( stdEstimates ( find(stdEstimates>0) ) );



