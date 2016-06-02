function varargout=size(obj,varargin)
% SIZE method overloaded for tstamp objects
%
% For tstamp objects SIZE applies to the data in the OBJ.MAP.DATA.STAMPS
% property. Thus: 
% SIZE(OBJ) or SIZE(OBJ(...))
% is equivalent to
% SIZE(OBJ.MAP.DATA.Stamps) or SIZE(OBJ.MAP.DATA.STAMPS(..))
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006

[varargout{1:max(nargout,1)}] =...
    builtin('size', obj.Map.Data.Stamps, varargin{:});




