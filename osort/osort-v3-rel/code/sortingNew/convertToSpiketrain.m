%
%converts array of timestamps to spiketrain, with 1ms binsize
%
%binsize: in ms
%
%
function n = convertToSpiketrain(timestamps, binsize)
if nargin<2
    binsize=1;
end

spiketrain=(timestamps/1000);  %now in ms
spiketrain=spiketrain-spiketrain(1); %offset gone
roundedSpiketrain = round(spiketrain);

if binsize==1
    n=zeros(1,roundedSpiketrain(end));
    n( roundedSpiketrain(find(roundedSpiketrain>0)) )=1; 
else
   n = histc( roundedSpiketrain, [0:binsize:roundedSpiketrain(end)] );
end
