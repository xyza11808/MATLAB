function h=jvSetHelp(h, varargin)
% 
% Examples:
% h=jvSetHelp(h, HelpFileName)
% h=jvSetHelp(h, CallingFunctionName, HelpFileName)

if nargin==2
    st=dbstack('-completenames');
    mfile=st(2).file;
    markup=varargin{1};
else
    mfile=varargin{1};
    markup=varargin{2};
    mfile=which(mfile);
    
end

path=fileparts(mfile);
helpfile=fullfile(path, 'private', 'help', markup);

[path name ext]=fileparts(helpfile);
if isempty(ext)
    helpfile=[helpfile '.html'];
end

h{1}.Help.MouseClickedCallback={@MouseClickedCallback, helpfile}; %#ok<NASGU>
h{1}.Help.Visible='on'; %#ok<NASGU>
return
end


function MouseClickedCallback(hObject, EventData, helpfile) %#ok<INUSL>
web(helpfile);
return
end
