function varargout=menu_DataViewHiRes(varargin)
%
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 07/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_RefreshChartDisplay(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Refresh Hi Res';
    varargout{3}=sprintf(...
        'Author: Malcolm Lidierth\n© 2006 King’s College London');
    return
end

[button fhandle]=gcbo;

try
    % Draw without pre-rendering
    scDataViewDrawData(fhandle, false);
catch
    % If this fails reload the file
    % This is most likely to occur if there is an out-of-memory error
    % drawing very large volumes of data
    h=findobj(fhandle,'Style','axes');
    h=findobj(h,'Style','line');
    delete(h);
    scDataViewDrawData(fhandle, true);
    disp('menu_DataViewHiRes: Attempting to recover from the following error:');
    rethrow(lasterror());
end


