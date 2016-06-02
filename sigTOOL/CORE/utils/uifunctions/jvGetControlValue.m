function val=jvGetControlValue(hObject)
% jvGetControlValue returns the values from a jvcontrol
%
% Example:
% val=jvGetControlValue(hObject)
%
%
%
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 07/07
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:



style=get(hObject,'UIClassID');

switch style
    case {'ComboBoxUI'}
        if (strcmp(class(hObject),'jcontrol') || strcmp(class(hObject),'hgjavacomponent'))...
                && strcmpi(get(hObject,'Tag'),'timemenu')
            % Start or stop menu
            val=FetchTime(hObject);
        else
            %Channel selector or other JComboBox
            val=get(hObject.Editor.getEditorComponent(),'Text');
            if any(~(isstrprop(val,'digit') | isstrprop(val, 'wspace') | isstrprop(val, 'punct')))==0
                % If purely numeric use textpane contents
                val=str2num(val); %#ok<ST2NM>
            elseif strcmp(val,'Selected')
                val=scGetChannelTree(ancestor(hObject.hghandle, 'figure'), 'selected');%08.11.08
            else
                % Otherwise retrieve value based on selected item
                v=get(hObject,'SelectedIndex');
                ReturnValues=getappdata(hObject,'ReturnValues');
                if isempty(ReturnValues)
                    % Nothing here, return combobox text as string
                    val=lower(val);
                else
                    % Lookup ReturnValue
                    val=ReturnValues{v+1};
                    if ischar(val)
                        % If it is a string, force all lower case
                        val=lower(val);
                    end
                end
            end
        end
    case {'ScrollPaneUI'}
        h=hObject.hgcontrol.Viewport.getComponents();
        switch get(h(1), 'Type')
            case {'javax.swing.JTextPane' 'javax.swing.JTextArea'}
                val=char(h(1).getText());
            otherwise
                v=get(h(1),'SelectedIndices')+1;
                ReturnValues=getappdata(h(1),'ReturnValues');
                val=cell(1,length(v));
                for k=1:length(v)
                    val{k}=ReturnValues{v(k)};
                end
                if length(val)==1
                    val=val{1};
                end
        end
    case {'CheckBoxUI'}
        val=hObject.isSelected();
    case {'TextFieldUI'}
        val=char(hObject.getText());
    case {'ColorChooserUI'}
        val=hObject.getColor;
    otherwise
        val=[];
end

return
end



%--------------------------------------------------------------------------
function time=FetchTime(hObject)
%--------------------------------------------------------------------------
% FetchTime returns the time from a TimeMenu JComboBox
str=get(hObject,'SelectedItem');
fhandle=get(get(hObject,'Parent'),'Parent');
ah=findobj(fhandle,'type','axes');
XLim=get(ah(1),'XLim');
switch str
    case 'Data Minimum'
        time=scMinTime(fhandle);
    case 'Data Maximum'
        time=scMaxTime(fhandle);
    case 'Axes Minimum'
        time=XLim(1);
    case 'Axes Maximum'
        time=XLim(2);
    otherwise
        if ~isempty(strfind(str,'Cursor'))
            %Get a Cursor position
            str=strrep(str,'Cursor ','');
            n=str2double(str);
            time=GetCursorLocation(fhandle,n);
        else
            % String type by user
            time=str2double(str);
        end
        
end
return
end
