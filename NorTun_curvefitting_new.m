clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task spike tunning');

%%

fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
%%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
        continue;
    else
        %
        SpikeDataPath = [tline,'\Tunning_fun_plot_New1s'];
        cd(SpikeDataPath);
        load('TunningDataSave.mat');
        
        nROIs = size(CorrTunningFun,2);
        if ~isdir('./Curve fitting plots/')
            mkdir('./Curve fitting plots/');
        end
        cd('./Curve fitting plots/');
        warning('off','all');
        if ~isdir('./NewLog_fit_test_new/')
            mkdir('./NewLog_fit_test_new/');
        end
       cd('./NewLog_fit_test_new/');
%       
%         LogFitMSE = zeros(nROIs,1);
%         GauFitMSE = zeros(nROIs,1);
        LogCoefFit = cell(nROIs,1);
        NMLogFit = cell(nROIs,1);
        GauCoefFit = cell(nROIs,1);
        ROIisResponsive = ones(nROIs,1);
        ROIResidueratio = zeros(nROIs,2);
        PassFitResult = cell(nROIs,1);
        PassFitGOF = cell(nROIs,1);
        PassSigmoidalFit = cell(nROIs,2);
        %
        LogResnRatios = zeros(nROIs,2);
        
%         nFitFun = cell(nROIs,1);
        IsCategROI = zeros(nROIs,1);
        IsTunedROI = zeros(nROIs,1);
        LogResidueAll = cell(nROIs,1);
        GauResidueAll = cell(nROIs,1);
        TaskIndexAll = ones(nROIs,1)*(-1);
        PassIndexAll = ones(nROIs,1)*(-1);
        ROISlopeFit = zeros(nROIs,7);
        %
        for ROInum = 1 : nROIs
            % ROInum = 1;
            cROITunData = CorrTunningFun(:,ROInum);
            cROINMData = NonMissTunningFun(:,ROInum);
            PassFreqConsidered = ~(abs(PassFreqOctave) > 1);
            PassTundata = PassTunningfun(PassFreqConsidered,ROInum);
            PassOctave = PassFreqOctave(PassFreqConsidered);
            [PassMaxAmp,PassmaxInds] = max(PassTundata);
            
            IsROItun = 0;
            SortData = sort(cROITunData);
            if max(cROITunData) < 10
                fprintf('ROI%d shows no significant response.\n',ROInum);
                ROIisResponsive(ROInum) = 0;
%                 continue;
            end
            NorTundata = cROITunData(:);%/mean(cROITunData);
            OctaveData = TaskFreqOctave(:);
            NMTunData = cROINMData(:);
            % using logistic fitting of current data
            opts = statset('nlinfit');
            opts.RobustWgtFun = 'bisquare';
            opts.MaxIter = 1000;
            modelfunb = @(b1,b2,b3,b4,x) (b1+ b2./(1+exp(-(x - b3)./b4)));
            % using the new model function
            UL = [max(NorTundata)+abs(min(NorTundata)), Inf, max(OctaveData), 100];
            SP = [min(NorTundata),max(NorTundata) - min(NorTundata), mean(OctaveData), 1];
            LM = [-Inf,-Inf, min(OctaveData), -100];
            ParaBoundLim = ([UL;SP;LM]);
            [fit_model,fitgof] = fit(OctaveData,NorTundata,modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
            OctaveRange = linspace(min(OctaveData),max(OctaveData),500);
            FitCurve = feval(fit_model,OctaveRange);
            FitSlope = fit_model.b2/(4*fit_model.b4);
            EndPointSlope = (NorTundata(end) - NorTundata(1))/(OctaveData(end) - OctaveData(1));
            
            % fit logistic model with NMData
            NMUL = [max(NMTunData)+abs(min(NMTunData)), Inf, max(OctaveData), 100];
            NMSP = [min(NMTunData),max(NMTunData) - min(NMTunData), mean(OctaveData), 1];
            NMLM = [-Inf,-Inf, min(OctaveData), -100];
            
            [NMfitMd,NMgof] = fit(OctaveData,NMTunData,modelfunb,'StartPoint',NMSP,'Upper',NMUL,'Lower',NMLM);
            NMFitCurve = feval(NMfitMd,OctaveRange);
            NMFitSlope = NMfitMd.b2/(4*NMfitMd.b4);
            NMEndPointSlope = (NMTunData(end) - NMTunData(1))/(OctaveData(end) - OctaveData(1));
            
            ROISlopeFit(ROInum,:) = [FitSlope,EndPointSlope,NMFitSlope,NMEndPointSlope,...
                max(NorTundata),max(NMTunData),PassMaxAmp];
            NMLogFit{ROInum} = NMfitMd;
            % first part plots
            hlogNewf = figure('position',[2750 100 450 400]);
            hold on
            plot(OctaveRange,FitCurve,'color','k','LineWidth',2.4);
            plot(OctaveData, NorTundata,'ro','MarkerSize',12);
            yscales = get(gca,'ylim');
            line([fit_model.b3 fit_model.b3],yscales,'Linewidth',2,'LineStyle','--','Color',[.7 .7 .7]);
            FitData = feval(fit_model,OctaveData);
            DiffRatio = sum((NorTundata - FitData).^2)/sum(NorTundata.^2);
            LogResnRatios(ROInum,1) = DiffRatio;
            LogCoefFit{ROInum} = fit_model;
            LogResidueAll{ROInum} = fitgof;
            if fit_model.b3 > OctaveData(2) && fit_model.b3 < OctaveData(end-1)
                if DiffRatio <= 0.1
                    IsCategROI(ROInum) = 1;
                end
            end
            if IsCategROI(ROInum)
%                 SortData = sort(NorTundata);
                GrNum = floor(length(NorTundata)/2);
                LeftMean = mean(NorTundata(1:GrNum));
                RightMean = mean(NorTundata(end-GrNum+1:end));
                if max(LeftMean, RightMean) < 20
                    IsCategROI(ROInum) = 0;
%                     ROIisResponsive(ROInum) = 0;
                    IsROItun = 1;
                else  % high response, but no significant difference between two groups
                    if abs(LeftMean - RightMean) < max([LeftMean , RightMean])/2  % no significant difference between two groups
                        IsCategROI(ROInum) = 0;
                        IsROItun = 0;
                    end
%                     if fit_model.b3 >= 0
%                         if (mean(NorTundata(end-GrNum+1:end)) - mean(NorTundata(1:GrNum))) < mean(NorTundata(end-GrNum+1:end))/2
%                             IsCategROI(ROInum) = 0;
%                             IsROItun = 0;
%                         end
%                     else
%                        if (mean(NorTundata(1:GrNum)) - mean(NorTundata(end-GrNum+1:end))) < mean(NorTundata(1:GrNum))/2
%                             IsCategROI(ROInum) = 0;
%                             IsROItun = 0;
%                        end 
%                     end
                end
            end
% %             text(0.4,mean(NorTundata),sprintf('rmse = %.3f',fitgof.rmse));
            
            if IsCategROI(ROInum)
                cFitbound = fit_model.b3;
                LeftInds = OctaveData < cFitbound;
                LeftMean = max(mean(NorTundata(LeftInds)),0.1);
                RightMean = max(mean(NorTundata(~LeftInds)),0.1);
                TaskIndexAll(ROInum) = abs(LeftMean - RightMean)/(LeftMean + RightMean);
            else
                LeftInds = OctaveData < 0;
                LeftMean = max(mean(NorTundata(LeftInds)),0.1);
                RightMean = max(mean(NorTundata(~LeftInds)),0.1);
                TaskIndexAll(ROInum) = abs(LeftMean - RightMean)/(LeftMean + RightMean);
            end
            
           % fitting the gaussian function
            modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
            [AmpV,AmpInds] = max(NorTundata);
            c0 = [AmpV,OctaveData(AmpInds),mean(abs(diff(OctaveData))),min(NorTundata)];  % 0.4 is the octave step
            cUpper = [max(AmpV*2,0),max(OctaveData),max(OctaveData) - min(OctaveData),AmpV];
            cLower = [min(NorTundata),min(OctaveData),0,-Inf];
            [ffit,gof] = fit(OctaveData(:),NorTundata(:),modelfunc,...
               'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR');  % 'Method','NonlinearLeastSquares',
           OctaveFitValue_gau = feval(ffit,OctaveData(:));
           Thresratio_gau = sum((NorTundata - OctaveFitValue_gau).^2)/sum(NorTundata.^2);
            ROIResidueratio(ROInum,:) = [DiffRatio,Thresratio_gau];
            %
            GauCoefFit{ROInum} = ffit;
            GauResidueAll{ROInum} = gof;
%             GauFitMSE(ROInum) = gof.rmse;
            if ~IsCategROI(ROInum)
               if  Thresratio_gau < 0.2
                   if ROIisResponsive(ROInum)
                       if ffit.c3 < min(abs(diff(OctaveData)))*2
                            IsTunedROI(ROInum) = 1;
                       end
                   end
               end
               if IsROItun
                   IsTunedROI(ROInum) = 1;
               end
            else
                IsTunedROI(ROInum) = 0;
            end
            if ~ROIisResponsive(ROInum)
                IsTunedROI(ROInum) = 0;
            end
            
            text(ffit.c2,mean(NorTundata)*0.8,sprintf('Width = %.3f',ffit.c3),...
                'HorizontalAlignment','center');
            
             GausFitData = feval(ffit,OctaveRange(:));
             plot(OctaveRange,GausFitData,'r','linewidth',1.6);
            
           % ############################################################################################
           % fitting passive data with gaussian function
           
           c0 = [PassMaxAmp,PassOctave(PassmaxInds),mean(abs(diff(PassOctave))),min(PassTundata)];  % 0.4 is the octave step
            cUpper = [PassMaxAmp*2,max(PassOctave),max(PassOctave) - min(PassOctave),PassMaxAmp];
            cLower = [min(PassTundata),min(PassOctave),min(abs(diff(PassOctave))),-Inf];
            [Passffit,Passgof] = fit(PassOctave(:),PassTundata(:),modelfunc,...
               'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR');  % 'Method','NonlinearLeastSquares',
           PassFitValue_gau = feval(Passffit,PassOctave(:));
           %
           if IsCategROI(ROInum)
                LeftInds = PassOctave < cFitbound;
                PassLMean = max(mean(PassTundata(LeftInds)),0.1);
                PassRMean = max(mean(PassTundata(~LeftInds)),0.1);
                PassIndexAll(ROInum) = abs(PassLMean - PassRMean)/(PassLMean + PassRMean);
           else
               LeftInds = PassOctave < 0;
               PassLMean = max(mean(PassTundata(LeftInds)),0.1);
                PassRMean = max(mean(PassTundata(~LeftInds)),0.1);
                PassIndexAll(ROInum) = abs(PassLMean - PassRMean)/(PassLMean + PassRMean);
           end
           
           % fit a sigmoidal function to passive data
           UL = [max(PassTundata)+abs(min(PassTundata)), Inf, max(PassOctave), 100];
            SP = [min(PassTundata),max(PassTundata) - min(PassTundata), mean(PassOctave), 1];
            LM = [-Inf,-Inf, min(PassOctave), -100];
            ParaBoundLim = ([UL;SP;LM]);
            [fit_modelP,fitgofP] = fit(PassOctave(:),PassTundata(:),modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
            PassOctRange = linspace(min(PassOctave),max(PassOctave),500);
            PassFitCurve = feval(fit_modelP,PassOctRange);
            PassLogFitV = feval(fit_modelP,PassOctave(:));
            PassLogDifRatio = sum((PassTundata(:) - PassLogFitV).^2)/sum(PassTundata.^2);
            LogResnRatios(ROInum,2) = PassLogDifRatio;
            PassLogSlope = fit_modelP.b2/(fit_modelP.b4*4);
            PassEndSlope = (PassTundata(end) - PassTundata(1))/(PassOctave(end) - PassOctave(1));
            
            PassSigmoidalFit{ROInum,1} = fit_modelP;
            PassSigmoidalFit{ROInum,2} = fitgofP;
           
            plot(PassOctRange,PassFitCurve,'Color',[0.4 0.4 0.4],'linewidth',1.6);
            plot(PassOctave,PassTundata,'d','Color',[0.4 0.4 0.4],'MarkerSize',12);
            
            yscales = get(gca,'ylim');
            text(0.3,yscales(2)*0.7,sprintf('PassLogRatio = %.4f',PassLogDifRatio));
            line([ffit.c2 ffit.c2],yscales,'Color','m','Linewidth',1.8,'LineStyle','--');
            text(-0.8,yscales(2)*0.8,sprintf('IsResponsive = %d',ROIisResponsive(ROInum)));
            set(gca,'ylim',yscales);
            title({sprintf('ROI%d,LogResratio = %.3f,IsCateg = %d',ROInum,DiffRatio,IsCategROI(ROInum));...
                sprintf('Gauratio = %.3f, IsGauTun = %d',Thresratio_gau,IsTunedROI(ROInum))});
            xlabel(sprintf('Task%.2f-%.2f, Pass%.2f-%.2f',FitSlope,EndPointSlope,PassLogSlope,PassEndSlope));
             %
            saveas(hlogNewf,sprintf('Log Fit test Save ROI%d',ROInum));
            saveas(hlogNewf,sprintf('Log Fit test Save ROI%d',ROInum),'png');
           
           PassFitResult{ROInum} = Passffit;
           PassFitGOF{ROInum} = Passgof;
          close(hlogNewf);
        end
        warning('on','all')
        warning('query','all')
       
%         LogGauFitMSE = [LogFitMSE,GauFitMSE];
        BehavBoundStrc = load(fullfile(tline,'RandP_data_plots\boundary_result.mat'));
        BehavBoundResult = BehavBoundStrc.boundary_result.Boundary - 1;
        
        save NewCurveFitsave.mat LogCoefFit GauCoefFit ROIisResponsive ROIResidueratio PassFitResult PassFitGOF ...
            LogResnRatios IsCategROI IsTunedROI LogResidueAll GauResidueAll BehavBoundResult TaskIndexAll ...
            PassIndexAll ROISlopeFit NMLogFit -v7.3
        %
        FitBoundInds = cellfun(@(x) x.c2,GauCoefFit);
        TunedROIBound = FitBoundInds(logical(IsTunedROI));
        TunBoundSEM = std(TunedROIBound)/sqrt(length(TunedROIBound));
        ts = tinv([0.025  0.975],length(TunedROIBound)-1);
        CI = mean(TunedROIBound) + ts*TunBoundSEM;
        hhf = figure('position',[750 250 430 500]);
        hold on
        plot(ones(size(TunedROIBound)),TunedROIBound,'*','Color',[.7 .7 .7],'MarkerSize',10,'Linewidth',1.4);
        patch([0.9 1.1 1.1 0.9],[CI(1) CI(1) CI(2) CI(2)],1,'EdgeColor','k','FaceColor','none','linewidth',2);
        errorbar(1,mean(TunedROIBound),TunBoundSEM,'bo','linewidth',1.8);
        set(gca,'xlim',[0.5,1.5],'ylim',[min(OctaveData) max(OctaveData)]);
        ll = line([0.7 1.1],[BehavBoundResult BehavBoundResult],'Color','r','linewidth',2,'linestyle','--');
        ll2 = line([0.9 1.3],[mean(TunedROIBound) mean(TunedROIBound)],'Color','k','linewidth',2,'linestyle','--');
        set(gca,'xtick',1,'xticklabel','TunBoundary','FontSize',18);
        legend([ll,ll2],{'Behav Boundary','Mean Boundary'},'location','NorthWest','FontSize',10);
        legend('boxoff')
        %
        saveas(hhf,'Tuning ROI TunedPeak index distribution');
        saveas(hhf,'Tuning ROI TunedPeak index distribution','png');
        close(hhf);
        %         SigROIinds = find(ROIisResponsive > 0);
%         SigLogfitmse = LogFitMSE(SigROIinds);
%         SigGaufitmse = GauFitMSE(SigROIinds);
%         GauCoefFitAll = GauCoefFit(SigROIinds);
%         GauCoefWid = cellfun(@(x) x(3),GauCoefFitAll);
%         FreqTunROIs = ((SigGaufitmse < SigLogfitmse) & (SigGaufitmse < 0.5) & (GauCoefWid < 0.7)) | ...
%             (10 * SigGaufitmse <= SigLogfitmse);
%         FreqCategROIs = ((SigGaufitmse > SigLogfitmse) & (SigLogfitmse < 0.5)) | ...
%             ((SigGaufitmse < SigLogfitmse) & (SigGaufitmse > 10 * SigLogfitmse) & (GauCoefWid >= 0.5 & GauCoefWid < 1));
%         %
%         nTunROI = sum(FreqTunROIs);
%         nCategROI = sum(FreqCategROIs);
%         TunROIInds = SigROIinds(FreqTunROIs);
%         CategROiinds = SigROIinds(FreqCategROIs);
%         
%         save CellCategorySave.mat LogFitMSE GauFitMSE ROIisResponsive TunROIInds CategROiinds LogCoefFit GauCoefFit CorrTunningFun OctaveData -v7.3
%         cd ..;
%         cd ..;
%         
%         NorTunData = CorrTunningFun ./ repmat(mean(CorrTunningFun),size(CorrTunningFun,1),1);
%         TuningROIData = NorTunData(:,TunROIInds);
%         CagROIdata = NorTunData(:,CategROiinds);
%         NoiseROIInds = true(size(NorTunData,2),1);
%         NoiseROIInds(TunROIInds) = false;
%         NoiseROIInds(CategROiinds) = false;
%         NoiseROIdata = NorTunData(:,NoiseROIInds);
%         PerferCagData = zeros(size(CagROIdata));
%         nPairNum = floor(size(CagROIdata,1)/2);
%         for nnn = 1 : size(CagROIdata,2)
%             if sum(CagROIdata(1:nPairNum,nnn)) > sum(CagROIdata(end-nPairNum+1:end,nnn))
%                 PerferCagData(:,nnn) = flipud(CagROIdata(:,nnn));
%             else
%                 PerferCagData(:,nnn) = CagROIdata(:,nnn);
%             end
%         end
%         BehavDataStrc = load('./RandP_data_plots/boundary_result.mat');
%         if ~isdir('./ROI type response plot/')
%             mkdir('./ROI type response plot/');
%         end
%         cd('./ROI type response plot/');
%         
%         if ~isempty(TuningROIData)
%             hTun = figure;
%             hold on
%             plot(OctaveData(:),TuningROIData,'color',[.7 .7 .7]);
%             plot(OctaveData,mean(TuningROIData,2),'k','linewidth',1.8);
%             yscales = get(gca,'ylim');
%             text(0,0.85*yscales(2),sprintf('nROI = %d/%d',size(TuningROIData,2),nROIs),'FontSize',16);
%             xlabel('Octave');
%             ylabel('Normal Firing rate');
%             title('Tunning ROI average');
%             set(gca,'FontSize',16);
%             saveas(hTun,'Tunning ROIs response plot');
%             saveas(hTun,'Tunning ROIs response plot','png');
%             saveas(hTun,'Tunning ROIs response plot','pdf');
%             close(hTun);
%         end
%         
%         if ~isempty(NoiseROIdata)
%             hNos = figure;
%             hold on
%             plot(OctaveData(:),NoiseROIdata,'color',[.7 .7 .7]);
%             plot(OctaveData,mean(NoiseROIdata,2),'k','linewidth',1.8);
%             yscales = get(gca,'ylim');
%             text(0,0.85*yscales(2),sprintf('nROI = %d/%d',size(NoiseROIdata,2),nROIs),'FontSize',16);
%             xlabel('Octave');
%             ylabel('Normal Firing rate');
%             title('Noisy ROI average');
%             set(gca,'FontSize',16);
%             saveas(hNos,'Noisy ROIs response plot');
%             saveas(hNos,'Noisy ROIs response plot','png');
%             saveas(hNos,'Noisy ROIs response plot','pdf');
%             close(hNos);
%         end
%         
%         if ~isempty(PerferCagData)
%             hCag = figure;
%             hold on
%             plot(OctaveData(:),PerferCagData,'color',[.7 .7 .7]);
%             plot(OctaveData(:),mean(PerferCagData,2),'k','linewidth',1.8);
%             yscales = get(gca,'ylim');
%             text(-0.5,0.85*yscales(2),sprintf('nROI = %d/%d',size(PerferCagData,2),nROIs),'FontSize',16);
%             xlabel('Octave');
%             ylabel('Normal Firing rate');
%             title('Categorical ROI average');
%             set(gca,'FontSize',16);
%             saveas(hCag,'Catogorical ROIs response plot');
%             saveas(hCag,'Catogorical ROIs response plot','png');
%             saveas(hCag,'Catogorical ROIs response plot','pdf');
%             close(hCag);
%        
%             BehavCorr = BehavDataStrc.boundary_result.StimCorr;
%             BehavCorr(1:nPairNum) = 1 - BehavCorr(1:nPairNum);
%             Octaves = log2(double(BehavDataStrc.boundary_result.StimType)/16000);
%             MeanCagResp = mean(PerferCagData,2);
%             MeanCagSEM = std(PerferCagData,[],2)/sqrt(size(PerferCagData,2));
%             Patchy = [MeanCagSEM+MeanCagResp;flipud(MeanCagResp - MeanCagSEM)];
%             Patchx = [OctaveData(:);flipud(OctaveData(:))];
%             %
%             hComb = figure;
%             hold on
%             yyaxis left
%             patch(Patchx,Patchy,1,'FaceColor',[.3 .3 .3],'EdgeColor','none','facealpha',0.4);
%             plot(OctaveData(:),mean(PerferCagData,2),'k-o','linewidth',1.8);
%             yscales = get(gca,'ylim');
%             text(-0.5,0.85*yscales(2),sprintf('nROI = %d/%d',size(PerferCagData,2),nROIs),'FontSize',16);
%             ylabel('Nor. FR','Color','k');
%             set(gca,'YColor','k','ytick',[min(mean(PerferCagData,2)),1,max(mean(PerferCagData,2))]);
% 
%             yyaxis right
%             plot(Octaves,BehavCorr,'r-o','linewidth',1.8);
%             xlabel('Octaves');
%             ylabel('RIghtward Frac.','Color','r');
%             set(gca,'YColor','r','ytick',[0.1 0.5 1]);
%             title('Behav and ROI Resp compare');
% 
%             set(gca,'FontSize',16);
%             saveas(hComb,'Catogorical ROIs vs behav response plot');
%             saveas(hComb,'Catogorical ROIs vs behav response plot','png');
%             saveas(hComb,'Catogorical ROIs vs behav response plot','pdf');
%             close(hComb);
%         
%         end
%         save TypeDataSave.mat OctaveData TuningROIData NoiseROIdata PerferCagData BehavCorr Octaves -v7.3
        %
%         cd ..;
        tline = fgetl(ff);
    end
end
%%
% compare the tunning peak position and boundary result with behavior
% condition
clear
clc
SessCategBoundTunPeakBehav = {};
m = 1;

[fn,fp,fi] = uigetfile('*.txt','Please select the task session data path');
Sessionfile = fullfile(fp,fn);
fid = fopen(Sessionfile);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    SessionFitDataPath = fullfile(tline,'Tunning_fun_plot_New1s\Curve fitting plots\NewCurveFitsave.mat');
    SessionTunPath = [tline,'\Tunning_fun_plot_New1s\Curve fitting plots'];
    BehavData = fullfile(tline,'RandP_data_plots\boundary_result.mat');
    %
    SessFitDataStrc = load(SessionFitDataPath);
    SessBehavStrc = load(BehavData);
    %
    CagCoefFitAll = SessFitDataStrc.LogCoefFit;
    TunCoefFitAll = SessFitDataStrc.GauCoefFit;
    CagROICoefAll = CagCoefFitAll(logical(SessFitDataStrc.IsCategROI));
    TunROICoefAll = TunCoefFitAll(logical(SessFitDataStrc.IsTunedROI));
    CagROIboundAll = cellfun(@(x) x.b3,CagROICoefAll);
    TunROIPeakPosAll = cellfun(@(x) x.c2,TunROICoefAll);
    BehavBound = SessBehavStrc.boundary_result.Boundary;
    %
    SessCategBoundTunPeakBehav{m,1} = CagROIboundAll;
    SessCategBoundTunPeakBehav{m,2} = TunROIPeakPosAll;
    SessCategBoundTunPeakBehav{m,3} = BehavBound;
    
    tline = fgetl(fid);
    m = m + 1;
end
%% plot the categorical ROI boundary diff from behavior data
nSess = size(SessCategBoundTunPeakBehav,1);
SessROIBound2BehavDiff = [];
for cSess = 1 : nSess
    cSessData = SessCategBoundTunPeakBehav{cSess,1} - SessCategBoundTunPeakBehav{cSess,3} + 1;
    SessROIBound2BehavDiff = [SessROIBound2BehavDiff;cSessData];
end
[~,p] = ttest(SessROIBound2BehavDiff);
[Count,Cent] = hist(SessROIBound2BehavDiff,20);

hf = figure('position',[3000 100 380 300]);
hold on
cBar = bar(Cent,Count,0.8,'FaceColor',[.6 .6 .6],'EdgeColor','none');
set(gca,'xlim',[-1 1]);
yscales = get(gca,'ylim');
line([1 1]*mean(SessROIBound2BehavDiff),yscales,'Color',[0.1 0.6 0.1],'Linewidth',1.6,'Linestyle','--');
text(mean(SessROIBound2BehavDiff)+0.05,yscales(2)*0.9,sprintf('p = %.2e',p),'FontSize',14,'Color','m');
text(mean(SessROIBound2BehavDiff)+0.05,yscales(2)*0.85,sprintf('mean = %.4f',mean(SessROIBound2BehavDiff)),'FontSize',14,'Color','m');
xlabel('Dis2BehavBound');
ylabel('CellCount');
title('Categ. ROI Boundary distribution');
set(gca,'FontSize',14);
% saveas(hf,'Categorical ROI boundary 2BehavBound distribution');
% saveas(hf,'Categorical ROI boundary 2BehavBound distribution','png');
% saveas(hf,'Categorical ROI boundary 2BehavBound distribution','pdf');
BackDiff = SessROIBound2BehavDiff;
%%
% plot the categorical ROI boundary diff from Set boundary
nSess = size(SessCategBoundTunPeakBehav,1);
SessROIBound2BehavDiff = [];
for cSess = 1 : nSess
    cSessData = SessCategBoundTunPeakBehav{cSess,1};
    SessROIBound2BehavDiff = [SessROIBound2BehavDiff;cSessData];
end
[~,p] = ttest(SessROIBound2BehavDiff);
[Count,Cent] = hist(SessROIBound2BehavDiff,20);

hf = figure('position',[3000 100 380 300]);
hold on
cBar = bar(Cent,Count,0.8,'FaceColor',[.6 .6 .6],'EdgeColor','none');
set(gca,'xlim',[-1 1]);
yscales = get(gca,'ylim');
line([1 1]*mean(SessROIBound2BehavDiff),yscales,'Color',[0.1 0.6 0.1],'Linewidth',1.6,'Linestyle','--');
text(mean(SessROIBound2BehavDiff)+0.05,yscales(2)*0.9,sprintf('p = %.2e',p),'FontSize',14,'Color','m');
text(mean(SessROIBound2BehavDiff)+0.05,yscales(2)*0.85,sprintf('mean = %.4f',mean(SessROIBound2BehavDiff)),'FontSize',14,'Color','m');
xlabel('Dis2BehavBound');
ylabel('CellCount');
title('Categ. ROI Boundary distribution');
set(gca,'FontSize',14);
% saveas(hf,'Categorical ROI boundary distribution');
% saveas(hf,'Categorical ROI boundary distribution','png');
% saveas(hf,'Categorical ROI boundary distribution','pdf');
%%
% plot the categorical ROI boundary diff from Set boundary
nSess = size(SessCategBoundTunPeakBehav,1);
SessROIBound2BehavDiff = [];
for cSess = 1 : nSess
    cSessData = SessCategBoundTunPeakBehav{cSess,1};
    SessROIBound2BehavDiff = [SessROIBound2BehavDiff;cSessData];
end
% [~,p] = ttest(SessROIBound2BehavDiff);
AbsDis = abs(SessROIBound2BehavDiff);
[Count,Cent] = hist(AbsDis,20);
[CumDisy,CumDisx] = ecdf(AbsDis);
Prc80Thres = prctile(AbsDis,80);

hf = figure('position',[3000 100 380 300]);
hold on
cline = plot(CumDisx,CumDisy,'Linewidth',1.5,'Color','k');
% set(gca,'xlim',[-1 1]);
yscales = get(gca,'ylim');
line([Prc80Thres Prc80Thres],yscales,'linewidth',1.2,'Color',[.7 .7 .7],'linestyle','--');
axPos = get(gca,'position');
SourceAx = gca;

InsertAx = axes('position',[axPos(1)+axPos(3)*2/3,axPos(2)+0.1,axPos(3)/3,axPos(4)/3]);
hbar = bar(InsertAx,Cent,Count,0.7,'FaceColor',[.7 .7 .7],'EdgeColor','none');
Newylim = get(InsertAx,'ylim');
line(InsertAx,[1 1]*Prc80Thres,Newylim,'Color',[0.1 0.6 0.1],'Linewidth',1.6,'Linestyle','--');
set(InsertAx,'box','off');
% text(mean(SessROIBound2BehavDiff)+0.05,yscales(2)*0.9,sprintf('p = %.2e',p),'FontSize',14,'Color','m');
% text(mean(SessROIBound2BehavDiff)+0.05,yscales(2)*0.85,sprintf('mean = %.4f',mean(SessROIBound2BehavDiff)),'FontSize',14,'Color','m');
xlabel(SourceAx,'Distance (Octave)');
ylabel(SourceAx,'Cell fraction');
title(SourceAx,'Categ. ROI to boundDis.');
set(SourceAx,'FontSize',14);

saveas(hf,'Categorical ROI To behavBound ');
saveas(hf,'Categorical ROI boundary distribution','png');
saveas(hf,'Categorical ROI boundary distribution','pdf');

%%
BehavDataAll = [];
ROICagMeanAll = [];
SessOct = [];
ROICagAll = {};
m = 0;

addchar = 'y';
while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('TypeDataSave.mat','Please select session analysis result');
    if ~fi
        return;
    end
    SessPath = fullfile(fp,fn);
    SessDataStrc = load(SessPath);
    
    m = m + 1;
    BehavDataAll(m,:) = SessDataStrc.BehavCorr;
    ROICagAll{m} = SessDataStrc.PerferCagData;
    MeanROICag = mean(SessDataStrc.PerferCagData,2);
    if mod(length(MeanROICag),2)
        MeanROICag(ceil(length(MeanROICag)/2)) = [];
    end
    ROICagMeanAll(m,:) = MeanROICag;
    addchar=input('Would you like to add another session data?\n','s');
end

%%  ############################################
%  ############################################
% for passive session
clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the text file contains the path of all task spike tunning');
fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
[PassFn,PassFp,PassFi] = uigetfile('*.txt','Please select the passive session data path');
PassPath = fullfile(PassFp,PassFn);
passfid = fopen(PassPath);
Passline = fgetl(passfid);

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ff);
        Passline = fgetl(passfid);
        continue;
    else
        SpikeDataPath = [tline,'\Spike_Tunfun_plot'];
        cd(SpikeDataPath);
        load('TunningDataSave.mat');
        
        PassSessData = load(fullfile(Passline,'SpikeData_analysis\EsSpikeSave.mat'));
        PassFreq = unique(double(PassSessData.SelectSArray));
        PassOctave = log2(PassFreq/16000);
        
        nROIs = size(PassTunningfun,2);
        if ~isdir('./Pass Curve fitting plots/')
            mkdir('./Pass Curve fitting plots/');
        end
        cd('./Pass Curve fitting plots/');
        warning('off','all');
%
        LogFitMSE = zeros(nROIs,1);
        GauFitMSE = zeros(nROIs,1);
        LogCoefFit = cell(nROIs,1);
        GauCoefFit = cell(nROIs,1);
        ROIisResponsive = ones(nROIs,1);
        OctaveData = PassOctave(:);
        for ROInum = 1 : nROIs
            % ROInum = 1;
            cROITunData = PassTunningfun(:,ROInum);
            if max(cROITunData) < 1
                fprintf('ROI%d shows no significant response.\n',ROInum);
                ROIisResponsive(ROInum) = 0;
                continue;
            end
            NorTundata = cROITunData(:)/mean(cROITunData);
            

            % using logistic fitting of current data
            opts = statset('nlinfit');
            opts.RobustWgtFun = 'bisquare';
            modelfunb = @(b,x) (b(1)+ b(2)./(1+exp(-(x - b(3))./b(4))));
            b0 = [min(OctaveData); max(OctaveData); mean([min(OctaveData),max(OctaveData)]); 0.1];
            [bCurvefit,~,~,~,bMSE,~] = nlinfit(OctaveData,NorTundata,modelfunb,b0,opts);
            LogFitMSE(ROInum) = bMSE;
            LogCoefFit{ROInum} = bCurvefit;
            
            % using gaussian fitting of current data
            modelfunc = @(c,x) c(1)*exp((-1)*((x - c(2)).^2)./(2*(c(3)^2)));
            [AmpV,AmpInds] = max(NorTundata);
            c0 = [AmpV,OctaveData(AmpInds),0.4];  % 0.4 is the octave step
            [cFit,~,~,~,cMSE,~] = nlinfit(OctaveData,NorTundata,modelfunc,c0,opts);
            GauFitMSE(ROInum) = cMSE;
            GauCoefFit{ROInum} = cFit;
            % plot the fitting result
            OctaveRange = linspace(min(OctaveData),max(OctaveData),500);
            LogfitData = modelfunb(bCurvefit,OctaveRange);
            GausFitData = modelfunc(cFit,OctaveRange);
            h = figure;
            hold on
            scatter(OctaveData,NorTundata,80,'k','linewidth',1.6);
            plot(OctaveRange,LogfitData,'b','linewidth',1.6);
            plot(OctaveRange,GausFitData,'r','linewidth',1.6);
            title({sprintf('Logmse = %.2e, Gaumse = %.2e',bMSE,cMSE);sprintf('TunPeakWid = %.2e',cFit(3))});
            set(gca,'FontSize',16);
            saveas(h,sprintf('ROI%d Fit curve compare plot',ROInum));
            saveas(h,sprintf('ROI%d Fit curve compare plot',ROInum),'png');
            close(h);
        end
        warning('on','all')
        warning('query','all')


        %
        SigROIinds = find(ROIisResponsive > 0);
        SigLogfitmse = LogFitMSE(SigROIinds);
        SigGaufitmse = GauFitMSE(SigROIinds);
        GauCoefFitAll = GauCoefFit(SigROIinds);
        GauCoefWid = cellfun(@(x) x(3),GauCoefFitAll);
        FreqTunROIs = ((SigGaufitmse < SigLogfitmse) & (SigGaufitmse < 0.5) & (GauCoefWid < 0.7)) | ...
            (10 * SigGaufitmse <= SigLogfitmse);
        FreqCategROIs = ((SigGaufitmse > SigLogfitmse) & (SigLogfitmse < 0.5)) | ...
            ((SigGaufitmse < SigLogfitmse) & (SigGaufitmse > 10 * SigLogfitmse) & (GauCoefWid >= 0.5 & GauCoefWid < 1));
        %
        nTunROI = sum(FreqTunROIs);
        nCategROI = sum(FreqCategROIs);
        TunROIInds = SigROIinds(FreqTunROIs);
        CategROiinds = SigROIinds(FreqCategROIs);
        
        save CellCategorySave.mat LogFitMSE GauFitMSE ROIisResponsive TunROIInds CategROiinds LogCoefFit GauCoefFit PassTunningfun OctaveData -v7.3
        cd ..;
        cd ..;
        
        NorTunData = PassTunningfun ./ repmat(mean(PassTunningfun),size(PassTunningfun,1),1);
        TuningROIData = NorTunData(:,TunROIInds);
        CagROIdata = NorTunData(:,CategROiinds);
        NoiseROIInds = true(size(NorTunData,2),1);
        NoiseROIInds(TunROIInds) = false;
        NoiseROIInds(CategROiinds) = false;
        NoiseROIdata = NorTunData(:,NoiseROIInds);
        PerferCagData = zeros(size(CagROIdata));
        nPairNum = floor(size(CagROIdata,1)/2);
        for nnn = 1 : size(CagROIdata,2)
            if sum(CagROIdata(1:nPairNum,nnn)) > sum(CagROIdata(end-nPairNum+1:end,nnn))
                PerferCagData(:,nnn) = flipud(CagROIdata(:,nnn));
            else
                PerferCagData(:,nnn) = CagROIdata(:,nnn);
            end
        end
        BehavDataStrc = load('./RandP_data_plots/boundary_result.mat');
        if ~isdir('./Passive ROI type response plot/')
            mkdir('./Passive ROI type response plot/');
        end
        cd('./Passive ROI type response plot/');
        
        hTun = figure;
        hold on
        plot(OctaveData(:),TuningROIData,'color',[.7 .7 .7]);
        plot(OctaveData,mean(TuningROIData,2),'k','linewidth',1.8);
        yscales = get(gca,'ylim');
        text(0,0.85*yscales(2),sprintf('nROI = %d/%d',size(TuningROIData,2),nROIs),'FontSize',16);
        xlabel('Octave');
        ylabel('Normal Firing rate');
        title('Tunning ROI average');
        set(gca,'FontSize',16);
        saveas(hTun,'Tunning ROIs response plot');
        saveas(hTun,'Tunning ROIs response plot','png');
        saveas(hTun,'Tunning ROIs response plot','pdf');
        close(hTun);
        
        hNos = figure;
        hold on
        plot(OctaveData(:),NoiseROIdata,'color',[.7 .7 .7]);
        plot(OctaveData,mean(NoiseROIdata,2),'k','linewidth',1.8);
        yscales = get(gca,'ylim');
        text(0,0.85*yscales(2),sprintf('nROI = %d/%d',size(NoiseROIdata,2),nROIs),'FontSize',16);
        xlabel('Octave');
        ylabel('Normal Firing rate');
        title('Noisy ROI average');
        set(gca,'FontSize',16);
        saveas(hNos,'Noisy ROIs response plot');
        saveas(hNos,'Noisy ROIs response plot','png');
        saveas(hNos,'Noisy ROIs response plot','pdf');
        close(hNos);
        
        hCag = figure;
        hold on
        plot(OctaveData(:),PerferCagData,'color',[.7 .7 .7]);
        plot(OctaveData(:),mean(PerferCagData,2),'k','linewidth',1.8);
        yscales = get(gca,'ylim');
        text(-0.5,0.85*yscales(2),sprintf('nROI = %d/%d',size(PerferCagData,2),nROIs),'FontSize',16);
        xlabel('Octave');
        ylabel('Normal Firing rate');
        title('Categorical ROI average');
        set(gca,'FontSize',16);
        saveas(hCag,'Catogorical ROIs response plot');
        saveas(hCag,'Catogorical ROIs response plot','png');
        saveas(hCag,'Catogorical ROIs response plot','pdf');
        close(hCag);
        
       
        BehavCorr = BehavDataStrc.boundary_result.StimCorr;
        BehavCorr(1:nPairNum) = 1 - BehavCorr(1:nPairNum);
        Octaves = log2(double(BehavDataStrc.boundary_result.StimType)/16000);
        MeanCagResp = mean(PerferCagData,2);
        MeanCagSEM = std(PerferCagData,[],2)/sqrt(size(PerferCagData,2));
        Patchy = [MeanCagSEM+MeanCagResp;flipud(MeanCagResp - MeanCagSEM)];
        Patchx = [OctaveData(:);flipud(OctaveData(:))];
        %
        hComb = figure;
        hold on
        yyaxis left
        patch(Patchx,Patchy,1,'FaceColor',[.3 .3 .3],'EdgeColor','none','facealpha',0.4);
        plot(OctaveData(:),mean(PerferCagData,2),'k-o','linewidth',1.8);
        yscales = get(gca,'ylim');
        text(-0.5,0.85*yscales(2),sprintf('nROI = %d/%d',size(PerferCagData,2),nROIs),'FontSize',16);
        ylabel('Nor. FR','Color','k');
        set(gca,'YColor','k','ytick',[min(mean(PerferCagData,2)),1,max(mean(PerferCagData,2))]);
        
        yyaxis right
        plot(Octaves,BehavCorr,'r-o','linewidth',1.8);
        xlabel('Octaves');
        ylabel('RIghtward Frac.','Color','r');
        set(gca,'YColor','r','ytick',[0.1 0.5 1]);
        title('Behav and ROI Resp compare');
        
        set(gca,'FontSize',16);
        saveas(hComb,'Catogorical ROIs vs behav response plot');
        saveas(hComb,'Catogorical ROIs vs behav response plot','png');
        saveas(hComb,'Catogorical ROIs vs behav response plot','pdf');
        close(hComb);
        %
        cd ..;
        tline = fgetl(ff);
        Passline = fgetl(passfid);
    end
end