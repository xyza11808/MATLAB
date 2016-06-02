%This sample code is to demonstrate sample usage of the abf file loader.
%any questions or comments email bigryan@users.sourceforge.net
%it is provided free for anyone to use and modify as they see fit

%in order for this to work you will need a sample abf file.
abfFileName = 'test.abf';

[data,metadata] = abf2load(abfFileName);

%% 
%below I'm just going to show some ways you can access the data
% you will need to rewrite this to suite your needs.

numChannels = size(data,2);
frequency = metadata.fADCSequenceInterval;
samplerateHz = 1/(frequency/1000000);
comments = cell2mat(metadata.sFileComment);
fprintf('Sample rate %f\nComments -- %s\n',samplerateHz, comments );

for i=1:numChannels
    subplot(numChannels,1,i);
    plot(data(:,i))
    title(metadata.sADCChannelName(i))
end