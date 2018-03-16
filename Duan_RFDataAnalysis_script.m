
load('N:\testCamKII\test01_cpntrol\im_data_reg_cpu\result_save\plot_save\NO_Correction\rfSelectDataSet.mat');
ControlTunDataPath = 'N:\testCamKII\test01_cpntrol\im_data_reg_cpu\result_save\plot_save\NO_Correction\RFtunDataSave.mat';
HalfHourTunDataPath = 'N:\testCamKII\test02_30min_after\im_data_reg_cpu\result_save\plot_save\NO_Correction\RFtunDataSave.mat';
OneHTunDataPath = 'N:\testCamKII\test03_1h_after\im_data_reg_cpu\result_save\plot_save\NO_Correction\RFtunDataSave.mat';
OneAndHalfTunDataPath = 'N:\testCamKII\test04_1_5h_after\im_data_reg_cpu\result_save\plot_save\NO_Correction\RFtunDataSave.mat';
TwoHourTunDataPath = 'N:\testCamKII\test05_2h_after\im_data_reg_cpu\result_save\plot_save\NO_Correction\RFtunDataSave.mat';

ControlTunData = load(ControlTunDataPath);
HalfHourTunData = load(HalfHourTunDataPath);
OneHTunData = load(OneHTunDataPath);
OneAndHalfTunData = load(OneAndHalfTunDataPath);
TwoHourTunData = load(TwoHourTunDataPath);

ComROIs = length(ControlTunData.RFTunData);

ControlDataMtx = cell2mat((ControlTunData.RFTunData)');
HalfHourTunDataMtx = cell2mat((HalfHourTunData.RFTunData)');
OneHTunDataMtx = cell2mat((OneHTunData.RFTunData)');
OneAndHalfTunDataMtx = cell2mat((OneAndHalfTunData.RFTunData)');
TwoHourTunDataMtx = cell2mat((TwoHourTunData.RFTunData)');

%% plot the tun data
Freqs = unique(SelectSArray);
UsedOcts = log2(Freqs/16000); % into octaves
OctStrs = cellstr(num2str(Freqs/1000,'%.1f'));

if ~isdir('./TunCurve_complot_save/')
    mkdir('./TunCurve_complot_save/');
end
cd('./TunCurve_complot_save/');
TunColors = cool(5);

for cR = 1 : ComROIs
    %
    hf = figure('position',[100 100 480 320]);
    hold on
    hl1 = plot(UsedOcts,ControlDataMtx(:,cR),'linewidth',1.6,'Color',TunColors(1,:));
    hl2 = plot(UsedOcts,HalfHourTunDataMtx(:,cR),'linewidth',1.6,'Color',TunColors(2,:));
    hl3 = plot(UsedOcts,OneHTunDataMtx(:,cR),'linewidth',1.6,'Color',TunColors(3,:));
    hl4 = plot(UsedOcts,OneAndHalfTunDataMtx(:,cR),'linewidth',1.6,'Color',TunColors(4,:));
    hl5 = plot(UsedOcts,TwoHourTunDataMtx(:,cR),'linewidth',1.6,'Color',TunColors(5,:));
    set(gca,'xtick',UsedOcts,'xticklabel',OctStrs,'xlim',[min(UsedOcts)-0.1,max(UsedOcts)+0.1]);
    hhll = legend([hl1,hl2,hl3,hl4,hl5],{'Cont','0.5h','1h','1.5h','2h'},'box','off','Location','northeastoutside');
    set(hhll,'position',get(hhll,'position')+[0.06 0 0 0])
    xlabel('Freq (kHz)');
    ylabel('\DeltaF/F (%)');
    title(sprintf('ROI%d',cR));
    set(gca,'FontSize',14);
   %
    saveas(hf,sprintf('ROI%d tunCurve across session plot',cR));
    saveas(hf,sprintf('ROI%d tunCurve across session plot',cR),'png');
    close(hf);
   %
end

%% population color plot
ContZSData = zscore(ControlDataMtx);
[~,maxInds] = max(ContZSData);
[~,ContIndsSeq] = sort(maxInds);
h1f = figure;
imagesc(ContZSData(:,ContIndsSeq),[-2,2]);
colorbar;
title('Control');
saveas(h1f,'Cont population Tun plot');
saveas(h1f,'Cont population Tun plot','png');

%%
HalfZSData = zscore(HalfHourTunDataMtx);
[~,maxInds] = max(HalfZSData);
[~,HalfIndsSeq] = sort(maxInds);
h2f = figure;
imagesc(HalfZSData(:,ContIndsSeq),[-2,2]);
colorbar;
title('Half hour');
saveas(h2f,'Half population Tun plot');
saveas(h2f,'Half population Tun plot','png');

%%
OneZSData = zscore(OneHTunDataMtx);
[~,maxInds] = max(OneZSData);
[~,OneIndsSeq] = sort(maxInds);
h3f = figure;
imagesc(OneZSData(:,ContIndsSeq),[-2,2]);
colorbar;
title('One hour');
saveas(h3f,'One population Tun plot');
saveas(h3f,'One population Tun plot','png');

%%
OneHZSData = zscore(OneAndHalfTunDataMtx);
[~,maxInds] = max(OneHZSData);
[~,OneHIndsSeq] = sort(maxInds);
h4f = figure;
imagesc(OneHZSData(:,ContIndsSeq),[-2,2]);
colorbar;
title('OneHalf hour');
saveas(h4f,'OneHalf population Tun plot');
saveas(h4f,'OneHalf population Tun plot','png');

%%
TwoZSData = zscore(TwoHourTunDataMtx);
[~,maxInds] = max(TwoZSData);
[~,TwoIndsSeq] = sort(maxInds);
h5f = figure;
imagesc(TwoZSData(:,ContIndsSeq),[-2,2]);
colorbar;
title('Two hours');
saveas(h5f,'Two population Tun plot');
saveas(h5f,'Two population Tun plot','png');

