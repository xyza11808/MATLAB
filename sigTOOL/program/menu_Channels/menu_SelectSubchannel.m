function varargout=menu_SelectSubchannel(varargin)

%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Select subchannel';
    varargout{3}=[];
    return
end


% Marker function
[button fhandle]=gcbo;

% Implement directly - no apply to all allowed
scSelectSubchannel(fhandle);

% Write only to history
arglist={fhandle,...
    scGetSubchannelList(fhandle)};
scExecute(@scSetSubchannelList, arglist, false, true);
return
end