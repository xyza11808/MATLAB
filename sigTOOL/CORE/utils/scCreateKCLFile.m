function matfilename=scCreateKCLFile(filename, targetpath)
% scCreateKCLFile creates a MAT-file giving it a 'kcl' extension.
%
% The function is usually called from a sigTOOL data import routine.
%
% Examples:
% matfilename=scCreateKCLFile(filename)
% matfilename=scCreateKCLFile(filename, targetpath)
%
% filename is the name of the source file from another application 
% e.g. a CED SMR file. Filename should include the full path for the file
% Targetpath will be used as  the path of the output matfilename.
% The target file will be deleted if it already exists.
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 10/06
% Copyright © The Author & King’s College London 2006-
%
% Acknowledgements:
% Revisions:
% 25.08.08  Include selection of new file name when access denied
% 26.08.08  Deal with folder access violations from mkdir


[pathname, name] = fileparts(filename);
if ~isempty(pathname)
    pathname=[pathname filesep];
end
if nargin>=2 && ~isempty(targetpath) && ~isdir(targetpath)
    [status, message]=mkdir(targetpath);   
    if status==0
        str=sprintf('sigTOOL could not create\n%s\n\n[mkdir message: %s]',...
            targetpath, message);
        errordlg(str,'Error creating folder');
        uiwait();
        return
    end
end
if isempty(targetpath)
    targetpath=pathname;
end
matfilename=[targetpath name '.kcl'];
% ... and delete any existing file
d=dir(matfilename);
if ~isempty(d)
    temp=fopen(matfilename,'w+');
    if temp>0
        fclose(temp);
        delete(matfilename);
    else
        % File access will be denied if there are any memmapfile
        % objects belonging to the file left over e.g. in the MATLAB Array
        % Editor or base workspace. Force change of filename.
        str=sprintf('%s\nThis file is already open in sigTOOL/MATLAB\nand can not be overwritten.\nChoose another file name.',...
            matfilename);
        errordlg(str,'File access denied');
        uiwait();
        [filename, targetpath]=uiputfile(fullfile(targetpath, '*.kcl'));
        matfilename=scCreateKCLFile(filename, targetpath);
        return;
    end
end
return
end