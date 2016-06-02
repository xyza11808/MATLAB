function out=extractPhase(trig, events)

out=[];
error('Obsolete');

progbar=scProgressBar(0, 'Setting up....', 'Name', 'Event Correlation/PETH',...
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
        % Do not allow retrigger before the end of a sweep
        trig=debounce(trig, Duration, pt);
    end

    if isempty(trig)
        % No valid triggers on this channels
        continue
    end

    if AutoFlag==true
        Sources=thistrigger;
    end
    
    % Form the averages
    for k=1:length(Sources)
        
        if AutoFlag
            i=tr;
        else
            i=k;
        end
        
        % For each source channel
        thissource=Sources(k);
        scProgressBar(tr/length(trig), progbar,...
            sprintf('<HTML><CENTER>Trigger: Channel %d<P>Processing Channel %d</P></CENTER></HTML>',...
            thistrigger, thissource));

        source=getValidTriggers(channels{thissource}, Start, Stop);
        [P{tr, i}.rdata, P{tr, i}.tdata]=eventcorr(trig, source, BinWidth, SweepsPerAverage, Duration, pt);
        if RetriggerFlag==true && thistrigger==thissource
            % Subtract trigger spikes at time zero in autocorrelations
            if pt==0
                idx=1;
            else
                idx=floor(pt/BinWidth)+1;
            end
            P{tr, i}.rdata(idx)=P{tr, i}.rdata(idx)-length(trig);
        end
        P{tr, i}.tdata=P{tr, i}.tdata*channels{thissource}.tim.Units*1e3;
        if ~isempty(P{tr,i})
            % Complete setup
            if SweepsPerAverage>0
                P{tr, i}.rdata=P{tr, i}.rdata/SweepsPerAverage;
                P{tr,i}.details.SweepsPerAverage=SweepsPerAverage;
            else
                P{tr, i}.rdata=P{tr, i}.rdata/length(trig);
                P{tr,i}.details.SweepsPerAverage=length(trig);
            end
            P{tr,i}.tlabel='Time (ms)';
            P{tr,i}.rlabel='Events/Sweep';
            P{tr,i}.olabel='Sweep';
            P{tr,i}.barFlag=true;

            P{tr,i}.details.codesource=mfilename();
            if size(P{tr, i}.rdata,1)>1
                P{tr, i}.odata=1:size(P{tr, i}.rdata,1);
            end
            
            P{tr,i}.details.BinWidth=BinWidth*channels{thissource}.tim.Units;
        end
    end
end

if AutoFlag==true
    Sources=Trigger;
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
if AutoFlag
    out.title='Event Autocorrelation';
else
    out.title='Event Cross-correlation';
end
delete(progbar);
out=sigTOOLResultData(out);
if nargout==0
    plot(out);
end

return
end

function h=LocalOptions()
h=uicontextmenu();
uimenu(h, 'Label', 'Show Rate', 'Callback', @LocalShowRate);
uimenu(h, 'Label', 'Add Plot');
uimenu(h, 'Label', 'Cusum', 'Callback', @LocalCusum);
SmoothingContextMenu(h);
return
end

%-------------------------------------------------------------------------
% CALLBACKS
% These will be added to uicontextmenus when the result is plotted
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalShowRate(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
[fhandle, ax, result, subs, data]=callbackgetparam(hObject);
if strcmp(data.rlabel, 'Rate (Hz)')==1
    return
end
binwidth=data.details.BinWidth;
data.rdata=data.rdata/binwidth;
data.rlabel='Rate (Hz)';
result.data{subs(1), subs(2)}=data;
h=findobj(fhandle, 'Type', 'Axes',...
    'Tag', 'sigTOOL:AddedPlotAxes',...
    'Position', get(ax,'Position'));
delete(h);
plot(fhandle, result);
h=findobj(get(ax,'uicontextmenu'), 'Label', 'Show Rate');
set(h, 'Label', 'Show Count', 'Callback', @LocalShowCount);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalShowCount(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
[fhandle, ax, result, subs, data]=callbackgetparam(hObject);
if strcmp(data.rlabel, 'Events/Sweep')==1
    return
end
binwidth=data.details.BinWidth;
data.rdata=data.rdata*binwidth;
data.rlabel='Events/Sweep';
result.data{subs(1), subs(2)}=data;
h=findobj(fhandle, 'Type', 'Axes',...
    'Tag', 'sigTOOL:AddedPlotAxes',...
    'Position', get(ax,'Position'));
delete(h);
plot(fhandle, result);
h=findobj(get(ax,'uicontextmenu'), 'Label', 'Show Rate');
set(h, 'Label', 'Show Rate', 'Callback', @LocalShowRate);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalCusum(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
[fhandle, ax, result, subs, data]=callbackgetparam(hObject);
x=data.tdata;
% Find bins at t<0, use only first half
idx=data.tdata<0;
m=mean(data.rdata(1:sum(idx)/2));
if isnan(m)
    % No pre-time period
    return
end
y=data.rdata-m;
y=cumsum(y);
newax=scAddPlot(ax);
[x2, y2]=stairs(x, y);
h=line(x2, y2,'Parent', newax, 'Color', [0 0 0], 'LineWidth', 2);
set(h, 'Tag', 'AddedPlot',...
    'UserData', [x(:), y(:)],...
    'ButtonDownFcn', @scWindowButtonDownFcn);
set(newax, 'XLim', get(ax, 'XLim'));
set(newax, 'YLim', [min(y) max(y)]);
ylabel(newax, 'Cusum');
return
end
%--------------------------------------------------------------------------


