function BinnedPCAPlot(smooth_data,behavResults,session_name,frame_rate,start_frame,bin,Dimension)
%specifically used for binned pca classification of different trial types

if bin > 1 && Dimension > 0
    fprintf('Performing binned PCA analysis for input data.\n');
    BinnedData=DataBinnedFunc(smooth_data,3,3);
    BinStartFrame = ceil(start_frame/bin);
    BinFramerate = frame_rate/bin;
    if ~isdir('./Binned_PCA_Classification/')
        mkdir('./Binned_PCA_Classification/');
    end
    cd('./Binned_PCA_Classification/');
    
    PCA_2AFC_classification(BinnedData,behavResults,session_name,BinFramerate,BinStartFrame);
    cd ..;
else
    fprintf('Skipping binned PCA analysis for input data.\n');
    return;
end