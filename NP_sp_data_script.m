myKsDir = 'I:\20210104\xy1_20210104_g0\xy1_20210104_g0_imec1';
sp = loadKSdir(myKsDir);

%%
SP_CLus_Inds = unique(sp.clu);
Num_sp_inds = length(SP_CLus_Inds);
SingleUnit_st = cell(Num_sp_inds,2);
for cInds = 1 : Num_sp_inds
    c_clu_inds = sp.clu == SP_CLus_Inds(cInds);
    c_clu_sp = sp.st(c_clu_inds);
    SingleUnit_st(cInds,:) = {c_clu_sp,numel(c_clu_sp)};
    
end

%%

huf = figure;
hold on
for cInds = 1 : 10%Num_sp_inds
    plot(SingleUnit_st{cInds,1},cInds*ones(SingleUnit_st{cInds,2},1),'ko','markersize',0.8);

end
%%
gwfparams.dataDir = 'I:\20210104\xy1_20210104_g0\xy1_20210104_g0_imec1';    % KiloSort/Phy output folder
gwfparams.fileName = 'xy1_20210104_g0_t0.imec1.ap.bin';         % .dat file containing the raw 
gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = 32;                      % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-40 41];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 100;                    % Number of waveforms per unit to pull out
gwfparams.spikeTimes = [2,3,5,7,8,9]; % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters =  [1,2,1,1,1,2];% Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes


%%
wf = getWaveForms(gwfparams);


