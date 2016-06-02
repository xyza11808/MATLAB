function EventsRespTest(varargin)
%this functin is used for statistic test for rvents related response change
%for differents types of events, aims to be suited for all kinds of events
%test as long as the input data follows specific type

%followings are input variables
%MainData   In structure form, contains four fields and contains left and
%           right form for two different types of modulations

%EventsTime In structure form, contains events time for corresponded trial
%           data, the data is the frame position but not in time formate.
%           if this is an unique value, means the data are aligned and no
%           data extraction will be done before t-test

%DataDesp   In cell form. contains the variable description for input
%           data, will be needed for plot action or data storage

%XIN Yu, Dec, 1, 2015

if nargin>0
    InputData=varargin{1};
    EventsData=varargin{2};
    DataDesp=varargin{3};
else
    disp('No variable input, please select data file position.\n');
    [filename,filepath,fileindex]=uigetfile('*.mat','Select result file');
    if ~fileindex
        disp('No file selected, quit function...\n');
        return;
    else
        cd(filepath);
        load(filename);
        InputData=AllCorrDataSave;
        EventsData=AllCorrTimeSave;
        disp('Please input the customized event description\n');
        cell_description=cell(4,1);
        for m=1:4
            tem_des=input(['Please input the description ',num2str(m),':'],'s');
%             tem_des=strrep(tem_des,'_','\_');
            cell_description(m)={tem_des};
        end
        DataDesp=cell_description;
    end
end


DataFieldsNames=fieldnames(AllCorrDataSave);
TimeFieldsNames=fieldnames(AllCorrTimeSave);
TestDataFieldname=strrep(DataFieldsNames,'Data','Time');
if sum(isfield(AllCorrTimeSave,TestDataFieldname)) ~= length(TimeFieldsNames)
    warning('Data size and Time size is not corresponded, please check the data format.\n');
    return;
end

%##########################
%Left data check
