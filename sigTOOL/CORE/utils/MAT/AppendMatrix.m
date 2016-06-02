function AppendMatrix(filename, varname, newdata)
% AppendMatrix appends the contents of a matrix to a variable in a MAT-file
%
% Example:
% AppendMatrix(FILENAME, VARNAME, NEWDATA)
%
% FILENAME is a string with the name of the file (which should be a v6
% MAT-file).
% VARNAME is a string with the name of the target variable.
% NEWDATA is the matrix containing the data to add to VARNAME
%
% The data in NEWDATA are added to the highest existing dimension of
% VARNAME. E.g. if VARNAME is a 100x100x21 matrix on disc and NEWNAME is
% 100x100x3, the resulting VARNAME will be 100x100x24.
%
% AppendMatrix can also add a submatrix following a call to AddDimension
% e.g.:
% x=zeros(2,2,2)
% save myfile x -v6
% AddDimension('myfile','x')% Create a 2x2x2x1 matrix in the file
% AddMatrix('myfile','x',x)% place x in x(:,:,:,2)
% load myfile x
% AddMatrix('myfile','x',x)% adds x to x(:,:,:,3:4)
%
% Restrictions: VARNAME must be the name of the final variable in FILENAME.
% NEWNAME and VARNAME must have identical dimensions below
% the highest dimension of VARNAME. The class of VARNAME on disc must be
% the same as NEWNAME (use RestoreDiscClass if need be) and both must be
% real valued.
%
% To append data to a vector, use AppendVector instead
% For 2D matrices, AppendColumns and AppendMatrix produce identical results
%
% See Also RestoreDiscClass, AppendVector, AppendColumns
%__________________________________________________________________________
%
% This program is distributed without any warranty,
% without even the implied warranty of fitness for a particular purpose.
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________


% Check var is a standard type - not structure, object etc
% Also, it must be real
if ~isnumeric(newdata) && ~islogical(newdata) && ~ischar(newdata) ||...
        issparse(newdata) || ~isreal(newdata)
    error('AppendMatrix%s is unsupported type',inputname(3));
    return
end


% Append default .mat extension if none supplied and check for problems
filename=argcheck(filename, varname);

w=where(filename, varname);
if ~isempty(w)
    % Return if variable and disc classes not the same
    if strcmp(w.DiscClass{1}, class(newdata))==0
        error('AppendMatrix: "%s" (on disc) and "%s" (in memory) must be same class',...
            varname, inputname(3));
        return
    end

    % Make sure we have the right dimensions
    s1=size(newdata);
    if length(s1)==length(w.size)
        r=(s1(1:end-1)==w.size(1:end-1));
    else
        % Equality test failed because ndims not equal
        % Maybe adding N-1 dim matrix e.g. x(:,:,:) to x(:,:,:,:)
        r=(s1(1:end)==w.size(1:end-1));
        if r(end)==0
            % Have we got a set of submatrices
            if rem(s1(end),w.size(end-1))==0
                r(end)=1;
            end
        end
    end
    % Check sizes of dimensions
    if ~any(r)
        error('AppendMatrix: "%s" and "%s" dimension mismatch',...
            varname, inputname(3));
    end

    AppendData(filename, w, newdata);
end


