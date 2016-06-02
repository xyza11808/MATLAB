function channels=UpdateChannelTree(fhandle, target, source)

[fhandle channels]=scParam(fhandle);

channels{target}.hdr.Group.Number=channels{source}.hdr.Group.Number;
channels{target}.hdr.Group.Label=channels{source}.hdr.Group.Label;
channels{target}.hdr.Group.DateNum=datestr(now());

for k=1:numel(channels)
    if ~isempty(channels{k})
        if channels{k}.hdr.Group.SourceChannel==target
            channels{k}.hdr.Group.SourceChannel=0;
        end
    end
end

channels{target}.hdr.Group.SourceChannel=source;

for k=1:numel(channels)
    for n=1:numel(channels)
        if ~isempty(channels{k}) && ~isempty(channels{n})
            if channels{k}.hdr.Group.SourceChannel==n
                t=datenum(channels{k}.hdr.Group.DateNum)-datenum(channels{n}.hdr.Group.DateNum);
                if t<=0
                    error('Error %d\t%d\t%g\n', k, n, 60*60*24*t);
                end
            end
        end
    end
end


if ~isempty(fhandle)
    setappdata(fhandle, 'channels', channels);
end
return
end
