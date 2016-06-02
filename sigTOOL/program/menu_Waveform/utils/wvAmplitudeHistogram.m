function out=wvAmplitudeHistogram(fhandle, varargin)
%wvAmplitudeHistogram calculates the waveform ampltitude distribution
%
% Exampe:
% result=wvAmplitudeHistogram(fhandle, field1, value1, field2, value2....)
%     
% returns a sigTOOLResultData object. If no output is requested the result
% will be plotted.
% 
% Valid field/value pairs are:

%     'sources'               one or more valid source channel numbers
%                                (scalar or vector) 
%     'start'                 the start time for data processing
%                                (scalar, in seconds)
%     'stop'                  the stop time for data processing
%                                (scalar, in seconds)
%     'nbins'                 number of bins to use. 
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
%

% Revisions:
% 09.08.08 Exclude NaNs and add details fields

% Process argumants
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'sources'
            Sources=varargin{i+1};
        case 'start'
            Start=varargin{i+1};
        case 'stop'
            Stop=varargin{i+1};
        case 'nbins'
            nbins=varargin{i+1};
        otherwise
            % Do nothing - may be argument for post-processing function
    end
end

[fhandle channels]=scParam(fhandle);

P=cell(i,i);
progbar=scProgressBar(0, 'Setting up....', 'Name', 'Waveform Amplitude');
for i=1:length(Sources)
    scProgressBar(i/length(Sources), progbar,...
    sprintf('<HTML><CENTER>Processing Channel %d</CENTER></HTML>',...
            Sources(i)));
    tu=channels{Sources(i)}.tim.Units;
    thischan=getData(channels{Sources(i)}, Start/tu, Stop/tu);
    x=thischan.adc();
    x=x(:);
    % 09.08.08 Exclude NaNs
    x=x(~isnan(x));
    [P{i,i}.rdata, P{i,i}.tdata]=hist(x, nbins);
    P{i,i}.odata=[];
    P{i,i}.rlabel='N';
    P{i,i}.tlabel=['Amplitude (' thischan.adc.Units ')'];
    P{i,i}.olabel='';
    % Add details
    P{i,i}.details.mean=mean(x);
    P{i,i}.details.std=std(x);
    P{i,i}.details.max=max(x);
    P{i,i}.details.min=min(x);
    binwidth=P{i,i}.tdata(2)-P{i,i}.tdata(1);
    P{i,i}.details.binwidth=binwidth;
    P{i,i}.details.fittedrange=[min(P{i,i}.tdata) max(P{i,i}.tdata+binwidth)];
    P{i,i}.details.nbins=nbins;
end

Q=scPrepareResult(P, {Sources Sources}, channels);
out.data=Q;
out.displaymode='Single Frame';
out.title='Amplitude Histogram';
out.plotstyle={@scBar};
out.viewstyle='2D';
out.datasource=fhandle;
out.acktext='';
out.options=@scAddDistributionTool;
delete(progbar);
out=sigTOOLResultData(out);
if nargout==0
    plot(out);
end

return
end




