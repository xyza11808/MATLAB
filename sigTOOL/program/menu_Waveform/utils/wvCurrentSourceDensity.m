function result=wvCurrentSourceDensity(fhandle, varargin)
% wvCurrentSourceDensity calculates 1-dimensional current source densities
%
% It is assumed that a fixed number of triggers have been delivered at each
% point along an electrode track. wvCurrentSourceDensity calls wvAverage
% to average the data at each point. The MATLAB del2 function is used to
% find the discrete Laplacian.
%
% Example:
% result=wvCurrentSourceDensity(fhandle, field1, value1, field2, value2...)
% 
% returns a sigTOOLResultData object. If no output is requested the result
% will be plotted.
%
% Valid field/value pairs are:
%     'trigger'               one or more valid trigger channel numbers
%                                (scalar or vector)
%     'sources'               one or more valid source channel numbers
%                                (scalar or vector) 
%     'start'                 the start time for data processing
%                                (scalar, in seconds)
%     'stop'                  the stop time for data processing
%                                (scalar, in seconds)
%     'duration'              the duration of the sweep (pre+post time)
%                                (scalar, in seconds)
%     'pretime'               the pre-time 
%                                (scalar, as a percentage of the duration)
%     'sweepsperaverage'      the number of triggers to use for each average.
%                             Set to zero to use all available triggers.
%                             If sweepsperaverage is non-zero and less than
%                             the total number of triggers available, 
%                             multiple averages will be returned each using
%                             sweepsperaverage triggers
%                                 (scalar)
%     'overlap'               the percentage overlap for multiple triggers.
%                             If overalp is non-zero, multiple averages will
%                             be calculated using overlapping data. For example,
%                             with sweepsperaverage=20 and overlap=50, 
%                             averages will be calculated for sweeps 1-20,
%                             11-30, 21-40 etc. 
%                                 (scalar)
%     'retrigger'             Logical flag. If retrigger is true, all 
%                             triggers will be used (typically e.g for 
%                             spike-triggered averaging). If false, triggers
%                             will be debounced (see debounce.m).
%                                 (Logical. default==false)
%     'dcflag'                Logical flag. If true, the average value in the
%                             pre-stimulus period (the values at t<0) will be
%                             subtracted from each average. If no pre-stimulus
%                             period is defined (i.e. pretrigger==0), the 
%                             value if the first bin in the result will
%                             be subtracted for each average.
%                                 (Logical. default==false)
%     'method'                the averaging method. A string, either 'mean'
%                             or 'median'
%                                 (Default=='mean')
%     'errtype'               the error type. A string, either 'std' for
%                             standard deviation or 'prctile' for percentiles. 
%                                 (Default=='std')
%     'percentiles'           a two-element vector giving the required
%                             percentiles if errtype=='prctile'. 
%                                 (Default [25 75]);
%     'spacing'               the spacing between recording points. May be
%                             a scalar, in which case equidistant recording
%                             points starting at zero will be assumed.
%                             Otherwise a vector of points can be given.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
%

% Revised 16/7/08
%   06.06.09 Modified for zero base on depth axis

% Calculate averages using wvAverage
result=wvAverage(fhandle, varargin{:});

% Recording spacing/interelectrode distance & DCFlag from inputs
DCFlag=false;
for i=1:2:length(varargin)
    if strcmpi(varargin{i}, 'spacing')
        loc=varargin{i+1};
    end
    if strcmpi(varargin{i}, 'DCFlag')
        DCFlag=true;
    end
end

progbar=scProgressBar(0, 'Converting result...', 'Name', '1D Current Source Density');

% Cycle through each average
for m=2:size(result.data,1)
    for n=2:size(result.data, 2)
        
        % Convert each to CSD
        data=result.data{m,n}.rdata;
        for k=1:size(data,2)
            % Get CSD
            data(:,k)=-del2(data(:,k), loc)/4;
%             if DCFlag
%                 % Subtract column mean from result
%                 data(:,k)=data(:,k)-mean(data(:,k));
%             end
        end 
        % Set exprapolated regions to NaN        
        data(1,:)=nan(size(data(1,:)));
        data(end,:)=nan(size(data(end,:)));        
        result.data{m,n}.rdata=data;
        result.data{m,n}.rlabel='CSD';
        
        % y-axis
        if isscalar(loc)
            % 06.06.09 Modify for zero base
            result.data{m,n}.odata(1)=0;
            result.data{m,n}.odata(2:end)=loc;
            result.data{m,n}.odata=cumsum(result.data{m,n}.odata);
            if loc==1
                result.data{m,n}.olabel='Distance';
            else
                result.data{m,n}.olabel='Distance (\mum)';
            end
        else
            result.data{m,n}.odata=loc;
            result.data{m,n}.olabel='Distance (\mum)';
        end
        
        result.data{m,n}.odir='reverse';
    end
end

% Plot as surface: use view(2) for 2-D view of result
result.plotstyle{1}=@scContour;
result.title=strrep(result.title, 'Waveform Mean', 'Current Source Density');
result.title=strrep(result.title, 'Waveform Median', 'Current Source Density');
if nargout==0
    rhandle=plot(result);
end

close(progbar);
return
end