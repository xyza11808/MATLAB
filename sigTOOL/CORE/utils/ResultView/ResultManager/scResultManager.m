function tp=scResultManager(fhandle, updateflag)
% scResultManager creates the result manager for a sigTOOL result view
%
% Example:
% tp=scResultManager(fhandle)
%
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%
% Revisions
% 05.09.09  Updated for more recent display modes
figure(fhandle);

Foreground=java.awt.Color(64/255,64/255,122/255);
Background=java.awt.Color(1,1,0.9);

% Check if result manager is already present
s=getappdata(fhandle, 'ResultManager');
if nargin==1 && ~isempty(s) || nargin==2 && updateflag==false
    tp=s.Panel;
    return
elseif nargin==2 && updateflag==true
    % Delete (if still valid) and recreate
        delete(s.Panel);
end

% Create a panel
tp.Panel=jcontrol(fhandle,'javax.swing.JPanel',...
    'Tag', 'sigTOOL:ResultManagerPanel',...
    'Foreground', Foreground,...
    'Background', Background,...
    'Border',javax.swing.BorderFactory.createTitledBorder('Result Manager'));
tp.Panel.Position=[0 0 0.15 1];
tp=DisplayMode(tp);
tp=Frames(tp);
tp=LineOptions(tp);
tp=Options3D(tp);
tp=AxesLimits(tp);
tp=AxesFeatures(tp);
tp=CameraTool(tp);
tp=ResetView(tp);
% Not implemented in this release
% tp=ResultOptionsButton(tp);
% tp=SketchPadButton(tp);

setappdata(fhandle, 'ResultManager', tp);
return
end

%-------------------------------------------------------------------------
function tp=Frames(tp)
%-------------------------------------------------------------------------
pos=getPosition(tp);
tp.Frames=jcontrol(tp.Panel, 'javax.swing.JTextField',...
    'Position',pos,...
    'Text','1:end');
addLabel(tp.Frames, 'Frames to display');

if tp.DisplayMode.isEnabled()==false
    tp.Frames.setEnabled(false);
end

tp.Frames.ActionPerformedCallback=@UpdateFrames;
return
end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function UpdateFrames(hObject, EventData) %#ok<INUSD>
%-------------------------------------------------------------------------
fhandle=ancestor(hObject.hghandle, 'figure');
str=char(hObject.getText());
if ~isempty(strfind(str, 'end'))
    result=getappdata(fhandle, 'sigTOOLResultData');
    data=result.data;
    endvalue=Inf;
    for i=2:size(data, 1)
        for j=2:size(data, 2)
            if ~isempty(data{i,j})
            endvalue=min(endvalue, size(data{i,j}.rdata, 1));
            end
        end
    end
    str=strrep(str, 'end', num2str(endvalue));
end
k=str2num(str); %#ok<ST2NM>

tp=getappdata(fhandle, 'ResultManager');

% 05.09.09 Revised
md=tp.DisplayMode.getSelectedItem();
switch md
    case {'Single Frame', 'Multiple Frames'}
        switch length(k)
            case 0
                return
            case 1
                txt=tp.DisplayMode.getSelectedItem();
                fcn=tp.DisplayMode.ActionPerformedCallback;
                tp.DisplayMode.ActionPerformedCallback=[];
                if ~strcmp(txt, 'Single Frame')
                    tp.DisplayMode.setSelectedItem('Single Frame');
                end
                tp.DisplayMode.ActionPerformedCallback=fcn;
                tp.Frames.setText(str);
            otherwise
                fcn=tp.DisplayMode.ActionPerformedCallback;
                tp.DisplayMode.ActionPerformedCallback=[];
                tp.DisplayMode.setSelectedItem('Multiple Frames');
                tp.DisplayMode.ActionPerformedCallback=fcn;
                tp.Frames.setText(str);
        end
    otherwise
        % No action
end

% Result data
h=findobj(fhandle, 'Tag', 'sigTOOL:ResultData');
set(h, 'Visible', 'off');
temp=get(h, 'UserData');
if iscell(temp)
    ID=cell2mat(temp);
else
    ID=temp;
end
TF=ismember(ID, k);
set(h(TF>0), 'Visible', 'on');

% Error data
h=findobj(fhandle, 'Tag', 'sigTOOL:ErrorData');
set(h, 'Visible', 'off');
if length(k)==1
    ID=cell2mat(get(h, 'UserData'));
    TF=ismember(ID, k);
    set(h(TF>0), 'Visible', 'on');
end

% Selected data objects
h=findobj(fhandle, 'Tag', 'sigTOOL:SelectedData');
set(h, 'Visible', 'off');
temp=get(h, 'UserData');
if iscell(temp)
    ID=cell2mat(temp);
else
    ID=temp;
end
TF=ismember(ID, k);
set(h(TF>0), 'Visible', 'on');
return
end
%-------------------------------------------------------------------------



