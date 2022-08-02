function UnitCriterias = BinaryRespCheck(ProbNPSess,RegressorInfosCell,BTTypeInds)
% currently only works for two block sessions

if ~exist('BTTypeInds','Var')
    BTTypeInds = 4;
end

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix

if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
% SMBinDataMtxRaw = SMBinDataMtx;


AllUnitBT_Evar = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,BTTypeInds,2))),RegressorInfosCell(:,1)); %alone model
BTInds = AllUnitBT_Evar > 0.02;
% BTRegressorCell = RegressorInfosCell(BTInds,1);
% BTPartEVs = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var)),BTRegressorCell,'un',0);
% BTPartEVsMtx = cat(3,BTPartEVs{:});

InDataUnitIndsAll = ExistField_ClusIDs(BTInds,2);
BaseDataAll = squeeze(mean(SMBinDataMtx(:,InDataUnitIndsAll,1:ProbNPSess.TriggerStartBin{1}),3));

%%
% close
% ccU = 1;
% 
% figure('position',[100 150 840 360])
% subplot(121)
% plot(diff(smooth(BaseDataAll(:,ccU),7)))
% yyaxis right
% plot(behavResults.BlockType,'m')
% set(gca,'ylim',[-0.5 1.5])
% 
% subplot(122)
% hold on
% AloneData = BTPartEVsMtx(ccU,:,2);
% ResidueData = BTPartEVsMtx(ccU,:,3);
% plot(AloneData,'k');
% plot(ResidueData,'r');
% title(sprintf('Res2Alone ratio = %.3f',(AloneData(4)-AloneData(3))/AloneData(4)));

%%
TrInds = (1:size(BaseDataAll,1))';
TotalNumofUnits = length(InDataUnitIndsAll);

% close
% close
UnitCriterias = zeros(TotalNumofUnits,3);
for ccU = 1 : TotalNumofUnits
% ccU = 31;
    ccUBaselineData = BaseDataAll(:,ccU);
    opts = statset('nlinfit');
    opts.RobustWgtFun = 'bisquare';
    opts.MaxIter = 1000;
    modelfunb = @(b1,b2,b3,b4,x) (b1+ b2./(1+exp(-(x - b3)./b4)));
    % using the new model function
    UL = [max(ccUBaselineData)+abs(min(ccUBaselineData)), Inf, max(TrInds), 1000];
    SP = [min(ccUBaselineData),max(ccUBaselineData) - min(ccUBaselineData), mean(TrInds), 1];
    LM = [0,0, 0, -1000];
    % ParaBoundLim = ([UL;SP;LM]);
    [fit_model,fitgo,logOut] = fit(TrInds,ccUBaselineData,modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
    ci = confint(fit_model);

    FitCurve = feval(fit_model,TrInds);
    % FitSlope = fit_model.b2/(4*fit_model.b4);

    % % figure('position',[50 100 420 340]);
    % % hold on
    % % plot(ccUBaselineData,'Color',[.7 .7 .7]);
    % % plot(FitCurve,'k','linewidth',1.4)
    % % title(sprintf('CI = %.2e',max(ci(2,:))));
    if max(ci(2,:)) > 1000 || any(isnan(ci(2,:)))
        Criterias = 0;
        locs = NaN;
        return;
    end
    % 
    % figure;
    % plot(diff(FitCurve)/max(FitCurve))

    % fit the diff data with gaussian functions
    % normalize the logistic fitting data firstly before tuning fitting
    NormLogfitData = abs(diff(FitCurve)/max(FitCurve));
    modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
    DiffFit_xInds = TrInds(1:end-1);
    [AmpV,AmpInds] = max(NormLogfitData);

    c0 = [AmpV-min(NormLogfitData),DiffFit_xInds(AmpInds),mean(abs(diff(DiffFit_xInds))),min(NormLogfitData)];  % 0.4 is the octave step
    cUpper = [max((AmpV-min(NormLogfitData))*2,0.01),max(DiffFit_xInds),1000,max(AmpV,0.01)];
    cLower = [0,min(DiffFit_xInds),1e-10,0];
    [ffit,gof] = fit(DiffFit_xInds(:),NormLogfitData(:),modelfunc,...
       'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR');  % 'Method','NonlinearLeastSquares',
    OctaveFitValue_gau = feval(ffit,DiffFit_xInds(:));

    EVexplain = 1 - sum((OctaveFitValue_gau - NormLogfitData).^2)/(sum((NormLogfitData-mean(NormLogfitData)).^2));
    % disp(EVexplain);
    % figure('position',[500 100 420 340]);
    % hold on
    % plot(NormLogfitData,'k');
    % plot(OctaveFitValue_gau,'r--');


    [~,locs,w,p] = findpeaks(OctaveFitValue_gau,'NPeaks',1);
    % disp(w/ffit.c3);

    % LogRatio = fit_model.b2/max(1,fit_model.b1);
    % title(sprintf('c3 = %.3f, EV = %.4f,width = %.2f, LogRatio = %.3f',ffit.c3,EVexplain,w,LogRatio))

    if ~isempty(w)
        Criterias = ffit.c3*2 < 120 &&  EVexplain > 0.9 && LogRatio > 1 && LogRatio < 200 && w > 1;
    else
        Criterias = 0; % indicates more likely being a linear ramping changes rather than binary
        locs = NaN;
    end
    % xlabel(sprintf('IsUsed = %d',Criterias));
    
    UnitCriterias(ccU,:) = [Criterias, locs, InDataUnitIndsAll(ccU)];

end
