function varargout = behav_cell2struct(varargin)
%this function is used for convert the cell formed behavior analysis adata
%into structure form, to be allowed for further analysis
%June 18th, 2015, by XIN
if nargin < 1
    disp('Please select your cell format behavior data position:\n');
    [filename,filepath,~]=uigetfile({'*.mat';'*.m';'*.*'},'Select your file');
    current_path=pwd;
    cd(filepath);
    load(filename);
    if ~(iscell(SessionResults) && iscell(SessionSettings))
        error('Error file selected, no cell variable named SessionResults and SessionSettings inside.\n');
    end
    isfilesave = 1;
else
    SessionResults = varargin{1};
    SessionSettings = varargin{2};
    isfilesave = 0;
end
    
single_res_struct=SessionResults{1};
single_set_struct=SessionSettings{1};
result_field_name=fieldnames(single_res_struct);
setting_field_name=fieldnames(single_set_struct);
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
            if strcmpi(result_field_name{n},'Stim_toneFreq') || strcmpi(result_field_name{n},'Stim_Probe_pureTone_freq')
                behavResults.Stim_toneFreq = cellfun(@(x) StimFreqSearchFun(x),SessionResults);
                fprintf('Merge field name Stim_toneFreq and Stim_Probe_pureTone_freq together into Stim_toneFreq.\n');
            end
            if strcmpi(result_field_name{n},'Stim_Type')
                behavResults.Stim_Type = cellfun(@(x) StimTypeSearchFun(x),SessionResults,'UniformOutput',false);
                fprintf('Merge field name Stim_Type and Stim_Probe_stimType together into Stim_Type.\n');
            end
        end
    end
end
if ~isfield(behavResults,'Stim_Type')
    behavResults.Stim_Type = cellfun(@(x) StimTypeSearchFun(x),SessionResults,'UniformOutput',false);
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

if isfilesave
    save_name=[filename(1:end-4) '_struct.mat'];
    disp(['result have been saved to ' fullfile(filepath,save_name)]);
    save(save_name,'behavResults','behavSettings','-v7.3');
    cd(current_path);
end

if nargout > 0
    varargout{1} = behavResults;
    varargout{2} = behavSettings;
end

function FieldValue = StimFreqSearchFun(strc)
% this function is specifically used for extracting data frequency from
% cell formed data save
if isfield(strc,'Stim_toneFreq')
    FieldValue = double(strc.Stim_toneFreq);
elseif isfield(strc,'Stim_Probe_pureTone_freq')
    FieldValue = double(strc.Stim_Probe_pureTone_freq);
else
    FieldValue = 0;
end

function FieldValue = StimTypeSearchFun(strc)
% this function is specifically used for normal stimtype value search
if isfield(strc,'Stim_Type')
    FieldValue = strc.Stim_Type;
elseif isfield(strc,'Stim_Probe_stimType')
    FieldValue = strc.Stim_Probe_stimType;
else
    FieldValue = ' ';
end
