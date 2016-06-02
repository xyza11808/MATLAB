function out=getCoincidence(obj, width)
% getCoincidence method for jpeth objects
% 
% Examples:
% out=getCoincidence(obj);          % when obj.filter is set
% or
% out=getCoincidence(obj, width);   % obj.filter will be ignored
% 
% getCoincidence(obj)
% returns the values from the coincidence matrix that are
% temporally aligned i.e. along the main diagional of the matrix. 
% The coincindence matrix will be filtered before taking the values if
% obj.filter is not empty (and does not contain unity). 
% 
% getCoincidence(obj, width)
% returns the average of the bins across the main diagonal i.e. those
% aligned at 90 degrees to the diagonal (=45 degrees to the horizontal).
% Width should be an odd whole number. The result will be appropriately
% scaled to account for the missing data at the corners of the matrix.
% 
% Note that the value of width will default to unity if the filter is set 
% (and a warning will be issued at the command line) since this would 
% otherwise involve averaging data that have already been averaged using the
% set filter
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------




if nargin==1
    width=1;
end

if rem(width,2)==0
    error('width must be odd');
end

if isscalar(width) && width>1 &&...
        (~isempty(obj.filter) && ~isscalar(obj.filter))
    warning('Defaulting to width=1 as non-scalar filter is being applied to matrix');
    width=1;
end

matrix=getMatrix(obj);

if width>size(obj.raw)
    error('width is too large for the result matrix');
end

% Width==1, just need the diagonal
if isscalar(width) && width==1   
    out=diag(matrix);
    return
end

if isscalar(width)
    % width is scalar and >1: sum the width/2 bins arranged at right angles to the
    % diagonal with the contents of the diagonal
    coeff=fliplr(eye(width));
    % Get the scaling coefficients: need to account for missing bins at the
    % corners
    scale=ones(1, size(matrix,1))*width;
    scale(1:floor(width/2)+1)=1:2:width;
    scale(end-floor(width/2):end)=width:-2:1;
else
    % User has provided the coefficients on input
    % Do not document this use: may be removed later
    coeff=width;
    scale=1;
end

temp=filter2(coeff, matrix, 'same');
out=diag(temp)';
% Scale
out=out./scale;

return
end