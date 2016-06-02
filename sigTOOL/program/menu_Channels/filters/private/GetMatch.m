function match=GetMatch(str)
% GetMatch is a private helper function called by some event filters
% 
% 
% Example:
% match=GetMatch(str)
%
% where     str is the dialog title
%           match is a vector
% 
% For details see scApplyEventFilter
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

Position=[0.45 0.45 0.25 0.25];
s=jvPanel('Title', str,...
    'Position', Position,...
    'ToolTipText', '',...
    'AckText','');
s=jvElement(s, 'Component', 'javax.swing.JComboBox',...
    'Label', 'Values To Match',...
    'Position', [0.1 0.65 0.8 0.1],...
    'DisplayList', {'1' '2' '3' '4', '5' '6' '7' '8' '9' '10'});

%...and call it
h=jvDisplay(gcf,s);
h{1}.ApplyToAll.Visible='off'; %#ok<NASGU>
uiwait();
s=getappdata(gcf, 'sigTOOLjvvalues');
match=s.ValuesToMatch;
return
end