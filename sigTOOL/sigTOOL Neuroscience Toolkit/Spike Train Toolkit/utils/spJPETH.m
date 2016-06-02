function out=spJPETH(fhandle, varargin)
% spJPETH returns  jpoint peri-event time histograms
% 
% Example:
% out= spJPETH(fhandle, ParamName1, ParamValue1.....)
% out= spJPETH(channels, ParamName1, ParamValue1.....)
%
% Inputs are string/vlaue pairs
%     'Trigger'               Trigger channel (single channel)
%     'Sources'               List of source channels
%     'Start'                 Start time for processing (in seconds)
%     'Stop'                  End time for processing (in seconds)
%     'Duration'              Duration of the required correlation (in seconds)
%     'BinWidth'              Binwidth (in seconds)
%     'PercentPreTime'        Percentage pre-time (% of Duration)
%     'SweepsPerAverage'      Number of triggers to use for each average.
%                                 Set to zero to use all triggers. Otherwise, if 
%                                 SweepsPerAverage is less than the number
%                                 of available triggers, multiple event 
%                                 correlations will be returned, each using
%                                 SweepsPerAverage triggers
%     'RetriggerFlag'         If true, all triggers will be used 
%                                 (typical for an event correlation)
%                             If false, triggers falling during a preceding
%                                 sweep will be ignored (typical for a PETH)
%
% NB spEventCorrelation calls the rasterprep m-file or the shadowing
% m-file if rasterprep.cpp has not been compiled for the current platform
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/09
% Copyright © The Author & King's College London 2009-
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
        case 'mode'
            AnalysisMode=varargin{i+1};
        case 'symmetric'
            SymmetryFlag=varargin{i+1};
        case 'filter'
            Filter=varargin{i+1};
        otherwise
            % Do nothing - may be argument for post-processing function
    end
end


[fhandle channels]=scParam(fhandle);

tu=channels{findFirstChannel(channels{:})}.tim.Units;
BinWidth=BinWidth*(1/tu);
Duration=Duration*(1/tu);
Start=Start*(1/tu);
Stop=Stop*(1/tu);
pt=PercentPreTime*0.01*Duration;

trig=getValidTriggers(channels{Trigger(1)}, Start, Stop);
% Limit triggers - use complete sweeps only
trig=trig(trig>Start+pt);
trig=trig(trig<Stop-Duration+pt);

P=cell(length(Sources));

for k=1:length(Sources)
    for m=1:length(Sources)
        if SymmetryFlag==0 && m<k
            continue
        else
            % Get valid events on each channel
            sp1=getValidTriggers(channels{Sources(k)}, Start, Stop);
            sp2=getValidTriggers(channels{Sources(m)}, Start, Stop);
            
            % Construct the object
            obj=jpeth(trig, sp1, sp2, BinWidth, Duration, pt, tu);
            % set selected mode for display
            obj=setMode(obj, AnalysisMode);
            obj=setFilter(obj, Filter);
            obj=setLabel(obj, [num2str(Sources(k)) '->' num2str(Sources(m)) '[Trig' num2str(Trigger(1)) ']' ]);  
            P{k,m}=obj;
        end
    end
end

Q=scPrepareResult(P, {Sources Sources}, channels);
s.data=Q;
s.options=@LocalCreateMenu;

s.plotstyle={@plot};
s.viewstyle='Custom';
s.displaymode='Custom';
s.datasource=fhandle;% 26.09.09
s.details=[];
s.title='Joint peri-event time histogram';

out=sigTOOLResultData(s);
if nargout==0
    plot(out);
end

return
end

function LocalPrintPreview(hObject, EventData)
[panel subs resultobj]=LocalGetParams(hObject);
resultobj.data={'' num2str(subs(1)); num2str(subs(2)) resultobj.data{subs(1), subs(2)}};
f=plot(resultobj);
obj=getappdata(f,'sigTOOLResultView');
printpreview(obj);
delete(f);
return
end

function LocalExport(hObject, EventData)
[panel subs resultobj]=LocalGetParams(hObject);
assignin('base', 'jpethobj',resultobj.data{subs(1), subs(2)});
return
end

function LocalSpreadsheet(hObject, EventData)
return
end

function LocalChangeMode(hObject, EventData)
[panel subs resultobj]=LocalGetParams(hObject);
resultobj.data{subs(1), subs(2)}=...
    setMode(resultobj.data{subs(1), subs(2)}, get(hObject, 'Label'));
plot(panel, resultobj.data{subs(1), subs(2)});
setappdata(ancestor(panel,'figure'), 'sigTOOLResultData', resultobj);
return
end

function LocalChangeDisplay(hObject, EventData)
[panel subs resultobj]=LocalGetParams(hObject);
switch get(hObject, 'Label')
    case 'Image'
        f=@imagesc;
    case 'Contour'
        f=@contour;
    case 'Surface'
        f=@surf;
end
resultobj.data{subs(1), subs(2)}=...
    setDisplay(resultobj.data{subs(1), subs(2)}, f);
setappdata(ancestor(panel,'figure'), 'sigTOOLResultData', resultobj);
plot(panel, resultobj.data{subs(1), subs(2)});
return
end


function LocalChangeFilter(hObject, EventData)
[panel subs resultobj]=LocalGetParams(hObject);
switch get(hObject, 'Label')
    case 'None'
        f=[];
    otherwise
        f=ones(str2num(get(hObject, 'Label')));
        f=f/sum(f(:));
end
resultobj.data{subs(1), subs(2)}=...
    setFilter(resultobj.data{subs(1), subs(2)}, f);
setappdata(ancestor(panel,'figure'), 'sigTOOLResultData', resultobj);
plot(panel, resultobj.data{subs(1), subs(2)});
return
end

function m=LocalCreateMenu()
m=uicontextmenu();
h=uimenu(m, 'Label', 'Mode');
c=methods('jpeth');
idx=strfind(c, 'get');
for k=1:length(idx)
    if isempty(idx{k})
        c{k}=[];
    else
        switch c{k}
            case {'getMatrix' 'getXcorr' 'getBinWidth' 'getCoincidence' 'getMode' 'getLabel'}
                c{k}=[];
            otherwise
                str=c{k};
                c{k}=str(4:end);
        end
    end
end
idx=1;
for k=1:length(c)
    if ~isempty(c{k})
        c1{idx}=c{k}; %#ok<AGROW>
        idx=idx+1;
    end
end
for k=1:length(c1)
    uimenu(h, 'Label', c1{k}, 'Callback', @LocalChangeMode);
end

h=uimenu(m, 'Label', 'Display');
uimenu(h, 'Label', 'Image', 'Callback', @LocalChangeDisplay);
uimenu(h, 'Label', 'Contour', 'Callback', @LocalChangeDisplay);
uimenu(h, 'Label', 'Surface', 'Callback', @LocalChangeDisplay);

h=uimenu(m, 'Label', 'Filter Width');
uimenu(h, 'Label', 'None', 'Callback', @LocalChangeFilter);
uimenu(h, 'Label', '3', 'Callback', @LocalChangeFilter);
uimenu(h, 'Label', '5', 'Callback', @LocalChangeFilter);
uimenu(h, 'Label', '7', 'Callback', @LocalChangeFilter);
uimenu(h, 'Label', '9', 'Callback', @LocalChangeFilter);

uimenu(m, 'Label', 'Print Preview', 'Callback', @LocalPrintPreview);
uimenu(m, 'Label', 'View Spreadsheet', 'Callback', @LocalSpreadsheet,...
    'Enable', 'off');

uimenu(m, 'Label', 'Export to MATLAB', 'Callback', @LocalExport);
return
end


function [panel subs resultobj]=LocalGetParams(hObject)
panel=hittest();
subs=getappdata(panel,'AxesSubscript');
resultobj=getappdata(ancestor(panel,'figure'), 'sigTOOLResultData');
return
end