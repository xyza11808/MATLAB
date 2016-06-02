function varargout=size(obj,varargin)
% size method for overloaded for the scchannel class
%
%
% Example:
% varargout=size(obj,varargin)
%   see the builtin size for details
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------

[varargout{1:max(nargout,1)}] =...
    builtin('size', obj, varargin{:});
return
end