function Q=scPrepareResult(P, varargin)
% scPrepareResult builds a cell matrix for use with sigTOOLResultData objects

if nargin<=3 
    if iscell(varargin{1})
        ChannelList=varargin{1};
    else
        ChannelList={varargin{1}};
    end
    if nargin==3
        channels=varargin{2};
    end
elseif nargin==4
    ChannelList{1}=varargin{1};
    ChannelList{2}=varargin{2};
    channels=varargin{3};
else
    error('Not enough inputs');
end

Q=cell(length(ChannelList{1})+1,length(ChannelList{end})+1);
Q{1,1}='Channel';

% Triggers in column 1,
for i=2:length(ChannelList{1})+1
    Q{i,1}=num2str(ChannelList{1}(i-1));
    if nargin>=3 && ~isempty(channels{ChannelList{1}(i-1)}.hdr.adc)...
            && channels{ChannelList{1}(i-1)}.hdr.adc.Multiplex>1
        Q{i,1}=num2str(ChannelList{1}(i-1)+0.1*channels{ChannelList{1}(i-1)}.CurrentSubchannel);
    else
        Q{i,1}=num2str(ChannelList{1}(i-1));
    end
end
% Sources in row 1
for i=2:length(ChannelList{end})+1
    if nargin>=3 && ~isempty(channels{ChannelList{end}(i-1)}.hdr.adc)...
            && channels{ChannelList{end}(i-1)}.hdr.adc.Multiplex>1
        Q{1,i}=num2str(ChannelList{end}(i-1)+0.1*channels{ChannelList{end}(i-1)}.CurrentSubchannel);
    else
        Q{1,i}=num2str(ChannelList{end}(i-1));
    end
end

if iscell(P)
    % Cell array (objects/structures etc)
    for idx1=2:length(ChannelList{1})+1
        for idx2=2:length(ChannelList{end})+1
            if ~isempty(P{idx1-1,idx2-1})
                if ~isobject((P{idx1-1,idx2-1}))
                    P{idx1-1,idx2-1}=CheckFields(P{idx1-1,idx2-1});
                end
                Q{idx1,idx2}=P{idx1-1,idx2-1};
            end
        end
    end
else
    % Single object
    Q{2,2}=P;
end

return
end


function P=CheckFields(P)
% Make sure we have all needed fields whether programmer has filled them or
% not
fnames={'rdata' 'tdata' 'odata' 'rlabel' 'tlabel' 'olabel' 'details'};
for i=1:length(fnames)
    if ~isfield(P, fnames{i})
        P.(fnames{i})=[];
    end
end
return
end