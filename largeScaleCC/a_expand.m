function l = a_expand(w, ig)
%
% optimize CC using ab expand
%
% Usage:
%   l = a_expand(w, [ig])
%
% Inputs:
%   w - sparse, symmetric affinity matrix containng BOTH positive and
%       negative entries (attraction and repultion).
%   ig- initial guess labeling (optional)
%
% Output:
%   l - labeling of the nodes into different clusters.
%


% make sure diagonal is zero
n = size(w,1);
w = w - spdiags( spdiags(w, 0), 0, n, n);

if nargin==2
    [NL, ~, l] = unique(ig);
    NL = numel(NL);
else
    l = ones(n,1);
    NL = 1;
end

cE = CCEnergy(w,l);

while 1
    accepted = false;
    
    li = 0;
    
    while li <= NL % labels can be added in the iteration...
        li = li+1;

        nl = BinaryExpand(w, l, li);
        
        nE = CCEnergy(w, nl);
        
        if nE < cE
            % accept move
            cE = nE;
            l = nl;
            accepted = true;
            NL = max(nl(:));

        end
    end
   
    % stop loop if no changes were made
    if ~accepted
        break;
    end
    % remove "empty" labels
    [NL, ~, l] = unique(l);
    NL = numel(NL);
end

% [gt w] = MakeSynthAff(100, [1 3 5 2], 10, .5, .1); % creates a synthetic sparse affinity matrix
% plotWl(w,gt);     % plot the matrix ordered according to the ground-truth labeling
% %%
% el = a_expand(w); % CC optimization using expand&explore
% plotWl(w,el);     % visualize the result
% sl = ab_swap(w);  % CC optimization using swap&explore
% plotWl(w,sl);     % visualize the result
% il = AL_ICM(w);   % CC optimization using adaptive-label ICM
% plotWl(w,il);     % visualize the result
% [CCEnergy(w,gt) CCEnergy(w,el) CCEnergy(w,sl) CCEnergy(w,il)], % output CC objective values for the different partitions.


