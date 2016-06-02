function varargout=menu_Preferences(varargin)
% menu_Preferences edits the sigTOOL preferences
% 
% Example:
% menu_Preferences(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Preferences';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;

Filing=getappdata(fhandle, 'Filing');
if isempty(Filing)
    Filing.OpenSaveDir='';
end
if ~isfield(Filing, 'ImportReplace')
    Filing.ImportReplace.Source='';
    Filing.ImportReplace.Target='';
end
    
% Create a structure for jvDisplay...
Position=[0.35 0.35 0.4 0.5];
s=jvPanel('Title', 'Filing Preferences',...
    'Position', Position,...
    'ToolTipText','',...
    'AckText','');

s=jvElement(s, 'Component', 'javax.swing.JTextField',...
    'Label', 'Replace' ,...
    'Position', [0.05 0.8 0.6 0.1],...
    'DisplayList', Filing.ImportReplace.Source);

s=jvElement(s, 'Component', 'javax.swing.JButton',...
    'Label', 'BrowseSource' ,...
    'DisplayList', 'Browse',...
    'Position', [0.68 0.8 0.3 0.1]);

s=jvElement(s, 'Component', 'javax.swing.JTextField',...
    'Label', 'With' ,...
    'Position', [0.05 0.6 0.6 0.1],...
    'DisplayList', Filing.ImportReplace.Target);

s=jvElement(s, 'Component', 'javax.swing.JButton',...
    'Label', 'BrowseTarget' ,...
    'DisplayList', 'Browse',...
    'Position', [0.68 0.6 0.3 0.1]);

s=jvElement(s, 'Component', 'javax.swing.JTextField',...
    'Label', 'Linux Bitmap Viewer',...
    'DisplayList', Filing.ExportBitmap,...
    'Position', [0.05 0.45 0.4 0.1]);

s=jvElement(s, 'Component', 'javax.swing.JButton',...
    'Label', 'BrowseBitmap' ,...
    'DisplayList', 'Browse',...
    'Position', [0.6 0.45 0.35 0.1]);

s=jvElement(s, 'Component', 'javax.swing.JTextField',...
    'Label', 'Linux Ducument Viewer',...
    'DisplayList', Filing.ExportVector,...
    'Position', [0.05 0.25 0.4 0.1]);

s=jvElement(s, 'Component', 'javax.swing.JButton',...
    'Label', 'BrowseDocViewer' ,...
    'DisplayList', 'Browse',...
    'Position', [0.6 0.25 0.35 0.1]);



h=jvDisplay(fhandle, s);
h{1}.ApplyToAll.setEnabled(0);
h{1}.BrowseSource.MouseClickedCallback={@Update h{1}.Replace};
h{1}.BrowseTarget.MouseClickedCallback={@Update h{1}.With};
h{1}.BrowseBitmap.MouseClickedCallback={@Update h{1}.BrowseBitmap};
h{1}.BrowseDocViewer.MouseClickedCallback={@Update h{1}.BrowseDocViewer}; %#ok<NASGU>
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end
Filing=getappdata(fhandle, 'Filing');
Filing.ImportReplace.Source=s.Replace;
Filing.ImportReplace.Target=s.With;
Filing.ExportBitmap=s.LinuxBitmapViewer;
Filing.ExportVector=s.LinuxDucumentViewer;
setappdata(fhandle, 'Filing', Filing);
scSavePreferences(fhandle);
return
end



function Update(hObject, EventData, target) %#ok<INUSL>
name=uigetdir(char(target.getText()));
target.setText(name);
return
end