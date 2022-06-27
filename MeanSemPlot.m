function varargout = MeanSemPlot(data,xticks,hf,SEMratio,shadowColor,varargin)
% this function will plot the input matrix data, using the rows as repeats
% and columns as observations, plot the mean trace for given data and add a
% shadow plot as SEM
% varargin contains support parameters of matlab built-in function plot

if ~isnumeric(data)
    error('Input data must be a numeric array');
end
if ~ismatrix(data)
    error('The input data must be a matrix');
end
if ~exist('SEMratio','var') || isempty(SEMratio)
    SEMratio = 1; % used to scale SEM values in case it is not visible
end
if ~exist('shadowColor','var') || isempty(shadowColor)
    shadowColor = [.5 .5 .5];
end

[nROws,nCloumns] = size(data);
MeanTrace = (smooth(mean(data),9))';
% MeanTrace = mean(data);
% MeanTrace = wdenoise(mean(data));
TraceSem = std(data)/sqrt(nROws) * SEMratio; 
if isempty(xticks)
    xticks = 1 : nCloumns;
    xpatch = [xticks,fliplr(xticks)];
else
    xticks = (xticks(:))';
    xpatch = [xticks,fliplr(xticks)];
end
ypatch = [(MeanTrace + TraceSem),fliplr(MeanTrace - TraceSem)];

if ~isempty(hf) && ishandle(hf)
    if isgraphics(hf,'axes')
        axes(hf);
        h = gca;
    elseif isgraphics(hf,'figure')
        figure(hf);
        h = hf;
    end
else
    h = figure('position',[200 200 1000 800]);
end

hold on;
hp = patch(xpatch,ypatch,1,'facecolor',shadowColor,...
              'edgecolor','none',...
              'facealpha',0.4);
hline = plot(xticks,MeanTrace,varargin{:});
if nargout > 0
    varargout{1} = h;
    varargout{2} = hp;
    varargout{3} = hline;
end