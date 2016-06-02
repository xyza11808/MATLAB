function errm=scCheckChannels(varargin)
% scCheckChannels checks for unexpected conditions in sigTOOL data
%
% Examples:
% errm=scCheckChannels(fhandle)
% errm=scCheckChannels(channels);
%
% ERRORS
% "The units field for the timestamps is not equal for all channels"
%     Although sigTOOL channels are independent of one another, many sigTOOL
%     functions assume that the tim.Units field will be equal for all channels.
%     If they are not, there is a risk of getting erroneous results
%     
%
% WARNINGS
% "The number of points in Npoints does not correspond with tim"
%      The number of points indicated in the channel header for one or more
%      epochs, on one or more channels, does not match with the timestamp
%      data for the channel. 
 



errm='';

[fhandle channels]=scParam(varargin{1});
if isempty(channels)
    return
end


% Units field for tim
n=findFirstChannel(channels{:});
Units=channels{n}.tim.Units;
for k=n:length(channels)
    if isempty(channels{k})
        continue
    end
    if channels{k}.tim.Units~=Units
        str='ERROR: The units field for the timestamps is not equal for all channels';
        errm=sprintf('%s\n',str);
        break
    end
end


% Npoints
str='';
for k=n:length(channels)
    if isempty(channels{k}) || isempty(channels{k}.hdr.adc)
        continue
    end
    si=getSampleInterval(channels{k});
    if isnan(si)
        continue
    end
    n1=round((channels{k}.tim(:, end)-channels{k}.tim(:, 1))*channels{k}.tim.Units...
        /si+1)*channels{k}.hdr.adc.Multiplex;
    n2=channels{k}.hdr.adc.Npoints';
    err=find((n1~=n2)==1);
    for m=1:length(err)
        ep=err(m);
        str='WARNING: The number of points in Npoints does not correspond with tim';
        fprintf('Channel %d: Epoch %d of %d Expected=%d Npoints=%d\n', k, ep, size(channels{ep}.tim,1), n1(ep), n2(ep));
    end
end


if ~isempty(str)
    errm=sprintf('%s\n',str);
end




return
end