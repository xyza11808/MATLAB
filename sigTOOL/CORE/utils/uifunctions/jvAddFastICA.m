function h=jvAddFastICA(h)
% jvAddFastICA addpanel function
% 
% Example:
% h=jvAddFastICA(h)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------


Height=0.09;
Top=0.8;

h=jvAddPanel(h, 'Title', 'Details',...
    'dimension', 0.6);


h=jvElement(h{end},'Component', 'javax.swing.JCheckBox',...
    'Position',[0.15 Top-(2*Height) 0.8 Height],...
    'Label', 'Save results to sigTOOL',...
    'ToolTipText', 'Add the ICs to the sigTOOL view as new channels');

h=jvElement(h{end},'Component', 'javax.swing.JCheckBox',...
    'Position',[0.15 Top-(3*Height) 0.8 Height],...
    'Label', 'Save results to file',...
    'ToolTipText', 'Save the Icasso structure as a MAT-file');

h=jvElement(h{end},'Component', 'javax.swing.JCheckBox',...
    'Position',[0.15 Top-(4*Height) 0.8 Height],...
    'Label', 'Save results to MATLAB',...
    'ToolTipText', 'Save the Icasso structure to the base workspace');

return
end


