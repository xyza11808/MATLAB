tifDataPath = '20211014-sfo-group3-8#_3_MMStack_Default.ome.tif';

tifDataInfos = imfinfo(tifDataPath);
NumFrames = length(tifDataInfos);
%%
FrameRows = tifDataInfos(1).Height;
FrameCols = tifDataInfos(1).Width;

NumframeForROIs = 20;
ROIframeDatas = zeros(FrameRows,FrameCols,NumframeForROIs);
for cf = 1 : NumframeForROIs
    ROIframeDatas(:,:,cf) = imread(tifDataPath,cf);
end
FrameAvgs = squeeze(mean(double(ROIframeDatas),3));

%%
hf = figure;
imagesc(FrameAvgs);
colormap gray

%% plot ROIs
ROINum = 0;
ROIpos = {};
ROIMask = {};
IsAddROI = 1;
figure(hf);

while IsAddROI
    hh = drawfreehand;
    IsROIconfirm = questdlg('Are you confirm about current drawing','IsROIConfirm','Yes','No','Cancel','Yes');
    switch IsROIconfirm
        case 'Yes'
            ROINum = ROINum + 1;
            ROIpos{ROINum} = hh.Position;
            ROIMask{ROINum} = createMask(hh);
            line(gca,hh.Position(:,1),hh.Position(:,2),'Color','r','linewidth',1.2);
            ROIcent = mean(hh.Position);
            text(gca,ROIcent(1),ROIcent(2),num2str(ROINum,'%d'),'Color','c','FontSize',14);
            delete(hh);
        case 'No'
            delete(hh);
        case 'Cancel'
            delete(hh);
    end
        
    IsMoreROINeeded = questdlg('Do you want to add another ROI?','Add New ROI?','Yes','No','Cancel','Yes');
    switch IsMoreROINeeded
        case 'Yes'
            IsAddROI = 1;
        case 'No'
            IsAddROI = 0;
        case 'Cancel'
            IsAddROI = 0;
        otherwise
            IsAddROI = 0;
    end
end
    
%% read ROI datas
t1 = tic;
ROIDatas = zeros(ROINum,NumFrames);
for cf = 1 : NumFrames
    cfData = imread(tifDataPath,cf,'Info',tifDataInfos);
    for cR = 1 : ROINum
        cRMask = ROIMask{cR};
        ROIDatas(cR,cf) = mean(cfData(cRMask));
    end
    
end
t1_time= toc(t1);
%% Use the new tif stack method to load tif files, try with fast ways before error
tsStack = TIFFStack(tifDataPath);
%%
t2 = tic;
ROIDatas = zeros(ROINum,NumFrames);

for cf = 1 : NumFrames
   cfData = squeeze(tsStack(:,:,cf));
    for cR = 1 : ROINum
        cRMask = ROIMask{cR};
        ROIDatas(cR,cf) = mean(cfData(cRMask));
    end
end
t2Time = toc(t2);


