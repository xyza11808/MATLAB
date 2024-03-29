clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the text file contains the path of all task spike tunning');
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
%
        LogFitMSE = zeros(nROIs,1);
        GauFitMSE = zeros(nROIs,1);
        LogCoefFit = cell(nROIs,1);
        GauCoefFit = cell(nROIs,1);
        ROIisResponsive = ones(nROIs,1);
        ROIResidueratio = zeros(nROIs,2);
        PassFitResult = cell(nROIs,1);
        PassFitGOF = cell(nROIs,1);
        %
        for ROInum = 1 : nROIs
            % ROInum = 1;
            cROITunData = CorrTunningFun(:,ROInum);
            if max(cROITunData) < 10
                fprintf('ROI%d shows no significant response.\n',ROInum);
                ROIisResponsive(ROInum) = 0;
%                 continue;
            end
            NorTundata = cROITunData(:);%/mean(cROITunData);
            OctaveData = TaskFreqOctave(:);

            % using logistic fitting of current data
            opts = statset('nlinfit');
            opts.RobustWgtFun = 'bisquare';
            opts.MaxIter = 1000;
            modelfunb = @(b,x) (b(1)+ b(2)./(1+exp(-(x - b(3))./b(4))));
            b0 = [min(OctaveData); max(OctaveData); mean([min(OctaveData),max(OctaveData)]); 0.1];
            [bCurvefit,~,~,~,bMSE,~] = nlinfit(OctaveData,NorTundata,modelfunb,b0,opts);
            LogFitMSE(ROInum) = bMSE;
            LogCoefFit{ROInum} = bCurvefit;
            OctaveFitValue_log = modelfunb(bCurvefit,OctaveData);
            Thresratio_log = sum((NorTundata - OctaveFitValue_log).^2)/sum(NorTundata.^2);
            % using gaussian fitting of current data
%             modelfuncOld = @(c,x) c(1)*exp((-1)*((x - c(2)).^2)./(2*(c(3)^2)))+c(4);
            modelfunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
            [AmpV,AmpInds] = max(NorTundata);
            c0 = [AmpV,OctaveData(AmpInds),mean(abs(diff(OctaveData))),min(NorTundata)];  % 0.4 is the octave step
            cUpper = [AmpV*2,max(OctaveData),max(OctaveData) - min(OctaveData),AmpV];
            cLower = [min(NorTundata),min(OctaveData),min(abs(diff(OctaveData))),-Inf];
            [ffit,gof] = fit(OctaveData(:),NorTundata(:),modelfunc,...
               'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR');  % 'Method','NonlinearLeastSquares',
           OctaveFitValue_gau = feval(ffit,OctaveData(:));
           
           % ############################################################################################
           % fitting passive data with gaussian function
           PassFreqConsidered = ~(abs(PassFreqOctave) > 1);
           PassTundata = PassTunningfun(PassFreqConsidered,ROInum);
           PassOctave = PassFreqOctave(PassFreqConsidered);
           [PassMaxAmp,PassmaxInds] = max(PassTundata);
           c0 = [PassMaxAmp,PassOctave(PassmaxInds),mean(abs(diff(PassOctave))),min(NorTundata)];  % 0.4 is the octave step
            cUpper = [AmpV*2,max(PassOctave),max(PassOctave) - min(PassOctave),AmpV];
            cLower = [min(NorTundata),min(PassOctave),min(abs(diff(PassOctave))),-Inf];
            [Passffit,Passgof] = fit(PassOctave(:),PassTundata(:),modelfunc,...
               'StartPoint',c0,'Upper',cUpper,'Lower',cLower,'Robust','LAR');  % 'Method','NonlinearLeastSquares',
           PassFitValue_gau = feval(ffit,PassOctave(:));
           
           PassFitResult{ROInum} = Passffit;
           PassFitGOF{ROInum} = Passgof;
           % #############################################################################################
           %
%             [cFit,~,~,~,cMSE,~] = nlinfit(OctaveData,NorTundata,modelfuncOld,c0,opts);
%             GauFitMSE(ROInum) = cMSE;
%             GauCoefFit{ROInum} = cFit;
%             OctaveFitValue_gau = modelfuncOld(cFit,OctaveData);
            Thresratio_gau = sum((NorTundata - OctaveFitValue_gau).^2)/sum(NorTundata.^2);
            ROIResidueratio(ROInum,:) = [Thresratio_log,Thresratio_gau];
            GauCoefFit{ROInum} = ffit;
            GauFitMSE(ROInum) = gof.rmse;
            % plot the fitting result
            OctaveRange = linspace(min(OctaveData),max(OctaveData),500);
            LogfitData = modelfunb(bCurvefit,OctaveRange);
            GausFitData = feval(ffit,OctaveRange(:));
            PassfitData = feval(Passffit,OctaveRange(:));
%             GausFitData = modelfuncOld(cFit,OctaveRange);
            %
            h = figure('position',[400 400 1050 500]);
            subplot(121)
            hold on
            scatter(OctaveData,NorTundata,80,'k','linewidth',1.6);
            plot(OctaveRange,LogfitData,'b','linewidth',1.6);
            plot(OctaveRange,GausFitData,'r','linewidth',1.6);
            yscales = get(gca,'ylim');
            text(OctaveData(1),yscales(2)*0.8,sprintf('log=%.3e,Gau=%.3e',Thresratio_log,Thresratio_gau),'FontSize',10);
            title({sprintf('Logmse = %.2e, Gaumse = %.2e',bMSE,GauFitMSE(ROInum));sprintf('TunPeakWid = %.2e',ffit.c3)});
            line([ffit.c2,ffit.c2],yscales,'Color',[.7 .7 .7],'linewidth',1.7,'linestyle','--');
            text(ffit.c2,mean(yscales),sprintf('Bound = %.3f',ffit.c2),'horizontalAlignment','center');
            set(gca,'FontSize',16,'ylim',yscales);
            
            subplot(122)
            hold on
            scatter(PassOctave,PassTundata,60,'k','linewidth',1.5);
            plot(OctaveRange,PassfitData,'r','linewidth',1.6);
            yscales = get(gca,'ylim');
            title(sprintf('Gaumse = %.2e,TunPeakWid = %.2e',Passgof.rmse,Passffit.c3));
            line([Passffit.c2,Passffit.c2],yscales,'Color',[.7 .7 .7],'linewidth',1.7,'linestyle','--');
            text(Passffit.c2,mean(yscales),sprintf('Bound = %.3f',Passffit.c2),'horizontalAlignment','center');
            set(gca,'FontSize',16,'ylim',yscales);
            
             annotation('textbox',[0.43,0.6,0.2,0.3],'String',sprintf('ROI%d',ROInum),'FitBoxToText','on','EdgeColor',...
                           'none','FontSize',14,'Color','m');
                       %
            saveas(h,sprintf('ROI%d Fit curve compare plot',ROInum));
            saveas(h,sprintf('ROI%d Fit curve compare plot',ROInum),'png');
            close(h);
        end
        warning('on','all')
        warning('query','all')
       % define significant response using threshold ratio
        FitBoundInds = cellfun(@(x) x.c2,GauCoefFit);
        FitGauWidth = cellfun(@(x) x.c3,GauCoefFit);
        SigFitInds = ROIResidueratio < 0.2; % mannually defined threshold
        FreqCategROIs = SigFitInds(:,1) & ~SigFitInds(:,2);
        FreqTunROIs = ~SigFitInds(:,1) & SigFitInds(:,2);
        BothSigInds = find(SigFitInds(:,1) & SigFitInds(:,2));
        BothSigGauBound = FitBoundInds(BothSigInds);
        BothSigGauWidth = FitGauWidth(BothSigInds);
        BothSigGauMSE = GauFitMSE(BothSigInds);
        BothSigCagMSE = LogFitMSE(BothSigInds);
        BothCagInds = (BothSigCagMSE < BothSigGauMSE) & (abs(BothSigGauBound) > 0.6 & BothSigGauWidth > mean(abs(diff(OctaveData))));
        FreqCategROIs(BothSigInds(BothCagInds)) = true;
        FreqTunROIs(BothSigInds(~BothCagInds)) = true;
        NonResponsiveInds = ROIisResponsive == 0;
        FreqCategROIs(NonResponsiveInds) = false;
        FreqTunROIs(NonResponsiveInds) = false;
        LogGauFitMSE = [LogFitMSE,GauFitMSE];
        BehavBoundStrc = load(fullfile(tline,'RandP_data_plots\boundary_result.mat'));
        BehavBoundResult = BehavBoundStrc.boundary_result.Boundary - 1;
        
        save NewCurveFitsave.mat GauCoefFit ROIisResponsive LogGauFitMSE LogCoefFit GauCoefFit FreqCategROIs ...
            PassFitResult PassFitGOF FreqTunROIs BehavBoundResult -v7.3
        %
        TunedROIBound = FitBoundInds(FreqTunROIs);
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
        legend([ll,ll2],{'Behav Boundary','Mean Boundary'},'location','NorthWest');
        legend('boxoff')
        legend({},'FontSize',10)
        
        saveas(hhf,'Tuning ROI TunedPeak index distribution');
        saveas(hhf,'Tuning ROI TunedPeak index distribution','png');
        close(hhf);
        %
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
CagROIbound = {};
TunROIPeakPos = {};
SessBehavBound = [];
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
    SessionFitDataPath = fullfile(tline,'Spike_Tunfun_plot\Curve fitting plots\CellCategorySave.mat');
    SessionTunPath = [tline,'\Spike_Tunfun_plot\Curve fitting plots'];
    BehavData = fullfile(tline,'RandP_data_plots\boundary_result.mat');
    
    SessFitDataStrc = load(SessionFitDataPath);
    SessBehavStrc = load(BehavData);
    
    CagCoefFitAll = SessFitDataStrc.LogCoefFit;
    TunCoefFitAll = SessFitDataStrc.GauCoefFit;
    CagROICoefAll = CagCoefFitAll(SessFitDataStrc.CategROiinds);
    TunROICoefAll = TunCoefFitAll(SessFitDataStrc.TunROIInds);
    CagROIboundAll = cellfun(@(x) x(3),CagROICoefAll);
    TunROIPeakPosAll = cellfun(@(x) x(2),TunROICoefAll);
    BehavBound = SessBehavStrc.boundary_result.Boundary;
    Behav4CompBound = log2(double(min(SessBehavStrc.boundary_result.StimType))/16000) + BehavBound;
    
    cd(SessionTunPath);
    save BoundTunROISave.mat CagROIboundAll TunROIPeakPosAll Behav4CompBound -v7.3
    CagROIbound{m} = CagROIboundAll;
    TunROIPeakPos{m} = TunROIPeakPosAll;
    SessBehavBound(m) = Behav4CompBound;
    
    tline = fgetl(fid);
    m = m + 1;
end
%%
savePath = uigetdir(pwd,'Please select the data save file');
cd(savePath);
save sumBoundTunData.mat CagROIbound TunROIPeakPos SessBehavBound -v7.3


SessROIbound = cellfun(@mean,CagROIbound);
SessBoundSem = cellfun(@std,CagROIbound)./sqrt(cellfun(@numel,CagROIbound));
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