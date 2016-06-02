function varargout=menu_LoadCursors(varargin)
% menu_SaveCursors loads the cursor positions from a MAT file
%
% Example
% menu_LoadCursors(hObject, EventData)
%     standard callback
% menu_LoadCursors loads the cursor positions of a sigTOOL data view from a
% MAT-file created by a prior call to menu_SaveCursors and creates those
% cursors. Any existing cursors with the same cursor number will be deleted
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Load Cursors';
    varargout{3}=[];
    return
end


[button fhandle]=gcbo;

% Specify file
str=get(fhandle, 'Name');
[pathname filename]=fileparts(str);
s=getappdata(fhandle, 'Filing');
str=sprintf('%sCursors_%s.mat', s.OpenSaveDir, filename);
d=dir(str);
if isempty(d)
    str=sprintf('%s*.mat', s.OpenSaveDir);
end
[filename pathname]=uigetfile(str);

if ~isscalar(filename)
    newfile=fullfile(pathname, filename);
    % Load data
    temp=load(newfile, 'cursorpositions');
    cursorpositions=temp.cursorpositions;
    
    % Set up cursors
    for k=1:length(cursorpositions)
        if ~isempty(cursorpositions)
            DeleteCursor(fhandle, k);
            CreateCursor(fhandle,k);
            SetCursorLocation(fhandle, k, cursorpositions{k});
        end
    end
end

return
end
