function channels=scApplyEventFilter(fhandle, chan, mode)
% scApplyEventFilter applies event filtering to a sigTOOL channel
% 
% channels=scApplyEventFilter(fhandle, chan, mode)
% channels=scApplyEventFilter(channels, chan, mode)
% 
% where    channels is a sigTOOL channel cell array
%          chan is the channel number (or list)
%          mode is a string - the name of the function to apply to the
%                             channel(s)
% 
% Standard functions for mode are:
%             oddepochs         select epochs 1:2:end
%             evenepochs        select epochs 2:2:end
%             everynthepoch     select epochs e.g. 5:3:end
%             matchany          select epochs where any marker value
%                               matches those in a list
%             matchall          select epochs where all marker values
%                               match those in a list
% If mode is empty, event filtering will be turned off for selected
% channels
%
% Note that scApplyEventFilter writes the sigTOOL history output where
% appropriate.
%
% Writing custom filter functions:
% Filter functions take the form
% [TF match]=functionname(channel, match)
% where     channel is an scchannel object
%           match, if present, are the values to match (e.g. as in
%           matchany)
% TF is the output to place in the channel.EventFilter.Flags field and is a
% logical vector with one value for each event/epoch in channel
%
% Functions must return match, even if it is unused (return it empty).
%
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------


[fhandle channels]=scParam(fhandle);

% Do the work
for k=1:length(chan)
    if ~isempty(mode)
        % Activate and set filters
        channels{chan}.EventFilter.Mode='on';
        fcn=str2func(mode);
        switch mode
            case 'cursoreventfilter'
                [channels{chan}.EventFilter.Flags match]=fcn(fhandle, channels{chan});
            otherwise
                [channels{chan}.EventFilter.Flags match]=fcn(channels{chan});
        end
    else
        % Turn filters off
        channels{chan}.EventFilter.Mode='off';
        channels{chan}.EventFilter.Flags=[];
    end
end

% Update figure
if ishandle(fhandle)
    setappdata(fhandle, 'channels', channels);
    % Delete text
    h=findobj(fhandle,'Type', 'hggroup', 'Tag', 'sigTOOL:MarkerValue');
    delete(h);
    % Refresh view
    scDataViewDrawData(fhandle);
end

% Write History
switch mode
    case {'matchall' 'matchany'}
        arglist={fhandle,...
            chan,...
            mode,...
            match};        
    otherwise
        arglist={fhandle,...
            chan,...
            mode};
end
scExecute(@scApplyEventFilter, arglist, false, true);
return
end











