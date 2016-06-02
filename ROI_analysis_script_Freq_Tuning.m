%% Axon1
% cd /media/Office.01/Data/Exp_data/animal_screening/ZTT/ztt_som02_gc6f_20141223/ztt_som02_20141223_axon1/Analysis_Results
load CaSignal_CaTrials_ztt_som02_20141223_axon1_256_10x_sound_dftReg_
load sound_stim_param

%% Axon2
% cd /media/Office.01/Data/Exp_data/animal_screening/ZTT/ztt_som02_gc6f_20141223/ztt_som02_20141223_axon2/Analysis_Results/
load CaTrials_ztt_som02_20141223_axon2_10x_tones_dftReg_.mat
load sound_stim_param
% Trial 93 missing one frame. Append zeros.
CaTrials(93).f_raw = cat(2, CaTrials(93).f_raw, zeros(40,1));
CaTrials(93).dff = cat(2, CaTrials(93).dff, zeros(40,1));

%% Xin Yu test1222
load CaSignal_CaTrials_xy_g04a09_RF_test01_dftReg_
load sound_stim_param
%% Xin Yu b05a03_20141227
load CaTrials_b05a03_20141227_RF_test01_118um_dftReg_
load sound_stim_param
%% 
t_stim = 1;

nROIs = CaTrials(1).nROIs;
nTrials = length(CaTrials);
xdata = (1:CaTrials(1).nFrames) * CaTrials(1).FrameTime/1000;

f_raw = [];

for i = 1:nTrials
    f_raw = cat(3, f_raw, CaTrials(i).f_raw);
end
% f_raw: [nTrials nFrames nROIs]
f_raw = permute(f_raw, [3 2 1]);

%%
for  i = 1:nROIs
%     for j = 1:nTrials
%         f_raw(j,:) = obj.imTrials{trialNums(j)}.f_raw(roi_no(i),:);
%     end
    f = f_raw(:,:,i);
    [N,X] = hist(reshape(f,1,[]), 50);
    
    f_mode = min(X(N==max(N)));
    f_base = prctile(f(f < f_mode),50);
    
    dff(:,:,i) = (f - f_base)./f_base*100;
end

%%
ROINo = 18;
imagesc(f_raw(:,:,ROINo));

%% Color Plot of Correlation map for all ROIs, and Response time series for all ROIs in each Trial.

f = dff;
trNo = 155;
% imagesc(squeeze(f_raw(trNo, :,:))')
% fig1 = figure('color','w');
% fig2 = figure('color','w');
for trNo = 1:nTrials
    %%
%     trNo = 1;
    corr_mat_trial = corrcoef(squeeze(f(trNo,:,:)));
    figure(fig1);
    
    ax1 = subplot(1,2,1);
    imagesc(corr_mat_trial, [0 1]);
    axis square
    title(sprintf('Trial No %d',trNo),'fontsize',15)
    xlabel('ROI #', 'fontsize',15)
    ylabel('ROI #', 'fontsize',15)
    set(gca,'fontsize',15);
    
%     figure(fig2);
    ax2 = subplot(1,2,2);
    
    imagesc(squeeze(f(trNo, :,:))', 'XData', xdata);
    set(gca,'Clim',[0 200])
    xlabel('Time (s)', 'fontsize', 15);
    ylabel('ROI #', 'fontsize', 15);
    set(gca,'fontsize',15);
    title(sprintf('Tone: %d kHz, %d dB', round(sound_stim_param.frequency(trNo)/1000), sound_stim_param.intensity(trNo)), 'fontsize', 15);
%     colorbar;
    y_line = get(gca, 'ylim');
    x_line = [t_stim t_stim];
    line(x_line, y_line, 'Color', 'w', 'LineWidth', 3);
    saveas(gcf,sprintf('ROI_corr_trial_colorplot/ROI_corr_trial_%d.png',trNo),'png')
end

%% Color Plot response of sorted trials for each ROI
for ROINo = 1:nROIs
    %%
% ROINo = 11;
colormap jet
f = dff; %f_raw;
spl = unique(sound_stim_param.intensity);
inds_freq_sort = {};
for i = 1:length(spl)
    inds1 = find(sound_stim_param.intensity == spl(i));
    [~, inds2] = sort(sound_stim_param.frequency(inds1));
    
    inds_freq_sort{i} = inds1(inds2);
    
    ydata = sound_stim_param.frequency(inds_freq_sort{i})/1000; % kHz
    ax(i) = subplot(length(spl), 1, i);
    h = imagesc(f(inds_freq_sort{i}, :, ROINo), 'XData', xdata, 'YData', ydata);
    ylabel('Freq (kHz)','fontsize',15)
    set(gca,'Clim',[0 150])
    y_line = get(gca, 'ylim');
    x_line = [t_stim t_stim];
    line(x_line, y_line, 'Color', 'w', 'LineWidth', 3);
end

axes(ax(1)); title(sprintf('ROI #%d', ROINo), 'FontSize',15);
axes(ax(end)); xlabel('Time (s)', 'FontSize', 15);

export_fig(gcf,sprintf('Tone_Intensity_Response/Tone_Response_ROI_%d.png', ROINo),'-png')

end

%% Mean trace plot for different SPL
colormap jet
f = dff; %f_raw;
spl = unique(sound_stim_param.intensity);
spl_use = 60; % max(spl);
mkdir(sprintf('%ddB_ROI_response', spl_use));
    %
    for ROINo = 1:nROIs
        %%
%     ROINo = 1;

    % inds_freq_sort = {};
    % for i = 1:length(spl)
        inds1 = find(sound_stim_param.intensity == spl_use) ;
        [freq_sort, inds2] = sort(sound_stim_param.frequency(inds1));

        inds_freq_sort_maxDB = inds1(inds2);
        
        figure(fig2);
        clf; set(gcf, 'Color','w')
    
        subplot(2,1,1);
        imagesc(f(inds_freq_sort_maxDB, :, ROINo), 'XData', xdata, 'YData', ceil(freq_sort/1000));
%         set(gca,'Clim',[0 200])
        
        y_line = get(gca, 'ylim');
        x_line = [t_stim t_stim];
        line(x_line, y_line, 'Color', 'w', 'LineWidth', 3);
        set(gca,'fontsize',15)
        ylabel('Tone Freq. (kHz)','fontsize',20);
        title(sprintf('ROI #%d, SPL=%d', ROINo, spl_use),'fontsize',20)
        subplot(2,1,2);
        plot(xdata, mean(f(inds_freq_sort_maxDB, :, ROINo)), 'LineWidth',2);
        axis tight
        
        % Plot mean trace
        
        y_line = get(gca, 'ylim');
        x_line = [t_stim t_stim];
        line(x_line, y_line, 'Color', 'k', 'LineWidth', 3);
        set(gca,'fontsize',15)
        xlabel('Time (s)', 'Fontsize',20)
        ylabel('dF/F','fontsize',20);
        axis tight
    % end

    % axes(ax(1)); title(sprintf('ROI #%d', ROINo), 'FontSize',15);
    % axes(ax(end)); xlabel('Time (s)', 'FontSize', 15);

%     saveas(gcf,sprintf('%ddB_ROI_response/%ddB_SPL_response_ROI_%d.png', spl_use,spl_use, ROINo),'png');
    export_fig(gcf, sprintf('%ddB_ROI_response/%ddB_SPL_response_ROI_%d.png', spl_use,spl_use, ROINo),'-png');

    end

    %%
    mkdir ROI_RF_Tuning
    
    for ROINo = 1:nROIs
        %%
%     ROINo = 1;
    
    ResponseWindow = [1 2]; % between 1 s and 2 s, Stim onset is 1 s.
    
    figure(fig3);
    colormap hot
    
    clf
    set(gcf, 'Color','w')
    cmap = jet;
    ax1 = subplot(1,2,1);
    for k = 1:length(spl)
        axes(ax1); hold on;
        spl_use = spl(k);
        plotColor = cmap(spl_use - 15,:);
        
        inds1 = find(sound_stim_param.intensity == spl_use) ;
        [~, inds2] = sort(sound_stim_param.frequency(inds1));
        
        inds_freq_sort_maxDB = inds1(inds2);
        f_trials = f(inds_freq_sort_maxDB, :, ROINo);
        inds_responseWindow = xdata > ResponseWindow(1) & xdata < ResponseWindow(2);
        f_meanResponse_trials = mean(f_trials(:,inds_responseWindow),2); % max(f_trials(:,inds_responseWindow)); % 
        
        allFreq = sound_stim_param.frequency(inds_freq_sort_maxDB);
        x_freq = unique(allFreq);
        
        for i = 1:length(x_freq)
            f_freqResponse(k,i) = mean(f_meanResponse_trials(allFreq == x_freq(i)));
        end
        hplot(k) = plot(log2(x_freq), f_freqResponse(k,:), '.-','linewidth',3, 'markersize',20, 'Color', plotColor);
        set(gca, 'xtickLabel', ceil((2.^(get(gca,'xtick'))/1000)))
    end
    hleg = legend(hplot, num2str(spl));
    set(hleg, 'FontSize',20, 'Location','northwest')
    set(gca,'fontsize',15)
    ylabel('dF/F', 'Fontsize',20);
    xlabel('Frequency (kHz)', 'Fontsize',20)
    axis square;
    title(sprintf('ROI #%d', ROINo),'fontsize',20)
    
    % Color plot of RF
    ax2 = subplot(1,2,2);
    imagesc(f_freqResponse, 'XData', log2(x_freq), 'YData', spl)
    set(hleg, 'FontSize',20)
    set(gca,'fontsize',15,'YDir','normal','YTick',spl)
    set(gca, 'xtickLabel', ceil((2.^(get(gca,'xtick'))/1000)))
    ylabel('SPL (dB)', 'Fontsize',20);
    xlabel('Frequency (kHz)', 'Fontsize',20)
    axis square;
    % Save the figure
%     saveas(gcf,sprintf('ROI_RF_Tuning/Freq_Tuning_ROI#_%d.png',ROINo),'png')
    export_fig(gcf,sprintf('ROI_RF_Tuning/Freq_Tuning_ROI#_%d.png',ROINo),'-png')
    
    end