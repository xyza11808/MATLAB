function [surprise excite inhib]=getSurprise(obj)
% getSurprise method for jpeth class
%
% Examples:
% surprise=getSurprise(obj)
% [surprise excite inhib]=getSurprise(obj)
%
% Returns the "surprise" matrix for the jpeth object as defined in Palm et
% al. 1988:
%           surprise=excite-inhib
% where
%           excite=-ln(prob(z>=M given K and L)) and
%           inhib=-ln(prob(z<=M given K and L)
% M is number of coincidences in the jpeth raw matrix and K and L are the
% corresponding number of spikes in peth1 and peth2 of the jpeth object
% (reversed if K>L). Corrections are included for Palm's Type 1 and 2
% errors following his original FORTRAN code.
% 
% Algorithm:
% The probabilities of z==M are estimated following Eqn. 7 of Palm et
% al. 1988 but natural logs are used throughout to minimize problems due
% to IEEE precision and to enhance speed: 
%           ln(x!) is estimated as gammaln(x+1) 
%           ln(choosek(n,k)) as gammaln(n+1)-(gammaln(n-k+1)+gammaln(k+1));
%               (see Press et al. 1992)
% Eqn 7 is then evaluated by log addition/subtraction before finally taking
% the exponent to return probabilities. This avoids intermediate results
% beyond the 15 significant digits of IEEE 64-bit floating point
% arithmetic
%
% References
% Palm et al. (1988) On the significance of correlations among neural spike
% trains Biological Cybernetics 59, 1-11.
% Press et al. (1992) Numerical Recipes in C.
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


% Get data
nsweeps=obj.nsweeps;
peth1=obj.peth1;
peth2=obj.peth2;
raw=getRaw(obj);
% Check them - we should have all floating point rep of integers
if any(rem(peth1,1)) || any(rem(peth2,1)) || any(any(rem(raw,1)))
    error('Expected flints');
end

% Initialize outputs
surprise=zeros(size(raw));
if nargout>1
    excite=zeros(size(raw));
end
if nargout>2
    inhib=zeros(size(raw));
end

% Do the sums
for i = 1:length(peth1)
    for j = 1:length(peth2)
        
        % K, L, M, and N as defined in Palm et al. (1988)
        K = peth1(i);
        L = peth2(j);
        M = raw(i,j);
        N = nsweeps;
        
        if (N<max([K L]))
            % Palm's type 1 error
            N=max([K L]);
        end
        
        if (M>min([K L]))
            % Palm's type 2 error
            M=min([K L]);
        end
        
        if (K>L)
            % Force K<=L by swapping
            K=peth2(j);
            L=peth1(i);
        end
        
        % Get vector of prob(z==m) for m=0:M given K, L
        a=nchoosekln(L,0:M);
        b=nchoosekln(N-L,K-(0:M));
        c=nchoosekln(N,K);
        p=exp(a+b-c);
        
               
        % prob(z>=M)
        X=1-sum(p(1:end-1));
        % prob(z<=M)
        Y=sum(p);
        
        % Set X to minimum of eps
        X=max([eps X]);
        % Force Y to 1 or less (rounding errors may create Y>1)
        Y=min([1 Y]);
        
        % Log
        LNX=-log(X);
        LNY=-log(Y);
        
        surprise(i,j)=LNX-LNY;
        
        if nargout>1
            excite(i,j)=LNX;
        end
        
        if nargout>2
            inhib(i,j)=LNY;
        end
        
    end
end
return

% Local function
    function c=nchoosekln(n,v)
        % nchoosekln returns the natural log of n!/v!(n-v)! for each value in v
        % Example:
        % c=nchoosekln(n,v)
        % where n is a scalar whole number >=0
        % and v is a scalar or vector of whole numbers >=0
        
%         %-----------------------------------------------------------------
%         % Input checks
%         % These can be commented out if the inputs are guaranteed to pass
%         if ~isscalar(n)
%             % n must be scalar
%             error('n must be a scalar');
%         end
%         
%         temp=[n v(:)'];
%              
%         if any(temp<0) && any(rem(temp,1))==1
%             % Fractional parts
%             error(' n and v must contain whole numbers >=0');
%         end
%         %------------------------------------------------------------------
        
        % Return the result
        c=gammaln(n+1)-(gammaln(n-v+1)+gammaln(v+1));
        return
    end

end



