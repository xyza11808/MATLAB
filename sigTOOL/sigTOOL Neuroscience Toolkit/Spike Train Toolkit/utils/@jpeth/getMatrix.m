function matrix=getMatrix(obj)
% getMatrix method for jpeth class
% 
% Example
% matrix=getMatrix(obj)
% 
% returns the JPETH matrix scaled according to the current mode (as set 
% by setMode) and filtered by the current filter (as set by setFilter).
%
% Mode is set to 'raw' by default in the jpeth constructor.
% Valid standard modes include 'raw', 'average', 'corrected', 'errors',
% 'normalized' and 'surprise'. User-defined modes may be added
% (see setMode for details).
%
% Note that the returned matrix is filtered with the contents of obj.filter
% by a call to filter2. Note that no re-scaling is done at the edges of
% matrix after filtering.
% 
% See Also filter2, jpeth setMode, setFilter
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------



switch lower(obj.mode)
    case 'average'
        % Spike count/number of trials
        matrix=getAverage(obj);
    case 'raw' 
        % Spike count
        matrix=getRaw(obj);
    case 'corrected'
        % Spike count - cross product of peths
        matrix=getCorrected(obj);
    case 'normalized'
        % Corrected matrix normalized by the sd of the cross product
        matrix=getNormalized(obj);
    case 'surprise' 
        % Palm's surprise
        matrix=getSurprise(obj);
    case ''
        error('You must set a mode in the jpeth object');
    otherwise
        % Not a recognized mode: user-defined?
        try
            md=obj.mode;
            md(1)=upper(md(1));
            mthd=['get' md];
            matrix=eval([mthd '(obj)']);
        catch %#ok<CTCH>
            error('No user-defined method "%s" to match mode "%s" for jpeth class', mthd, obj.mode);
        end
end

if ~isempty(obj.filter) && ~(isscalar(obj.filter) && obj.filter==1)
    matrix=filter2(obj.filter, matrix, 'same');
end

return
end
