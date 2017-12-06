function Anminfo = SessInfoExtraction(SessionPath)
% SessionPath is a string indicating session path
% parsing session data information from given session path
SessStr = SessionPath;

% extract session data from path string
[StartI,EndIn] = regexp(SessStr,'\d{6,10}');  % eight consecutive numbers for pattern recognition
YearPatt = {'2015','2016','2017'};
if isempty(StartI)
    SessDate = 'NaN';
else
    StrInds = cellfun(@(x) ~isempty(x),strfind(YearPatt,SessStr(StartI:(StartI+3))));
    YearDate = YearPatt{StrInds};
    if ~isempty(YearDate)
        SessDate = SessStr(StartI:EndIn);
    end
end

% session Batch number
[StartI,EndIn] = regexp(SessStr,'batch\d{1,2}');  % two consecutive numbers after character 'batch' for pattern recognition
if isempty(StartI)
    BatchNum = 'NaN';
else
    BatchNum = SessStr(StartI:EndIn);
end

% animal number extraction
[StartI,EndIn] = regexp(SessStr,'anm\d{1,2}');  % two consecutive numbers after character 'batch' for pattern recognition
if isempty(StartI)
    AnmNum = 'NaN';
else
    AnmNum = SessStr(StartI:EndIn);
end

% test number extraction
[StartI,EndIn] = regexp(SessStr,'test\d{1,3}');  % two consecutive numbers after character 'batch' for pattern recognition
if isempty(StartI)
    TestNum = 'NaN';
else
    TestNum = SessStr(StartI:EndIn);
end
% test number extraction
StartI = regexp(SessStr,'test\d{1,3}rf','once');  % two consecutive numbers after character 'batch' for pattern recognition
if isempty(StartI)
    SessionType = 'Task'; % task or passive
else
    SessionType = 'Passive';
end

Anminfo.SessionDate = SessDate;
Anminfo.AnimalNum = AnmNum;
Anminfo.BatchNum = BatchNum;
Anminfo.TestNum = TestNum;
Anminfo.Sesstype = SessionType;
