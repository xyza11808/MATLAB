function fcn=plotoptions(obj) %#ok<INUSD>
% plotoptions method for jpeth object
%
% fcn=plotoptions(obj)
% returns the handle to a function that will be called when the plot
% options button is selected in a sigTOOL result view.
%
% Alternatively,
% c=plotoptions(obj)
% returns a cell array with the handle in the first element and optional
% arguments in subsequent elements
%
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 10/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

% NB Presently only used for illustration

fcn=[];
%fcn=@LocalCallBack;
return
end


function LocalCallBack(hObject, EventData) %#ok<INUSD>
return
end