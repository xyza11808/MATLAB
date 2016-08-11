function behavDataPlotCheck(varargin)
%this function will be used for behavior data processing and try to figure
%out whether there are some trials with error time savage and return their
%trial numbers for further processing

if nargin < 1
    fprintf('No input being processed, please select your behavior data mat file.\n');
    [fn,fp,~]=uigetfile('*.mat','Please Select your behavior dat amat file','MultiSelect','on');
    cd(fp);
    xxxx=load(fn);
    BehavResult = xxxx.behavResults;
    BehavSet = xxxx.behavSettings;
else
    BehavResult = varargin{1};
    BehavSet = varargin{2};
    if ~isdir('./Behavior_Data_plot/')
        mkdir('./Behavior_Data_plot/');
    end
    cd('./Behavior_Data_plot/');
end

%%
% behavior putcome plot
TrialNum = length(BehavResult.Trial_Type);
Trialtype = BehavResult.Trial_Type;
TrialAction = BehavResult.Action_choice;
CorrectInds = TrialAction == Trialtype;
ErrorInds = TrialAction ~= Trialtype & TrialAction ~= 2;
MissInds = TrialAction == 2;
TrialOutc = zeros(TrialNum,1);  % error trial value set to 0
TrialOutc(CorrectInds) = 1;  % correct trial value set to 1
TrialOutc(MissInds) = 2; % miss trial value set to 2
TrialInds = 1:TrialNum;

h_points=figure('position',[260 80 1200 1000]);
hold on
plot(TrialInds(CorrectInds),TrialOutc(CorrectInds)+1,'ko','MarkerSize',12,'LineWidth',1.8);
plot(TrialInds(MissInds),TrialOutc(MissInds)+1,'mo','MarkerSize',12,'LineWidth',1.8);
plot(TrialInds(ErrorInds),TrialOutc(ErrorInds)+1,'ro','MarkerSize',12,'LineWidth',1.8);
ylim([-0.5 4])
set(gca,'ytick',[1 2 3],'yticklabel',{'Error','Correct','Miss'});
xlabel('Trials');
ylabel('Trial Outcome');
set(gca,'Fontsize',20);
saveas(h_points,'Trial Outcome Plot');
saveas(h_points,'Trial Outcome Plot.png');
close(h_points);

%%
Timedelay = 300 + double(BehavSet.responseDelay(1));
TimeAnswer = double(BehavResult.Time_answer);
StimOnset = double(BehavResult.Time_stimOnset);
TimeReward = double(BehavResult.Time_reward);

[Lick_time_data,~]=beha_lickTime_data(BehavResult,10);  %exclude all lick time longer than 10s

isTrialSysErr = zeros(TrialNum,1);
SuppoAnsT = zeros(TrialNum,1);
for nT = 1:TrialNum
    if TrialOutc(nT) ~=2
        LickTSum = sort([Lick_time_data(nT).LickTimeLeft,Lick_time_data(nT).LickTimeRight]);
        SupposeAnsWerT = LickTSum(find(LickTSum > (StimOnset(nT)+Timedelay+1),1,'first'));
        SuppoAnsT(nT) = SupposeAnsWerT;
        if abs(SupposeAnsWerT - TimeAnswer(nT)) > 20
            isTrialSysErr(nT) = 1;
        end
    end
end
SysErrTrialInds = find(isTrialSysErr);
fprintf('Totally %d trials in %d trials have error time recoding.\n',sum(isTrialSysErr),TrialNum);
save SysErrorTrials.mat isTrialSysErr SuppoAnsT SysErrTrialInds -v7.3

cd ..;
