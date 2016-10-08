function varargout = ROC_check(AlignedData,Trial_Type,alignpoint,FrameRate,varargin)
%this funtion will be used for early response ROC check to see whether
%single ROI can do the stimulus discriminnation
%the discrimination critiria is setted at 0.8, just for a hard test
%ROC function call the roc function, which is modified from an online
%version
%XIN Yu, 20, July, 2015
isplot = 1;
if length(varargin) > 2
    if ~isempty(varargin{3})
        isplot = varargin{3};
    end
end
if nargin>4
    if ~isempty(varargin{1})
        TimeLength=varargin{1};
    else
        TimeLength=1.5;
    end
    if length(varargin) > 1
        if ~isempty(varargin{2})
            ProcessDesp=varargin{2};
            if isplot
                if ~isdir(['./',ProcessDesp,'/']);
                    mkdir(['./',ProcessDesp,'/']);
                end
                cd(['./',ProcessDesp,'/']);
            end
        end
    end
end

if isplot
    if ~isdir('./ROC_Left2Right_result/')
        mkdir('./ROC_Left2Right_result/');
    end
    cd('./ROC_Left2Right_result/');
end
SizeData=size(AlignedData);
TrialType=Trial_Type;
SelectData=AlignedData(:,:,((alignpoint+1):floor(alignpoint+FrameRate*TimeLength)));
% TrialTimeLength=size(SelectData,3);  %select data points number fro each trial
Trials=reshape(TrialType,1,[]);
% TrialInput=double(reshape(repmat(Trials,TrialTimeLength,1),[],1));
mean_data=mean(SelectData,3);
LeftTrial=TrialType==0;
RightTrial=TrialType==1;
ROCarea=zeros(1,SizeData(2));
ROCRevert=zeros(1,SizeData(2));
ROCRevertShff=zeros(1,SizeData(2));
ROCShufflearea=zeros(1,SizeData(2));
ROCShuffleAll=zeros(500,SizeData(2));
ROIDiffmd=zeros(1,SizeData(2));
ROIDiffmn=zeros(1,SizeData(2));
% % ROIDiffMax=zeros(1,SizeData(2));
MaxInput = max(SelectData,[],3);

for n=1:SizeData(2)
    CurrentData=squeeze(MaxInput(:,n));
    DataInput=reshape(CurrentData',[],1);
    test_data=mean_data(:,n);
    if isplot
        [ROCSummary,LabelMeanS]=rocOnline([DataInput double(Trials)']);
        ROCarea(n)=ROCSummary.AUC;
        ROCRevert(n)=gather(LabelMeanS.Type1value > LabelMeanS.Type2value);    %ubar   hbar
        suptitle(sprintf('ROI%d AUC',n));
        saveas(gcf,['ROC distinguish for LR Trials result for ROI' num2str(n)],'png');
        saveas(gcf,['ROC distinguish for LR Trials result for ROI' num2str(n)],'fig');
        close(gcf);
    else
        [ROCSummary,LabelMeanS]=rocOnlineFoff([DataInput double(Trials)']);
        ROCarea(n)=ROCSummary;
        ROCRevert(n)=double(LabelMeanS);
    end
    %     LabelMeanS=gpuArray(LabelMeanS);
    ROIDiffmd(n)=abs(median(test_data(LeftTrial))-median(test_data(RightTrial)));
    ROIDiffmn(n)=abs(mean(test_data(LeftTrial))-mean(test_data(RightTrial)));
    %     ROIDiffMax(n)=max(abs(test_data(LeftTrial)-test_data(RightTrial)));
    [AllROC,~,sigvalue]=ROCSiglevelGene([DataInput,double(Trials)'],500,1,0.01);
    ROCShufflearea(n) = sigvalue;
    ROCShuffleAll(:,n) = AllROC(:);
    %     ShuffleType=RandShuffle(test_data(:,2));
    %     DataShuffle=[test_data(:,1),ShuffleType];
    %     [ShuffleSummary,ShuffleStrc]=rocOnlineFoff(DataShuffle);
    %     ROCRevertShff(n)=gather(ShuffleStrc.Type1value > ShuffleStrc.Type2value);    %ubar   hbar
    %     ROCShufflearea(n)=ShuffleSummary.AUC;
end

ShffROCareaABS=ROCShufflearea;
% ShffROCareaABS(ROCRevertShff == 1) = 1 - ShffROCareaABS(ROCRevertShff == 1);
ROCareaABS = ROCarea;
ROCareaABS(ROCRevert == 1) = 1 - ROCareaABS(ROCRevert == 1); % using real AUC value to check whether ROI is significantly response or not
SigROC = ROCareaABS > ROCShufflearea;
RandThres=mean(ShffROCareaABS);
RespFraction=sum(ROCareaABS>RandThres)/length(ROCarea);
if isplot
    hist(ROCarea);
    % set(h,'FaceColor','c','EdgeColor','w');
    xlabel('ROC area distribution');
    saveas(gcf,'ROC_area_dis','png');
    close;
    
    h_popu_sort=figure;
    ROCsort=sort(ROCareaABS,'descend');
    plot(ROCsort,'o','LineWidth',1.8);
    AxesScale=axis(gca);
    line([AxesScale(1) AxesScale(2)],[RandThres RandThres],'color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','-.');
    text(AxesScale(2)*0.65,AxesScale(4)*0.8,sprintf('Frac. Above=%.4f',RespFraction));
    xlabel('# ROIs');
    ylabel('AUC value');
    ylim([0 1]);
    title('Population AUC distribution');
    saveas(h_popu_sort,'PopuSort_ROC.png');
    saveas(h_popu_sort,'PopuSort_ROC.fig');
    close(h_popu_sort);
    
    %%
    h_popu_correl=figure('position',[90 200 1200 800],'PaperPositionMode','auto');
    
    subplot(1,2,1)
    [ROIDiffmnS,ROIDiffmnI]=sort(ROIDiffmn);
    [hmn,pmn]=corrcoef(ROIDiffmnS,ROCareaABS(ROIDiffmnI));
    scatter(ROIDiffmnS,ROCareaABS(ROIDiffmnI),45,linspace(1,10,length(ROCarea)),'LineWidth',2);
    axis square
    colormap cool
    title({'mean response value',sprintf('Coef = %0.2f, p=%.2e',hmn(1,2),pmn(1,2))});
    ylabel('L2R AUC')
    xlabel('\DeltaF/f_0');
    
    subplot(1,2,2)
    [ROIDiffmdS,ROIDiffmdI]=sort(ROIDiffmd);
    [hmd,pmd]=corrcoef(ROIDiffmdS,ROCareaABS(ROIDiffmdI));
    scatter(ROIDiffmdS,ROCareaABS(ROIDiffmdI),45,linspace(1,10,length(ROCarea)),'LineWidth',2);
    axis square
    colormap cool
    title({'median response value',sprintf('Coef = %0.2f, p=%.2e',hmd(1,2),pmd(1,2))});
    xlabel('\DeltaF/f_0');
    
    % subplot(1,3,3)
    % [ROIDiffmaxS,ROIDiffmaxI]=sort(ROIDiffMax);
    % [hmax,pmax]=corrcoef(ROIDiffmaxS,ROCareaABS(ROIDiffmaxI));
    % scatter(ROIDiffmaxS,ROCareaABS(ROIDiffmaxI),45,linspace(1,10,length(ROCarea)),'LineWidth',2);
    % colormap cool
    % title({'max response value',sprintf('Coef = %0.2f, p=%.2e',hmax(1,2),pmax(1,2))})
    % xlabel('\DeltaF/f_0');
    
    suptitle('Scatter plot of ROC vs ROI response');
    saveas(h_popu_correl,'PopuSort_ROC_corr_resp.png');
    saveas(h_popu_correl,'PopuSort_ROC_corr_resp');
    close(h_popu_correl);
    
    save ROC_score.mat ROCarea RespFraction ROIDiffmd ROIDiffmn ROCRevert ROCShufflearea ROCRevertShff -v7.3
    
    %%
    %left trials response compared with baseline levels
    SelectData=AlignedData(:,:,(alignpoint:floor(alignpoint+FrameRate*TimeLength)));
    % TraceDatapoints=size(SelectData,3);
    if ~isdir('./Left_resp2base_roc/')
        mkdir('./Left_resp2base_roc/');
    end
    
    if ~isdir('./Right_resp2base_roc/')
        mkdir('./Right_resp2base_roc/');
    end
    LeftBase2RespRoc=zeros(size(SelectData,2),1);
    RightBase2RespRoc=zeros(size(SelectData,2),1);
    ShuffleLeftRoc=zeros(size(SelectData,2),1);
    ShuffleRightRoc=zeros(size(SelectData,2),1);
    LeftBase2RespMNDiff=zeros(size(SelectData,2),1);
    LeftBase2RespMaxAmp=zeros(size(SelectData,2),1);
    RightBase2RespMNDiff=zeros(size(SelectData,2),1);
    RightBase2RespMaxAmp=zeros(size(SelectData,2),1);
    for n=1:size(SelectData,2)
        DataLeft=squeeze(SelectData(LeftTrial,n,:));
        DataRight=squeeze(SelectData(RightTrial,n,:));
        ROILeftBase = max(DataLeft(:,1:alignpoint),[],2);
        ROILeftResp = max(DataLeft(:,(alignpoint+1):end),[],2);
        %     ROILeftBase=reshape(DataLeft(:,1:alignpoint),[],1);
        %     ROILeftResp=reshape(DataLeft(:,alignpoint:end),[],1);
        LeftBase2RespMNDiff(n)=mean(ROILeftResp)-mean(ROILeftBase);
        MeanT=mean(DataLeft);
        LeftBase2RespMaxAmp(n)=max(MeanT(alignpoint:end));  %maxium amplitude of deltaF\F0
        LeftBase=zeros(length(ROILeftBase),1);
        LeftResp=ones(length(ROILeftResp),1);
        test_data=[[ROILeftBase;ROILeftResp],[LeftBase;LeftResp]];
        [cROC,~]=rocOnline(test_data);
        LeftBase2RespRoc(n)=cROC.AUC;
        ShuffleType=RandShuffle(test_data(:,2));
        DataShuffle=[test_data(:,1),ShuffleType];
        [ShuffleSummary,~]=rocOnlineFoff(DataShuffle);
        ShuffleLeftRoc(n)=ShuffleSummary;
        %     LeftBase2RespRoc(n)=ROCL_Base2Resp(n).AUC;
        saveas(gcf,sprintf('./Left_resp2base_roc/ROC_resultL_ROI%d.png',n));
        saveas(gcf,sprintf('./Left_resp2base_roc/ROC_resultL_ROI%d.fig',n));
        close(gcf);
        
        ROIRightBase=max(DataRight(:,1:alignpoint),[],2);
        ROIRightResp=max(DataRight(:,(alignpoint+1):end),[],2);
        RightBase=zeros(length(ROIRightBase),1);
        RightResp=ones(length(ROIRightResp),1);
        RightBase2RespMNDiff(n)=mean(RightResp)-mean(RightBase);
        MeanTR=mean(DataRight);
        RightBase2RespMaxAmp(n)=max(MeanTR(alignpoint:end));
        test_data=[[ROIRightBase;ROIRightResp],[RightBase;RightResp]];
        [cROC,~]=rocOnline(test_data);
        RightBase2RespRoc(n)=cROC.AUC;
        %     RightBase2RespRoc(n)=ROCR_Base2Resp(n).AUC;
        ShuffleType=RandShuffle(test_data(:,2));
        DataShuffle=[test_data(:,1),ShuffleType];
        [ShuffleSummary,~]=rocOnlineFoff(DataShuffle);
        ShuffleRightRoc(n)=ShuffleSummary;
        saveas(gcf,sprintf('./Right_resp2base_roc/ROC_resultR_ROI%d.png',n));
        saveas(gcf,sprintf('./Right_resp2base_roc/ROC_resultR_ROI%d.fig',n));
        close(gcf);
    end
    c=linspace(1,10,length(LeftBase2RespRoc));
    hROC_sum=figure;
    subplot(1,2,1)
    scatter(1:length(LeftBase2RespRoc),sort(LeftBase2RespRoc),30,c,'o','LineWidth',1.5);
    colormap cool
    yaxis=axis();
    RandThres=mean(ShuffleLeftRoc);
    line([yaxis(1) yaxis(2)],[RandThres RandThres],'LineWidth',2.5,'LineStyle','-.');
    xlabel('ROIs');
    title(sprintf('Left Trials ROC thres=%.4f',RandThres));
    
    subplot(1,2,2)
    scatter(1:length(RightBase2RespRoc),sort(RightBase2RespRoc),30,c,'o','LineWidth',1.5);
    colormap cool
    yaxis=axis();
    RandThresR=mean(ShuffleRightRoc);
    line([yaxis(1) yaxis(2)],[RandThresR RandThresR],'LineWidth',2.5,'LineStyle','-.');
    xlabel('ROIs');
    title(sprintf('Right Trials ROC thres=%.4f',RandThresR));
    
    saveas(hROC_sum,'Population ROC distinguish.png');
    saveas(hROC_sum,'Population ROC distinguish.fig');
    close(hROC_sum);
    
    hROC_respCorr=figure;
    c=linspace(1,10,length(LeftBase2RespRoc));
    subplot(2,2,1)
    scatter(LeftBase2RespMNDiff,LeftBase2RespRoc,30,c,'o','LineWidth',2);
    colormap cool
    [r,p]=corrcoef(LeftBase2RespMNDiff,LeftBase2RespRoc);
    coefV=r(1,2); pV=p(1,2);
    title(sprintf('Left Corrcoef=%.3f vs P value=%.2e',coefV,pV));
    xlabel('Mean value diff')
    ylabel('ROC value')
    
    subplot(2,2,2)
    scatter(LeftBase2RespMaxAmp,LeftBase2RespRoc,30,c,'o','LineWidth',2);
    colormap cool
    [r,p]=corrcoef(LeftBase2RespMaxAmp,LeftBase2RespRoc);
    coefV=r(1,2); pV=p(1,2);
    title(sprintf('Left Corrcoef=%.3f vs P value=%.2e',coefV,pV));
    xlabel('Max Amp')
    ylabel('ROC value')
    
    c=linspace(1,10,length(RightBase2RespRoc));
    subplot(2,2,3)
    scatter(RightBase2RespMNDiff,RightBase2RespRoc,30,c,'o','LineWidth',2);
    colormap cool
    [r,p]=corrcoef(RightBase2RespMNDiff,RightBase2RespRoc);
    coefV=r(1,2); pV=p(1,2);
    title(sprintf('Right Corrcoef=%.3f vs P value=%.2e',coefV,pV));
    xlabel('Mean value diff')
    ylabel('ROC value')
    
    subplot(2,2,4)
    scatter(RightBase2RespMaxAmp,RightBase2RespRoc,30,c,'o','LineWidth',2);
    colormap cool
    [r,p]=corrcoef(RightBase2RespMaxAmp,RightBase2RespRoc);
    coefV=r(1,2); pV=p(1,2);
    title(sprintf('Right Corrcoef=%.3f vs P value=%.2e',coefV,pV));
    xlabel('Max Amp')
    ylabel('ROC value')
    
    saveas(hROC_respCorr,'Amp_value_correlation_with_ROC_value.png');
    saveas(hROC_respCorr,'Amp_value_correlation_with_ROC_value.fig');
    close(hROC_respCorr);
    
    save LeftRightROC_result.mat LeftBase2RespRoc RightBase2RespRoc ...
        ShuffleLeftRoc ShuffleRightRoc RightBase2RespMaxAmp RightBase2RespMNDiff LeftBase2RespMaxAmp LeftBase2RespMNDiff -v7.3
    
    % plot Selection index, which is calculated by 2*(AUC - 0.5), we will
    % get a result as: better Left selectivity, result close to -1, and
    % better right selectivity gets a result close to 1
    SelectIndex = (ROCarea - 0.5)*2;
    SigAUCValue = SigROC;
    [Count,Center] = hist(SelectIndex,15);
    [CountSig,CenterSig] = hist(SelectIndex(SigAUCValue),15);
    h_Sindex = figure('position',[430 300 1100 800],'PaperPositionMode','auto');
    hold on
    bar(Center,(Count/numel(SelectIndex)),'r');
    alpha(0.3);
    bar(CenterSig,(CountSig/numel(SelectIndex)),'r');
    xlabel('Index value');
    ylabel('Cell Fraction');
    title('Population Selection index');
    set(gca,'xtick',[-1,0,1],'xticklabel',[-1,0,1]);
    set(gca,'FontSize',20);
    saveas(h_Sindex,'Population selection index plot','png');
    saveas(h_Sindex,'Population selection index plot','fig');
    saveas(h_Sindex,'Population selection index plot','epsc');
    close(h_Sindex);
    
    cd ..;
    cd ..;
end
if nargout > 0
    varargout(1) = {ROCareaABS};
end