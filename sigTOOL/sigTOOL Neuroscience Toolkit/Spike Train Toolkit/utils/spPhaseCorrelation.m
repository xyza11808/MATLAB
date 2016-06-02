function out=spPhaseCorrelation(fhandle, varargin)
% spPhaseCorrelation main routine for event correlation
% 
% spPhaseCorrelation is called for event auto- and cross- correlations
% and peri-event time histograms
% 
% Example:
% spPhaseCorrelation(fhandle, InputName1, InputValue1,....);
% spPhaseCorrelation(channels, InputName1, InputValue1,....);
% or
% out=spPhaseCorrelation(....);
% where
%         fhandle is a valid sigTOOL data view handle
%         channels is a sigTOOL channel cell array
%         out (if requested) will be a sigTOOLResultData object
%             
% If no output is requested the reslut will be plotted
% 
% Inputs are string/vlaue pairs
%     'Trigger'               List of trigger channels
%     'Sources'               List of source channels
%     'Start'                 Start time for processing (in seconds)
%     'Stop'                  End time for processing (in seconds)
%     'Duration'              Duration of the required correlation (in cycles)
%     'BinWidth'              Binwidth (in degrees)
%     'PercentPreTime'        Percentage pre-time (% of Duration)
%     'SweepsPerAverage'      Number of triggers to use for each average.
%                                 Set to zero to use all triggers. Otherwise, if 
%                                 SweepsPerAverage is less than the number
%                                 of available triggers, multiple event 
%                                 correlations will be returned, each using
%                                 SweepsPerAverage triggers
%
% NB spPhaseCorrelation calls the eventcorr mex-file or the shadowing
% m-file if eventcorr.cpp has not been compiled for the current platform
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------                                

% Revisions:
%       02.01.10    Options uicontextmenu replaced with function handle

% Process arguments
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
        case 'binwidth'
            BinWidth=varargin{i+1};
        case 'pretime'
            PercentPreTime=varargin{i+1};
        case 'sweepsperaverage'
            SweepsPerAverage=varargin{i+1};
        otherwise
            % Do nothing - may be argument for post-processing function
    end
end


[fhandle channels]=scParam(fhandle);

tu=channels{findFirstChannel(channels{:})}.tim.Units;
Start=Start*(1/tu);
Stop=Stop*(1/tu);

P=cell(length(Trigger) ,length(Sources));



progbar=scProgressBar(0, 'Setting up....', 'Name', 'Phase Correlation',...
    'Progbar','off');
for tr=1:length(Trigger)
    thistrigger=Trigger(tr);
    pt=PercentPreTime*0.01*Duration;
    % Form the averages
    for k=1:length(Sources)
        
        % For each source channel
        thissource=Sources(k);
        scProgressBar(tr/length(Trigger), progbar,...
            sprintf('<HTML><CENTER>Trigger: Channel %d<P>Processing Channel %d</P></CENTER></HTML>',...
            thistrigger, thissource));

        phase=getPhase(channels{thistrigger}, channels{thissource}, Start, Stop);
        trig=(1:floor(phase(end)))'; 
        trig=trig(trig<trig(end)-Duration+pt);
        warning('off', 'sigtool:eventcorr:tolwarn');
        [P{tr, k}.rdata, P{tr, k}.tdata]=eventcorr(trig, phase, BinWidth/360, SweepsPerAverage, Duration, pt);
        warning('on', 'sigtool:eventcorr:tolwarn');
        if ~isempty(P{tr, k})
            % Complete setup
            if SweepsPerAverage>0
                P{tr, k}.rdata=P{tr, k}.rdata/SweepsPerAverage;
                P{tr, k}.details.SweepsPerAverage=SweepsPerAverage;
            else
                P{tr, k}.rdata=P{tr, k}.rdata/length(trig);
                P{tr, k}.details.SweepsPerAverage=length(trig);
            end
            P{tr, k}.tlabel='Phase (Cycles)';
            P{tr, k}.rlabel='Events/Sweep';
            P{tr, k}.olabel='Sweep';
            P{tr, k}.barFlag=true;

            P{tr, k}.details.codesource=mfilename();
            if size(P{tr, k}.rdata,1)>1
                P{tr, k}.odata=1:size(P{tr, k}.rdata,1);
            end
            
            P{tr, k}.details.BinWidth=BinWidth;
        end
    end
end

Q=scPrepareResult(P, {Trigger Sources}, channels);
out.data=Q;

if SweepsPerAverage==0
    out.displaymode='Bars';
    out.viewstyle='2D Bar';
else
    out.displaymode='Bars';
    out.viewstyle='3D Bar';
end
out.plotstyle={@scBar};


out.options=@LocalOptions;
out.datasource=fhandle;
out.title='Phase Correlation';

delete(progbar);
out=sigTOOLResultData(out);
if nargout==0
    plot(out);
end

return
end


function h=LocalOptions()
h=uicontextmenu();
uimenu(h, 'Label', 'Add Plot');
uimenu(h, 'Label', 'Cusum', 'Callback', @Cusum);
SmoothingContextMenu(h);
return
end








