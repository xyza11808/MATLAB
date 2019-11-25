function summarizRNNbyPconn(useSameG)

if nargin < 1; useSameG = false; end

datadir = '/jukebox/brody/briandd/RNN/';
savedir = '/jukebox/braininit/Analysis/RNN/';
cd(datadir)
PconnVals   = [.05 .1 .25 .5 1];
gvals       = zeros(1,numel(PconnVals));
goffvals    = zeros(1,numel(PconnVals));
learnerJ    = cell(1,numel(PconnVals));
teacherJ    = cell(1,numel(PconnVals));
EA_corr     = teacherJ;
detect_corr = teacherJ;

if useSameG
  datapath  = sprintf('%sdata/gsame/',datadir);
else
  datapath  = sprintf('%sdata/',datadir);
end

for iConn = 1:numel(PconnVals)
  fprintf('.')
  if PconnVals(iConn) ~= 1
    cd(sprintf('%s%g',datapath,PconnVals(iConn)))
  else
    cd(sprintf('%s1.0',datapath))
  end
  fn = sprintf('data_and_network_sparse_%g.mat',PconnVals(iConn));
  load(fn,'J1','J2','R2data','Task_data','post_post','ant_post','N','g','goff')
  
  teacherJ{iConn} = J1;
  learnerJ{iConn} = J2;
  gvals(iConn)    = g;
  goffvals(iConn) = goff;
  
  visIdx      = post_post;
  frontIdx    = ant_post;
  pulsesR     = R2data([visIdx frontIdx],:,Task_data == 1);
  detectR     = R2data([visIdx frontIdx],:,Task_data == 2);

  nPulseTrial = size(pulsesR,3);
  iEA_corr    = zeros(N,N,nPulseTrial);
  for iTrial = 1:nPulseTrial
      iEA_corr(:,:,iTrial) = corr(pulsesR(:,:,iTrial)');
  end

  nDetectTrial = size(detectR,3);
  idetect_corr = zeros(N,N,nDetectTrial);
  for iTrial = 1:nDetectTrial
      idetect_corr(:,:,iTrial) = corr(detectR(:,:,iTrial)');
  end

  EA_corr{iConn}     = mean(iEA_corr,3);
  detect_corr{iConn} = mean(idetect_corr,3);
end

fn = 'RNNsummaryByPconn';
fprintf('\n')
cd(savedir)
if useSameG
  fn = [fn '_sameG'];
end
save(fn,'PconnVals','teacherJ','learnerJ','EA_corr','detect_corr','visIdx','frontIdx','N','gvals','goffvals','-v7.3')
