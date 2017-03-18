function h_net = ROIConnectNetPlot(ROIinfo,ROICorrCoef,varargin)
% plot of neuron connection network, using thick line indicating strong
% correlation, and thin line indicating weak correlation.
% using dash line to represent negtive correlation, and solid line to
% represent positie correlation
% if given response group, using blue circles to represent Left selective
% ROIs, and red circles to represent Right selective ROIs
if length(ROIinfo) > 1
    ROIposInfo = ROIinfo(1);
else
    ROIposInfo = ROIinfo;
end
ROIcenters = ROI_insite_label(ROIposInfo,0); % first column is y axis value, while second column is x axis value
FieldSize = size(ROIposInfo.ROImask{1}); % using to define image boundary

% processing correlation cofficient data
if length(ROICorrCoef) == numel(ROICorrCoef)
    ROIPairCoef = squareform(ROICorrCoef); % matrix data
else
    ROIPairCoef = ROICorrCoef;
end
if size(ROIcenters,1) ~= size(ROIPairCoef,1)
    fprintf('ROI position data have %d ROIs, while correlation coef data have %d ROIs.\n',size(ROIcenters,1),size(ROIPairCoef,1));
    error('Input data dimension dismatched.');
end
ROINum = size(ROIcenters,1);
% plot the ROI positions using circle
ROIRespGroup = ones(size(ROIcenters,1),1);
if nargin > 2
    if ~isempty(varargin{1})
        ROIRespGroup = varargin{1}; % -1 indicates left group, and 1 indicate right group, 0 indicates no significant selectivety
    end
end

coefValueThres = 0.5;
if nargin > 3
    if ~isempty(varargin{2})
        coefValueThres = varargin{2};
    end
end

Is3dPlot = 0;
if nargin > 4
    if ~isempty(varargin{3})
        Is3dPlot = varargin{3};
    end
end

%%
h_net = figure('position',[400 200 1000 900]);
hold on;
if ~Is3dPlot
    if length(unique(ROIRespGroup)) == 1
        scatter(ROIcenters(:,2),ROIcenters(:,1),70,'mo','LineWidth',1.8);
    else
        ROIindicates = unique(ROIRespGroup);
        LeftROIInds = ROIRespGroup == ROIindicates(1);
        RightROIInds = ROIRespGroup == ROIindicates(3);
        QuietROIinds = ROIRespGroup == ROIindicates(2);
        scatter(ROIcenters(LeftROIInds,2),ROIcenters(LeftROIInds,1),70,'bo','LineWidth',1.8);
        scatter(ROIcenters(RightROIInds,2),ROIcenters(RightROIInds,1),70,'ro','LineWidth',1.8);
        scatter(ROIcenters(QuietROIinds,2),ROIcenters(QuietROIinds,1),70,'ko','LineWidth',1.8);
    end
    set(gca,'xlim',[0 FieldSize(2)],'ylim',[0 FieldSize(1)]);
else
    % generate z axis data, using random values within same scale as
    % imaging pixel number
    ROIzValues = rand(ROINum,1)*FieldSize(1);
    
    if length(unique(ROIRespGroup)) == 1
        scatter3(ROIcenters(:,2),ROIcenters(:,1),ROIzValues,70,'mo','LineWidth',1.8);
    else
        ROIindicates = unique(ROIRespGroup);
        LeftROIInds = ROIRespGroup == ROIindicates(1);
        RightROIInds = ROIRespGroup == ROIindicates(3);
        QuietROIinds = ROIRespGroup == ROIindicates(2);
        scatter3(ROIcenters(LeftROIInds,2),ROIcenters(LeftROIInds,1),ROIzValues(LeftROIInds),70,'bo','LineWidth',1.8);
        scatter3(ROIcenters(RightROIInds,2),ROIcenters(RightROIInds,1),ROIzValues(RightROIInds),70,'ro','LineWidth',1.8);
        scatter3(ROIcenters(QuietROIinds,2),ROIcenters(QuietROIinds,1),ROIzValues(QuietROIinds),70,'ko','LineWidth',1.8);
    end
    set(gca,'xlim',[0 FieldSize(2)],'ylim',[0 FieldSize(1)],'zlim',[0 FieldSize(1)]);
end
    
%%
if ~Is3dPlot
    % plot the Lines
    ROICoefRaw = ones(size(ROIPairCoef));
    ROIcoefMask = logical(tril(ROICoefRaw,-1));
    VectorROICoefData = ROIPairCoef(ROIcoefMask);
    SigCoefValueInds = find(abs(VectorROICoefData) > coefValueThres);
    SigCoefValueAll = VectorROICoefData(SigCoefValueInds);
    AbsSigCoefValueAll = abs(SigCoefValueAll);
    LineScaleAll = 2.8*(AbsSigCoefValueAll - min(AbsSigCoefValueAll))./(max(AbsSigCoefValueAll) - min(AbsSigCoefValueAll)) + 0.2; % rescale coef value into [0.2,2] range for linewidth set
    [SigROIpairRow,SigROIpairCol] = ind2sub([ROINum,ROINum],SigCoefValueInds);
    %
    % plot the positive correlation using solid lines
    PosVectorInds = SigCoefValueAll > 0;
    PosVectorLineWid = LineScaleAll(PosVectorInds);
    PosROIcentRows = ROIcenters(SigROIpairRow(PosVectorInds),:); % n by 2 matrix
    PosROIcentCols = ROIcenters(SigROIpairCol(PosVectorInds),:); % n by 2 matrix
    PosROIPairX = ([PosROIcentRows(:,2),PosROIcentCols(:,2)])'; % x values for line plot
    PosROIPairY = ([PosROIcentRows(:,1),PosROIcentCols(:,1)])'; % x values for line plot
    hPos = plot(PosROIPairX,PosROIPairY,'k');
    set(hPos,{'LineWidth'},num2cell(PosVectorLineWid(:)));
    %
    % plot the negtive correlation using dash line
    NegVectorInds = SigCoefValueAll < 0;
    NegVectorLineWid = LineScaleAll(NegVectorInds);
    NegROIcentRows = ROIcenters(SigROIpairRow(NegVectorInds),:); % n by 2 matrix
    NegROIcentCols = ROIcenters(SigROIpairCol(NegVectorInds),:); % n by 2 matrix
    NegROIPairX = ([NegROIcentRows(:,2),NegROIcentCols(:,2)])'; % x values for line plot
    NegROIPairY = ([NegROIcentRows(:,1),NegROIcentCols(:,1)])'; % x values for line plot
    hNeg = plot(NegROIPairX,NegROIPairY,'k','LineStyle','--');
    set(hNeg,{'LineWidth'},num2cell(NegVectorLineWid(:)));
else
    % plot the Lines
    ROICoefRaw = ones(size(ROIPairCoef));
    ROIcoefMask = logical(tril(ROICoefRaw,-1));
    VectorROICoefData = ROIPairCoef(ROIcoefMask);
    SigCoefValueInds = find(abs(VectorROICoefData) > coefValueThres);
    SigCoefValueAll = VectorROICoefData(SigCoefValueInds);
    AbsSigCoefValueAll = abs(SigCoefValueAll);
    LineScaleAll = 2.8*(AbsSigCoefValueAll - min(AbsSigCoefValueAll))./(max(AbsSigCoefValueAll) - min(AbsSigCoefValueAll)) + 0.2; % rescale coef value into [0.2,2] range for linewidth set
    [SigROIpairRow,SigROIpairCol] = ind2sub([ROINum,ROINum],SigCoefValueInds);
%     ROIcentDepthRow = ROIzValues(SigROIpairRow);
%     ROIcentDepthCol = ROIzValues(SigROIpairCol);
    %
    % plot the positive correlation using solid lines
    PosVectorInds = SigCoefValueAll > 0;
    PosVectorLineWid = LineScaleAll(PosVectorInds);
    PosROIcentRows = ROIcenters(SigROIpairRow(PosVectorInds),:); % n by 2 matrix
    PosROIcentCols = ROIcenters(SigROIpairCol(PosVectorInds),:); % n by 2 matrix
    PosROIcentDepthS = ROIzValues(SigROIpairRow(PosVectorInds)); % start z depth
    PosROIcentDepthE = ROIzValues(SigROIpairCol(PosVectorInds)); %end z depth
    PosROIPairX = ([PosROIcentRows(:,2),PosROIcentCols(:,2)])'; % x values for line plot
    PosROIPairY = ([PosROIcentRows(:,1),PosROIcentCols(:,1)])'; % y values for line plot
    PosROIPairZ = ([PosROIcentDepthS(:),PosROIcentDepthE(:)])'; % z values for line plot
    hPos = plot3(PosROIPairX,PosROIPairY,PosROIPairZ,'k');
    set(hPos,{'LineWidth'},num2cell(PosVectorLineWid(:)));
    %
    % plot the negtive correlation using dash line
    NegVectorInds = SigCoefValueAll < 0;
    NegVectorLineWid = LineScaleAll(NegVectorInds);
    NegROIcentRows = ROIcenters(SigROIpairRow(NegVectorInds),:); % n by 2 matrix
    NegROIcentCols = ROIcenters(SigROIpairCol(NegVectorInds),:); % n by 2 matrix
    NegROIcentDepthS = ROIzValues(SigROIpairRow(NegVectorInds)); % start z depth
    NegROIcentDepthE = ROIzValues(SigROIpairCol(NegVectorInds)); %end z depth
    NegROIPairX = ([NegROIcentRows(:,2),NegROIcentCols(:,2)])'; % x values for line plot
    NegROIPairY = ([NegROIcentRows(:,1),NegROIcentCols(:,1)])'; % x values for line plot
    NegROIPairZ = ([NegROIcentDepthS(:),NegROIcentDepthE(:)])'; % z values for line plot
    hNeg = plot3(NegROIPairX,NegROIPairY,NegROIPairZ,'k','LineStyle','--');
    set(hNeg,{'LineWidth'},num2cell(NegVectorLineWid(:)));
end
%%
axis off
title({'Correlation Connect network',sprintf('Coefficient thres = %.2f',coefValueThres)});
set(gca,'FontSize',18);
% saveas(h_net,'Coef Connect network plot');
% saveas(h_net,'Coef Connect network plot','png');
% close(h_net);

