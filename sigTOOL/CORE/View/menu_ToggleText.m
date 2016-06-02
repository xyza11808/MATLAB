function varargout=menu_ToggleText(varargin)

%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 07/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportSMR(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Remove Text';
    varargout{3}=sprintf(...
        'Author: Malcolm Lidierth\n© 2006 King’s College London');
    return
end

[button handle]=gcbo;

lb=get(button,'Label');
h=findobj(handle,'Tag', 'sigTOOL:MarkerValue');

switch lb
    case 'Restore Text'
        h=findobj(handle,'Tag', 'sigTOOL:MarkerValue');
        set(h,'Visible','on');
        set(button,'Label','Remove Text');
    case 'Remove Text'
        set(h,'Visible','off');
        set(button,'Label','Restore Text');
end



