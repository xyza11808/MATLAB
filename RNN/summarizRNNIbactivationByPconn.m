function summarizRNNIbactivationByPconn(useSameG)

if nargin < 1; useSameG = false; end

datadir = '/jukebox/brody/briandd/RNN/';
savedir = '/jukebox/braininit/Analysis/RNN/';
cd(datadir)
PconnVals            = [.05 .1 .25 .5 1];
nruns                = 50;
nfractions           = 22;
Pconn_modules        = .05;
r2th                 = 0.7;
EA_perf              = cell(1,numel(PconnVals));
detect_perf          = cell(1,numel(PconnVals));
EA_tolerance         = nan(nruns,numel(PconnVals));
detect_tolerance     = nan(nruns,numel(PconnVals));
EA_tolerance_fit     = nan(nruns,numel(PconnVals));
detect_tolerance_fit = nan(nruns,numel(PconnVals));
model                = 'a+b*exp(c*x)';
EA_fitParams         = cell(1,numel(PconnVals));
detect_fitParams     = cell(1,numel(PconnVals));
fitParamNames        = {'a (%)','\Delta Perf(%)','\Delta Rate (%/%)'};

if useSameG
  datapath  = sprintf('%sdata/gsame/',datadir);
else
  datapath  = sprintf('%sdata/',datadir);
end

for iConn = 1:numel(PconnVals)
  fprintf('.')
  if PconnVals(iConn) < 1
    cd(sprintf('%s%g',datapath,PconnVals(iConn)))
  else
    cd(sprintf('%s1.0',datapath))
  end
  
  EA_perf{iConn}          = nan(nruns,nfractions);
  detect_perf{iConn}      = nan(nruns,nfractions);
  EA_fitParams{iConn}     = nan(nruns,3);
  detect_fitParams{iConn} = nan(nruns,3);
  for iRun = 1:nruns
    fn = sprintf('data_inactivation_sparse_%g_%d.mat',PconnVals(iConn),iRun);
    if isempty(dir(fn)); continue; end
    load(fn,'iscorrect','tasks','percents')
    
    lowerb_EA     = nan(1,nfractions);
    lowerb_detect = nan(1,nfractions);
    for iFrac = 1:nfractions
      EA_perf{iConn}(iRun,iFrac) = 100.*sum(iscorrect(tasks(:,iFrac)==1,iFrac))./sum(tasks(:,iFrac)==1);
      [~,bci] = binofit(sum(iscorrect(tasks(:,iFrac)==1,iFrac)),sum(tasks(:,iFrac)==1),1-(normcdf(1, 0, 1) - normcdf(-1, 0, 1)));
      lowerb_EA(iFrac) = bci(1);
      
      detect_perf{iConn}(iRun,iFrac) = 100.*sum(iscorrect(tasks(:,iFrac)==2,iFrac))./sum(tasks(:,iFrac)==2);
      [~,bci] = binofit(sum(iscorrect(tasks(:,iFrac)==2,iFrac)),sum(tasks(:,iFrac)==2),1-(normcdf(1, 0, 1) - normcdf(-1, 0, 1)));
      lowerb_detect(iFrac) = bci(1);
    end
    
    percents = percents*100;
    EA_tolerance(iRun,iConn)     = percents(find(lowerb_EA<=.5,1,'first'));
    detect_tolerance(iRun,iConn) = percents(find(lowerb_detect<=.5,1,'first'));
    
    [thisf,stats] = fit(percents,EA_perf{iConn}(iRun,:)',model,'startpoint',[50 50 -3]);%,'lower',[40 0 -10],'upper',[100 60 0]);
    if stats.rsquare > r2th
      EA_fitParams{iConn}(iRun,:)  = [thisf.a thisf.b thisf.c];
      xaxis = (0:.5:100)';
      pred  = fiteval(thisf,xaxis);
      idx   = find(pred<51,1,'first');
      if isempty(idx); tol = 100; else; tol = xaxis(idx); end
      EA_tolerance_fit(iRun,iConn) = tol;
    end
    
    [thisf,stats] = fit(percents,detect_perf{iConn}(iRun,:)',model,'startpoint',[50 50 -3]);%,'lower',[40 0 -10],'upper',[100 60 0]);
    if stats.rsquare > r2th
      detect_fitParams{iConn}(iRun,:) = [thisf.a thisf.b thisf.c];
      pred  = fiteval(thisf,xaxis);
      idx   = find(pred<51,1,'first');
      if isempty(idx); tol = 100; else; tol = xaxis(idx); end
      detect_tolerance_fit(iRun,iConn) = tol;
    end
    clear iscorrect tasks bci lowerb_EA lowerb_detect
  end
  
  if PconnVals(iConn) == Pconn_modules
    EA_perf_ant          = nan(nruns,nfractions);
    detect_perf_ant      = nan(nruns,nfractions);
    EA_tolerance_ant     = nan(nruns,1);
    detect_tolerance_ant = nan(nruns,1);
    EA_tolerance_fit_ant     = nan(nruns,1);
    detect_tolerance_fit_ant = nan(nruns,1);
    EA_fitParams_ant     = nan(nruns,3);
    detect_fitParams_ant = nan(nruns,3);
    for iRun = 1:nruns
      fn = sprintf('data_inactivation_module_ant_sparse_%g_%d.mat',PconnVals(iConn),iRun);
      load(fn,'iscorrect','tasks','percents')

      lowerb_EA     = nan(1,nfractions);
      lowerb_detect = nan(1,nfractions);
      for iFrac = 1:nfractions
        EA_perf_ant(iRun,iFrac) = 100.*sum(iscorrect(tasks(:,iFrac)==1,iFrac))./sum(tasks(:,iFrac)==1);
        [~,bci] = binofit(sum(iscorrect(tasks(:,iFrac)==1,iFrac)),sum(tasks(:,iFrac)==1),1-(normcdf(1, 0, 1) - normcdf(-1, 0, 1)));
        lowerb_EA(iFrac) = bci(1);

        detect_perf_ant(iRun,iFrac) = 100.*sum(iscorrect(tasks(:,iFrac)==2,iFrac))./sum(tasks(:,iFrac)==2);
        [~,bci] = binofit(sum(iscorrect(tasks(:,iFrac)==2,iFrac)),sum(tasks(:,iFrac)==2),1-(normcdf(1, 0, 1) - normcdf(-1, 0, 1)));
        lowerb_detect(iFrac) = bci(1);
      end
      
      percents = percents*100;
      EA_tolerance_ant(iRun)     = percents(find(lowerb_EA<=.5,1,'first'));
      detect_tolerance_ant(iRun) = percents(find(lowerb_detect<=.5,1,'first'));
      
      [thisf,stats] = fit(percents,EA_perf_ant(iRun,:)',model,'startpoint',[50 50 -3]);%,'lower',[40 0 -10],'upper',[100 60 0]);
      if stats.rsquare > r2th
        EA_fitParams_ant(iRun,:)  = [thisf.a thisf.b thisf.c];
        pred  = fiteval(thisf,xaxis);
        idx   = find(pred<51,1,'first');
        if isempty(idx); tol = 100; else; tol = xaxis(idx); end
        EA_tolerance_fit_ant(iRun,iConn) = tol;
      end
      
      [thisf,stats] = fit(percents,detect_perf_ant(iRun,:)',model,'startpoint',[50 50 -3]);%,'lower',[40 0 -10],'upper',[100 60 0]);
      if stats.rsquare > r2th
        detect_fitParams_ant(iRun,:) = [thisf.a thisf.b thisf.c];
        pred  = fiteval(thisf,xaxis);
        idx   = find(pred<51,1,'first');
        if isempty(idx); tol = 100; else; tol = xaxis(idx); end
        detect_tolerance_fit_ant(iRun,iConn) = tol;
      end
      
      clear iscorrect tasks bci lowerb_EA lowerb_detect
    end
  end
  
  if PconnVals(iConn) == Pconn_modules
    EA_perf_post          = nan(nruns,nfractions);
    detect_perf_post      = nan(nruns,nfractions);
    EA_tolerance_post     = nan(nruns,1);
    detect_tolerance_post = nan(nruns,1);
    EA_tolerance_fit_post     = nan(nruns,1);
    detect_tolerance_fit_post = nan(nruns,1);
    EA_fitParams_post     = nan(nruns,3);
    detect_fitParams_post = nan(nruns,3);
    for iRun = 1:nruns
      fn = sprintf('data_inactivation_module_post_sparse_%g_%d.mat',PconnVals(iConn),iRun);
      if isempty(dir(fn)); continue; end
      load(fn,'iscorrect','tasks','percents')

      lowerb_EA     = nan(1,nfractions);
      lowerb_detect = nan(1,nfractions);
      for iFrac = 1:nfractions
        EA_perf_post(iRun,iFrac) = 100.*sum(iscorrect(tasks(:,iFrac)==1,iFrac))./sum(tasks(:,iFrac)==1);
        [~,bci] = binofit(sum(iscorrect(tasks(:,iFrac)==1,iFrac)),sum(tasks(:,iFrac)==1),1-(normcdf(1, 0, 1) - normcdf(-1, 0, 1)));
        lowerb_EA(iFrac) = bci(1);

        detect_perf_post(iRun,iFrac) = 100.*sum(iscorrect(tasks(:,iFrac)==2,iFrac))./sum(tasks(:,iFrac)==2);
        [~,bci] = binofit(sum(iscorrect(tasks(:,iFrac)==2,iFrac)),sum(tasks(:,iFrac)==2),1-(normcdf(1, 0, 1) - normcdf(-1, 0, 1)));
        lowerb_detect(iFrac) = bci(1);
      end
      
      percents = percents*100;
      EA_tolerance_post(iRun)     = percents(find(lowerb_EA<=.5,1,'first'));
      detect_tolerance_post(iRun) = percents(find(lowerb_detect<=.5,1,'first'));
      
      [thisf,stats] = fit(percents,EA_perf_post(iRun,:)',model,'startpoint',[50 50 -3]);%,'lower',[40 0 -10],'upper',[100 60 0]);
      if stats.rsquare > r2th
        EA_fitParams_post(iRun,:)  = [thisf.a thisf.b thisf.c];
        pred  = fiteval(thisf,xaxis);
        idx   = find(pred<51,1,'first');
        if isempty(idx); tol = 100; else; tol = xaxis(idx); end
        EA_tolerance_fit_post(iRun,iConn) = tol;
      end

      [thisf,stats] = fit(percents,detect_perf_post(iRun,:)',model,'startpoint',[50 50 -3]);%,'lower',[40 0 -10],'upper',[100 60 0]);
      if stats.rsquare > r2th
        detect_fitParams_post(iRun,:) = [thisf.a thisf.b thisf.c];
        pred  = fiteval(thisf,xaxis);
        idx   = find(pred<51,1,'first');
        if isempty(idx); tol = 100; else; tol = xaxis(idx); end
        detect_tolerance_fit_post(iRun,iConn) = tol;
      end
      clear iscorrect tasks bci lowerb_EA lowerb_detect
    end
  end
end

clear iConn iRun iFrac fn stats
fprintf('\n')
cd(savedir)
fn = 'RNNinactivationSummaryByPconn';
if useSameG
  fn = [fn '_sameG'];
end
save(fn,'-v7.3')