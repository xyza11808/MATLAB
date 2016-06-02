function varargout=menu_EventAutoCorrelation(varargin)
% 
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_PowerSpectra(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Event Auto-Correlation';
    varargout{3}=[];
    return
end

% Main function
menu_PETH(varargin{:});
return
end


 
