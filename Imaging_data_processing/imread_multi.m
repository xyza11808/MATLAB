function [im, header] = imread_multi(filename, varargin)
% Input: filename - scanimage tiff file name.
%        channel - 'g' or 'green', 'r' or 'red'
%        varargin{1}, parseHeader_flag
% Output: im - uint16 image matrix
%         header - scanimage header info.
%
% NX 3/11/2009

finfo = imfinfo(filename); 
if nargin > 1
    channel = varargin{1};
else
    channel = [];
end
if nargin > 2
    parseHeader_flag = varargin{2};
else
    parseHeader_flag = 1;
end
if isfield(finfo, 'ImageDescription') && parseHeader_flag == 1
    header = parseHeader(finfo(1).ImageDescription);
    if isfield(header.acq, 'saveDuringAcquisition') && header.acq.saveDuringAcquisition == 0
        n_channel = header.acq.numberOfChannelsSave;
    else
        n_channel = header.acq.numberOfChannelsAcquire;
    end
%     header.width = header.acq.pixelsPerLine;
%     header.height = header.acq.linesPerFrame;
    header.n_frame = header.acq.numberOfFrames;
else
    n_channel = 1;
    header.n_frame = length(finfo);
end

header.width = finfo(1).Width;
header.height = finfo(1).Height;
if n_channel > 1 && ~isempty(channel)
    if strncmpi(channel, 'g', 1)
        firstframe = 1;
        step = n_channel;
    elseif strncmpi(channel, 'r', 1)
        firstframe = 2;
        step = n_channel;
    else
        error('unknown channel name?')
        
    end
else
    firstframe = 1;
    step = 1;
end

im = zeros(finfo(1).Height, finfo(1).Width, length(finfo)/step, 'uint16');

count = 0;
for i = firstframe : step : length(finfo)
    count = count+1;
    im (:,:,count) = imread(filename, i);
end;