function [x tb]=getXcorr(obj)
% getXcorr method for jpeth class returns the cross-correlation
% 
% Example:
% x=xcorr(obj);
% [x tb]=xcorr(obj);
% 
% returns the cross-correlation formed by averaging along
% the anti-diagonals of the jpeth matrix calculated according to the
% current mode. If requested, the timebase for the correlation will also
% be returned. 
%
% -------------------------------------------------------------------------
% Note that no filter is applied to the matrix before calculating the
% cross-corelation
% -------------------------------------------------------------------------
%
% See also setMode
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


% Get matrix - do not apply filter
obj.filter=[];
matrix=flipud(getMatrix(obj));

n=length(matrix);
x=zeros(1,2*(n-1)+1);

% xcorr
for k=-n+1:n-1
   d=diag(matrix,k);
   x(k+n)=sum(d)/length(d) ;
end

% timebase
if nargout==2
    b=getBinWidth(obj);
    tb=-(n-1)*b:b:(n-1)*b;
end

return
end
