function [data npoints epochs]=extractValidEpochData(channel, varargin)
% getEpochData returns the adc data in an episodically sampled scchannel object
% 
% [data npoints epochs]=extractValidEpochData(channel, epoch)
% [data npoints epochs]=extractValidEpochData(channel, epoch1, epoch2)
% [data npoints epochs]=extractValidEpochData(channel, epoch1, step, epoch2)
% 
% If EventFilter.Mode is 'on' the specified epoch numbers will be translated
% to valid epochs for which EventFilter.Flag==true.
% Thus with EventFilter.Flags=[0 1 0 1 0 1 0 1 0 1], passing epochs 1:3
% on input would return data from the first 3 valid epochs i.e 2,4 and 6.
% 
%
% Inputs:
%         channel is a scchannel object containing episodic data
%         epoch is the required epoch (e.g. 1, 2) or range of epochs (e.g. 1:10)
%                 Note that the 'end' statement can not be used with this form
%         epoch1 and epoch2 allow the the use of the end statement but it
%                 must be included as a string e.g.
%                     getEpochData(channel, 2, 'end') returns epochs 2:end
%                     where end refers to the last valid epoch.
%         step if specified sets the increment e.g.
%                     getEpochData(channel, 2, 2, 'end') returns epochs 2:2:end
%                     where 'end' refers to the last valid epoch as above.
%                     
% Ouputs:
%         data contains the scaled adc data in double precision with each epoch 
%         represented in columns
%         npoints and epochs are optional outputs. Each is a row vector.
%          npoints gives the number of valid data points in each column
%          epochs gives the physical epoch number of the returned data.
        
epochs=getValidEpochNumbers(channel, varargin);
nd=ndims(channel.adc);
str=repmat({':'}, nd-1);
str{end+1}=epochs;

index=substruct('.', 'adc', '()', str);
data=subsref(channel, index);

if nargout>1
    index=substruct('.', 'hdr', '.', 'adc', '.', 'Npoints', '()', str);
    npoints=subsref(channel, index);
end

return
end