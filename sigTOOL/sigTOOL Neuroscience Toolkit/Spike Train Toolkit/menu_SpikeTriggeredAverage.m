function varargout=menu_STA(varargin)
% menu_STA: gateway to the wvAverage function for spike-triggered aveaging
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
    varargout{2}='Spike-Triggered Average';
    varargout{3}=[];
    return
end

% Main function
menu_Average(varargin{:});
return
end


 
