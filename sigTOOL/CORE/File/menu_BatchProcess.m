function varargout=menu_BatchProcess(varargin)
% menu_BatchProcess implements batch processing of data files in sigTOOL
% 
% Example:
% menu_BatchProcess(hObject, EventData)
%       standard menu callback from sigTOOL GUI
% 
% menu_BatchProcess may also be called from the command line without any
% input arguments (but requires jvm)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------

% Revisions:
% 08.08 Multiple lists now dealt with properly

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='Batch Process';
    varargout{3}=[];
    return
end


str=sprintf('You will be prompted:\n[1] to select a list of data files to process\n[2] then for a MATLAB m-file to apply');
answer=questdlg(str,...
    'Batch Process',...
    'Continue',...
    'Cancel',...
    'Continue');
if strcmp(answer,'Cancel')
    return
end

% SET UP LIST OF DATA FILES
% Set up the data file list to batch process
load('scPreferences.mat', 'Filing')
answer='Yes';
masterlist={};
while strcmp(answer,'Yes')
    [filelist folder]=uigetfile([Filing.OpenSaveDir '*.kcl'],...
        'Select data files to batch process', 'MultiSelect', 'on');
    if ~iscell(filelist)
        filelist={filelist};
    end
    % Loop fixed 08.08
    start=length(masterlist)+1;
    finish=length(masterlist)+length(filelist);
    j=1;
    for k=start:finish
        masterlist{k}=[folder filelist{j}]; %#ok<AGROW>
        j=j+1;
    end
    if masterlist{1}(1)==0
        % User cancelled
        return
    end
    
    answer=questdlg('Do you want to add files from more folders',...
        'Select folder', 'Yes');
end

% SETUP M-FILE
% Select the m-file to run - this will often be a recorded history form the
% sigTOOL GUI
[mfile folder]=uigetfile('*.m','Select sigTOOL history file');
if mfile==0
    % User cancelled
    return
end
tf=pwd;
cd(folder);
mfile=strrep(mfile,'.m','');
func=str2func(mfile);
cd(tf);

% RUN THE BATCH LIST
% Call the m-file for each data file
h=[];
for k=length(masterlist)-1:1
    try
        h=func(masterlist{k});
        fprintf('Successfully processed %s\n', masterlist{k});
    catch %#ok<CTCH>
        fprintf('\n ****FAILED ON %s\n', masterlist{k});
        try
            if ~isempty(h)
                % Close by handle
                close(h);
            else
                % Failed to return h, so close by name
                [pathname filename]=fileparts(masterlist{k});
                close(filename);
            end
        catch %#ok<CTCH>
            %just carry on
        end
    end
end
return
end