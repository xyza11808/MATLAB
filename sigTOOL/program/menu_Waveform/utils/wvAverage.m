function out=wvAverage(fhandle, varargin)
% wvAverage performs waveform averaging about a set of trigger times
%
% wvAverage is also called for spike-triggered averaging by the sigTOOL
% Spike Train Toolkit
%
% wvAverage provides both mean and median averaging and also returns error
% estimates: standard deviations for the mean or, with the Statistics
% Toolbox installed, 25/75th percentiles for the median
%
% Exampe:
% result=wvAverage(fhandle, field1, value1, field2, value2....)
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
%                             subtracted for each average. If no pre-stimulus
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
%     percentiles             a two-element vector giving the required
%                             percentiles if errtype=='prctile'.
%                                 (Default [25 75]);
%
% Toolboxes Required: For percentiles, the MATLAB prctile function is
%                       needed (e.g. Stats Toolbox).
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
%
% Revisions:
%       12.10.08    Fix odata
%       27.09.09    Add test for shorter sampling time on source compared
%                   to trigger channel
%       09.10.09    Add pairwise trigger/source averaging

% Defaults
avmethod=@mean;
avmethodstr='mean';
errtype='std';
RetriggerFlag=false;
DCFlag=false;
RequiredPercentiles=[25 75];

% Process argumants
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'trigger'
            Trigger=varargin{i+1};
        case 'sources'
            Sources=varargin{i+1};
        case 'start'
            Start=varargin{i+1};
        case 'stop'
            Stop=varargin{i+1};
        case 'duration'
            Duration=varargin{i+1};
        case 'pretime'
            PercentPreTime=varargin{i+1};
        case 'sweepsperaverage'
            SweepsPerAverage=varargin{i+1};
        case 'overlap'
            Overlap=varargin{i+1};
        case 'retrigger'
            RetriggerFlag=varargin{i+1};
        case 'dcflag'
            DCFlag=varargin{i+1};
        case 'method'
            avmethodstr=varargin{i+1};
            avmethod=str2func(avmethodstr);
        case 'errtype'
            errtype=varargin{i+1};
        case 'percentiles'
            RequiredPercentiles=varargin{i+1};
        case 'pairwise'
            PairWise=varargin{i+1};
        otherwise
            % Do nothing - may be argument for post-processing function
    end
end

[fhandle channels]=scParam(fhandle);

tu=channels{findFirstChannel(channels{:})}.tim.Units;
Duration=Duration*(1/tu);
Start=Start*(1/tu);
Stop=Stop*(1/tu);

P=cell(length(Trigger) ,length(Sources));
progbar=scProgressBar(0, 'Setting up....', 'Name', 'Waveform Average');
for tr=1:length(Trigger)
    thistrigger=Trigger(tr);
    % Find the trigger times from the trigger channels
    trig=getValidTriggers(channels{thistrigger}, Start, Stop);
    
    % Limit triggers to those in the requested time span
    pt=PercentPreTime*0.01*Duration;
    trig=trig(trig>Start+pt);
    trig=trig(trig<Stop-Duration+pt);
    
    if isempty(trig)
        % No valid triggers on this channels
        continue
    end
    
    if RetriggerFlag==false
        % Do not retrigger before the end of a sweep
        trig=debounce(trig, Duration, pt);
    end
    
    % Setup
    if SweepsPerAverage==0
        spa=length(trig);
    else
        spa=SweepsPerAverage;
    end
    
    if Overlap>0
        noverlap=fix(Overlap*0.01*spa);
    else
        noverlap=0;
    end
    
    % Form the averages
    for i=1:length(Sources)
        
        % If PairWise==true take matching pairs of triggers/sources from
        % list only
        if PairWise
            if i~=tr
                continue
            end
        end
        
        % For each source channel
        nsweeps=max(1, ceil((length(trig)-spa+1)/(spa-noverlap)));
        thissweep=0;
        thissource=Sources(i);
        
        duration=min(Duration, findMaxPostTime(channels{thissource}, trig));
        if duration==0
            % No data available
            continue
        end
        pretime=min(PercentPreTime*0.01*duration, findMaxPreTime(channels{thissource}, trig));
        
        % Now form the averages
        for k=1:spa-noverlap:length(trig)-spa+1
            
            thissweep=thissweep+1;
            
            if trig(k+spa-1)>channels{thissource}.tim(end)+duration-pretime;
                % Sampling on source channel is shorter than the trigger
                % channel. Insufficient data remaining. 
                % [This is most likely to arise with demo files]
                P{tr,i}.rdata(thissweep:end, :)=[];
                P{tr,i}.odata(thissweep:end)=[];
                switch errtype
                    case 'std'
                        P{tr,i}.errdata.r(thissweep:end,:)=[];
                    case 'prctile'
                        P{tr,i}.errdata.r.upper(thissweep:end,:)=[];
                        P{tr,i}.errdata.r.lower(thissweep:end,:)=[];
                end
                thissweep=thissweep-1;
                break
            end
            
            
            scProgressBar(k/length(trig), progbar,...
                sprintf('<HTML><CENTER>Trigger: Channel %d<P>Processing Channel %d</P></CENTER></HTML>',...
                thistrigger, thissource));
            % Get the data
            [d tb epochs]=extractValidFrames(channels{thissource}, trig(k:k+spa-1), duration, pretime);
            % Initialize data areas on first iteration
            if thissweep==1
                P{tr,i}.tdata=tb*channels{thissource}.tim.Units*1e3;
                P{tr,i}.rdata=zeros(nsweeps, size(d, 2));%, nsweeps);
                P{tr,i}.odata=zeros(nsweeps, 1);
                switch errtype
                    case 'std'
                        P{tr,i}.errdata.r=zeros(nsweeps, size(d, 2));
                    case 'prctile'
                        P{tr,i}.errdata.r.upper=zeros(nsweeps, size(d, 2));
                        P{tr,i}.errdata.r.lower=zeros(nsweeps, size(d, 2));
                    otherwise
                        P{tr,i}.errdata.r=[];
                end
            end
            % Calculate averages and errors
            P{tr,i}.rdata(thissweep, :)=avmethod(d, 1);
            switch errtype
                case {'std'}
                    P{tr,i}.errdata.r(thissweep,:)=std(d, 1);
                case {'prctile'}
                    v=prctile(d, RequiredPercentiles);
                    P{tr,i}.errdata.r.lower(thissweep,:)=v(1,:);
                    P{tr,i}.errdata.r.upper(thissweep,:)=v(2,:);
            end
            % Record details
            P{tr,i}.odata(thissweep)=(trig(k)-pretime)*channels{thissource}.tim.Units;
            if length(unique(epochs))>1
                P{tr,i}.details.frames{thissweep}=epochs;
            else
                P{tr,i}.details.frames{thissweep}=1;
            end
        end
        
        if ~isempty(P{tr,i})
            % Complete setup
            P{tr,i}.tlabel='Time (ms)';
            P{tr,i}.rlabel=[channels{thissource}.hdr.title ' (' channels{thissource}.adc.Units ')'];
            P{tr,i}.olabel='Time (s)';
            P{tr,i}.details.nsweeps=thissweep;
            P{tr,i}.details.codesource=mfilename();
            P{tr,i}.details.method=avmethod;
            P{tr,i}.errdata.type=errtype;
            
            % Remove DC offset from averages if requested. Calculate
            % pre-time average using mean or median as requested and
            % subtract from both average and error estimates.
            if DCFlag
                if pretime>0
                    idx=P{tr,i}.tdata<0;
                    for j=1:size(P{tr,i}.rdata, 1);
                        m=avmethod(P{tr,i}.rdata(j, idx));
                        P{tr,i}.rdata(j, :)=P{tr,i}.rdata(j, :)-m;
                        if strcmp(errtype, 'prctile')
                            P{tr,i}.errdata.r.lower(j,:)=P{tr,i}.errdata.r.lower(j,:)-m;
                            P{tr,i}.errdata.r.upper(j,:)=P{tr,i}.errdata.r.upper(j,:)-m;
                        end
                    end
                else
                    for j=1:size(P{tr,i}.rdata, 1);
                        P{tr,i}.rdata(j,:)=P{tr,i}.rdata(j,:)-P{tr,i}.rdata(j,1);
                        if strcmp(errtype, 'prctile')
                            P{tr,i}.errdata.r.lower(j,:)=P{tr,i}.errdata.r.lower(j,:)-P{tr,i}.rdata(j,1);
                            P{tr,i}.errdata.r.upper(j,:)=P{tr,i}.errdata.r.upper(j,:)-P{tr,i}.rdata(j,1);
                        end
                    end
                end
            end
        end
    end
    
end


Q=scPrepareResult(P, {Trigger Sources}, channels);
out.data=Q;

if SweepsPerAverage==0
    out.displaymode='Single Frame';
else
    out.displaymode='Multiple Frames';
end
out.plotstyle={@scFrames};
out.viewstyle='2D';
switch avmethodstr
    case 'mean'
        out.title='Waveform Mean';
    case 'median'
        out.title='Waveform Median';
end
out.datasource=fhandle;
out.acktext='wvAverage: sigTOOL Core function';
delete(progbar);
out=sigTOOLResultData(out);
if nargout==0
    plot(out);
end

return
end

