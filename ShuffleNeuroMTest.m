function ShuffleNeuroMTest(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,varargin)
%this function is used for shuffle trial types and then test with the
%NeuroMetrix function to test whether test result is computational artifact


DataSize=size(RawDataAll);
% CorrectInds=TrialResult==1;
CorrectInds=true(1,length(TrialResult));
CorrTrialStim=StimAll(CorrectInds);
CorrTrialData=RawDataAll(CorrectInds,:,:);
CorrStimType=unique(CorrTrialStim);
ALLROIMeanData=zeros(length(CorrStimType),DataSize(2));

if ~isdir('./NeuroM_shuffle_test/')
    mkdir('./NeuroM_shuffle_test/');
end
cd('./NeuroM_shuffle_test/');
ThreeExplained=zeros(1,100);
for k = 1:100
ShuffleType=CorrTrialStim;
%#######################################
%stimtype shuffle section
TrialLength=numel(ShuffleType);
for n=1:TrialLength
    w = ceil(rand*n);
    t = ShuffleType(w);
    ShuffleType(w) = ShuffleType(n);
    ShuffleType(n) = t;
end


for n=1:length(CorrStimType)
    TempStim=CorrStimType(n);
    SingleStimInds=ShuffleType==TempStim;
    SingleStimData=CorrTrialData(SingleStimInds,:,AlignFrame:floor(AlignFrame+FrameRate*1.5));
    TrialMeanData=squeeze(mean(SingleStimData));
    ROIMeanData=mean(TrialMeanData,2);
    ALLROIMeanData(n,:)=ROIMeanData';
end

% ALLROIMeanNor=zeros(length(CorrStimType),DataSize(2));
% ROIMaxV=max(ALLROIMeanData);
% ALLROIMeanNor=(ALLROIMeanData./repmat(ROIMaxV,length(CorrStimType),1)); %each ROI will be normalized to each ROIs max value
% [coeff,score,latent,~,explained,~]=pca(ALLROIMeanNor);
% ALLROIMeanNor=ALLROIMeanNor';

% ALLROIMeanZsTrans=zscore(ALLROIMeanData);
% [coeff,score,latent,~,explained,~]=pca(ALLROIMeanZsTrans);
% 
% ThreeExplained(k)=sum(explained(1:3));
% if sum(explained(1:3))<80
%     warning('The first three component explains less than 80 percents, the pca result may not acurate.');
% end
% save RandPcaResult.mat ALLROIMeanData coeff score latent explained -v7.3

% Stimstr=num2str(CorrStimType);
% StimstrCell=strsplit(Stimstr,' ');
% h3d=figure;
% biplot(coeff(:,1:3),'varlabels',StimstrCell);
% grid off;
% title('PCA score for given stimulus');
% saveas(h3d,'Random_pcs_3d_space.png');
% saveas(h3d,'Random_pcs_3d_space.fig');
% close(h3d);
% 
% h2d=figure;
% biplot(coeff(:,1:2),'scores',score(:,1:2),'varlabels',StimstrCell);
% grid off;
% title('PCA score for given stimulus');
% saveas(h2d,'Random_pcs_2d_space.png');
% saveas(h2d,'Random_pcs_2d_space.fig');
% close(h2d);

LeftStims=CorrStimType(1:length(CorrStimType)/2);
RightStims=CorrStimType((length(CorrStimType)/2+1):end);
LeftStimsStr=cellstr(num2str(LeftStims(:)));
RightStimsStr=cellstr(num2str(RightStims(:)));

% h3d=figure;
% hold on;
% scatter3(score(1:3,1),score(1:3,2),score(1:3,3),30,'ro');
% text(score(1:3,1),score(1:3,2),score(1:3,3),LeftStimsStr);
% scatter3(score(4:6,1),score(4:6,2),score(4:6,3),30,'g*');
% text(score(4:6,1),score(4:6,2),score(4:6,3),RightStimsStr);
% legend('LeftScore','RightScore','location','northeastoutside');
% xlabel('pc1');
% ylabel('pc2');
% zlabel('pc3');
% % saveas(h3d,'PC_score_distribution_3d_space.png');
% % saveas(h3d,'PC_score_distribution_3d_space.fig');
% pause(0.5);
% close(h3d);

labelType=[zeros(1,length(CorrStimType)/2) ones(1,length(CorrStimType)/2)]';
svmmodel=fitcsvm(ALLROIMeanData,labelType);
[~,classscores]=predict(svmmodel,ALLROIMeanData);
difscore=classscores(:,2)-classscores(:,1);
fity=((difscore-min(difscore))./(max(difscore)-min(difscore)));  %rescale to [0 1]
% [filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
% load(fullfile(filepath,filename));
Octavex=log2(double(CorrStimType)/min(double(CorrStimType)));
% Octavefit=Octavex;
% Octavexfit=Octavex;
% realy=boundary_result.StimCorr;
% realy(1:3)=1-realy(1:3);
% Curve_x=linspace(min(Octavex),max(Octavex),500);

% [~,breal]=fit_logistic(Octavex,realy);
%excludes some bad points from fit
h3=figure;
scatter(Octavex,fity,60,'MarkerEdgeColor','r','MarkerFaceColor','c','LIneWidth',2.5);
xlim([-0.2 2.2]);
ylim([-0.1 1.1]);
% hold on;
% inds_exclude=input('please select the trial inds that should be excluded from analysis.\n','s');
% if ~isempty(inds_exclude)
%     inds_exclude=str2num(inds_exclude);
%     octave_dist_exclude=Octavex(inds_exclude);
%     reward_type_exclude=realy(inds_exclude);
%     Octavex(inds_exclude)=[];
%     realy(inds_exclude)=[];
%     scatter(octave_dist_exclude,reward_type_exclude,100,'x','MarkerEdgeColor','b');
% end
% 
% [~,breal]=fit_logistic(Octavex,realy);
% close(h3);
% 
% %####################
% h3=figure;
% 
% scatter(Octavexfit,fity,30,'MarkerEdgeColor','r','MarkerFaceColor','y');
% hold on;
% inds_excludefit=input('please select the trial inds that should be excluded from analysis.\n','s');
% if ~isempty(inds_excludefit)
%     inds_excludefit=str2num(inds_excludefit);
%     octave_dist_excludefit=Octavexfit(inds_excludefit);
%     reward_type_excludefit=fity(inds_excludefit);
%     Octavexfit(inds_excludefit)=[];
%     fity(inds_excludefit)=[];
%     scatter(octave_dist_excludefit,reward_type_excludefit,100,'x','MarkerEdgeColor','b');
% end
% 
% [~,bfit]=fit_logistic(Octavexfit,fity');
% close(h3);
% 
% 
% %##############################
% % [~,bfit]=fit_logistic(Octavefit,fity');
% modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
% curve_realy=modelfun(breal,Curve_x);
% curve_fity=modelfun(bfit,Curve_x);
% h2CompPlot=figure;
% hold on;
% plot(Curve_x,curve_fity,'c','LineWidth',2);
% plot(Curve_x,curve_realy,'k','LineWidth',2);
% scatter(Octavex,realy,40,'g','p','LineWidth',2);
% scatter(Octavexfit,fity,40,'b','o','LineWidth',2);
% if ~isempty(inds_exclude)
%     scatter(octave_dist_exclude,reward_type_exclude,100,'x','MarkerEdgeColor','r');
%     scatter(octave_dist_exclude,reward_type_exclude,50,'p','MarkerEdgeColor','r');
% end
% if ~isempty(inds_excludefit)
%     scatter(octave_dist_excludefit,reward_type_excludefit,100,'x','MarkerEdgeColor','m');
%     scatter(octave_dist_excludefit,reward_type_excludefit,50,'o','MarkerEdgeColor','m');
% end
% legend('logi\_fitc','logi\_realc','Real\_data','Fit\_data','location','northeastoutside');
title('Shuffled data fit result');
xlabel('Octave');
ylabel('Rightward Choice');
saveas(h3,sprintf('Neuro_psycho_comp_plot%03d.png',k));
saveas(h3,sprintf('Neuro_psycho_comp_plot%03d.fig',k));

% save randCurveFit.mat svmmodel Octavex realy fity breal bfit -v7.3
pause(0.5);
close(h3);
end
save ExplainResult.mat ThreeExplained -v7.3
cd ..;