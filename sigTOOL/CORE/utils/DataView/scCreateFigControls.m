function h=scCreateFigControls(fhandle, MaxTime)
% scCreateFigControls displays standard uicontrols for a sigTOOL data view
%
% scCreateFigControls adds controls to a strip chart created with 
% scCreateDataView()
%
% Example:
% scCreateFigControls(fhandle, MaxTime)
%     MaxTime = maximum x-axis value (default 100)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 05/05
% Copyright © The Author & King's College London 2005-2007
% -------------------------------------------------------------------------

desc=scGetFigureType(fhandle);

if ~isempty(findobj(fhandle,'Tag',[desc 'XSlider']))
    % This figure already has the controls installed
    return
end

% Set up defaults
if nargin<2
    MaxTime=1;
end;
if MaxTime==0
    MaxTime=1;
end
% Is fhandle a sigTOOL view?
if isappdata(fhandle,'AxesList')
    % Get handles from application area - preserves order
    h=getappdata(fhandle,'AxesList');
else 
    % Reverse order if using findobj which returns LIFO
    h=findobj(fhandle, 'Type', 'Axes');
    h=h(end:-1:1);
    setappdata(fhandle,'AxesList',h);
end

% Find the last axes, ignoring zero handles
h=h(find(h~=0,1,'last'));
    
if isempty(h) || strcmpi(get(h, 'Type'), 'uipanel')
    % Empty or Custom objects in uipanels
    return
else
    subplot(h);
    % Create the axis controls
    h=scXAxisControls(fhandle, MaxTime);
end

              


