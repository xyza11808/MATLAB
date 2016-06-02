function epochs=convTime2ValidEpochs(chan, varargin)
% convTime2ValidEpochs returns valid epoch numbers within a time range
%
% Example:
% epochs=convTime2ValidEpochs(chan, start, stop)
% where
%   chan is a sigTOOL channel object
%   start & stop are the beginning and end times for the search.
% 
% Returns valid epoch numbers where
%               start <= chan.tim(:, 1) < stop 
%
% Toolboxes required: None
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King’s College London 2007
%--------------------------------------------------------------------------
% Acknowledgements:
% Revisions:

epochs=convTime2PhysicalEpochs(chan, varargin{:});
TF=ismember(epochs,getValidEpochNumbers(chan, 1, 'end'));
epochs=epochs(TF);
return
end

