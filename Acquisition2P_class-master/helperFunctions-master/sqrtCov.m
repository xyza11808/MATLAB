function sqrtCovMat = sqrtCov(data)

covData = cov(data);
covComplex = sqrt(covData);
signPos = angle(covComplex) == 0;
signNeg = angle(covComplex) == pi/2;
signMult = signPos-signNeg;
sqrtCovMat = abs(covComplex).*signMult;
