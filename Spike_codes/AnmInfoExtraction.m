function Anminfo = AnmInfoExtraction(SessionPath)
% SessionPath is a string indicating session path
% parsing session data information from given session path
SessStr = SessionPath;

% extract session data from path string
[StartI,EndIn] = regexp(SessStr,'A\d{6,10}');  % eight consecutive numbers for pattern recognition

if isempty(StartI)
    SessDate = 'NaN';
else
    SessDate = SessStr(StartI(1)+1:EndIn(1));
end

% session Batch number
[StartI,EndIn] = regexp(SessStr,'b\d{1,3}a\d{1,2}');  % two consecutive numbers after character 'batch' for pattern recognition
if isempty(StartI)
%     [StartINew,EndInNew] = regexp(SessStr,'Batch\d{1,2}');
%     if isempty(StartINew)
        BatchNum = 'NaN';
%     else
%         BatchNum = SessStr(StartINew:EndInNew);
%     end
else
    BatchNum = SessStr(StartI(1):EndIn(1));
end

% NPsession number extraction
[StartI,EndIn] = regexp(SessStr,'NPSess\d{1,3}');  % two consecutive numbers after character 'batch' for pattern recognition
if isempty(StartI)
    NPsession = 'NaN';
else
    NPsession = SessStr(StartI(1):EndIn(1));
end

% probe index number extraction
[StartI,EndIn] = regexp(SessStr,'imec\d{1,1}');  % two consecutive numbers after character 'batch' for pattern recognition
if isempty(StartI)
    ProbeIndex = 'NaN';
else
    ProbeIndex = SessStr(StartI(1):EndIn(1));
end

Anminfo.SessionDate = SessDate;
Anminfo.NPSessIndex = NPsession;
Anminfo.AnimalNum = BatchNum;
Anminfo.ProbeIndex = ProbeIndex;
