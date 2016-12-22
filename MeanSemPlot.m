function varargout = MeanSemPlot(data,xticks,hf,varargin)
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
[nROws,nCloumns] = size(data);
MeanTrace = mean(data);
TraceSem = std(data)/sqrt(nROws);
if isempty(xticks)
    xticks = 1 : nCloumns;
    xpatch = [xticks,fliplr(xticks)];
else
    xticks = (xticks(:))';
    xpatch = [xticks,fliplr(xticks)];
end
ypatch = [(MeanTrace + TraceSem),fliplr(MeanTrace - TraceSem)];

if ~isempty(hf) && ishandle(hf)
    figure(hf);
    h = hf;
else
    h = figure('position',[200 200 1000 800]);
end
hold on;

hp = patch(xpatch,ypatch,1,'facecolor',[.5 .5 .5],...
              'edgecolor','none',...
              'facealpha',0.6);
hline = plot(xticks,MeanTrace,varargin{:});
if nargout > 0
    varargout{1} = h;
    varargout{2} = hp;
    varargout{3} = hline;
end