function [h, w, nFrames] = tiffDimensions(fPath)
% nFrames = tiffDimensions(fPath) finds the pixel dimensions of a
% tiff file on disk without loading the entire file.

% Gracefully handle missing extension:
if exist(fPath, 'file') ~= 2
    if exist([fPath, '.tif'], 'file')
        fPath = [fPath, '.tif'];
    elseif exist([fPath, '.tiff'], 'file')
        fPath = [fPath, '.tiff'];
    else
        error(['Could not find ' fPath '.'])
    end
end

% Create Tiff object:
t = Tiff(fPath);

% Get number of directories (= frames):
t.setDirectory(1);
[h, w] = size(t.read);  

while ~t.lastDirectory
    t.nextDirectory;
end

nFrames = t.currentDirectory;

t.close;

if nargout==1
    h = [h, w, nFrames];
end