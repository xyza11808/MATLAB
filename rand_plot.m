function rand_plot(varargin)
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
else
    SelfPlot=0;
    data_save_path='./RandP_data_plots/';
    if ~isdir(data_save_path)
        mkdir(data_save_path);
    end
    behavResults=varargin{1};
    choice=varargin{2};
    fileNum=1;
%     fn='Behavior_plottest'
end
    
boundary_result=struct('SessionName',[],'FitParam',[],'Boundary',[],'LeftCorr',[],'RightCorr',[],'StimType',[],...
    'StimCorr',[],'Coefficients',[],'P_value',[],'FitValue',[]);
if SelfPlot
    choice=input('please select the logistic analysis method.\n1 for non-linear regression.\n2 for linear regression analysis.\n3 for fit_logistic analysis.\n');
end
for n = 1:fileNum
    if SelfPlot
        cd(FilePath);
        fn = files(n).name;
        load(fn);
    else
        FilePath=pwd;
    end
    
    trialInds = 1:length(behavResults.Trial_Type);
    inds_leftTrials = find(behavResults.Trial_Type == 0);
    inds_rightTrials = find(behavResults.Trial_Type == 1);
    
    %     correct_a = behavResults.Trial_Type == behavResults.Action_choice;
    rewarded = behavResults.Time_reward ~= 0;
    figure('color','w'); hold on;
    
    plot(trialInds, smooth(double(rewarded), 20),'k','linewidth',2)
    plot(trialInds(inds_leftTrials), smooth(double(rewarded(inds_leftTrials)), 20),'b','linewidth',2);
    plot(trialInds(inds_rightTrials), smooth(double(rewarded(inds_rightTrials)), 20),'r','linewidth',2);
    hold off;
    title_name='Behavior\_plot';
    title(title_name);
    cd(data_save_path);
    if exist('fn','var')
        saveas(gcf,[fn(1:end-4),'_correct_rate.png'],'png');
        boundary_result(n).SessionName=fn(1:end-4);
    else
        saveas(gcf,'Behavior_correct_rate.png','png');
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
    
    stim_types=unique(behavResults.Stim_toneFreq);
    if length(stim_types)==2 || strcmpi(behavResults.Stim_Type,'sweep')
        %for probe trial data analysis, further analysis can be added here
        disp('This behavior data is not the random puretone trial result, quit analysis.\n');
%         cd(FilePath);
        continue;
    elseif choice==1
        %     stim_types=[behavSettings.randompureTone_left(1,:) behavSettings.randompureTone_right(1,:)];
        reward_type=zeros(1,length(stim_types));
        for i=1:length(stim_types)
            type_inds= behavResults.Stim_toneFreq==stim_types(i);
            reward_type(i)=mean(rewarded(type_inds));
        end
        
        boundary_result(n).StimType=stim_types;
        boundary_result(n).StimCorr=reward_type;
        if(mean(reward_type)<0.5)
            continue;
        end
        octave_sum=log2(double(max(behavResults.Stim_toneFreq))/double(min(behavResults.Stim_toneFreq)));
        octave_dist=log2(double(max(behavResults.Stim_toneFreq))./double(stim_types));
        octave_dist=octave_sum-octave_dist;
        xtick_label=(2.^octave_dist)*min(behavResults.Stim_toneFreq);
        xtick_label=xtick_label/1000;
        %trans into rightword percent
        %     reward_type(1:length(behavSettings.randompureTone_left(1,:)))=1-reward_type(1:length(behavSettings.randompureTone_left(1,:)));
        reward_type(1:length(stim_types)/2)=1-reward_type(1:length(stim_types)/2);
        %     modelfun=@()
        %     b=glmfit(octave_dist,reward_type,'binomial','link','logit');
        %      there should use fitnlm maybe
        % [yfit,f_low,f_high]=glmval(b,octave_dist,'logit');
        
        %the function of nlinfit and fitnlm returns the same prediction result
        %the lsqcurvefit returns different result but the curve follows very
        %similar trajectory with previous result.
        modelfun=@(b,x)(1./(1+exp(-b(1).*x-b(2))));
        b0=[-1,1];
        mdl=fitnlm(octave_dist,reward_type,modelfun,b0);
        
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
            mdl1 = fitnlm(octave_dist,reward_type,modelfun,b0,'Exclude',outer_points);
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
        scatter(octave_dist,reward_type,30,'MarkerEdgeColor','r','MarkerFaceColor','y');
        hold on;
        plot(fit_plot_x,resp_pred,'-','color','r');
        axis([0 2 0 1]);
        %     plot(octave_dist,reward_type,'o');
        for i=1:length(octave_dist)
            %         scatter([octave_dist(i),octave_dist(i)],[f_low(i),f_high(i)],'o','color','r','fill');
            line([octave_dist(i),octave_dist(i)],[resp_ci(i,1)+resp_pred,resp_ci(i,2)+resp_pred]);
        end
        title('behavior randompuretone');
        axis([0 2 0 1]);
        set(gcf,'xtick',0:2/(length(octave_dist)-1):2);
        set(gcf,'xticklabel',sprintf('%.1f|',xtick_label));
        xlabel('Frequency(kHz)');
        ylabel('Rightward choice');
        
        hold off;
        if exist('fn','var')
            saveas(h3,[fn(1:end-4),'_fit plot.png'],'png');
        else
            saveas(h3,['Behav_fit plot.png'],'png');
        end
        close;
        syms x
        internal_boundary=solve(modelfun(b,x)==0.5,x);
        
%         cd(FilePath);
    elseif choice==2
        %use the function of log(p/(1-p))=beta(1)*x+beta(2) for linear
        %regression analysis, but not with a nonlinear regression analysis
        reward_type=zeros(1,length(stim_types));
        for i=1:length(stim_types)
            type_inds= behavResults.Stim_toneFreq==stim_types(i);
            reward_type(i)=mean(rewarded(type_inds));
        end
        boundary_result(n).StimType=stim_types;
        boundary_result(n).StimCorr=reward_type;
        if(mean(reward_type)<0.5)
            continue;
        end
        octave_sum=log2(double(max(behavResults.Stim_toneFreq))/double(min(behavResults.Stim_toneFreq)));
        octave_dist=log2(double(max(behavResults.Stim_toneFreq))./double(stim_types));
        octave_dist=octave_sum-octave_dist;
        xtick_label=(2.^octave_dist)*min(behavResults.Stim_toneFreq);
        xtick_label=xtick_label/1000;
        %trans into rightword percent
        %     reward_type(1:length(behavSettings.randompureTone_left(1,:)))=1-reward_type(1:length(behavSettings.randompureTone_left(1,:)));
        reward_type(1:length(stim_types)/2)=1-reward_type(1:length(stim_types)/2);
        %         reward_left=reward_type(1:length(stim_types)/2);
        %         octave_left=octave_dist(1:length(stim_types)/2);
        %         reward_right=reward_type(length(stim_types)/2+1:end);
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
        %         reward_type_sort=[1-reward_left,reward_right];
        %
        %         if length(octave_dist_sort)<4
        %             fitable=0;
        %             disp('not enough data point for logistic regression analysis, quit fitness.\n');
        %             cd(FilePath);
        %             continue;
        %         else
        %
        linear_fit_rate=log(reward_type./(1-reward_type));
        b=polyfit(octave_dist,linear_fit_rate,1);
        modelfun=@(beta,x)(1./(1+exp(-beta(2)-beta(1).*x)));
        %         step=(max(octave_dist)-min(octave_dist))/200;
        line_space=linspace(min(octave_dist),max(octave_dist),200);
        fit_data=modelfun(b,line_space);
        plot(octave_dist,reward_type,'o',line_space,fit_data,'color','k');
        title([fn(1:end-4),'randompuretone']);
        axis([0 2 0 1]);
        set(gcf,'xtick',0:2/(length(octave_dist)-1):2);
        set(gcf,'xticklabel',sprintf('%.1f|',xtick_label));
        xlabel('Frequency(kHz)');
        ylabel('Rightward choice');
        
        if exist('fn','var')
            saveas(h3,[fn(1:end-4),'_fit plot.png'],'png');
        else
            saveas(h3,['Behav_fit plot.png'],'png');
        end
        close;
        syms x
        internal_boundary=solve(modelfun(b,x)==0.5,x);
%         cd(FilePath);
    elseif choice==3
        %for fit_logistic regression analysis
        reward_type=zeros(1,length(stim_types));
        for i=1:length(stim_types)
            type_inds= behavResults.Stim_toneFreq==stim_types(i);
            reward_type(i)=mean(rewarded(type_inds));
        end
        
        boundary_result(n).StimType=stim_types;
        boundary_result(n).StimCorr=reward_type;
        if(mean(reward_type)<0.5)
            continue;
        end
        octave_sum=log2(double(max(behavResults.Stim_toneFreq))/double(min(behavResults.Stim_toneFreq)));
        octave_dist=log2(double(max(behavResults.Stim_toneFreq))./double(stim_types));
        octave_dist=octave_sum-octave_dist;
        xtick_label=(2.^octave_dist)*double(min(behavResults.Stim_toneFreq));
        xtick_label=xtick_label/1000;
        %trans into rightword percent
        %     reward_type(1:length(behavSettings.randompureTone_left(1,:)))=1-reward_type(1:length(behavSettings.randompureTone_left(1,:)));
        reward_type(1:length(stim_types)/2)=1-reward_type(1:length(stim_types)/2);
        h3=figure;
        scatter(octave_dist,reward_type,30,'MarkerEdgeColor','r','MarkerFaceColor','y');
        hold on;
        inds_exclude=input('please select the trial inds that should be excluded from analysis.\n','s');
        if ~isempty(inds_exclude)
            inds_exclude=str2num(inds_exclude);
            octave_dist_exclude=octave_dist(inds_exclude);
            reward_type_exclude=reward_type(inds_exclude);
            octave_dist(inds_exclude)=[];
            reward_type(inds_exclude)=[];
            scatter(octave_dist_exclude,reward_type_exclude,100,'x','MarkerEdgeColor','b');
        end
        
        [Qreg,b]=fit_logistic(octave_dist,reward_type);
%         parobj=gcp('nocreate');
%         if isempty(parobj)
%             parpool('local',8);
%         end
%         options = statset('UseParallel',true);
%         [bootstat_control, ~] = bootstrp(500, @(x, y) fit_logistic_psych_con(x, y,0), octave_dist, reward_type,'Options',options);
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
        curve_x=linspace(min(octave_dist),max(octave_dist),500);
        curve_y=modelfun(b,curve_x);
        
        %         plot(octave_dist,reward_type,'o');
%         h3=figure;
        plot(curve_x,curve_y,'color','b');
        hold off;
        if exist('fn','var')
            saveas(h3,[fn(1:end-4),'_fit plot.png'],'png');
        else
            saveas(h3,['Behav_fit plot.png'],'png');
        end
        axis([0 2 0 1]);
        set(gca,'xtick',0:2/(length(octave_dist)-1):2);
        set(gca,'xticklabel',cellstr(num2str(xtick_label(:),'%.1f')));
        xlabel('Frequency(kHz)');
        ylabel('Rightward choice');
        
        if exist('fn','var')
            saveas(h3,[fn(1:end-4),'_fit plot.png'],'png');
        else
            saveas(h3,['Behav_fit plot.png'],'png');
        end
        close;
        syms x
%         internal_boundary=solve(modelfun(ParAll,x)==0.5,x);
        internal_boundary=solve(modelfun(b,x)==0.5,x);
        boundary_result(n).FitValue=Qreg;
%         cd(FilePath);
    end
    
    
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
save boundary_result.mat boundary_result '-v7.3'
cd(FilePath);
