function coefinfos = folderCoefExtraction(folderpath)

ss = load(fullfile(folderpath,'laggedCorrDatas.mat'));

smooth_r = smooth(ss.r,0.005,'rloess');
smooth_r_sic = smooth(ss.r_SIC,0.005,'rloess');

[rMaxCoef,r_maxIndex] = max(smooth_r);
[rsicMaxCoef,rsic_maxIndex] = max(smooth_r_sic);
r_maxInds = ss.lag(r_maxIndex);
rsic_maxInds = ss.lag_SIC(rsic_maxIndex);
% align timelagged coef values into max inds
Align_rlag = ss.lag - r_maxInds;
Align_rsiclag = ss.lag_SIC - rsic_maxInds;

shuf95rs = prctile(ss.shufCorrs,95);
shuf95rSICs = prctile(ss.shufCorrsSIC,95);

coefinfos = struct();
coefinfos.rPeakInds = r_maxInds;
coefinfos.align_rlags = Align_rlag;
coefinfos.rCoefs = ss.r;
coefinfos.rMaxCoef = rMaxCoef;
coefinfos.rsicPeakInds = rsic_maxInds;
coefinfos.align_rsiclags = Align_rsiclag;
coefinfos.rSICCoefs = ss.r_SIC;
coefinfos.rMaxCoefSIC = rsicMaxCoef;
coefinfos.shufr_coefs = shuf95rs;
coefinfos.shufrsic_coefs = shuf95rSICs;


