function [TF unused]=everynthepoch(obj)
% everynthepoch - sigTOOL event/epoch filter function
%
% Example:
% [TF match]=everynthepoch(channel)
% [TF match]=everynthepoch(channel, match)
% 
% If match is not supplied on input, the user will be prompted to supply it
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

Position=[0.45 0.45 0.25 0.25];
s=jvPanel('Title', 'Select Every Nth Epoch',...
    'Position', Position,...
    'ToolTipText', '',...
    'AckText','');
s=jvElement(s, 'Component', 'javax.swing.JComboBox',...
    'Label', 'First Event(or Epoch)',...
    'Position', [0.1 0.65 0.8 0.1],...
    'DisplayList', {'1' '2' '3' '4', '5' '6' '7' '8' '9' '10'});
s=jvElement(s, 'Component', 'javax.swing.JComboBox',...
    'Label', 'Use every N',...
    'Position', [0.1 0.4 0.8 0.1],...
    'DisplayList', {'1' '2' '3' '4', '5' '6' '7' '8' '9' '10'});

h=jvDisplay(gcf,s);
h{1}.ApplyToAll.Visible='off'; %#ok<NASGU>
uiwait();
s=getappdata(gcf, 'sigTOOLjvvalues');


if isempty(s)
    TF=[];
else
    TF=zeros(1, size(obj.tim,1));
    TF(s.FirstEvent:s.UseeveryN:size(obj.tim,1))=true;
end
unused=[];
return
end