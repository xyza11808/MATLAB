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

% another way of import data
% selectquery = 'SELECT * FROM inventoryTable';
% data = select(conn,selectquery)

%%
InsertData = table({'b27a0316042501'},{'b27a03'},{'2016-04-25'},{'VGAT-IRES_cre'},{'Window'},{'null'},{'Puretone'},450,0.9,...
    {'null'},0.85,0.95,0,0,'VariableNames',Columnlist);
TableName = 'BehavDataT';
%%
datainsert(conn,TableName,Columnlist',InsertData);
close(conn)