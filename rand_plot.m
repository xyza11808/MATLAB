function varargout = rand_plot(varargin)
%plot of the random puretone behavior data and then performing a logistic
%fit using bootstrp function
if nargin<1
    SelfPlot=1;
    disp('please input the data path where you behavior data saved.\n');
    FilePath=uigetdir();
    cd(FilePath);
    data_save_path='./RandP_data_plots/';
    if ~isdir(data_save_path)
        mkdir(data_save_path);
    end
    %mkdir('./session_data_plots');
    files = dir('*.mat');
    fileNum=length(files);
    isProbAsPuretone = 1;
else
    isProbAsPuretone = 1;
    SelfPlot=0;
    behavResults=varargin{1};
    choice=varargin{2};
    if nargin > 2 
        if ~isempty(varargin{3})
            fn = varargin{3};
        end
        if nargin >3
            isProbAsPuretone = varargin{4};
        end
    end
    data_save_path='./RandP_data_plots/';
    if ~isdir(data_save_path)
        mkdir(data_save_path);
    end
    fileNum=1;
end

boundary_result=struct('SessionName',[],'FitParam',[],'Boundary',[],'LeftCorr',[],'RightCorr',[],'StimType',[],...
    'StimCorr',[],'Coefficients',[],'P_value',[],'FitValue',[],'Typenumbers',[],'gof',[],'SessBehavAll',[],...
    'FitModelAll',{},'SlopeCurve',{},'RevertStimRProb',[]);
if SelfPlot
    choice=input(['please select the logistic analysis method.\n1 for non-linear regression.\n',...
        '2 for linear regression analysis.\n3 for fit_logistic analysis.\n',...
        '4 for new logistic fitting method.\n']);
end
for n = 1:fileNum
    if SelfPlot
        cd(FilePath);
        fn = files(n).name;
        load(fn);
    else
        FilePath=pwd;
    end
    
    if ~isProbAsPuretone
        % exclude prob trials from analysis for current plot
        IsProbT = double(behavResults.Trial_isProbeTrial);
        if max(IsProbT)
            fprintf('Excluded all prob trials for plotting.\n');
            ProbInds = IsProbT == 1;
            behavResults.Action_choice(ProbInds) = [];
            behavResults.Time_reward(ProbInds) = [];
            behavResults.Trial_Type(ProbInds) = [];
            behavResults.Stim_toneFreq(ProbInds) = [];
            if iscell(behavResults.Stim_Type(1))
                behavResults.Stim_Type(ProbInds) = [];
            else
                behavResults.Stim_Type(ProbInds,:) = [];
            end
        end
    end
    if min(behavResults.Stim_toneFreq) == 0
        InvalidValueInds = behavResults.Stim_toneFreq == 0;
        behavResults.Action_choice(InvalidValueInds) = [];
        behavResults.Time_reward(InvalidValueInds) = [];
        behavResults.Trial_Type(InvalidValueInds) = [];
        behavResults.Stim_toneFreq(InvalidValueInds) = [];
        if iscell(behavResults.Stim_Type(1))
            behavResults.Stim_Type(InvalidValueInds) = [];
        else
            behavResults.Stim_Type(InvalidValueInds,:) = [];
        end
    end
        
    AnimalActionC = behavResults.Action_choice;
    MissTrialsInds = AnimalActionC == 2;
    CorrectInds = behavResults.Time_reward ~= 0;
    ErrorTrials = behavResults.Time_reward == 0;
    
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % excluded all miss trials from analysis
    behavResults.Trial_Type(MissTrialsInds) = [];
    behavResults.Time_reward (MissTrialsInds) = [];
    behavResults.Stim_toneFreq(MissTrialsInds) = [];
    if iscell(behavResults.Stim_Type(1))
        behavResults.Stim_Type(MissTrialsInds) = [];
    else
        behavResults.Stim_Type(MissTrialsInds,:) = [];
    end
    behavResults.Action_choice(MissTrialsInds) = [];
    SessBehavDatas = [behavResults.Stim_toneFreq(:),behavResults.Trial_Type(:),behavResults.Action_choice(:),...
        behavResults.Time_reward(:)];
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    trialInds = 1:length(behavResults.Trial_Type);
    inds_leftTrials = find(behavResults.Trial_Type == 0);
    inds_rightTrials = find(behavResults.Trial_Type == 1);
    cd(data_save_path);
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RealMissTrials = logical(double(ErrorTrials) - double(MissTrialsInds));
    AllTrialsOutcome = ones(length(AnimalActionC),1);
    h_points = figure;
    hold on
    plot(find(CorrectInds),AllTrialsOutcome(CorrectInds),'ko','LineWidth',1.4,'MarkerSize',10);
    plot(find(RealMissTrials),AllTrialsOutcome(RealMissTrials)*0,'ro','LineWidth',1.4,'MarkerSize',10);
    plot(find(MissTrialsInds),AllTrialsOutcome(MissTrialsInds)*2,'mo','LineWidth',1.4,'MarkerSize',10);
    ylim([-1 3]);
    set(gca,'ytick',[0 1 2],'yticklabel',{'Error','Correct','Miss'});
    xlabel('# Trials');
    ylabel('Outcomes');
    set(gca,'FontSize',20);
    title('Session animal response plot')
    set(gca,'FontSize',20);
    if exist('fn','var')
        saveas(h_points,[fn(1:end-4),'_Behav_plot']);
        saveas(h_points,[fn(1:end-4),'_Behav_plot'],'png');
    else
        saveas(h_points,'Behav_plot_Save');
        saveas(h_points,'Behav_plot_Save','png');
    end
    close(h_points);
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     correct_a = behavResults.Trial_Type == behavResults.Action_choice;
    rewarded = behavResults.Time_reward ~= 0;
    figure('color','w'); hold on;
    
    plot(trialInds, smooth(double(rewarded), 20),'k','linewidth',2)
    plot(trialInds(inds_leftTrials), smooth(double(rewarded(inds_leftTrials)), 20),'b','linewidth',2);
    plot(trialInds(inds_rightTrials), smooth(double(rewarded(inds_rightTrials)), 20),'r','linewidth',2);
    hold off;
    title_name='Behavior\_plot';
    title(title_name);
    set(gca,'FontSize',20);
    if exist('fn','var')
        saveas(gcf,[fn(1:end-4),'_correct_rate.png'],'png');
        saveas(gcf,[fn(1:end-4),'_correct_rate.png']);
        boundary_result(n).SessionName=fn(1:end-4);
    else
        saveas(gcf,'Behavior_correct_rate.png','png');
        saveas(gcf,'Behavior_correct_rate.png');
        boundary_result(n).SessionName='';
    end
    
    close;
    
    boundary_result(n).LeftCorr=mean(rewarded(inds_leftTrials));
    boundary_result(n).RightCorr=mean(rewarded(inds_rightTrials));
    %      rand_right_type=behavSettings.randompureTone_right;
    %      rand_left_type=behavSettings.randompureTone_left;
    %      inds_right=cellfun('length',behavSettings.randompureTone_right);
    %      inds_left=cellfun('length',behavSettings.randompureTone_left);
    %      rand_right_type(inds_right==0)=[];
    %      rand_left_type(inds_left==0)=[];
    
    stim_types=double(unique(behavResults.Stim_toneFreq));
    GrNum = floor(length(stim_types)/2); % in case boundary tone exists
    if iscell(behavResults.Stim_Type(1))
        FirstTrType = behavResults.Stim_Type(1);
    else
        FirstTrType = behavResults.Stim_Type(1,:);
    end
    if length(stim_types)==2 || strcmpi(FirstTrType,'sweep')
        %for probe trial data analysis, further analysis can be added here
        disp('This behavior data is not the random puretone trial result, quit analysis.\n');
%         cd(FilePath);
        continue;
    elseif choice==1
        %     stim_types=[behavSettings.randompureTone_left(1,:) behavSettings.randompureTone_right(1,:)];
        Type_choiceR = zeros(1,length(stim_types));
        TypeNumber = zeros(1,length(stim_types));
        TypeTrTypes = zeros(length(stim_types),1);
        for i=1:length(stim_types)
            type_inds = behavResults.Stim_toneFreq==stim_types(i);
            TypeNumber(i) = sum(type_inds);
            Type_choiceR(i)=mean(behavResults.Action_choice(type_inds)); % right choice prob
            TypeTrTypes(i) = mode(behavResults.Trial_Type(type_inds));
        end
        boundary_result(n).Typenumbers = TypeNumber;
        boundary_result(n).StimType=stim_types;
        boundary_result(n).StimCorr=Type_choiceR;
        boundary_result(n).StimCorr(~TypeTrTypes) = 1 - boundary_result(n).StimCorr(~TypeTrTypes);
        boundary_result(n).RevertStimRProb = ~TypeTrTypes;
        boundary_result(n).SessBehavAll = SessBehavDatas;
        if(mean( boundary_result(n).StimCorr)<0.5)
            continue;
        end
        octave_sum=log2(double(max(behavResults.Stim_toneFreq))/double(min(behavResults.Stim_toneFreq)));
        octave_dist=log2(double(max(behavResults.Stim_toneFreq))./double(stim_types));
        octave_dist=octave_sum-octave_dist;
        xtick_label=(2.^octave_dist)*min(behavResults.Stim_toneFreq);
        xtick_label=xtick_label/1000;
        %trans into rightword percent
        %     Type_choiceR(1:length(behavSettings.randompureTone_left(1,:)))=1-Type_choiceR(1:length(behavSettings.randompureTone_left(1,:)));
%         Type_choiceR(1:length(stim_types)/2)=1-Type_choiceR(1:length(stim_types)/2);
        %     modelfun=@()
        %     b=glmfit(octave_dist,Type_choiceR,'binomial','link','logit');
        %      there should use fitnlm maybe
        % [yfit,f_low,f_high]=glmval(b,octave_dist,'logit');
        
        %the function of nlinfit and fitnlm returns the same prediction result
        %the lsqcurvefit returns different result but the curve follows very
        %similar trajectory with previous result.
        modelfun=@(b,x)(1./(1+exp(-b(1).*x-b(2))));
        b0=[-1,1];
        mdl=fitnlm(octave_dist,Type_choiceR,modelfun,b0);
        
        figure;
        plotDiagnostics(mdl,'cookd');
        outer_points=input('Please input the number of outlier points.\n');
        close;
        %use for ci prediction, also can use the nlparci function for ci
        %prediction, which is incorperaion with nlinfit function
        %     [beta,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(X,Y,modelfun,beta0,options);
        %     ci = nlparci(beta,R,'Jacobian',J) or
        %     ci = nlparci(ahat,r,'covar',cov)
        fit_plot_x=linspace(min(octave_dist),max(octave_dist),200);
        if ~isempty(outer_points)
            mdl1 = fitnlm(octave_dist,Type_choiceR,modelfun,b0,'Exclude',outer_points);
            [resp_pred,resp_ci]=predict(mdl1,fit_plot_x');
            b=mdl1.Coefficients.Estimate;
            boundary_result(n).Coefficients=mdl1.Coefficients;
            boundary_result(n).P_value=mdl1.Coefficients.pValue;
            
        else
            [resp_pred,resp_ci]=predict(mdl,fit_plot_x');
            b=mdl.Coefficients.Estimate;
            boundary_result(n).Coefficients=mdl.Coefficients;
            boundary_result(n).P_value=mdl.Coefficients.pValue;
            
        end
        
        close;
        h3=figure;
        scatter(octave_dist,Type_choiceR,30,'MarkerEdgeColor','r','MarkerFaceColor','y');
        text(octave_dist,Type_choiceR,cellstr(num2str(TypeNumber(:)),'n=%d'),'Fontsize',15,'color','b');
        hold on;
        plot(fit_plot_x,resp_pred,'-','color','r');
        axis([0 2 0 1]);
        %     plot(octave_dist,Type_choiceR,'o');
        for i=1:length(octave_dist)
            %         scatter([octave_dist(i),octave_dist(i)],[f_low(i),f_high(i)],'o','color','r','fill');
            line([octave_dist(i),octave_dist(i)],[resp_ci(i,1)+resp_pred,resp_ci(i,2)+resp_pred]);
        end
        title('behavior randompuretone');
%         axis([0 2 0 1]);
        ylim([0 1]);
        set(gcf,'xtick',0:2/(length(octave_dist)-1):2);
        set(gcf,'xticklabel',sprintf('%.1f|',xtick_label));
        xlabel('Frequency(kHz)');
        ylabel('Rightward choice');
        set(gca,'FontSize',20);
        hold off;
        if exist('fn','var')
            saveas(h3,[fn(1:end-4),'_fit plot'],'png');
        else
            saveas(h3,'Behav_fit plot.png');
        end
        
        close;
        syms x
        internal_boundary=solve(modelfun(b,x)==0.5,x);
        
%         cd(FilePath);
    elseif choice==2
        %use the function of log(p/(1-p))=beta(1)*x+beta(2) for linear
        %regression analysis, but not with a nonlinear regression analysis
        Type_choiceR=zeros(1,length(stim_types));
        TypeNumber = zeros(1,length(stim_types));
        TypeTrTypes = zeros(length(stim_types),1);
        for i=1:length(stim_types)
            type_inds= behavResults.Stim_toneFreq==stim_types(i);
            TypeNumber(i) = sum(type_inds);
            Type_choiceR(i)=mean(behavResults.Action_choice(type_inds));
            TypeTrTypes(i) = mode(behavResults.Trial_Type(type_inds));
        end
        
        boundary_result(n).Typenumbers = TypeNumber;
        boundary_result(n).StimType=stim_types;
        boundary_result(n).StimCorr=Type_choiceR;
        boundary_result(n).StimCorr(~TypeTrTypes) = 1 - boundary_result(n).StimCorr(~TypeTrTypes);
        boundary_result(n).RevertStimRProb = ~TypeTrTypes;
        boundary_result(n).SessBehavAll = SessBehavDatas;
        if(mean(boundary_result(n).StimCorr)<0.5)
            continue;
        end
        octave_sum=log2(double(max(behavResults.Stim_toneFreq))/double(min(behavResults.Stim_toneFreq)));
        octave_dist=log2(double(max(behavResults.Stim_toneFreq))./double(stim_types));
        octave_dist=octave_sum-octave_dist;
        xtick_label=(2.^octave_dist)*min(behavResults.Stim_toneFreq);
        xtick_label=xtick_label/1000;
        %trans into rightword percent
        %     Type_choiceR(1:length(behavSettings.randompureTone_left(1,:)))=1-Type_choiceR(1:length(behavSettings.randompureTone_left(1,:)));
%         Type_choiceR(1:length(stim_types)/2)=1-Type_choiceR(1:length(stim_types)/2);
        %         reward_left=Type_choiceR(1:length(stim_types)/2);
        %         octave_left=octave_dist(1:length(stim_types)/2);
        %         reward_right=Type_choiceR(length(stim_types)/2+1:end);
        %         octave_right=octave_dist(length(stim_types)/2+1:end);
        %
        %         %exclude bad performance data point
        %         inds_left=reward_left<0.5;
        %         reward_left(inds_left)=[];
        %         octave_left(inds_left)=[];
        %         inds_right=reward_right<0.5;
        %         reward_right(inds_right)=[];
        %         octave_right(inds_right)=[];
        %         octave_dist_sort=[octave_left,octave_right];
        %         Type_choiceR_sort=[1-reward_left,reward_right];
        %
        %         if length(octave_dist_sort)<4
        %             fitable=0;
        %             disp('not enough data point for logistic regression analysis, quit fitness.\n');
        %             cd(FilePath);
        %             continue;
        %         else
        %
        linear_fit_rate=log(Type_choiceR./(1-Type_choiceR));
        b=polyfit(octave_dist,linear_fit_rate,1);
        modelfun=@(beta,x)(1./(1+exp(-beta(2)-beta(1).*x)));
        %         step=(max(octave_dist)-min(octave_dist))/200;
        line_space=linspace(min(octave_dist),max(octave_dist),200);
        fit_data=modelfun(b,line_space);
        plot(octave_dist,Type_choiceR,'o',line_space,fit_data,'color','k');
        text(octave_dist,Type_choiceR,cellstr(num2str(TypeNumber(:)),'n=%d'),'Fontsize',15,'color','b');
        title([fn(1:end-4),'randompuretone']);
%         axis([0 2 0 1]);
        ylim([0 1]);
        set(gcf,'xtick',0:2/(length(octave_dist)-1):2);
        set(gcf,'xticklabel',sprintf('%.1f|',xtick_label));
        xlabel('Frequency(kHz)');
        ylabel('Rightward choice');
        set(gca,'FontSize',20);
        if exist('fn','var')
            saveas(h3,[fn(1:end-4),'_fit plot'],'png');
        else
            saveas(h3,'Behav_fit plot','png');
        end
        close(h3);
        RTrNext_ChoiceBias_script
        syms x
        internal_boundary=solve(modelfun(b,x)==0.5,x);
%         cd(FilePath);
    elseif choice==3
        %for fit_logistic regression analysis
        Type_choiceR=zeros(1,length(stim_types));
        TypeNumber=zeros(1,length(stim_types));
        TypeTrTypes = zeros(length(stim_types),1);
        for i=1:length(stim_types)
            type_inds= behavResults.Stim_toneFreq==stim_types(i);
            TypeNumber(i) = sum(type_inds);
            Type_choiceR(i)=mean(behavResults.Action_choice(type_inds));
            TypeTrTypes(i) = mode(behavResults.Trial_Type(type_inds));
        end
        boundary_result(n).Typenumbers = TypeNumber;
        boundary_result(n).StimType=stim_types;
        boundary_result(n).StimCorr=Type_choiceR;
        boundary_result(n).StimCorr(~TypeTrTypes) = 1 - boundary_result(n).StimCorr(~TypeTrTypes);
        boundary_result(n).RevertStimRProb = ~TypeTrTypes;
        boundary_result(n).SessBehavAll = SessBehavDatas;
        if(mean(boundary_result(n).StimCorr)<0.5)
            continue;
        end
        octave_sum=log2(double(max(behavResults.Stim_toneFreq))/double(min(behavResults.Stim_toneFreq)));
        OctavesAll = log2(double(behavResults.Stim_toneFreq)/double(min(stim_types)));
        TrChoice = double(behavResults.Action_choice);
%         octave_dist=log2(double(max(behavResults.Stim_toneFreq))./double(stim_types));
%         octave_dist=octave_sum-octave_dist;
        octave_dist = log2(double(stim_types)/double(min(stim_types)));
        xtick_label=(2.^octave_dist)*double(min(behavResults.Stim_toneFreq));
        xtick_label=xtick_label/1000;
        %trans into rightword percent
        %     Type_choiceR(1:length(behavSettings.randompureTone_left(1,:)))=1-Type_choiceR(1:length(behavSettings.randompureTone_left(1,:)));
%         Type_choiceR(1:floor(length(stim_types)/2))=1-Type_choiceR(1:floor(length(stim_types)/2));
        h3=figure;
        scatter(octave_dist,Type_choiceR,30,'MarkerEdgeColor','k','LineWidth',1.5);
        text(octave_dist,Type_choiceR,cellstr(num2str(TypeNumber(:),'n=%d')),'Fontsize',15,'color','b');
        hold on;
%       % inds exclusion for plot
%         inds_exclude=input('please select the trial inds that should be excluded from analysis.\n','s');
%         if ~isempty(inds_exclude)
%             inds_exclude=str2num(inds_exclude);
%             octave_dist_exclude=octave_dist(inds_exclude);
%             Type_choiceR_exclude=Type_choiceR(inds_exclude);
%             octave_dist(inds_exclude)=[];
%             Type_choiceR(inds_exclude)=[];
%             scatter(octave_dist_exclude,Type_choiceR_exclude,100,'x','MarkerEdgeColor','b');
%         end
        
        [Qreg,b]=fit_logistic(octave_dist,Type_choiceR);
        [QregAll,bAll] = fit_logistic(OctavesAll,TrChoice);
%         parobj=gcp('nocreate');
%         if isempty(parobj)
%             parpool('local',8);
%         end
%         options = statset('UseParallel',true);
%         [bootstat_control, ~] = bootstrp(500, @(x, y) fit_logistic_psych_con(x, y,0), octave_dist, Type_choiceR,'Options',options);
%         gof = [bootstat_control.gof];
%         rmse = [gof.rmse];
%         sse = [gof.sse];
%         rsq = [gof.rsquare];
%         adjrsquare = [gof.adjrsquare];
% 
%         inds_use1 = find(rmse < prctile(rmse,50));
%         inds_use2 = find(rsq > prctile(rsq,50));
% 
%         a1 = mean([bootstat_control(inds_use1).a]);
%         b1 = mean([bootstat_control(inds_use1).b]);
%         c1 = mean([bootstat_control(inds_use1).c]);
%         ParAll=[a1,b1,c1];
        
        modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
        curve_x = linspace(min(octave_dist),max(octave_dist),500);
        
        OctStep = mean(diff(curve_x(:,1)));
        BehavDerivateCurve = diff(fit_ReNew.curve(:,2));
        BehavDerivateCurve = [BehavDerivateCurve(1);BehavDerivateCurve]/OctStep;
        
        curve_y=modelfun(b,curve_x);
        curve_Allfity = modelfun(bAll,curve_x);
        BehavDerivateCurve = diff(curve_y(:,2));
        BehavDerivateCurve = [BehavDerivateCurve(1);BehavDerivateCurve]/OctStep;
        
        %         plot(octave_dist,Type_choiceR,'o');
%         h3=figure;
        plot(curve_x,curve_y,'color','k','LineWidth',1.8);
        plot(curve_x,curve_Allfity,'color','r','LineWidth',1.8);
        hold off;
        ylim([0 1]);
        set(gca,'xtick',octave_dist);
        set(gca,'xticklabel',cellstr(num2str(xtick_label(:),'%.1f')));
        xlabel('Frequency(kHz)');
        ylabel('Rightward choice');
        set(gca,'FontSize',20);
        %
        if exist('fn','var')
            saveas(h3,[fn(1:end-4),'_fit plot'],'png');
            saveas(h3,[fn(1:end-4),'_fit plot'],'fig');
        else
            saveas(h3,'Behav_fit plot','png');
            saveas(h3,'Behav_fit plot','fig');
        end
        
        close(h3);
        RTrNext_ChoiceBias_script;
        syms x
%         internal_boundary=solve(modelfun(ParAll,x)==0.5,x);
        internal_boundary=solve(modelfun(b,x)==0.5,x);
        boundary_result(n).FitValue=Qreg;
        boundary_result(n).FitModelAll = {bAll,b};
        boundary_result(n).SlopeCurve = BehavDerivateCurve;
%         cd(FilePath);
    elseif choice == 4
        % using new fitting method
        Type_choiceR=zeros(1,length(stim_types));
        TypeNumber=zeros(1,length(stim_types));
        TypeTrTypes = zeros(length(stim_types),1);
        TypeChoiceSEM = zeros(1,length(stim_types));
        TypeBinoCI = zeros(2,length(stim_types));
        for i=1:length(stim_types)
            type_inds= behavResults.Stim_toneFreq==stim_types(i);
            TypeNumber(i) = sum(type_inds);
            cTrChoice = double(behavResults.Action_choice(type_inds));
            Type_choiceR(i) = mean(cTrChoice);
%             TypeBinoCI(:,i) = std(cTrChoice)/sqrt(numel(cTrChoice)) * [1 1] + mean(cTrChoice);
            [pHat,pCI] = binofit(sum(cTrChoice),numel(cTrChoice));
            Type_choiceR(i) = pHat;
            TypeBinoCI(:,i) = pCI;
            
            TypeTrTypes(i) = mode(behavResults.Trial_Type(type_inds));
            TypeChoiceSEM(i) = std(double(behavResults.Action_choice(type_inds)))/sqrt(sum(TypeNumber(i)));
        end
        ErrorBarNegDis = abs(Type_choiceR - TypeBinoCI(1,:));
        ErrorBarPosDis = abs(TypeBinoCI(2,:) - Type_choiceR);
        boundary_result(n).Typenumbers = TypeNumber;
        boundary_result(n).StimType=stim_types;
        boundary_result(n).StimCorr=Type_choiceR;
        boundary_result(n).StimCorr(~TypeTrTypes) = 1 - boundary_result(n).StimCorr(~TypeTrTypes);
        boundary_result(n).RevertStimRProb = ~TypeTrTypes;
        boundary_result(n).SessBehavAll = SessBehavDatas;
        boundary_result(n).ErrorCI = TypeBinoCI;
%         if(mean(boundary_result(n).StimCorr)<0.5)
%             continue;
%         end
        octave_sum=log2(double(max(behavResults.Stim_toneFreq))/double(min(behavResults.Stim_toneFreq)));
        octave_dist = log2(double(stim_types)/double(min(stim_types)));
        OctavesAll = log2(double(behavResults.Stim_toneFreq)/double(min(stim_types)));
        TrChoice = double(behavResults.Action_choice);
%         Type_choiceR(1:floor(length(stim_types)/2))=1-Type_choiceR(1:floor(length(stim_types)/2));
        %
        h4=figure('position',[100 100 380 320]);
        scatter(octave_dist,Type_choiceR,50,'MarkerEdgeColor','k','LineWidth',3);
        text(octave_dist+0.01,Type_choiceR-0.02,cellstr(num2str(TypeNumber(:),'n=%d')),'Fontsize',12,'color','b');
        hold on;
        % for parameters: g,l,u,v
        UL = [0.5, 0.5, max(octave_dist), 100];
        SP = [Type_choiceR(1),1 - Type_choiceR(end)-Type_choiceR(1), mean(octave_dist), 1];
        LM = [0, 0, min(octave_dist), 0];
        ParaBoundLim = ([UL;SP;LM]);
        fit_ReNew = FitPsycheCurveWH_nx(octave_dist, Type_choiceR, ParaBoundLim);
        fit_ReNewAll = FitPsycheCurveWH_nx(OctavesAll, TrChoice, ParaBoundLim);
        OctStep = mean(diff(fit_ReNew.curve(:,1)));
        BehavDerivateCurve = diff(fit_ReNew.curve(:,2));
        BehavDerivateCurve = [BehavDerivateCurve(1);BehavDerivateCurve]/OctStep;
        [~,BoundInds] = min(abs(fit_ReNewAll.curve(:,2) - 0.5));
        internal_boundary = fit_ReNewAll.curve(BoundInds,1);
        %
%         plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'color','k','LineWidth',2.4);
        plot(fit_ReNewAll.curve(:,1),fit_ReNewAll.curve(:,2),'color','r','LineWidth',2.4);
        line([fit_ReNewAll.ffit.u fit_ReNewAll.ffit.u],[0 1],'color',[.7 .7 .7],'LineWidth',1.6,'linestyle','--');
        errorbar(octave_dist,Type_choiceR,ErrorBarNegDis,ErrorBarPosDis,'ko','linewidth',2);
%         line([internal_boundary internal_boundary],[0 1],'color','m','LineWidth',1.6,'linestyle','--');
        hold off;
        ylim([0 1]);
        set(gca,'xtick',octave_dist);
        Freqs = double(unique(behavResults.Stim_toneFreq));
        set(gca,'xticklabel',cellstr(num2str(Freqs(:)/1000,'%.1f')));
        xlabel('Frequency(kHz)');
        ylabel('Rightward choice');
        set(gca,'ylim',[-0.03 1.02],'ytick',[0 0.5 1]);
        set(gca,'FontSize',10);
        %
        if exist('fn','var')
            saveas(h4,[fn(1:end-4),'_fit plot'],'png');
            saveas(h4,[fn(1:end-4),'_fit plot'],'fig');
        else
            saveas(h4,'Behav_fit plot','png');
            saveas(h4,'Behav_fit plot','fig');
        end
        %
        close(h4);
          
        boundary_result(n).FitValue = fit_ReNewAll;
        boundary_result(n).gof = fit_ReNewAll.gof;
        b = coeffvalues(fit_ReNewAll.ffit);
        boundary_result(n).FitModelAll = {{fit_ReNewAll,fit_ReNew}};
        boundary_result(n).SlopeCurve = BehavDerivateCurve;
    end
    try
        RTrNext_ChoiceBias_script;
    catch
        fprintf('Unable to do last trial choice modulation plots.\n');
    end
    close(gcf);
    % cd(FilePath);
    
    if ~(length(stim_types)==2)
%         boundary_result(n).FitParam=ParAll;
          boundary_result(n).FitParam=b;
        if boundary_result(n).LeftCorr+boundary_result(n).RightCorr>1.2
            boundary_result(n).Boundary=double(internal_boundary);
        else
            boundary_result(n).Boundary=[];
        end
    else
        boundary_result(n).FitParam=[];
        boundary_result(n).Boundary=[];
    end
end
% mat_file_name=[fn(1:end-4),'_boundary_result.mat'];
save boundary_result.mat boundary_result -v7.3
cd(FilePath);
if nargout > 0
    varargout{1} = boundary_result;
end