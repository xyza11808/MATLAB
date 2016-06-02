%
%reads the raw data from a neuralynx CSC file.
%
%urut/april04
function [timestamps,dataSamples] = getRawCSCData( filename, fromInd, toInd, mode )
if nargin==3
    mode=2;
end

FieldSelection(1) = 1;%timestamps
FieldSelection(2) = 0;
FieldSelection(3) = 0;%sample freq
FieldSelection(4) = 0;
FieldSelection(5) = 1;%samples
ExtractHeader = 0;

ExtractMode = mode; % 2 = extract record index range; 4 = extract timestamps range.
ModeArray(1)=fromInd;
ModeArray(2)=toInd;

if ~exist(filename)
    error(['File not found: ' filename]);
end

if strcmp(computer,'PCWIN64') | strcmp(computer,'PCWIN')
    [timestamps, dataSamples] = Nlx2MatCSC(filename, FieldSelection, ExtractHeader, ExtractMode,ModeArray);
else
    [timestamps, dataSamples] = Nlx2MatCSC_v3(filename, FieldSelection, ExtractHeader, ExtractMode,ModeArray);
end

%flatten
dataSamples=dataSamples(:);



%controls. 
%-- Use code below to insert an artifact at the lowest level for checking of all code
%(timings)
%need to manually change in each case.

% load('/data/events/LP_063008/eventsRaw.mat');
% renvar events eventsRaw
% indsStimOn = find(eventsRaw(:,2)==1);
% tOn = eventsRaw(indsStimOn);
% 
% whichOnEvent = find(  tOn>timestamps(1) & tOn<timestamps(end) );
% 
% if length(whichOnEvent)~=1
%     error('unclear mapping');
% end
% 
% %find closest timestamp
% d= abs(timestamps-tOn(whichOnEvent));
% 
% indMin = find( d == min(d) );
% indMin=indMin(1); %in case there are several
% 
% indsToChange=512*(indMin-1):512*(indMin+30);  %about 500ms,at stim onset, double power
% dataSamples( indsToChange:end )=dataSamples( indsToChange:end )*1.2;
