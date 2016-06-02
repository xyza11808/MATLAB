function ROI_2AFC_combined_analysis
%this function used for 2AFC and ROI data analysis

%%
%load ROI analysis result
filepath=input('please input the ROI analysis result file path.\n','s');
cd(filepath);
files=dir('*.mat');
for i=1:length(files);
    load(files(i).name);
    if strncmp(files(i).name,'CaSignal',8)
        export_filename_raw=files(i).name(1:end-4);
    end
    disp(['loading file ',files(i).name]);
end

%%
filepath2=input('please input the data path for behavior result.\n','s');
if ~isdir(filepath2)
    error(message('wrong file path for behavior result!'));
end
cd(filepath2);
files=dir('*.mat');
for i=1:length(files);
    load(files(i).name);
    disp(['loading file ',files(i).name]);
end

%%
%combined two structture in one
feldname_behavResults=fieldnames(behavResults);
fieldname_behavSettings=fieldnames(behavSettings);
fieldname_CaTrials=fieldnames(CaTrials);
fieldname_ICA_results=fieldnames(ICA_results);

% Total_result_combination=struct();
Total_result_combination=CaTrials;

%combined behavResult structure components into the final structure
for i=1:length(feldname_behavResults)
    for j=1:length(Total_result_combination)
        field_string=feldname_behavResults{i};
        if any(size(behavResults.(field_string))==1)
            value=behavResults.(field_string)(j);
        else
            value=behavResults.(field_string)(j,:);
        end
        Total_result_combination(j).(field_string)=value;
    end
end

%%combined behavResult structure components into the final structure
for i=1:length(fieldname_behavSettings)
    for j=1:length(Total_result_combination)
        field_string=fieldname_behavSettings{i};
        if any(size(behavSettings.(field_string))==1)
            value=behavSettings.(field_string)(j);
        else
            value=behavSettings.(field_string)(j,:);
        end
        Total_result_combination(j).(field_string)=value;
    end
end

cd(filepath);
if isdir('.\Final_data_save\')==0
    mkdir('.\Final_data_save\');
end
cd('.\Final_data_save\');
save Combined_2AFC_2P_Result.mat Total_result_combination;
disp(['combined data have been saved in folder ',pwd,'\Combined_2AFC_2P_Result.mat\n']);
cd ..;


