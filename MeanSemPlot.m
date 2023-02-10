function varargout = MeanSemPlot(data,xticks,hf,SEMratio,shadowColor,varargin)
% this function will plot the input matrix data, using the rows as repeats
% and columns as observations, plot the mean trace for given data and add a
% shadow plot as SEM
% varargin contains support parameters of matlab built-in function plot

if ~exist('SEMratio','var') || isempty(SEMratio)
    SEMratio = 1; % used to scale SEM values in case it is not visible
end
if ~exist('shadowColor','var') || isempty(shadowColor)
    shadowColor = [.5 .5 .5];
end

if ~iscell(data)
    if ~isnumeric(data)
        error('Input data must be a numeric array');
    end
    if ~ismatrix(data)
        error('The input data must be a matrix');
    end

    [nROws,nCloumns] = size(data);
    if nCloumns > 10
        if nROws == 1
            MeanTrace = (sgolayfilt(data,3,7));
            TraceSem = zeros(size(MeanTrace));
        elseif nROws == 2
            MeanTrace = (sgolayfilt(mean(data,'omitnan'),3,7));
            TraceSem = zeros(size(MeanTrace));
        else
            % MeanTrace = (smooth(mean(data),7))';
            MeanTrace = (sgolayfilt(mean(data,'omitnan'),3,7));
            % MeanTrace = mean(data);
            % MeanTrace = wdenoise(mean(data));
            TraceSem = std(data,'omitnan')/sqrt(nROws) * SEMratio; 
        end
    else
        if nROws == 1
            MeanTrace = data;
            TraceSem = zeros(size(MeanTrace));
        elseif nROws == 2
            MeanTrace = mean(data,'omitnan');
            TraceSem = zeros(size(MeanTrace));
        else
            % MeanTrace = (smooth(mean(data),7))';
            MeanTrace = mean(data,'omitnan');
            % MeanTrace = mean(data);
            % MeanTrace = wdenoise(mean(data));
            TraceSem = std(data,'omitnan')/sqrt(nROws) * SEMratio; 
        end
        
    end
else
    % if the input data is cell format, means the input data 
    % is already the calculated Mean and SEM
    if length(data) == 1 % the data should be a two row matrix
        % the first row is avg, and the second row is SEM
        MeanTrace = data{1}(1,:);
        TraceSem = data{1}(2,:)*SEMratio;
    else
        MeanTrace = data{1};
        TraceSem = data{2}*SEMratio;
        if ~isvector(MeanTrace) || ~isvector(TraceSem)
            warning('The input data should contains only two row-vectors');
            return;
        end
        if size(MeanTrace,1) ~= 1
            MeanTrace = MeanTrace';
        end
        if size(TraceSem,1) ~= 1
            TraceSem = TraceSem';
        end
    end
    nCloumns = length(MeanTrace);
end

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
    h = figure('position',[100 100 300 240]);
end

hold on;
hp = patch(xpatch,ypatch,1,'facecolor',shadowColor,...
              'edgecolor','none',...
              'facealpha',0.3);
hline = plot(xticks,MeanTrace,varargin{:});
if nargout > 0
    varargout{1} = h;
    varargout{2} = hp;
    varargout{3} = hline;
end