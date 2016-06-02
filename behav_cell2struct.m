function behav_cell2struct
%this function is used for convert the cell formed behavior analysis adata
%into structure form, to be allowed for further analysis
%June 18th, 2015, by XIN

disp('Please select your cell format behavior data position:\n');
[filename,filepath,~]=uigetfile({'*.mat';'*.m';'*.*'},'Select your file');
current_path=pwd;
cd(filepath);
load(filename);
if ~(iscell(SessionResults) && iscell(SessionSettings))
    error('Error file selected, no cell variable named SessionResults and SessionSettings inside.\n');
end

single_res_struct=SessionResults{1};
single_set_struct=SessionSettings{1};
result_field_name=fieldnames(single_res_struct);
setting_field_name=fieldnames(single_res_struct);
behavResults=struct();
behavSettings=struct();
for n=1:length(result_field_name)
    try
        behavResults.(result_field_name{n})=cellfun(@(x) x.(result_field_name{n}),SessionResults);
    catch err
        if strfind(err.message,'UniformOutput')
            try
                behavResults.(result_field_name{n})=cellfun(@(x) x.(result_field_name{n}),SessionResults,'UniformOutput',false);
            catch err
                if strfind(err.message,result_field_name{n})
                   disp(['Some of the trials with no exists of field name',result_field_name{n} '\n']);
                end
            end
        elseif strfind(err.message,result_field_name{n})
            disp(['Some of the trials with no exists of field name',result_field_name{n} '\n']);
        end
    end
end

for n=1:length(setting_field_name)
    try
        behavSettings.(setting_field_name{n})=cellfun(@(x) x.(setting_field_name{n}),SessionSettings);
    catch err
        if strfind(err.message,'UniformOutput')
            try
                behavSettings.(setting_field_name{n})=cellfun(@(x) x.(setting_field_name{n}),SessionSettings,'UniformOutput',false);
            catch err
                if strfind(err.message,setting_field_name{n})
                    disp(['Some of the trials with no exists of field name',setting_field_name{n} '\n']);
                end
            end
        elseif strfind(err.message,setting_field_name{n})
            disp(['Some of the trials with no exists of field name',setting_field_name{n} '\n']);
        end
    end
end

save_name=[filename(1:end-4) '_struct.mat'];
disp(['result have been saved to ' fullfile(filepath,save_name)]);
save(save_name,'behavResult','behavSetting','-v7.3');
cd(current_path);
