function [fhandle channels]=scParam(in)
% scParam deals with parsing of sigTOOL function inputs
%
% Example:
% [fhandle channels]=scParam(in)
% where in is either a sigTOOL data view handle or a cell array of sigTOOL
% channels


fhandle=[];
channels=[];

if ishandle(in)
    fhandle=in;
    channels=getappdata(fhandle, 'channels');
elseif iscell(in)
    fhandle=[];
    channels=in;
elseif isstruct(in) || isobject(in)
    fhandle=[];
    channels={in};
end

return
end
