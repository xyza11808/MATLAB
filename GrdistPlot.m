function hhf = GrdistPlot(GrData,varargin)
% plot the column wise data distribution plots
% if varargin is given, then:
%    GrNames = varargin{1};
%    GrNames should have the same length as GrData columns number
%
% temp function
if ~iscell(GrData)
    if length(GrData) == numel(GrData)
        GrData = GrData(:);
        nCols = 1;
    else
        nCols = size(GrData,2);
    end
else
    nCols = length(GrData);
end
    
if nargin > 1
    GrNames = varargin{1};
    if length(GrNames) ~= nCols
        error('Input Grnames should have the same length as data column number');
    end
else
    GrInds = 1 : nCols;
    GrNames = cellstr(num2str(GrInds(:),'Gr%d'));
end
if isempty(GrNames)
    warning('Empty Group name was given.');
    GrInds = 1 : nCols;
    GrNames = cellstr(num2str(GrInds(:),'Gr%d'));
end
IsfigGiven = 0;
if nargin > 2
    if ~isempty(varargin{2})
        hhf = varargin{2};
        if ishandle(hhf)
            IsfigGiven = 1;
        end
    end
end

if IsfigGiven
    figure(hhf);
else
    hhf = figure('position',[750 250 430 300]+[0 0 50*nCols 0]);
end
hold on
for nGr = 1 : nCols
    if ~iscell(GrData)
        GrColData = GrData(:,nGr);
    else
        GrColData = GrData{nGr};
    end
    GrSEM = std(GrColData)/sqrt(length(GrColData));
    ts = tinv([0.025  0.975],length(GrColData)-1);
    CI = mean(GrColData) + ts*GrSEM;
    plot(ones(size(GrColData))*nGr,GrColData,'*','Color',[.7 .7 .7],'MarkerSize',8,'Linewidth',1.4);
    patch([0.9 1.1 1.1 0.9]+nGr-1,[CI(1) CI(1) CI(2) CI(2)],1,'EdgeColor','k','FaceColor','none','linewidth',2);
    errorbar(nGr,mean(GrColData),mean(GrColData) - CI(1),CI(2) - mean(GrColData),'ko','linewidth',1.8);
    line([0.8 1.2]+nGr-1,[mean(GrColData) mean(GrColData)],'Color','k','linewidth',2,'linestyle','--');
end
set(gca,'xlim',[0.5 , nCols+0.5]);
set(gca,'xtick',1 : nCols,'xticklabel',GrNames,'FontSize',15);

