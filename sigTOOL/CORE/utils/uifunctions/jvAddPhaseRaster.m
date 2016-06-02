function h=jvAddPhaseRaster(h)
% jvAddPhaseRaster addpanel function
% 
% Example:
% h=jvAddPhaseRaster(h)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------


Height=0.09;
Top=0.75;

h=jvAddPanel(h, 'Title', 'Details',...
    'dimension', 0.6);



h=jvElement(h{end},'Component', 'javax.swing.JComboBox',...
    'Position',[0.1 Top-(2*Height) 0.8 Height],...
    'DisplayList', {'1' '2' '5'},...
    'Label', 'Duration(cycles)',...
    'ToolTipText', 'Duraion of average (s)');



h=jvElement(h{end},'Component', 'javax.swing.JComboBox',...
    'Position',[0.1 Top-(4*Height) 0.8 Height],...
    'DisplayList', {'0' '10' '20' '50'},...
    'ReturnValues', {0 10 20 50},...
    'Label', 'PreTime(%)',...
    'ToolTipText', 'Pre-trigger time');







return
end


