function scDeleteFigure(fhandle)
% scDeleteFigure does some house-keeping when a sigTOOL data view is deleted
% 
% Example:
% scDeleteFigure()
% scDeleteFigure(fhandle)
% fhandle will default to gcbf is not specified.
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-2007
% -------------------------------------------------------------------------

if nargin==0
    fhandle=gcbf;
end


if isappdata(fhandle, 'channels')
    rmappdata(fhandle,'channels');
end

% Delete any temporary files created through this figure
TempFileList=getappdata(fhandle, 'TempFileList');
for k=1:length(TempFileList)
    % Make sure they have not been deleted already
    warning('off', 'MATLAB:DELETE:Permission');%    Add 07.11.08   
    if ~isempty(dir(TempFileList{k}))
        delete(TempFileList{k});
    end
    warning('on', 'MATLAB:DELETE:Permission');
end

list=getappdata(fhandle,'sigTOOLResultViewList');
% NB dbstack will equal 2 if figure has been closed manually
st=dbstack();
if ~isempty(list) && strcmp(st(end).name,'closereq')
    answer=questdlg('Do you want to close result views associated with this file', 'Close File','Yes','No','No');
    if strcmp(answer, 'Yes')
        close(list(ishandle(list)));
    end
end

Filing=getappdata(fhandle, 'Filing'); %#ok<NASGU>
save(fullfile(scGetBaseFolder(), 'program', 'scPreferences.mat'),'Filing', '-append', '-v6');
return
end
