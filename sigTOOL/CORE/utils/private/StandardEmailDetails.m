function p=StandardEmailDetails(p, str)

try
    emstr=getpref('Internet','E_mail');
catch
    emstr='';
end

p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'From',...
    'Position', [0.125 0.9 0.35 0.155],'DisplayList', emstr);
p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'To',...
    'Position', [0.525 0.9 0.35 0.155],'DisplayList','sigTOOL@kcl.ac.uk');
p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'Subject',...
    'Position', [0.125 0.8 0.75 0.155],'DisplayList',sprintf('<<%s>>',str));
p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'University (or Affiliation)',...
    'Position', [0.125 0.7 0.75 0.155],'DisplayList','');
return
end