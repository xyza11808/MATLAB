
fileName = 'Mylarge.tif'; % Determine the number of image frames and the offset to the first image 
ImDataInfo = imfinfo(fileName);

%%
numFramesStr = regexp(ImDataInfo.ImageDescription, 'images=(\d*)', 'tokens');
numFrames = str2double(numFramesStr{1}{1});
% Use low-level File I/O to read the file
fp = fopen(fileName , 'rb');
% The StripOffsets field provides the offset to the first strip. Based on
% the INFO for this file, each image consists of 1 strip.
fseek(fp, ImDataInfo.StripOffsets, 'bof');
% Assume that the image is 16-bit per pixel and is stored in big-endian format.
% Also assume that the images are stored one after the other.
% For instance, read the first 100 frames
framenum=100; %numFrames
imData=cell(1,framenum);
for cnt = 1:framenum
    imData{cnt} = fread(fp, [ImDataInfo.Width ImDataInfo.Height], 'uint16', 0, 'ieee-be')';
end
fclose(fp);
