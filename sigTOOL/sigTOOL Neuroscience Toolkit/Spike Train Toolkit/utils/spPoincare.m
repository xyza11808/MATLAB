function out=spPoincare(fhandle, varargin)
% spPoincare creates a Poincare diagram
%
% Example:
% spPoincare(fhandle, InputName1, InputValue1,....)
% spPoincare(fhandle, InputName1, InputValue1,....)
% or
% out=spPoincare(....)
%     
% where
%         fhandle is a valid sigTOOL data view handle
%         channels is a sigTOOL channel cell array
%         out (if requested) will be a sigTOOLResultData object
%     
% A Poincare diagram plots the interval between successive events as a
% scatter plot i.e. the n+1th interval is plotted against the nth.
%
% If no output is requested the result will be plotted
%
% Inputs are string/value pairs
%     'Sources'               Vector of source channels
%     'Start'                 Start time for processing (in seconds)
%     'Stop'                  End time for processing (in seconds)
%
% 
% A similar analysis can be presented as a colored image though the
% spJointIntervalDistribution function
%
% See also spJointIntervalDistribution
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 04/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

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
            % Ignore
        otherwise
            error('Unrecognized parameter ''%s''', varargin{i});
    end
end
[fhandle, channels]=scParam(fhandle);
Start=Start/channels{Sources(1)}.tim.Units;
Stop=Stop/channels{Sources(1)}.tim.Units;

nchan=length(unique(Sources));
P=cell(nchan, nchan);

for i=1:nchan
    thischan=Sources(i);
    d=getValidTriggers(channels{thischan}, Start, Stop);
    d=diff(d)';
    P{i,i}.tdata=d(1:end-1)*1000*channels{thischan}.tim.Units;
    P{i,i}.rdata=d(2:end)*1000*channels{thischan}.tim.Units;
    P{i,i}.tlabel='Interval n (ms)';
    P{i,i}.rlabel='Interval n+1 (ms)';
    % Record details
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

out.displaymode='Scatter';
out.plotstyle={@scScatter};
out.viewstyle='2D';
out.datasource=fhandle;
out.title='Poincare Diagram';
out=sigTOOLResultData(out);
if nargout==0
    plot(out);
end
