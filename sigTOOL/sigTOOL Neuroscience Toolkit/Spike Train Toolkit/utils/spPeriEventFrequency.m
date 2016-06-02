function out=spPeriEventFrequency(fhandle, varargin)



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
        case 'retrigger'
            RetriggerFlag=varargin{i+1};
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
progbar=scProgressBar(0, 'Setting up....', 'Name', 'Peri-event Time Histogram',...
    'Progbar','off');
for tr=1:length(Trigger)
    thistrigger=Trigger(tr);
    % Find the trigger times from the trigger channels
    trig=getValidTriggers(channels{thistrigger}, Start, Stop);

    % Limit triggers to those in the requested time span
    pt=PercentPreTime*0.01*Duration;
    trig=trig(trig>Start+pt);
    trig=trig(trig<Stop-Duration+pt);

    if RetriggerFlag==false
        % Do not retrigger before the end of a sweep
        trig=debounce(trig, Duration, pt);
    end

    if isempty(trig)
        % No valid triggers on this channels
        continue
    end


    % Form the averages
    for i=1:length(Sources)
        % For each source channel
        thissweep=0;
        thissource=Sources(i);
        scProgressBar(tr/length(trig), progbar,...
            sprintf('<HTML><CENTER>Trigger: Channel %d<P>Processing Channel %d</P></CENTER></HTML>',...
            thistrigger, thissource));

        source=getValidTriggers(channels{thissource}, Start, Stop);
        [P{tr, i}.tdata, dum, P{tr, i}.rdata]=rasterprep(trig, source, Duration, pt);
        % Convert to seconds 
        P{tr, i}.rdata=1./(P{tr, i}.rdata*channels{thissource}.tim.Units);
        if P{tr, i}.rdata==Inf
            P{tr, i}.rdata=NaN;
        end
        P{tr, i}.tdata=P{tr, i}.tdata*channels{thissource}.tim.Units*10^3;
        if ~isempty(P{tr,i})
            % Complete setup
            P{tr,i}.tlabel='Time (ms)';
            P{tr,i}.rlabel='Frequency (Hz)';
            P{tr,i}.details.nsweeps=thissweep;
            P{tr,i}.details.codesource=mfilename();


        end
    end
end


Q=scPrepareResult(P, {Trigger Sources}, channels);
out.data=Q;

out.plotstyle={@scScatter};
out.viewstyle='2D';

out.displaymode='Single Frame';

out.datasource=fhandle;
delete(progbar);
out=sigTOOLResultData(out);
if nargout==0
    plot(out);
end

return
end

