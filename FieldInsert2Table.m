function FieldInsert2Table(conn,DataStrc,Fieldnames,tablename,varargin)
% this function is just used for insert the new field of the data structure
% into connected database 'conn'

nFields = length(Fieldnames);
for nnn = 1 : nFields
    cname = Fieldnames{nnn};
%     BehavDataList = '';
    if isnumeric(DataStrc.(cname))
        AddSessName = sprintf('%s int',cname);
%         BehavDataList = sprintf('%s %s,',BehavDataList,AddSessName);
        continue;
    end
    if ischar(DataStrc.(cname))
        AddSessName = sprintf('%s varchar(200)',cname);
%         BehavDataList = sprintf('%s %s,',BehavDataList,AddSessName);
        continue;
    end
    sqlquery = sprintf('ALTER TABLE %s ADD %s',tablename,AddSessName);  % create a new table
    curs = exec(conn,sqlquery);
end
% BehavDataList = sprintf('%s ResponseDelay int',BehavDataList);
% close(curs);