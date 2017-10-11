% path parameter departure for mat file "TargetPathSave.mat"
nPathUsed = length(TargetPath);
nPathPara = struct('PathDate',zeros(nPathUsed,1),...
    'PathAnm',zeros(nPathUsed,1),'PathTestNum',zeros(nPathUsed,1),...
    'PathBatchNum',zeros(nPathUsed,1));
AnmExpr = 'anm\d{2}'; % check animal label
TestNumExpr = 'test\d{2}'; % check test label
DateExpr = '\d{8}';
BatchNumExpr = 'batch\d{2}';

for cPathN = 1 : nPathUsed
    cPathStr = TargetPath{cPathN};
    % anmal label
    AnmMatch = regexp(cPathStr,AnmExpr,'match','ignorecase'); %[AnmstartInd,AnmendInd]
    AnmStr = AnmMatch{:}; %cPathStr(AnmstartInd:AnmendInd);
    nPathPara.PathAnm(cPathN) = str2num(AnmStr(end-1:end));
    % Date
    [DateStartInd,DateEndInd] = regexp(cPathStr,DateExpr);
    DateStr = cPathStr(DateStartInd:DateEndInd);
    nPathPara.PathDate(cPathN) = str2num(DateStr);
    % test number
    TestMatch = regexp(cPathStr,TestNumExpr,'match','ignorecase'); %[TestStartInd,TestEndInd]
    TestStr = TestMatch{:};%cPathStr(TestStartInd:TestEndInd);
    nPathPara.PathTestNum(cPathN) = str2num(TestStr(end-1:end));
    % Batch number
    BatchMatch = regexp(cPathStr,BatchNumExpr,'match','ignorecase'); %[BatchStartInd,BatchEndInd];
    BatchStr = BatchMatch{:};%cPathStr(BatchStartInd:BatchEndInd);
    nPathPara.PathBatchNum(cPathN) = str2num(BatchStr(end-1:end));
end
%%
AnmWisePath = uigetdir(pwd,'Please select the data path to save animal path data');
cd(AnmWisePath);
AnmLabeltypes = unique(nPathPara.PathAnm);
AnmNum = length(AnmLabeltypes);
for n = 1 : AnmNum
    fprintf('Generating anmal %02d data path...\n',AnmLabeltypes(n));
    cAnmInds = nPathPara.PathAnm == AnmLabeltypes(n);
    cAnmTestInds = nPathPara.PathTestNum(cAnmInds);
    [~,SortInds] = sort(cAnmTestInds);
    cAnmPath = TargetPath(cAnmInds);
    SortAnmPath = cAnmPath(SortInds);
    cAnmtxtfn = sprintf('Anm%02d data save path sort.txt',AnmLabeltypes(n));
    fid = fopen(cAnmtxtfn,'w');
    fFormat = '%s \r\n';
    fprintf(fid,sprintf('Anm%02d analysized data path:\r\n',AnmLabeltypes(n)));
    for cPath = 1 : length(SortAnmPath)
        fprintf(fid,fFormat,SortAnmPath{cPath});
        fprintf(fid,'\r\n');
    end
    fclose(fid);
end
