% analysis and load all tif files
% F:\20200806_xsn\20200806_field01_zoom2.2_d210_sess02-002\Aligned_datas
cclr
[fn,fp,fi] = uigetfile('*.xml','Please select the xml file within tif file folder');
if ~fi
    return;
end
cd(fp);
%
cDoc = xmlread(fullfile(fp,fn));
cc = parseChildNodes(cDoc);
ccChildrens = cc.Children;

SeqIndex = find(arrayfun(@(x) strcmpi(x.Name,'Sequence'),ccChildrens));
UsedStrc = ccChildrens(SeqIndex).Children;
FrameIndex = find(arrayfun(@(x) strcmpi(x.Name,'Frame'),UsedStrc));
IsCalRef = 1;

% %% or load existed ref images from another session for alignment
% [ffn,ffp,ffi] = uigetfile('TargetIm.mat','Please select same FOV ref data');
% if fi
%     load(fullfile(ffp,ffn));
% else
%     return;
% end
% save TargetIm.mat RefImage -v7.3
% IsCalRef = 0;
% %%

nFrames = length(FrameIndex);
IndexAndFileAll = cell(nFrames*2,4);
for cf = 1 : nFrames
    cfStrcIndex = FrameIndex(cf);
    cfIndexInds = arrayfun(@(x) strcmpi(x.Name,'index'),UsedStrc(cfStrcIndex).Attributes);
    cfIndex = str2num(UsedStrc(cfStrcIndex).Attributes(cfIndexInds).Value);
    AbsoluteTimeIndex = arrayfun(@(x) strcmpi(x.Name,'absoluteTime'),UsedStrc(cfStrcIndex).Attributes);
    AbsoluteTime = str2num(UsedStrc(cfStrcIndex).Attributes(AbsoluteTimeIndex).Value);
    
    cfFileAndChannel = FileNameExtraction(UsedStrc(cfStrcIndex).Children);
    cStartInds = (cf-1)*2+1;
    
    IndexAndFileAll{cStartInds,1} = cfIndex;
    IndexAndFileAll{cStartInds+1,1} = cfIndex;
    
    IndexAndFileAll(cStartInds:(cStartInds+1),2:3) = cfFileAndChannel;
    IndexAndFileAll{cStartInds,4} = AbsoluteTime;
    IndexAndFileAll{cStartInds+1,4} = AbsoluteTime;
end

clearvars ccChildrens

%% load all tif files
warning off
Testfilename = IndexAndFileAll{1,3};
cTif = Tiff(Testfilename,'r');
Tif_height = getTag(cTif,'ImageLength');
Tif_width = getTag(cTif,'ImageWidth');
%
TifStrc = struct();
% TifTags = cTif.getTagNames();
TagFields = {'ImageLength',...
    'ImageWidth',...
    'Photometric',...
    'BitsPerSample',...
    'SamplesPerPixel',...
    'RowsPerStrip',...
    'PlanarConfiguration',...
    'Software',...
    'SampleFormat',...
    'Compression',...
    'SubFileType',...
    'ImageDescription',...
    'Orientation'};%,...
%     '',...
%     '',...
%     '',...
%     '',...
%     '',...
nTagNum = length(TagFields);

for cTag = 1 : nTagNum
    TifStrc.(TagFields{cTag}) = getTag(cTif,TagFields{cTag});
end
 %
    
% AllTifDatas.Ch1_data = zeros(Tif_height,Tif_width,nFrames);
AllTifDatas.Ch2_data = zeros(Tif_height,Tif_width,nFrames);
% ch1_filesIndsAll = find(strcmpi('Ch1',IndexAndFileAll(:,2)));
ch2_filesIndsAll = find(strcmpi('Ch2',IndexAndFileAll(:,2)));

for cf = 1 : nFrames
%     cCh1_data = double(read(Tiff(IndexAndFileAll{ch1_filesIndsAll(cf),3})));
%     AllTifDatas.Ch1_data(:,:,cf) = cCh1_data;
    
    cCh2_data = double(read(Tiff(IndexAndFileAll{ch2_filesIndsAll(cf),3})));
    AllTifDatas.Ch2_data(:,:,cf) = cCh2_data;
end

% % warning on

%% align tif files 
% if IsCalRef
    RefAvgIndexScale = [100, 200];
    RefImage = squeeze(mean(AllTifDatas.Ch2_data(:,:,RefAvgIndexScale(1):RefAvgIndexScale(2)),3));
    figure('position',[2000 100 450 380]);
    imagesc(RefImage,[100 800]);
    colormap gray
    save TargetIm.mat RefImage -v7.3
% end
%% or load from another session

% [Ch1_alignedData,ch1_shift] = dft_reg(AllTifDatas.Ch1_data,RefImage);
[Ch2_alignedData,ch2_shift] = dft_reg(AllTifDatas.Ch2_data,RefImage);
% padding = [0 0 0 0];
% Ch2_alignedData = ImageTranslation_nx(AllTifDatas.Ch2_data,ch1_shift,padding,0);

%% save aligned data
if ~isdir('./Aligned_datas/')
    mkdir('./Aligned_datas/');
end
cd('./Aligned_datas/');
save ShiftData.mat ch2_shift -v7.3
fileSize = 1000;
SubfileNum = ceil(nFrames/fileSize);
k = 1;
% Ch1_savefileName = 'Ch1_aligned_datasave_file%d.tif';
Ch2_savefileName = 'Ch2_aligned_datasave_file%d.tif';
for cf = 1 : nFrames
    if mod(cf,fileSize) == 1
        cSubfNum = floor(cf/fileSize) + 1;
%         t1 = Tiff(sprintf(Ch1_savefileName,cSubfNum),'w');
        t2 = Tiff(sprintf(Ch2_savefileName,cSubfNum),'w');
    else
%         t1 = Tiff(sprintf(Ch1_savefileName,cSubfNum),'a');
        t2 = Tiff(sprintf(Ch2_savefileName,cSubfNum),'a');
    end
%     t1.setTag(TifStrc);
    t2.setTag(TifStrc);
    
%     t1.write(squeeze(uint16(Ch1_alignedData(:,:,cf)))); 
    t2.write(squeeze(uint16(Ch2_alignedData(:,:,cf))));
    
%     t1.close();
    t2.close();
end
figure;plot(ch2_shift')
