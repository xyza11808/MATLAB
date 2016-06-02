function s=jvElement(s, varargin)
% jvElement adds components to a GUI panel
% 
% jvElement is called after jvPanel, to populate a GUI panel e.g.
% s=jvPanel('Title', 'Play Sound', 'Position', [0.4 0.4 0.2 0.2]);
% s=jvElement(s, 'Component','javax.swing.JComboBox',...etc
%
% The GUI is displayed by calling jvDisplay(figurehandle, s) which returns
% handles to the invidual GUI components and stores the handles in the 
% relevant figure application data area.
%               
% Examples
% s=jvElement();
%     returns a structure with empty fields
% s=jvElement(s, PropName1, PropValue1,....);
%     adds a field to the structure s with the name given by the ''Label''
%     property value provided in the input argument list. The GUI elements
%     need to be created subsequently by calling h=jvDisplay(s)
%
% After a panel has been created it can be supplemented with further panels
% by calling jvAddPanel. The added panel is populated by calling jvElement
% with a structure containing the panel handle e.g
% h=jvDisplay(......);
% h=jvAddPanel(.....)
% h=jvElement(h{2}, PropName1, PropValue1,.....);
%     creates an additional field in the structure h{2} which contains handles
%     previously returned by a call to jvDisplay or jvAddPanel.
%     NOTE THAT THE OUTPUT IS h, NOT h{2} - the jvfunctions use the
%     application data area to access all elements
%
% Property name/value pairs are:
%     
%     Component:      the name of the GUI component e.g javax.swing.JComboBox
%                           (string)
%     Label:          the label to attach to the component (compulsory field)
%                           (string)
%     Position:       the components position in the parent container 
%                           (4 element vector - normalized units)
%     DisplayList:    the list of strings to display in the GUI
%                           (cell array - left empty for some components)
%     ReturnValues:   the numeric values to return, one entry for each item
%                     is DisplayList
%                           (cell array - left empty for some components).
%     ToolTipText:    tool tip text for the component
%                           (string)
%
% See also jvPanel, jvDisplay
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------


% Property List
names={'Component', 'Label', 'Position', 'DisplayList', 'ReturnValues', 'ToolTipText'};

% Create a structure with empty fields

s2.Component='';
s2.Position=[];
s2.DisplayList={};
s2.ReturnValues={};
s2.ToolTipText='';
s2.Label='';

if nargin==0
    % Return empty fields
    s=s2;
    return
end

% Sort the property name/value pairs
propertyname=cell(1,length(varargin)/2);
propertyvalue=cell(1,length(varargin)/2);
idx=1;
for i=1:2:length(varargin)-1
    propertyname{idx}=varargin{i};
    propertyvalue{idx}=varargin{i+1};
    idx=idx+1;
end

% Assign them in s2
for i=1:length(propertyname)
    TF=strcmp(propertyname{i}, names);
    if sum(TF)~=0
        s2.(propertyname{i})=propertyvalue{i};
    else
        error('jvElement: Invalid field name');
    end
end

if ~isa(s.Panel,'jcontrol')
    % s is a structure being built for jvDisplay 
    ok=false;
    for i=1:length(propertyname)
        if strcmp(propertyname{i},'Label')
            str=propertyvalue{i};
            str=jvMakeFieldName(str);
            s.(str)=s2;
            ok=true;
        end
    end
    if ok==false
        % No Label property given
        error('jvElement: You must include a ''Label'' property name/value pair');
    end
else
    % s contains jcontrol objects returned by jvDisplay and being built via
    % jvAddPanel or similar
    ReturnValues=s2.ReturnValues;
    h=jvCreateUI(s, s2.Component, s2.Label, s2.ToolTipText,...
        s2.Position, s2.DisplayList, ReturnValues);
    appdata=getappdata(ancestor(s.Panel,'figure'),'sigTOOLjvhandles');
    % find target panel in appdata
    for idx=1:length(appdata)
        if s.Panel.equals(appdata{idx}.Panel.hgcontrol)
            break;
        end
    end
    % Update it
    appdata{idx}=h;
    setappdata(ancestor(s.Panel,'figure'),'sigTOOLjvhandles',appdata);
    % and return all panels
    s=appdata;
end
return
end
