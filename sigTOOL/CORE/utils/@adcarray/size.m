function varargout=size(obj,varargin)
% SIZE method overloaded for adcarray objects
%
% For adcarray objects SIZE applies to the data in the OBJ.MAP.DATA.ADC
% property. Thus: 
% SIZE(OBJ) or SIZE(OBJ(...))
% is equivalent to
% SIZE(OBJ.MAP.DATA.ADC) or SIZE(OBJ.MAP.DATA.ADC(..))
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006

[varargout{1:max(nargout,1)}] =...
    builtin('size', obj.Map.Data.Adc, varargin{:});




