function varargout=menu_Poincare(varargin)
% menu_Poincare: gateway to the spPoincare function
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/07
% Copyright © King’s College London 2007
%
% Acknowledgements:
% Revisions:


% Called from dir2menu
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Poincare plot';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;
h=jvDefaultPanel(fhandle, 'Title', 'Poincare plot',...
    'ChannelType', {'All' 'none'});
jvSetHelp(h, 'Poincare plot');
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s) || (length(s.ChannelA)==1 && s.ChannelA==0)
    return
end

s={s};
arglist={fhandle,...
    'Sources', s{1}.ChannelA,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop};
scExecute(@spPoincare, arglist, s{1}.ApplyToAll)
return
end


 
