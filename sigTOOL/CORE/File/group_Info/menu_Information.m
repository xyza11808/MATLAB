function varargout=menu_Information(varargin)
%
% Toolboxes required: None
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 10/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
% Acknowledgements:
% Revisions:


% Called as menu_Information(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='File Information';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;

channels=getappdata(fhandle, 'channels');

j=0;
buf=cell(length(channels),10);
for i=1:length(channels)
    if isempty(channels{i})
        continue
    end
    j=j+1;
    buf{j,1}=num2str(i);
    buf{j,2}=channels{i}.hdr.title;
    buf{j,3}=channels{i}.hdr.channeltype;
    buf{j,4}=getSampleRate(channels{i});
    if isfield(channels{i}.hdr, 'comment')
       buf{j,5}=channels{i}.hdr.comment;
    else
       buf{j,5}=''; 
    end
    buf{j,6}=strrep(mat2str(size(channels{i}.adc)),' ','x');
    try
        buf{j,7}=channels{i}.adc.Map.Format{1};
    catch
        buf{j,7}='';
    end
    buf{j,8}=strrep(mat2str(size(channels{i}.tim)),' ','x');
    try
        buf{j,9}=channels{i}.tim.Map.Format{1};
    catch
        buf{j,9}='';
    end
    buf{j,10}=channels{i}.tim.Units;
    buf{j,11}=strrep(mat2str(size(channels{i}.mrk)),' ','x');
    buf{j,12}=channels{i}.EventFilter.Mode;
    try
        n=channels{i}.hdr.adc.Multiplex;
    catch %#ok<CTCH>
        n=1;
    end
    if n>1
        buf{j,13}=num2str(n);
    else
        buf{j,13}='';
    end
    if isfield(channels{i}.hdr, 'Group')
        buf{j,14}=datestr(channels{i}.hdr.Group.DateNum);
    else
        buf{j,14}='';
    end
end


warning('off', 'MATLAB:uitable:OldTableUsage')

tf=figure('Units', 'normalized',...
    'Position', [0.4 0.4 0.4 0.4],...
    'menubar','none',...
    'ResizeFcn', @ResizeTable,...
    'Name', ['File Info: ', get(fhandle, 'Name')]);
tb=uitable(tf, buf, {'Channel', 'Title', 'Type', 'Sample Rate (Hz)', 'Comment', 'ADC dim', 'Disc Format'...
    'Timestamp dim', 'Disc Format', 'Resolution(s)','Marker dim', 'Event Filtering', 'Subchannels', 'Created'});
set(tf, 'Units', 'pixels');
pos=get(tf,'Position');
set(tb, 'Position', [0 0 pos(3) pos(4)]);
set(tf, 'UserData', tb);

warning('on', 'MATLAB:uitable:OldTableUsage');
end


function ResizeTable(tf, EventData)
tb=get(tf,'UserData');
pos=get(tf,'Position');
set(tb, 'Position', [0 0 pos(3) pos(4)]);
return
end
