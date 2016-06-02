function varargout=ROI_Coeff_Calcu(RawData,varargin)
%this functin is used to calculate ROIs correlation coefficience accorsing
%to the input contents
%the Raw data should be the fluo changed data after smoothed
% last modification 26, Oct, 2015
RawDataBU=RawData;
%Raw data cutoff using threshold value
if nargin<3 || isempty(varargin{2})
    disp('Skip baseline data cut off\n');
else
    CutOffData=ThresCutoff(RawData,1);
end

DataSize=size(RawData);
% TrialsNum=DataSize(1);
ROIsNum=DataSize(2);
ROIVect=(1:ROIsNum)';
if nargin<2
%     ChoiceC=input('No ROI inds selected, are you sure you want to calculate the corr coeff between all ROIs?\n','s');
%     if strcmpi('y',ChoiceC)
%         disp('Perform following analysis...\n');
        ROIInds=(1:ROIsNum)';
        AllROICoefCal=1;
%     else
%         disp('Quit following analysis...\n');
%         return;
%     end
else
    AllROICoefCal=0;
    ROIInds=varargin{1};  %two columns matrix, with the forst column contains left ROI inds, and second column contains right inds
end
if isempty(ROIInds)
    AllROICoefCal=1;
end

if ~AllROICoefCal
    LeftROIs=ROIVect(ROIInds(:,1));
    RightROIs=ROIVect(ROIInds(:,2));
    LeftROIsSelNum=length(LeftROIs);
    RightROIsSelNum=length(RightROIs);
    RawDataShift=permute(RawData,[2,3,1]);
    RawDataReshape=reshape(RawDataShift,DataSize(2),DataSize(1)*DataSize(3));
    % LeftROIData=RawData(:,LeftROIs,:);
    % RightROIData=RawData(:,RightROIs,:);:
    LeftROISDataShift=RawDataReshape(LeftROIs,:);
    RightROISDataShift=RawDataReshape(RightROIs,:);
    
    % %#################################################################################
    % %calculate the left inds corr coeff
    % corrROINumLeft=LeftROIsSelNum*(LeftROIsSelNum-1)/2;
    % corrROIindsL=zeros(corrROINumLeft,2);
    % corrcoefLeft=zeros(corrROINumLeft,1);
    % k=1;
    % for n=1:LeftROIsSelNum
    %     for m=(n+1):LeftROIsSelNum
    %         SingleROI1=squeeze(RawData(:,LeftROIs(n),:));
    %         SingleROI2=squeeze(RawData(:,LeftROIs(m),:));
    %         corrROIindsL(k,:)=[n,m];
    %         Tempcorr=corrcoef(SingleROI1',SingleROI2');
    %         corrcoefLeft(k)=Tempcorr(1,2);
    %         k=k+1;
    %     end
    % end
    %
    % %###################################################################################
    % %calculate Right inds corr coef
    % corrROINumRight=RightROIsSelNum*(RightROIsSelNum-1)/2;
    % corrROIindsR=zeros(corrROINumRight,2);
    % corrcoefRight=zeros(corrROINumRight,1);
    % k=1;
    % for n=1:RightROIsSelNum
    %     for m=(n+1):RightROIsSelNum
    %         SingleROI1=squeeze(RawData(:,RightROIs(n),:));
    %         SingleROI2=squeeze(RawData(:,RightROIs(m),:));
    %         corrROIindsR(k,:)=[n,m];
    %         Tempcorr=corrcoef(SingleROI1',SingleROI2');
    %         corrcoefRight(k)=Tempcorr(1,2);
    %         k=k+1;
    %     end
    % end
    
    %#################################################################################
    %calculate Left and Right corrcoef
    CorrNum=LeftROIsSelNum*RightROIsSelNum;
    corrROIindsA=zeros(CorrNum,2);
    corrcoefAll=zeros(CorrNum,1);
    k=1;
    for n=1:LeftROIsSelNum
        for m=1:RightROIsSelNum
            SingleROI1=squeeze(RawData(:,LeftROIs(n),:));
            SingleROI2=squeeze(RawData(:,RightROIs(m),:));
            corrROIindsA(k,:)=[n,m];
            Tempcorr=corrcoef(SingleROI1',SingleROI2');
            corrcoefAll(k)=Tempcorr(1,2);
            k=k+1;
        end
    end
    
    %using matrix reshape methods to calculate the corrcoef
    LeftCoCoef=corrcoef(LeftROISDataShift');
    RightCoCoef=corrcoef(RightROISDataShift');
    LeftCoCoefTri=tril(LeftCoCoef,-1);
    RightCoCoefTri=tril(RightCoCoef,-1);
    LeftCoCoefTriS=LeftCoCoefTri(:);
    LeftCoCoefTriS2=LeftCoCoefTriS(LeftCoCoefTriS~=0); %the vector variable that can be correlated with the distance calculation result
    RightCoCoefTriS=RightCoCoefTri(:);
    RightCoCoefTriS2=RightCoCoefTriS(RightCoCoefTriS~=0);  %the vector variable that can be correlated with the distance calculation result
    
    
    %save result
    if ~isdir('./ROI_Corrcoef_result/')
        mkdir('./ROI_Corrcoef_result/');
    end
    cd('./ROI_Corrcoef_result/');
    %plot of all the corrcoef values
    LeftPlot=triu(LeftCoCoef); %#ok<*NASGU>
    h_corrleft=figure;
    % h_im=imagesc(LeftPlot,[-0.5 1]);
    imagesc(LeftCoCoef,[-0.5 1]);
    % set(h_im,'alphadata',LeftPlot~=0);
    title('Left responsive ROIs coef');
    xlabel('ROIs');
    ylabel('ROIs');
    % axis off;
    box off;
    colorbar;
    saveas(h_corrleft,'Left ROIs corrcoef value','png');
    saveas(h_corrleft,'Left ROIs corrcoef value');
    close(h_corrleft);
    
    RightPlot=triu(RightCoCoef);
    h_coeeright=figure;
    % h_im=imagesc(RightPlot,[-0.5 1]);
    imagesc(RightCoCoef,[-0.5 1]);
    % set(h_im,'alphadata',RightPlot~=0);
    title('Right responsive ROIs coef');
    xlabel('ROIs');
    ylabel('ROIs');
    % axis off;
    box off;
    colorbar;
    saveas(h_coeeright,'Right ROIs corrcoef value','png');
    saveas(h_coeeright,'Right ROIs corrcoef value');
    close(h_coeeright);
    
    AllPlot=reshape(corrcoefAll,LeftROIsSelNum,RightROIsSelNum);
    h_corrall=figure;
    imagesc(AllPlot,[-0.5 1]);
    title('Left vs Right responsive ROIs coef');
    % axis off;
    box off;
    colorbar;
    xlabel('RightSide ROIs');
    ylabel('LeftSide ROIs');
    saveas(h_corrall,'L2R ROIs corrcoef value','png');
    saveas(h_corrall,'L2R ROIs corrcoef value');
    close(h_corrall);
    
    save CorrResult.mat LeftCoCoef RightCoCoef corrROIindsA corrcoefAll -v7.3
    
    if nargout==1
        varargout{1}={{LeftCoCoefTriS2},{RightCoCoefTriS2},{corrcoefAll}};
        % elseif nargout==2
        %     varargout{1}={{corrROIindsL},{corrROIindsR},{corrROIindsA}};
        %     varargout{2}={{corrcoefLeft},{corrcoefRight},{corrcoefAll}};
    elseif nargout==3
        varargout{1}={LeftCoCoefTriS2};
        varargout{2}={RightCoCoefTriS2};
        varargout{3}={corrcoefAll};
    end
else
    if ~isdir('./ALL_ROI_coef/')
        mkdir('./ALL_ROI_coef/');
    end
    cd('./ALL_ROI_coef/');
    RawDataShift=permute(RawData,[2,3,1]);
    RawDataReshape=reshape(RawDataShift,DataSize(2),DataSize(1)*DataSize(3));
    AllROICoefmatrix=corrcoef(RawDataReshape');
    AllCoCoefTri=tril(AllROICoefmatrix,-1);
    AllCoCoefTri=AllCoCoefTri(:);
    AllCoCoefTri2=AllCoCoefTri(AllCoCoefTri~=0);
    
    h=figure;
    imagesc(AllROICoefmatrix);
    colorbar;
    axis off
    xlabel('# ROIs');
    ylabel('# ROIs');
    title(sprintf('Mean Popu. coef = %.3f',mean(AllCoCoefTri2)));
    saveas(h,'Paired ROIs corrcoef value','png');
    saveas(h,'Paired ROIs corrcoef value');
    close(h);
    
    save AllCorrResult.mat AllCoCoefTri2 -v7.3
    
    if nargout==1
        varargout={AllCoCoefTri2};
    end
end
cd ..;
