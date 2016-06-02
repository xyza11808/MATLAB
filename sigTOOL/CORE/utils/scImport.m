function targetfile=scImport(funchandle, extensionlist, postImportFunc)
% scImport provides a common gateway to all other import functions
%
% Example:
% targetfile=scImport(funchandle, extensionlist)
% targetfile=scImport(funchandle, extensionlist, postImportFunc)
% Inputs: funchandle      is the handle if the relevant ImportXXXX function
%         extensionlist   is a list of file extensions that can be opened
%         postImportFunc  is the handle of a MATLAB function that will be
%                           called after the import is completed.
%                           This function should take the form:
%                               MyFunction(sourcefilename, targetfile)
%                         ScImport will call the function providing the
%                         appropriate file names. MyFunction might, for
%                         example add custom variable to the sigTOOL data
%                         file);
% 
%         
% Output: targetfile      is the name of the generated sigTOOL data file
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
%--------------------------------------------------------------------------
%
% Revisions:
%       26.09.09    Ignore invalid target folders in
%                       Filing.ImportReplace.Target
%       15.11.09    Add support for postImportFunc argument

% Set up file name, paths etc
[dum fhandle]=gcbo;
Filing=getappdata(fhandle,'Filing');
if isempty(Filing) || ~isfield(Filing, 'ImportDir')
    Filing.ImportDir='';
end

template=[Filing.ImportDir filesep extensionlist]; %#ok<AGROW>
[name, pathname]=uigetfile(template, 'Select File To Import');

if name==0
    return
end



if isempty(Filing) || ~isfield(Filing, 'ImportReplace')...
        || ~isfield(Filing.ImportReplace, 'Source')...
        || isempty(Filing.ImportReplace.Source)...
        || strcmp(Filing.ImportReplace.Target, '')
    targetpath='';
else
    pathname2=strrep(lower(pathname),lower(Filing.ImportReplace.Source),...
        lower(Filing.ImportReplace.Target));
    if ~isdir(pathname2)
        status=mkdir(pathname2);
        if status>0
            targetpath=pathname2;
        end
    else
        targetpath=[Filing.ImportReplace.Target filesep];
        if ~isdir(targetpath)
            % Filing.ImportReplace.Target folder does not exist so ignore
            % it
            targetpath='';
        end
    end
end

% Call the required function
source=fullfile(pathname, name);
targetfile=funchandle(source, targetpath);
if nargin>=3
    if isa(postImportFunc, 'function_handle')
        postImportFunc(source, targetfile);
    elseif iscell(postImportFunc) && numel(postImportFunc)>1
        postImportFunc{1}(source, targetfile, postImportFunc{2:end});
    elseif iscell(postImportFunc)
        postImportFunc{1}(source, targetfile);
    end
end

if strcmp(targetfile,'')==1
    % Not imported - wrong format?
    % TODO: May be share violation - likely because of memmapfile in e.g. the
    % Array Editor
    targetfile=[];
    return;
end

[dum handle]=gcbo;
if isempty(handle)
    handle=get(0,'CurrentFigure');
end

Filing.ImportDir=pathname;
Filing.OpenSaveDir=[fileparts(targetfile) filesep];
setappdata(fhandle,'Filing',Filing);
    
if ishandle(handle) && isappdata(handle,'channels')==0
    [path name]=fileparts(targetfile);
    set(handle,'Name',name);
    channels=scOpen(targetfile);
    setappdata(handle,'channels',channels);
    scCreateDataView(handle);
else
    sigTOOL(targetfile);
end

scSavePreferences(fhandle)
return
end
