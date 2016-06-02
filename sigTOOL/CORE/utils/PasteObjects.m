function hg=PasteObjects(varargin)
% PASTEOBJECTS pastes the objects from one axes into another
%
% A call to PASTEOBJECTS should be preceded by a call to COPYOBJECTS
%
% Examples:
% PASTEOBJECTS(SourceAxesHandle)
% stores the source axes handle for the objects in a persistent variable
% (this essentially acts as an internal clipboard - but without storing any
% data). This is the form called by CopyObjects
%
% PASTEOBJECTS(TargetAxesHandle, [])
% pastes the objects from the source axes into the target axes.
% The objects are grouped into an hggroup object

persistent source;

if ishandle(varargin{1}) && strcmpi(get(varargin{1},'Type'),'axes')==1
    if nargin==1
        % Called as PasteObjects(SourceAxesHandle)
        source=varargin{1};
    else
        % Called as PasteObjects(TargetAxesHandle,[])
        if ishandle(source)
            h=findall(source);
            axes(varargin{1});
            newhandles=copyobj(h(2:end), varargin{1});
            hg=hggroup();
            set(hg, 'Tag', 'PastedObjects');
            set(newhandles,'Parent',hg);
        else
            fprintf('PasteObjects: Source axes no longer exist\n');
        end
    end
end