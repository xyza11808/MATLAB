function regFunCallFun(varargin)
% this function is a caller function for regression analysis of the
% behavior data, try to see whether animal choice is significantly affected
% by some parameters considered

if nargin < 1
    [fn,fp,fi] = uigetfile('*.mat','Please select the data files for analysis');
    if ~fi
        fprintf('Cancel file selection, quit analysis.\n');
        return;
    else
        xx = load(fullfile(fp,fn));
        if isfield(xx,'behavResults') && isfield(xx,'behavSettings')
            BehavStrc = xx.behavResults;
        elseif isfield(xx,'SessionResults') && isfield(xx,'SessionSettings')
            [behavResults,~] = behav_cell2struct(xx.SessionResults,xx.SessionSettings);
            BehavStrc = behavResults;
        end
    end
else
   BehavStrc = varargin{1};
end
if max(BehavStrc.Trial_isOpto)
    BehavParameter = {'FreqDiff','Bias','RewardHist','LastTrEffect','Modu'};
else
    BehavParameter = {'FreqDiff','Bias','RewardHist','LastTrEffect'};
end
ImagingTimeLen = 6;
 [~,Lick_bias_side]=beha_lickTime_data(BehavStrc,ImagingTimeLen); %this function is used for converting lick time strings into arrays and save in a struct
BehavRegStrc = struct();
ActionChoice = double(BehavStrc.Action_choice);
ChoosedTr = ActionChoice~= 2; % miss trials will be excluded from analysis
BehavRegStrc.Action_choice = ActionChoice(ChoosedTr);
BehavRegStrc.Trial_Type = double(BehavStrc.Trial_Type(ChoosedTr));
BehavRegStrc.Time_reward = double(BehavStrc.Time_reward(ChoosedTr));
BehavRegStrc.BiasSide = Lick_bias_side(ChoosedTr);
BehavRegStrc.Stim_toneFreq = double(BehavStrc.Stim_toneFreq(ChoosedTr));
BehavRegStrc.isModu = double(BehavStrc.Trial_isOpto(ChoosedTr));

BehavRegression(BehavRegStrc,BehavParameter,16000);
