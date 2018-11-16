function [F,RingF] = ROIDataExtractionFun(ROImask,ROIringMask,im,varargin)
    nFrames = size(im,3);
    mask = repmat(ROImask, [1 1 nFrames]); % reproduce masks for every frame
    % Using indexing and reshape function to increase speed
    nPix = sum(sum(ROImask));
    % Using reshape to partition into different trials.
    roi_img = reshape(im(mask), nPix, []);
    % Raw intensity averaged from pixels of the ROI in each trial.
    if nPix == 0
        F = zeros(nFrames,1);
    else
        F = mean(roi_img);
    end
    %neurual puil extraction
    Ringmask = repmat(ROIringMask, [1 1 nFrames]); % reproduce masks for every frame
    % Using indexing and reshape function to increase speed
    nPix_ring = sum(sum(ROIringMask));
    % Using reshape to partition into different trials.
    roi_img_ring = reshape(im(Ringmask), nPix_ring, []);
    % Raw intensity averaged from pixels of the ROI in each trial.
    if nPix_ring == 0
        RingF = zeros(nFrames,1);
    else
        RingF = mean(roi_img_ring);
    end
    %%%%%%%%%%%%% Obsolete slower method to compute ROI pixel intensity %%%%%%%
    %     roi_img = mask .* double(im);                                       %
    %                                                                         %
    %     roi_img(roi_img<=0) = NaN;                                          %
    %    % F(:,i) = nanmean(nanmean(roi_img));                                %
    %     F(i,:) = nanmean(nanmean(roi_img));                                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin > 3  % BG mask not empty
        BGmaskAllMask = repmat(BGmask,[1 1 nFrames]);
        nBGPixel = sum(sum(BGmask));
        BG = mean(reshape(im(BGmaskAllMask),nBGPixel,[])); % 1-by-nFrames array
        opt_subBG = 1; 
    else
        BG = 0;
        opt_subBG = 0;
    end
    
    if opt_subBG == 1
        F = F - BG;
    end
%     [N,X] = hist(F);
%     F_mode = X((N==max(N)));
%     baseline = mean(F_mode);
%     dff(i,:) = (F(i,:)- baseline)./baseline*100;
    
