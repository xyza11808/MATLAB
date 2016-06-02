function s=jvPanel(varargin)
% jvPanel is used to initiate a new GUI panel
% 
% Example:
% s=jvPanel(PropName1, PropValue1,.....)
%     
% Valid property name/value pairs are:
%     Title:          The panel title
%                         (string)
%     Position:       Panel position in normalized units
%                         (4-element vector e.g. [0.4 0.4 0.2 0.2])
%     ToolTipText:    A pop-up description of what the panel does
%                         (string)
%     AckText:        An acknowledgment string naming authors/affiliations
%                     to display in the panel
%                         (string)
%
% To make the panel useful, add controls to it using jvElement. To invoke
% the GUI call jvDisplay.
%
% See also: jvElement, jvDisplay
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------


% Property List
names={'Title', 'Position', 'ToolTipText', 'AckText'};

s.Panel.Title='';
s.Panel.Position=[];
s.Panel.ToolTipText='';
s.AckText=' ';
s.OK=[];
s.Cancel=[];

% Sort the property name/value pairs
propertyname=cell(1,length(varargin)/2);
propertyvalue=cell(1,length(varargin)/2);
idx=1;
for i=1:2:length(varargin)-1
    propertyname{idx}=varargin{i};
    propertyvalue{idx}=varargin{i+1};
    idx=idx+1;
end

% Assign them in s.Panel
for i=1:length(propertyname)
    TF=strcmp(propertyname{i}, names);
    if sum(TF)~=0
        s.Panel.(propertyname{i})=propertyvalue{i};
    else
        error('jvPanel: Invalid field name');
    end
end

for i=1:length(propertyname)
    if strcmp(propertyname{i},'AckText')
        s.AckText=propertyvalue{i};
    end
end

return
end

    