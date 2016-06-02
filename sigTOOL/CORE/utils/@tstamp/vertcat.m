function out=vertcat(varargin)
% VERTCAT method overloaded for tstamp objects
%
% Example:
% C = vertcat(A1, A2, ...)
% returns a double precision array C.
% Called when A1, A2 etc includes an tstamp object
% 
% See also VERTCAT, TSTAMP/HORZCAT
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006


index(1).type='()';
index(1).subs={};
out=builtin('vertcat',subsref(varargin{1},index),subsref(varargin{2},index));
if nargin>2
    for i=3:nargin
        out=builtin('vertcat',out,subsref(varargin{i},index));
    end;
end;
