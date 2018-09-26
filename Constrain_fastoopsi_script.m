
cROI = 1;
data = DataRaw;
if iscell(data)
    cROICellData = cellfun(@(x) (x(cROI,:))',data,'uniformOutput',false);
    cROIData = cell2mat(cROICellData);
else
    cROIData = squeeze(data(:,cROI,:));
end
cROISessTraceWithNAN = reshape(cROIData',[],1);
cROISessTrace = cROISessTraceWithNAN(~isnan(cROISessTraceWithNAN));
cROISessTraceNM = (cROISessTrace - min(cROISessTrace))/100;

%%
spk_SNR = 0.5;
lam_pr = 0.99; % false positive probability for determing lambda penalty
fr = frame_rate;
decay_time = 2; % length of a typical transient in seconds
lam = choose_lambda(exp(-1/(fr*decay_time)),GetSn(cROISessTraceNM),lam_pr);
spkmin = spk_SNR*GetSn(cROISessTraceNM);
%%
[cc2, spk2, opts_oasis2] = deconvolveCa(cROISessTraceNM,'ar1','optimize_b',true,'method','thresholded',...
                                    'optimize_pars',true,'maxIter',100,'smin',spkmin,'window',200,'lambda',lam);    

%%                                
hf = figure;
yyaxis left
hold on
plot(cROISessTraceNM,'k')
plot(cc2+opts_oasis2.b,'r')

yyaxis right
plot(spk2,'g')

%% loading old deconvolution data
cROIDataCells = cellfun(@(x) (x(cROI,:))',nnspike,'uniformOutput',false);
cROIDataOldSP = cell2mat(cROIDataCells);
