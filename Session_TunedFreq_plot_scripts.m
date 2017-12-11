clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select session data path file');
if ~fi
    return;
end
%%
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    cd(tline);
    
    clearvars PassTunningfun PassFreqOctave CorrTunningFun TaskFreqOctave
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd('Tunning_fun_plot_New1s');
    % main script part
    % Passive data processing part
    for IsOuterFreqUsed = 0:1;
        if ~IsOuterFreqUsed
            ExcludePassInds = abs(PassFreqOctave) > 1;
            UsedPassTunData = PassTunningfun(~ExcludePassInds,:);
            UsedPassOctave = PassFreqOctave(~ExcludePassInds);
        else
            UsedPassTunData = PassTunningfun;
            UsedPassOctave = PassFreqOctave;
        end

        [MaxValue,MaxInds] = max(UsedPassTunData);
        [nFreqs,nROIs] = size(UsedPassTunData);
        MaxIndsFreq = zeros(nROIs,1);
        for cROI = 1 : nROIs
            MaxIndsFreq(cROI) = UsedPassOctave(MaxInds(cROI));
        end
        Behavfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
        BehavBound = Behavfile.boundary_result.Boundary - 1;
        [AmpSortValue,AmpSortInds] = sort(MaxValue,'descend');
        TickStrs = cellstr(num2str(BoundFreq*(2.^UsedPassOctave(:))/1000,'%.1f'));
        [counts,centers] = hist(MaxIndsFreq,10,[-1 1]);
        % ColorMap = jet(nFreqs);
        %
        hhf = figure('position',[700 160 780 300]);
        subplot(121)
        hold on;
        scatter(1:nROIs,AmpSortValue,30,MaxIndsFreq(AmpSortInds),'o','filled');
        colormap jet
        xlabel('nROIs');
        ylabel('Amplitude \DeltaF/F_0(%)');
        set(gca,'FontSize',18);
        hbar = colorbar('east');
        set(hbar,'ytick',UsedPassOctave,'yticklabel',TickStrs,'FontSize',10);
        title(hbar,'kHz');
        set(hbar,'position',get(hbar,'position').*[1,1,0.3,0.8]+[0 0.18 0 0]);

        subplot(122)
        bar(centers,counts,0.4,'EdgeColor','none','FaceColor','c')
        yscales = get(gca,'ylim');
        ll = line([BehavBound BehavBound],yscales,'Color',[.7 .7 .7],'linewidth',1.8,'linestyle','--');
        set(gca,'xtick',UsedPassOctave,'xticklabel',TickStrs,'FontSize',16);
        xlabel('Frequency (kHz)')
        ylabel('ROI counts')
        legend(ll,{'behavBoundary'},'Location','Northwest','FontSize',8);
        legend('boxoff');

        annotation('textbox',[0.43,0.7,0.2,0.3],'String','Passive','FitBoxToText','on','EdgeColor',...
                           'none','FontSize',14,'Color','m');

        if IsOuterFreqUsed
            saveas(hhf,'Passive session Frequency Tuned with outerFreq');
            saveas(hhf,'Passive session Frequency Tuned with outerFreq','png');
            close(hhf);
        else
            saveas(hhf,'Passive session Frequency Tuned without outerFreq');
            saveas(hhf,'Passive session Frequency Tuned without outerFreq','png');
            close(hhf);
        end
    end
    % #################################################################################
    % task data part
    TaskFreqStr = cellstr(num2str(BoundFreq*(2.^TaskFreqOctave(:))/1000,'%.1f'));
    [TaskMaxvalue,TaskMaxInds] = max(CorrTunningFun);
    [TaskFreqs,TaskROIs] = size(CorrTunningFun);
    TaskTunedFreqs = zeros(TaskROIs,1);
    for cROI = 1 : TaskROIs
        TaskTunedFreqs(cROI) = TaskFreqOctave(TaskMaxInds(cROI));
    end
    [TaskAmpSort,TaskSortInds] = sort(TaskMaxvalue,'descend');
    [TaskCot,TaskCen] = hist(TaskTunedFreqs,10,[-1 1]);

    hf = figure('position',[700 580 780 300]);
    subplot(121)
    hold on;
    scatter(1:TaskROIs,TaskAmpSort,30,TaskTunedFreqs(TaskSortInds),'o','filled');
    colormap jet
    xlabel('nROIs');
    ylabel('Amplitude \DeltaF/F_0(%)');
    set(gca,'FontSize',18);
    hbar = colorbar('east');
    set(hbar,'ytick',TaskFreqOctave,'yticklabel',TaskFreqStr,'FontSize',10);
    title(hbar,'kHz');
    set(hbar,'position',get(hbar,'position').*[1,1,0.3,0.8]+[0 0.18 0 0]);

    subplot(122)
    bar(TaskCen,TaskCot,0.4,'EdgeColor','none','FaceColor','c')
    yscales = get(gca,'ylim');
    ll = line([BehavBound BehavBound],yscales,'Color',[.7 .7 .7],'linewidth',1.8,'linestyle','--');
    set(gca,'xtick',TaskFreqOctave,'xticklabel',TaskFreqStr,'FontSize',16);
    xlabel('Frequency (kHz)')
    ylabel('ROI counts')
    legend(ll,{'behavBoundary'},'Location','Northwest','FontSize',8);
    legend('boxoff');
    annotation('textbox',[0.43,0.7,0.2,0.3],'String','Task','FitBoxToText','on','EdgeColor',...
                       'none','FontSize',14,'Color','m');
    saveas(hf,'Task session Tuned Frequency distribution');
    saveas(hf,'Task session Tuned Frequency distribution','png');
    close(hf);
    
    tline = fgetl(fid);
end