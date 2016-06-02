%
%designs the bandpass filter used for spike detection/extraction
%
%the pass band is 300-3000
%default sampling freq is 25kHz unless the handles.samplingFreq variable is set.
%
%This file can either accept parameters with in the handles array (for GUI
%purposes) or with separate list of arguments
%
%urut
function [handles, Fs, HdNew] = initFilter(handles, rawFileVersion, Fs, passband)
if nargin<2
    rawFileVersion = 1;
end
if nargin<3
    Fs = 25000; %default Fs
end
if nargin<4
    passband=[300 3000];
end

if ~isempty(handles)
    if isfield(handles,'samplingFreq')
        Fs = handles.samplingFreq;
    end
    if isfield(handles,'rawFileVersion')
        rawFileVersion = handles.rawFileVersion;
    end
end

%1 and 2 are neuralynx specific formats
if rawFileVersion==2
    %digital cheetah
   load('contFilt32556_1');
    HdNew=[];
    b = HdFilt3.Numerator;
    a = HdFilt3.Denominator;
    HdNew{1} = b;
    HdNew{2} = a;
    handles.Hd = HdNew;
else
    %analog cheetah and txt file -> normal filter.
    n = 4;
    Wn = passband/(Fs/2);
    [b,a] = butter(n,Wn);
    HdNew=[];
    HdNew{1}=b;
    HdNew{2}=a;
    handles.Hd=HdNew;
end

