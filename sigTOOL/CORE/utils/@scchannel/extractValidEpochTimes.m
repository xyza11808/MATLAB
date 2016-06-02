function [times epochs]=extractValidEpochTimes(channel, varargin)
% getValidEpochTimes returns the tim data in a channel object
% 
% [data epochs]=extractValidEpochTimes(channel, epoch)
% [data epochs]=extractValidEpochTimes(channel, epoch1, epoch2)
% [data epochs]=extractValidEpochTimes(channel, epoch1, step, epoch2)
% 
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------      
epochs=getValidEpochNumbers(channel, varargin);
str={epochs ':'};
index=substruct('.', 'tim', '()', str);
times=subsref(channel, index);
return
end