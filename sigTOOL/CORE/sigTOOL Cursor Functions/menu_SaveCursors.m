function varargout=menu_SaveCursors(varargin)
% menu_SaveCursors saves the cursor positions to a MAT file
% 
% Example
% menu_SaveCursors(hObject, EventData)
%     standard callback
% menu_SaveCursors saves the cursor positions of a sigTOOL data view to a
% MAT-file as a cell array
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Save Cursors';
    varargout{3}=[];
    return
end


[button fhandle]=gcbo;

% Set up cell array of positions
cursors=getappdata(fhandle, 'VerticalCursors');
n=length(cursors);
cursorpositions=cell(1,n);
for k=1:n
    cursorpositions{k}=GetCursorLocation(k);
end

% Save them
str=get(fhandle, 'Name');
[pathname filename]=fileparts(str);
s=getappdata(fhandle, 'Filing');
[filename pathname]=uiputfile(sprintf('%sCursors_%s.mat', s.OpenSaveDir, filename));
newfile=fullfile(pathname, filename);
save(newfile, 'cursorpositions');
return
end
