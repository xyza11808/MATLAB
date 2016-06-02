function varargout=menu_CopyFigure(varargin)
% menu_CopyFigure copies a figure to the clipboard
% 
% Example
% menu_CopyFigure(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% ------------------------------------------------------------------------- 

if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Copy Figure';
    varargout{3}=[];
    return
end

if ispc==1
    print(gcbf, '-dmeta', '-noui','-opengl');
else
    h=findall(gcbf,'Type','uicontrol');
    h=[h; findall(gcbf,'Type','uimenu')];
    h=[h; findall(gcbf,'Type','uipanel')];
    set(h,'Visible','off');
    editmenufcn(gcbf,'EditCopyFigure')
    set(h,'Visible','on');
end