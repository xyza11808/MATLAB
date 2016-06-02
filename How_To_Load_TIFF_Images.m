% Regular old Matlab code
FileTif='ImageStack.tif';
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width
nImage=InfoImage(1).Height
NumberImages=length(InfoImage)
  
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
for i=1:NumberImages
   FinalImage(:,:,i)=imread(FileTif,'Index',i);
end

% Old Code
FileTif='ImageStack.tif';
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
  
for i=1:NumberImages
   FinalImage(:,:,i)=imread(FileTif,'Index',i,'Info',InfoImage);
end

%%
% New Code
FileTif='b15a04_test01_3x_160um_2afc_001.tif';
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
 
TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   FinalImage(:,:,i)=TifLink.read();
end
TifLink.close();

%%
% Optimized Code
FileTif='b15a04_test01_3x_160um_2afc_001.tif';
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
FileID = tifflib('open',FileTif,'r');
rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);
 
for i=1:NumberImages
   tifflib('setDirectory',FileID,i);
   % Go through each strip of data.
   rps = min(rps,nImage);
   for r = 1:rps:nImage
      row_inds = r:min(nImage,r+rps-1);
      stripNum = tifflib('computeStrip',FileID,r);
      FinalImage(row_inds,:,i) = tifflib('readEncodedStrip',FileID,stripNum);
   end
end
tifflib('close',FileID);

