function varargout=menu_BatchImport(varargin)


if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Batch Import';
    varargout{3}=[];
    return
end



% SET UP LIST OF DATA FILES
% Set up the data file list to batch process
load('scPreferences.mat', 'Filing')
answer='Yes';
masterlist={};
while strcmp(answer,'Yes')
    [filelist folder]=uigetfile([Filing.OpenSaveDir scSupportedFormats()],...
        'Select data files to batch process', 'MultiSelect', 'on');
    if ~iscell(filelist)
        filelist={filelist};
    end
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
    Filing.OpenSaveDir=folder;
end

progbar=scProgressBar(0, '', 'Name', 'Batch Import');
pos=get(progbar,'Position');
pos(2)=pos(2)+0.2;
pos(1)=pos(1)-0.1;
set(progbar,'Position',pos);

for k=1:length(masterlist)
scProgressBar(k/length(masterlist), progbar, sprintf('File %s',masterlist{k}));
    try
        
    [pathname filename extension]=fileparts(masterlist{k});

    if isempty(Filing.ImportReplace.Source)
        targetpath='';
    else
        pathname2=strrep(lower(pathname),lower(Filing.ImportReplace.Source),...
            lower(Filing.ImportReplace.Target));
        if ~isdir(pathname2)
            status=mkdir(pathname2);
            if status>0
                targetpath=[pathname2  filesep];
            end
        else
            targetpath=[pathname2  filesep];
        end
    end

    % Choose the correct ImportXXX function...
    fcn=scSelectImporter(extension);
    %...and invoke it
    fcn(masterlist{k}, targetpath);
    
    catch %#ok<CTCH>
        fprintf('FAILED ON:\n%s',masterlist{k});
        continue
    end
end

delete(progbar)
return
end



