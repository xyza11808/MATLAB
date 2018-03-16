
% GrandPath = 'H:\data\behavior\2p_data\behaviro_data\batch49';
GrandPath = uigetdir(pwd,'Please select target data path');
xpath = genpath(GrandPath);
nameSplit = strsplit(xpath,';');
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);
%%
SessionDespStrc = struct('SessfName','','SessDate','','SessType','','IsProbSess',0,'ProbCorrrate',[-1,-1],...
    'TrNumAll',0,'TrainCorrrate',[-1,-1],'SessTrainFreqs',[],'SessProbFreqs',[],'TrainFreqNum',[],...
    'ProbFreqNum',[],'testNum','','SessBatch','');
nStrc = 0;
ErrorPath = {};
nErrors = 1;
% exec(conn,'CREATE TABLE BehavDataSummary(SessfName varchar(200),SessDate varchar(200),SessType varchar(80),IsProbSess int,',...
%     'ProbCorrrate int(10),TrNumAll int,TrainCorrrate int(10),SessTrainFreqs int(10),SessProbFreqs int(10),TrainFreqNum int(10),ProbFreqNum int(10)',...
%     'testNum varchar(20),SessBatch varchar(20))');
% curs = exec(conn,'select * from BehavDataSummary','MaxRows',10);
% cursInfo = fetch(curs);
% Columnlist = columnnames(cursInfo,true);
% datainsert(conn,NewTableName,VariableNamesAll,TBData);
%%
for cnDir = 1 : DirLength
    cDirPath = nameSplit{cnDir};
    cDirMatfs = dir(fullfile(cDirPath,'*strc.mat'));
    if ~isempty(cDirMatfs)
        cDirfNum = length(cDirMatfs);
        try
            for cfNum = 1 : cDirfNum
                nStrc = nStrc + 1;
                cfNameFull = fullfile(cDirMatfs(cfNum).folder,cDirMatfs(cfNum).name);
                [StartI,EndI] = regexp(cDirMatfs(cfNum).name,'\d{6,9}');
                if ~isempty(StartI)
                    SessionDespStrc(nStrc).SessDate = cDirMatfs(cfNum).name(StartI:EndI);
                end
                [StartIt,EndIt] = regexp(cDirMatfs(cfNum).name,'test\d{2,3}');
                if ~isempty(StartIt)
                    SessionDespStrc(nStrc).testNum = cDirMatfs(cfNum).name(StartIt:EndIt);
                end
                [SessStartInds,SessEndInds] = regexp(cDirMatfs(cfNum).name,'\d{1,3}a\d{1,3}');
                if ~isempty(SessStartInds)
                    SessionDespStrc(nStrc).SessBatch = sprintf('b%s',cDirMatfs(cfNum).name(SessStartInds:SessEndInds));
                end
                SessionDespStrc(nStrc).SessfName = cDirMatfs(cfNum).name;
                cBehavStrc = load(cfNameFull);
                IsTrProbs = cBehavStrc.behavResults.Trial_isProbeTrial;
                TrOutcome = cBehavStrc.behavResults.Action_choice(:) == cBehavStrc.behavResults.Trial_Type(:);
                TrMissInds = cBehavStrc.behavResults.Action_choice(:) == 2;
                TrFreqsAll = double(cBehavStrc.behavResults.Stim_toneFreq(:));
                SessionDespStrc(nStrc).TrNumAll = length(TrFreqsAll);
                if sum(IsTrProbs)
                    SessionDespStrc(nStrc).IsProbSess = 1;
                    ProbInds = logical(IsTrProbs(:));
                    ProbTrIndex = find(ProbInds,1,'first');
                    TrainIndex = find(~ProbInds,1,'first');
                    ProbTrType = cBehavStrc.behavResults.Stim_Type(ProbTrIndex,:);
                    TrainTrType = cBehavStrc.behavResults.Stim_Type(TrainIndex,:);
                    SessionDespStrc(nStrc).SessType = sprintf('%s--%s',ProbTrType,TrainTrType);
                    ProbCorrRate = [mean(TrOutcome(ProbInds)),mean(TrOutcome(ProbInds & ~TrMissInds))];
                    TrainCorrrate = [mean(TrOutcome(~ProbInds)),mean(TrOutcome(~ProbInds & ~TrMissInds))];
                    SessionDespStrc(nStrc).ProbCorrrate = ProbCorrRate;
                    SessionDespStrc(nStrc).TrainCorrrate = TrainCorrrate;
                    SessionDespStrc(nStrc).SessProbFreqs = unique(TrFreqsAll(ProbInds));
                    SessionDespStrc(nStrc).SessTrainFreqs = unique(TrFreqsAll(~ProbInds));
                    SessionDespStrc(nStrc).ProbFreqNum = histc(TrFreqsAll(ProbInds),unique(TrFreqsAll(ProbInds)));
                    SessionDespStrc(nStrc).TrainFreqNum = histc(TrFreqsAll(~ProbInds),unique(TrFreqsAll(~ProbInds)));
                    SessionDespStrc(nStrc).SessDate = cDirMatfs(cfNum).name(StartI:EndI);

                else
                    SessionDespStrc(nStrc).IsProbSess = 0;
                    SessionDespStrc(nStrc).SessType = cBehavStrc.behavResults.Stim_Type(1,:);
                    TrainCorrrate = [mean(TrOutcome),mean(TrOutcome(~TrMissInds))];
                    SessionDespStrc(nStrc).TrainCorrrate = TrainCorrrate;
                    SessionDespStrc(nStrc).SessTrainFreqs = unique(TrFreqsAll);
                    SessionDespStrc(nStrc).TrainFreqNum = histc(TrFreqsAll,unique(TrFreqsAll));
                    SessionDespStrc(nStrc).ProbCorrrate = [-1 -1];
                end
                
            end
        catch ME
            ErrorPath{nErrors,1} = ME;
            ErrorPath{nErrors,2} = cDirPath;
            nErrors = nErrors + 1;
            nStrc = nStrc - 1;
        end            
    else
        continue;
    end
    
end
%%
TableDatas = struct2table(SessionDespStrc);
cd(GrandPath);
save BehavDataSumSave.mat SessionDespStrc TableDatas -v7.3
%%
% find target session data
SessDespAll = TableDatas.SessBatch;
TypeInds = strcmp(SessTypeData,'b49a02');
TableTargetDatas = TableDatas(TypeInds,:);
