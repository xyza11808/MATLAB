function TF=isSwapNeeded(obj)
% isSwapNeeded method for scchannel objects
% 
% Example
% TF=isSwapNeeded(obj)
%     returns true if data in the Map.Data.Adc need to be byte swapped
%     on the current platform, false otherwise
%
% isSwapNeeded should rarely be needed. If data are accessed through the
% scchannel/subsref or adcarray/subsref methods, byte swapping will be done
% automatically as required. Only, if you extract the memmapfile object
% (e.g. using get) will you need to know the byte order.

TF=obj.adc.Swapbytes;
return
end