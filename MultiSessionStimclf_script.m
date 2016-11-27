% this script is used for summarize multisession data together and
% performing multisession classification of stimulus types
% save CSessionData.mat smooth_data trial_outcome behavResults start_frame frame_rate NormalTrialInds -v7.3
add_char = 'y';
inputChoice = input('would like to added new session data into last summary result?\n','s');
if strcmpi(inputChoice,'y')
    [fnx,fpx,fix] = uigetfile('SessionDataSum.mat','Please load your last summary plot result');
    if fix
        load(fullfile(fpx,fnx));
        isOldLoad = 1;
    else
        isOldLoad = 0;
    end
else
    isOldLoad = 0;
end
if ~isOldLoad
    m = 1;
    datapath = {};
    DataSum = {};
    SumSessionData = {};
    SumSessionStim = {};
else
   m = length(DataSum) + 1;
end

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('CSessionData.mat','Please select your ROI fraction based classification result save');
    if fi
        datapath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        DataSum{m} = xx;
        [DataOutput,SessionStim] = SessionDataExtra(xx.smooth_data,xx.trial_outcome,xx.behavResults.Stim_toneFreq,xx.start_frame,...
            xx.frame_rate,xx.NormalTrialInds,30);
        SumSessionData{m} = DataOutput; % finally should be a 1 by m cell vector
        SumSessionStim{m} = SessionStim;
    end
    add_char = input('Do you want to add with more session data?\n','s');
    m = m + 1;
end
m = m - 1;

fp = uigetdir(pwd,'Please select a session to save your current data');
cd(fp);
f = fopen('Session_resp_path.txt','w');
fprintf(f,'Sessions path for response summary plot:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,datapath{nbnb});
end
fclose(f);
save SessionDataSum.mat DataSum SumSessionData SumSessionStim -v7.3
%%
SessionStimNum = cellfun(@length,SumSessionStim);
if length(unique(SessionStimNum)) > 1
    SelectStimLen = min(unique(SessionStimNum));
    OutlengthStimInds = SessionStimNum == SelectStimLen;
    SessionStimSelect = SumSessionStim(OutlengthStimInds);
    SessionDataSelect = SumSessionData(OutlengthStimInds);
end
isequalStim = false(length(SessionStimSelect),1);
for nxnx = 1 : length(SessionStimSelect)
    if isequal(SessionStimSelect(nxnx),SessionStimSelect(1))
        isequalStim(nxnx) = true;
    end
end
equalStimSession = SessionStimSelect(isequalStim);
equalDataSession = SessionDataSelect(isequalStim);

StimTypes = equalStimSession{1};
StimNums = length(StimTypes);
disp(StimTypes);
StimDataSet = repmat((StimTypes(:))',30,1);
StimDataSet = StimDataSet(:);  % vector used for y input, corresponded to the input dataset

PairNum = StimNums*(StimNums - 1)/2;
for nxnx = 1 : StimNums
    for nmnm = (nxnx+1) : StimNums 
        cNegStim = StimTypes(nxnx);
        cPosStim = StimTypes(nmnm);
        