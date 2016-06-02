function desc=scGetFigureType(fhandle)
% scGetFigureType returns the sigTOOL figure type from the Tag
% This is the Tag with ':' appended to the end.
%
% Example:
% string=scGetFigureType(fhandle)
%


switch get(fhandle,'Tag')
    case 'sigTOOL:DataView'
        desc='sigTOOL:DataView:';
    case 'sigTOOL:ResultView'
        desc='sigTOOL:ResultView:';
    otherwise
        desc=[];
end