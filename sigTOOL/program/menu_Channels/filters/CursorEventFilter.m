function [TF unused]=CursorEventFilter(fhandle, obj)
% CursorEventFilter - sigTOOL event/epoch filter function
%
% Example:
% [TF match]=CursorEventFilter(fhandle, obj)
%
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------


% Pre-allocate
unused=[];
TF=zeros(1, size(obj.tim,1));

% Get the cursors
cursors=getappdata(fhandle, 'VerticalCursors');
if isempty(cursors) || numel(cursors)<2
    return
end

% Ignore any trailing unpaired cursor
if rem(numel(cursors),2)==1
    cursors=cursors{1:end-1};
end

% Scale factor to convert to seconds
tu=obj.tim.Units;

for k=1:2:length(cursors)-1
    % For each cursor pair
    start=GetCursorLocation(fhandle, k)*(1/tu);
    stop=GetCursorLocation(fhandle, k+1)*(1/tu);
    if isempty(start) || isempty(stop)
        % Skip if missing or incomplete pair
        continue
    end
    % Set flags
    tTF=obj.tim(:,1)>=start & obj.tim(:,end)<=stop;
    TF(tTF)=true;
end

return
end
