function random_all_plot(raw_data,stim_freq,stim_onset_time,result_type,FrameRate,varargin)
%this function is used to plot all random puretone results, which is
%containing correct, error and miss trials
%all plots will be sorted by stim onset time,using the same scale for all
%the variable named result_type indicates the outcome for each trial, as 0
%for error, 1 for correct and 2 for miss trial
%plots
%by XIN Yu, June 29,2015

stim_type=unique(stim_freq);
data_size=size(raw_data);
if max(stim_onset_time)>500
    stim_onset_time=floor((double(stim_onset_time)/1000)*FrameRate);
elseif max(stim_onset_time)<2.5
    stim_onset_time=floor(stim_onset_time*FrameRate);
end
if nargin>5
    session_desp=varargin{1};
    if size(session_desp,1)>1
        session_desp=session_desp';
    end
end
if nargin>6
    PlotOption=varargin{2};
    if strcmpi(PlotOption,'prob')
        PlotChoice=1;  %this option indicates prob trials plot
    end
else
    PlotChoice=0;  %using default plot option, random plot
end
if PlotChoice==0
    disp('Plot all frequency response of random puretone trials.\n');
    if ~isdir('./Random_all_plot/')
        mkdir('./Random_all_plot/');
    end
    cd('./Random_all_plot/');
elseif PlotChoice==1
    disp('Plot all frequency response of probe trials.\n');
    if ~isdir('./Prob_all_plot/')
        mkdir('./Prob_all_plot/');
    end
    cd('./Prob_all_plot/');
end

if length(stim_freq)~=data_size(1) || length(stim_onset_time)~=data_size(1)
    disp(['length of stim freq=' num2str(length(stim_freq)) ';\n length of stim onset time=' num2str(length(stim_onset_time)) '.\n']);
    error('Error input length for stim freq or stim onset time, quit analysis.\n');
end

PlotColNum=length(stim_type);

parfor m=1:data_size(2)
    h_all=figure;
    ROISingleData=squeeze(raw_data(:,m,:));
    clim=[];
    clim(1)=min(ROISingleData(:));
    clim(2)=mean([max(ROISingleData(:)),median(ROISingleData(:))]);
    if clim(2)<=clim(1) || isnan(clim(2))
        disp(['NaN data exist in ROI' num2str(m) ', skip this ROI plot.\n']);
        close;
        continue;
    end
    for n=1:PlotColNum
        ColFreq=stim_type(n);
        ColFreqInds=stim_freq==ColFreq;
        ColFreqData=squeeze(raw_data(ColFreqInds,m,:));
        ColFreqOnset=stim_onset_time(ColFreqInds);
        ColFreqTType=result_type(ColFreqInds);
        
        PanelPlotInds=ColFreqTType==1; %correct trials inds
        PanelPlotData=ColFreqData(PanelPlotInds,:);
        PanelPlotOnset=ColFreqOnset(PanelPlotInds);
        [PanelPlotOnsetSort,I]=sort(PanelPlotOnset);
        subplot(3,PlotColNum,n);
        imagesc(PanelPlotData(I,:),clim);
        set(gca,'xtick',[],'FontSize',6);
        if n==1
             ylabel('corr trials','FontSize',6);
        end
        title([num2str(ColFreq) 'Hz']);
        hold on;
        for k=1:length(I)
            line([PanelPlotOnsetSort(k) PanelPlotOnsetSort(k)],[k-0.5 k+0.5],'color',[1 0 1],'LineWidth',1.8);
        end
        hold off;
        if n==PlotColNum
            h_bar=colorbar;
            plot_position_3=get(h_bar,'position');
            set(h_bar,'position',[plot_position_3(1)*1.08 plot_position_3(2) plot_position_3(3)*0.5 plot_position_3(4)]);
            set(get(h_bar,'Title'),'string','\DeltaF/F_0');
        end
        
        PanelPlotInds=ColFreqTType==0; %error trials inds
        PanelPlotData=ColFreqData(PanelPlotInds,:);
        PanelPlotOnset=ColFreqOnset(PanelPlotInds);
        [PanelPlotOnsetSort,I]=sort(PanelPlotOnset);
        subplot(3,PlotColNum,n+PlotColNum);
        imagesc(PanelPlotData(I,:),clim);
        set(gca,'xtick',[],'FontSize',6);
        if n==1
            ylabel('error trials','FontSize',6);
        end
        title([num2str(ColFreq) 'Hz']);
        hold on;
        for k=1:length(I)
            line([PanelPlotOnsetSort(k) PanelPlotOnsetSort(k)],[k-0.5 k+0.5],'color',[1 0 1],'LineWidth',1.8);
        end
        hold off
        if n==PlotColNum
            h_bar=colorbar;
            plot_position_3=get(h_bar,'position');
            set(h_bar,'position',[plot_position_3(1)*1.08 plot_position_3(2) plot_position_3(3)*0.5 plot_position_3(4)]);
            set(get(h_bar,'Title'),'string','\DeltaF/F_0');
        end
        
        PanelPlotInds=ColFreqTType==2; %miss trials inds
        PanelPlotData=ColFreqData(PanelPlotInds,:);
        PanelPlotOnset=ColFreqOnset(PanelPlotInds);
        [PanelPlotOnsetSort,I]=sort(PanelPlotOnset);
        subplot(3,PlotColNum,n+2*PlotColNum);
        imagesc(PanelPlotData(I,:),clim);
        x_tick=0:FrameRate:size(PanelPlotData,2);
        x_tick_label=0:length(x_tick);
        set(gca,'xtick',x_tick,'xticklabel',x_tick_label,'FontSize',6);
        if n==1
            ylabel('miss trials','FontSize',6);
        end
        title([num2str(ColFreq) 'Hz']);
        hold on;
        for k=1:length(I)
            line([PanelPlotOnsetSort(k) PanelPlotOnsetSort(k)],[k-0.5 k+0.5],'color',[1 0 1],'LineWidth',1.8);
        end
        hold off
        if n==PlotColNum
            h_bar=colorbar;
            plot_position_3=get(h_bar,'position');
            set(h_bar,'position',[plot_position_3(1)*1.08 plot_position_3(2) plot_position_3(3)*0.5 plot_position_3(4)]);
            set(get(h_bar,'Title'),'string','\DeltaF/F_0');
        end
    end
    suptitle(['All trial plot for ROI' num2str(m)]);
    saveas(h_all,[session_desp '_SessionPlot_ROI' num2str(m)],'fig');
    close;
end

for n=1:data_size(2)
    open(sprintf('%s_SessionPlot_ROI%d.fig',session_desp,n));
    set(gcf,'position',[200 100 1500 900],'PaperPositionMode','auto');
    print(gcf,'-dpng','-opengl','-r200',sprintf('%s_SessionPlot_ROI%d.png',session_desp,n));
    close(gcf);
end

disp('Session plot for all trials complete.\n');
cd ..;