%%
% filename = 'rs4';
% load('rs4_20200924_Afc_used22');
ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
saveFoldername = fullfile(ksfolder,'BSRL_ReversingTrials');
clearvars behavResults P_choiceLeft nll delta V_R V_L P_bound_low P_bound_high
load(fullfile(ksfolder,'NPClassHandleSaved.mat'),'behavResults');
if ~isfolder(saveFoldername)
    mkdir(saveFoldername);
end
%%
% lb = [0,1e-10,0,0,1e-10,0];
% ub = [1,10,1,1,10,1];

lb = [0,1e-10,0.4,0];
ub = [1,10,1,1];

NumParas = numel(ub);
ntime = 20;

matfileBlockInfos = BlockpsyCurveCalFun(behavResults);
BlockSectionInfo = matfileBlockInfos{1};
HighAndLowBlock_bound = [matfileBlockInfos{3},matfileBlockInfos{4}];
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
if exist('SessionResults','var')
   [Octave_used,left_choice_used,inds_correct_used,inds_use,inds_rev] = BehInput(SessionResults,RevFreqs);
elseif exist('behavResults','var')
    [Octave_used,left_choice_used,inds_correct_used,inds_use,inds_rev] = BehInput(behavResults,RevFreqs);
end
        
        
% NLLfun = @(x,Octave_used,left_choice_used,inds_correct_used) NLL_MB_RL_function_v5(x(1),x(2),x(3),...
%     x(4),x(5),x(6),Octave_used,left_choice_used,inds_correct_used);
NLLfun = @(x,Octave_used,left_choice_used,inds_correct_used) NLL_MB_RL_function_v4(x(1),x(2),x(3),...
    x(4),Octave_used,left_choice_used,inds_correct_used); %,HighAndLowBlock_bound


fitfun = @(para) NLLfun(para,Octave_used,left_choice_used,inds_correct_used);
bestx = zeros(ntime,NumParas);
negll = zeros(ntime,1);
for n = 1:ntime
    tic
    xx =lb+rand(1,numel(ub)).*(ub-lb); %seed random starting point
%     disp(xx)
    options = optimset('Algorithm','sqp','MaxFunEvals',3000,'MaxIter',1000,'FunValCheck','on');
    nonlcon = [];

    [bestx(n,:) negll(n)]=fmincon(fitfun,xx,[],[],[],[],lb,ub);
    toc
end
%%
numbest = find(negll == min(negll));

parameters = bestx(numbest(1),:);
theta_fit = parameters(1);
beta_fit = parameters(2);
alpha_fit = parameters(3);
P_bound_low_init = parameters(4);
%
[P_choiceLeft,nll,delta,V_R,V_L,P_bound_low,P_bound_high]= MB_RL_function_v4(theta_fit,beta_fit,alpha_fit,P_bound_low_init,Octave_used,left_choice_used,inds_correct_used);


%% figure for behavior
hif = figure('position',[100 100 780 360]);
UsedIndsInReal = find(inds_rev(inds_use));
inds_revBack = inds_rev;
inds_revBack(~inds_use) = false;
OriginalIndsReal = find(inds_revBack);
%
% RevUsedInds = UsedIndsInReal(inds_rev(inds_use));
hl4 = plot(OriginalIndsReal,P_bound_high(UsedIndsInReal+1,1),'color','r','linewidth',2);
hold on
hl1 = plot(OriginalIndsReal,smooth(P_choiceLeft(UsedIndsInReal,1),5),'color','c','linewidth',2);
hl2 = plot(OriginalIndsReal,P_bound_low(UsedIndsInReal+1,1),'color','b','linewidth',2);
hl3 = plot(OriginalIndsReal,smooth(double(left_choice_used(UsedIndsInReal)),5),'k','linewidth',2);
yscales = get(gca,'ylim');
for cBInds = 1 : size(BlockSectionInfo.BlockTrScales,2)
    cBEndInds = BlockSectionInfo.BlockTrScales(cBInds,2)+0.5;
    line([cBEndInds cBEndInds],yscales,'Color','m','linewidth',1.6,'linestyle','--');
end
legend([hl1,hl2,hl3,hl4],{'p\_LChoice','p\_low','LChoice','p\_high'},'box','off','location','northeastoutside');
xlabel('#Trial','FontSize',10);
ylabel('Leftward choice','FontSize',10);
set(gca,'FontSize',10);
%%

% saveas(hif,[filename_1  '.png']);
% saveas(hif,[filename_1  '.fig']);
% saveas(hif,[filename_1  '.eps']);
saveName = fullfile(saveFoldername,'behavModel_fitting_plots');

saveas(hif,saveName);
print(hif,saveName,'-dpng','-r0');
print(hif,saveName,'-dpdf','-bestfit');
close(hif);

%
filename_2 = [saveFoldername,filesep, 'BSRL_modelData.mat'];
save(filename_2,'theta_fit','beta_fit','alpha_fit','P_bound_low_init','nll','inds_correct_used','P_choiceLeft','delta','V_L','V_R','P_bound_low','P_bound_high');
%%
% load('F:\20200924\rs4\afc\im_data_reg_cpu\result_save_new\rs4_BSRL.mat')
 %
% figure;plot (delta,'.');
% 
% xlabel('#Trial','FontSize',15);
% ylabel('Prediction error(delta)','FontSize',15);
% set(gca,'FontSize',15);
% box off
% set(gca,'tickdir','out');
%%
%%
% lb = [0,1e-10,0,0,-0.5];
% ub = [1,10,1,1,0.5];
% 
% % lb = [0,1e-10,0,0];
% % ub = [1,10,1,1];
% 
% NumParas = numel(ub);
% ntime = 20;
% BlockSectionInfo = Bev2blockinfoFun(behavResults);
% RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
% if exist('SessionResults','var')
%    [Octave_used,left_choice_used,inds_correct_used,inds_use,inds_rev] = BehInput(SessionResults,RevFreqs);
% elseif exist('behavResults','var')
%     [Octave_used,left_choice_used,inds_correct_used,inds_use,inds_rev] = BehInput(behavResults,RevFreqs);
% end
%         
%         
% NLLfun = @(x,Octave_used,left_choice_used,inds_correct_used) NLL_MB_RL_function_v5(x(1),x(2),x(3),...
%     x(4),x(5),Octave_used,left_choice_used,inds_correct_used);
% % NLLfun = @(x,Octave_used,left_choice_used,inds_correct_used) NLL_MB_RL_function_v4(x(1),x(2),x(3),...
% %     x(4),Octave_used,left_choice_used,inds_correct_used);
% 
% 
% fitfun = @(para) NLLfun(para,Octave_used,left_choice_used,inds_correct_used);
% bestx2 = zeros(ntime,NumParas);
% negll2 = zeros(ntime,1);
% for n = 1:ntime
%     tic
%     xx =lb+rand(1,numel(ub)).*(ub-lb); %seed random starting point
%     options = optimset('Algorithm','sqp','MaxFunEvals',3000,'MaxIter',1000,'FunValCheck','on');
%     nonlcon = [];
% 
%     [bestx2(n,:) negll2(n)]=fmincon(fitfun,xx,[],[],[],[],lb,ub);
%     toc
% end
% 
% %%
% numbest = find(negll2 == min(negll2));
% 
% parameters = bestx2(numbest(1),:);
% theta_fit = parameters(1);
% beta_fit = parameters(2);
% alpha_fit = parameters(3);
% P_bound_low_init = parameters(4);
% p_boundBias = parameters(5);
% %%
% [P_choiceLeft2,nll2,delta2,V_R2,V_L2,P_bound_low2,P_bound_high2]= MB_RL_function_v5(theta_fit,beta_fit,alpha_fit,...
%     P_bound_low_init,p_boundBias,Octave_used,left_choice_used,inds_correct_used);
