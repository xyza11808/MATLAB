function varargout=menu_ToggleSmoothing(varargin)
% menu_ToggleSmoothing turns line smoothing on/off
%
% Example:
% menu_ToggleSmoothing(hObj, EventData)
%       sigTOOL menu callback function
%
% See also: opengl
%
% Toolboxes required: None
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © King’s College London 2007
%--------------------------------------------------------------------------
% Acknowledgements:
% Revisions:
%       21.01.10    R2010a compatible

if nargin==1 && varargin{1}==0
    % Disable in early MATLAB versions - can make some java controls invisible
    varargout{1}=scverLessThan('MATLAB','7.1');
    varargout{2}='Smooth Lines';
    varargout{3}=[];
    return
end

% Menu callback
[button fhandle]=gcbo;
lb=get(button,'Label');
switch lb
    case {'Smooth Lines'}
        scLineSmoothing(fhandle, true);
    case {'Jagged Lines'}
        scLineSmoothing(fhandle, false);
end
return
end



