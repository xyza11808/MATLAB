function out=spInterspikeInterval(fhandle, varargin)
% spInterspikeInterval returns the interspike interval distribution
% 
% Example:
% spInterspikeInterval(fhandle, InputName1, InputValue1,....);
% spInterspikeInterval(channels, InputName1, InputValue1,....);
% or
% out=spInterspikeInterval(....);
% where
%         fhandle is a valid sigTOOL data view handle
%         channels is a sigTOOL channel cell array
%         out (if requested) will be a sigTOOLResultData object
%             
% If no output is requested the result will be plotted
% 
% Other inputs are string/vlaue pairs
%     'Sources'               List of source channels
%     'Start'                 Start time for processing (in seconds)
%     'Stop'                  End time for processing (in seconds)
%     'BinWidth'              The width of the bins in the result (in
%                               seconds)
%
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 04/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

% Revisions:
%       02.01.10    Options uicontextmenu replaced with function handle

% Process arguments
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'sources'
            Sources=varargin{i+1};
        case 'start'
            Start=varargin{i+1};
        case 'stop'
            Stop=varargin{i+1};
        case 'binwidth'
            BinWidth=varargin{i+1};
        otherwise
            error('Unrecognized parameter ''%s''', varargin{i});
    end
end

[fhandle, channels]=scParam(fhandle);
Start=Start/channels{Sources(1)}.tim.Units;
Stop=Stop/channels{Sources(1)}.tim.Units;
BinWidth=BinWidth/channels{Sources(1)}.tim.Units;

nchan=length(unique(Sources));
P=cell(nchan, nchan);

for i=1:nchan
    thischan=Sources(i);
    d=getValidTriggers(channels{thischan}, Start, Stop);
    if length(d)<2
        continue
    end
    d=diff(d);
    maxinterval=max(d);
    tb=(0:BinWidth:maxinterval+BinWidth);
    P{i,i}.rdata=histc(d, tb)';
    P{i,i}.tdata=tb*1000*channels{thischan}.tim.Units;
    P{i,i}.rlabel='Count';
    P{i,i}.tlabel='Interval (ms)';
    % Record details
    P{i,i}.details.binwidth=BinWidth;
    % Stats
    P{i,i}.details.n=length(d);
    P{i,i}.details.mean=mean(d);
    P{i,i}.details.std=std(d);
    P{i,i}.details.mode=mode(d);
    P{i,i}.details.median=median(d);
    try
        P{i,i}.details.prctile2575=prctile(d,[25 75]);
    catch
    end
    P{i,i}.details.meanif=mean(1./d);
    P{i,i}.details.stdif=std(1./d);
end

Q=scPrepareResult(P, Sources, channels);
out.data=Q;

out.displaymode='Single Frame';
out.plotstyle={@scBar};
out.viewstyle='2D';
out.datasource=fhandle;
out.title='Interspike Distribution Histogram';
out.options=@scAddDistributionTool;
out=sigTOOLResultData(out);
if nargout==0
    plot(out);
end
