function [TF unused]=cursorpositions(fhandle, obj)
% cursorpositions - sigTOOL event/epoch filter function
%
% Example:
% [TF match]=cursorpositions(fhandle, obj)
%
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------


unused=[];
TF=zeros(1, size(obj.tim,1));
cursors=getappdata(fhandle, 'VerticalCursors');
if isempty(cursors) || numel(cursors)<2
    return
end

if rem(numel(cursors),2)==1
    cursors=cursors{1:end-1};
end

tu=obj.tim.Units;

for k=1:2:length(cursors)-1
    start=GetCursorLocation(fhandle, k)*(1/tu);
    stop=GetCursorLocation(fhandle, k+1)*(1/tu);
    tTF=obj.tim(:,1)>=start & obj.tim(:,end)<=stop;
    TF(tTF)=true;
end

return
end
