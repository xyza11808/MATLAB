host = 'xyMechaine_MySQL57';
user = 'root';
password = '1180875,youKU';
dbname = 'testdata';
Drivername = 'com.mysql.jdbc.Driver';
% DrivUrl = ['jdbc:z1MySQL://localhost:3306/',dbname];
DrivUrl = ['jdbc:mysql://localhost:3306/',dbname];
conn = database(dbname,user,password,Drivername,DrivUrl,'Vendor','MySQL');
if ~isempty(conn.Message) % after connection seccess, return message will be empty
    fprintf('Error while connect to the database:\n %s;\n',conn.Message);
    return;
end
%%
% InventoryTablename = []
curs = exec(conn,'select * from behavDataT');
cursInfo = fetch(curs);
Columnlist = columnnames(cursInfo,true);
cursInfo.Data

%%
% InsertData = table({'b27a0316042501'},{'b27a03'},{'2016-04-25'},{'VGAT-IRES_cre'},{'Window'},{'null'},{'Puretone'},450,0.9,...
%     {'null'},0.85,0.95,0,0,'VariableNames',Columnlist);
% TableName = 'BehavDataT';
% %%
% datainsert(conn,TableName,Columnlist',InsertData);
% close(conn)
%% built a new table for behavData storage
% This section should only run once, after that the rest behavdata should
% only add to exist table
[fn,fp,fi] = uigetfile('*.mat','Please select a behavior mat file to use the fild name to create a new table');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
Behavdata = load(fpath);
%%
Names = fieldnames(Behavdata.behavResults);
BehavDataList = 'SessionName varchar(80),';%sprintf('SessionName %s',fn(1:end-4));
for ne = 1 : length(Names)
    cname = Names{ne};
    if isnumeric(Behavdata.behavResults.(cname))
        AddSessName = sprintf('%s int',cname);
        BehavDataList = sprintf('%s %s,',BehavDataList,AddSessName);
        continue;
    end
    if ischar(Behavdata.behavResults.(cname))
        AddSessName = sprintf('%s varchar(200)',cname);
        BehavDataList = sprintf('%s %s,',BehavDataList,AddSessName);
        continue;
    end
end
BehavDataList = sprintf('%s ResponseDelay int',BehavDataList);
sqlquery = sprintf('CREATE TABLE BehavDataAll(%s)',BehavDataList);  % create a new table
curs = exec(conn,sqlquery);
% ssquery = 'ALTER TABLE behavdatat ADD testInsert varchar(20)';  % insert
% % a new column to table named behavdatat, exists data lists will be given
% % value 'null'; if insert a number, others will given a NaN value
% cursInsert = exec(conn,ssquery);
%%
% curs = exec(conn,'select * from BehavDataAll WHERE SessionName = ''40a01_20170611_test01strc''');
curs = exec(conn,'select * from BehavDataAll');
cursInfo = fetch(curs);
% Columnlist = columnnames(cursInfo,true);
zz = cursInfo.Data;
numrows = rows(cursInfo)
%%
[fn,fp,fi] = uigetfile('*.mat','Please select a behavior mat file to use the fild name to create a new table');
if ~fi
    return;
end
fBehavpath = fullfile(fp,fn);
cd(fp);
%%
% fBehavpath = 'H:\data\behavior\2p_data\behaviro_data\batch40\anm01\data\40a01_20170611_test01strc.mat';
% GrandPath = 'H:\data\behavior\2p_data\behaviro_data\batch40';
GrandPath = uigetdir(pwd,'Please select a folder path');
xpath = genpath(GrandPath);
nameSplit = strsplit(xpath,';');
DirLength = length(nameSplit);
for nDir = 1 : DirLength
    folderPath = nameSplit{nDir};
%     folderPath = uigetdir(pwd,'Please select a folder path');
    if isempty(folderPath)
        continue;
    end
    cd(folderPath);
    files = dir('*.mat');
    if isempty(files)
        fprintf('Folder path %s have no behavior data files indside.\n',folderPath);
        continue;
    end
    for nf = 1 : length(files)
        fn = files(nf).name;
        curs = exec(conn,sprintf('select * from BehavDataAll WHERE SessionName = ''%s''',fn(1:end-4)));
        cursInfo = fetch(curs);
        % Columnlist = columnnames(cursInfo,true);
        zz = cursInfo.Data;
        if ~(size(zz,1) == 1 || size(zz,2) == 1)
            warning('Session:\n%s\n already load into database, skip loading...\n',fullfile(folderPath,fn));
            continue;
        end 
        BehavDataInsert = load(fn);
        InsertData={};
        InsertColName = {};
        if ~(isfield(BehavDataInsert,'behavResults') && isfield(BehavDataInsert,'behavSettings'))
            continue;
        end
        if ~isfield(BehavDataInsert.behavResults,'Stim_toneFreq') || length(BehavDataInsert.behavResults.Stim_toneFreq) < 100
            continue; % session with too few trials will be excluded from load into database
        end
        cSessTrNum = length(BehavDataInsert.behavResults.Stim_toneFreq);
        columnsnames = columns(conn,'','','BehavDataAll');
        % if strcmpi(columnsnames{1},'SessionName');
            InsertData(1:cSessTrNum,1) = repmat({fn(1:end-4)},cSessTrNum,1);
            InsertColName{1} = 'SessionName';
        % else
        %     InsertData(1:cSessTrNum,1) = {''};
        %     InsertColName{1} = columnsnames{1};
        %     warning('The first column name is not %s, please check the database structure.\n',columnsnames{1});
        % end
        k = 2;
        BehavFieldName = fieldnames(BehavDataInsert.behavResults);
        FieldInsert = zeros(length(BehavFieldName),1);
        for nColname = 1 : length(BehavFieldName)
            cColName = BehavFieldName{nColname}; %cfieldname
            IsfieldnameExist = sum(strcmpi(cColName,columnsnames));
            if IsfieldnameExist
                InsertColName{k} = cColName;
                if isfield(BehavDataInsert.behavResults,cColName)
                    cfieldData = BehavDataInsert.behavResults.(cColName);
                    if size(cfieldData,1) ~= cSessTrNum
                        cfieldData = cfieldData';
                    end
                    if size(cfieldData,2) > 200 && size(cfieldData,1) ~= 1
                        cfieldData = cfieldData(:,1:200);
                    end
                    try
                        if isnumeric(cfieldData)
                            InsertData(1:cSessTrNum,k) = mat2cell(cfieldData,ones(cSessTrNum,1));
            %                 continue;
                        end
                        if ischar(cfieldData)
                            InsertData(1:cSessTrNum,k) = cellstr(cfieldData);
            %                 continue;
                        end
                        if iscell(cfieldData)
                            InsertData(1:cSessTrNum,k) = cfieldData(:);
                        end
                    catch ME
                        if isnumeric(cfieldData)
                            InsertData(1:cSessTrNum,k) = {NaN};
                        elseif ischar(cfieldData) || iscell(cfieldData)
                            InsertData(1:cSessTrNum,k) = {''};
                        end
                    end
        %             fieldnameInds = strcmpi(cColName,BehavFieldName);
        %             FieldInsert(fieldnameInds) = 1;
                end
                FieldInsert(nColname) = 1;
                k = k + 1;
            end
        end
        if isfield(BehavDataInsert.behavSettings,'responseDelay')
            if iscell(BehavDataInsert.behavSettings.responseDelay)
                InsertData(1:cSessTrNum,k) = BehavDataInsert.behavSettings.responseDelay(:);
            elseif isnumeric(BehavDataInsert.behavSettings.responseDelay)
                InsertData(1:cSessTrNum,k) = mat2cell(BehavDataInsert.behavSettings.responseDelay,ones(cSessTrNum,1));
            end
            InsertColName{k} = 'ResponseDelay';
        end
        %
        fastinsert(conn,'BehavDataAll',InsertColName,InsertData);
        if sum(FieldInsert) ~= length(FieldInsert)
            NewFields = ~FieldInsert;
            NewFieldNames = BehavFieldName(NewFields);
            FieldInsert2Table(conn,BehavDataInsert.behavResults,NewFieldNames,'BehavDataAll');
        end
    end
end