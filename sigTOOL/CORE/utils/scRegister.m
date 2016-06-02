function scRegister(fhandle)
% scRegister utility to register sigTOOL
% 
% Example:
% scRegister(fhandle)
%
% Auto send of emails requires that the MATLAB preferences are set up
% If auto send fails, use the usual email utility on your PC. The message
% will be copied automatically to the system clipboard for pasting.
%
% See also: sendmail
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/10
% Copyright © The Author & King's College London 2010-
% -------------------------------------------------------------------------

if nargin==0
    fhandle=gcf;
end

% Panel
p=jvPanel('Title', 'Register sigTOOL', 'Position', [0.1 0.1 0.8 0.8]);


% Usage
p=StandardEmailDetails(p, 'sigTOOL:Register');

p=jvElement(p, 'Component', 'javax.swing.JLabel', 'Label', 'x_______________________sigTOOL Use_______________________x',...
    'Position', [0.1 0.65 0.65 0.05]);


p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'General Waveform Analysis',...
    'Position', [0.1 0.6 0.35 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Local Field Potentials',...
    'Position', [0.4 0.6 0.35 0.1]);


p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Spike Train Analysis',...
    'Position', [0.1 0.55 0.35 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Spike Recognition',...
    'Position', [0.4 0.55 0.35 0.1]);


p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Ion Channel Analysis',...
    'Position', [0.1 0.5 0.35 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'EMG',...
    'Position', [0.4 0.5 0.35 0.1]);


p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'ECG or Evoked potentials',...
    'Position', [0.1 0.45 0.35 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Data Import Only',...
    'Position', [0.4 0.45 0.35 0.1]);

% Platforms
p=jvElement(p, 'Component', 'javax.swing.JLabel', 'Label', 'x_______Target platforms______x',...
    'Position', [0.65 0.65 0.25 0.05]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Windows 32bit',...
    'Position', [0.7 0.6 0.3 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Windows 64bit',...
    'Position', [0.7 0.55 0.3 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Linux 32bit',...
    'Position', [0.7 0.5 0.3 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Linux 64bit',...
    'Position', [0.7 0.45 0.3 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Intel Mac 32bit',...
    'Position', [0.7 0.4 0.3 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Intel Mac 64bit',...
    'Position', [0.7 0.35 0.3 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'G3 or G4 Mac',...
    'Position', [0.7 0.3 0.3 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Sun Solaris 2 SPARC',...
    'Position', [0.7 0.25 0.3 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Sun Solaris',...
    'Position', [0.7 0.2 0.3 0.1]);


% Registration type
p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Register',...
    'Position', [0.2 0.1 0.2 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Subscribe',...
    'Position', [0.4 0.1 0.2 0.1]);

p=jvElement(p, 'Component', 'javax.swing.JCheckBox', 'Label', 'Unsubscribe',...
    'Position', [0.6 0.1 0.2 0.1]);

warning('off', 'MATLAB:namelengthmaxexceeded');
p=jvElement(p, 'Component', 'javax.swing.JLabel', 'Label', 'Registration will be acknowledged Subscribers will receive occasional emails/news',...
    'Position', [0.2 0.05 0.8 0.05]);
warning('on', 'MATLAB:namelengthmaxexceeded');

% Message
temp=javax.swing.JButton;
str=sprintf('<<Locale=%s>>\t\t*Java Locale setting\n<<COUNTRY=%s>>\n<<Java Language=%s>>\n\n<<sigTOOLVersion=%g>>\t*sigTOOL Version\n',...
    char(temp.getLocale()), char(temp.getLocale.getDisplayCountry()), char(temp.getLocale.getDisplayLanguage()), scVersion('nodisplay'));
str=sprintf('%s\n*SYSTEM INFO\n%s\n%s\n%s\n%s\n%s\n', str, computer(), getPlatform(),...
    version(), version('-java'), char(javax.swing.UIManager.getLookAndFeel()));
a=ver();
a={a.Name}';
for k=1:numel(a)
    str=sprintf('%s\n<<%s>>', str, a{k});
end

try
a=memory();
str=sprintf('%s\n\n<Memory:\t%g\t%g\t%g>\n',str,a.MaxPossibleArrayBytes,a.MemAvailableAllArrays,a.MemUsedMATLAB);
catch
end

try
    warning('off', 'MATLAB:maxNumCompThreads:Deprecated');
    str=sprintf('%s\n<MaxThreads=%d>\n\n', str, maxNumCompThreads());
    warning('on','MATLAB:maxNumCompThreads:Deprecated');
catch
end


p=jvElement(p, 'Component', 'javax.swing.JScrollPane', 'Label', 'Message (Editable)',...
    'Position', [0.1 0.2 0.55 0.2], 'DisplayList',str);

warning('off', 'MATLAB:namelengthmaxexceeded');
h=jvDisplay(fhandle, p);
warning('off', 'MATLAB:namelengthmaxexceeded');

h{1}.GeneralWaveformAnalysis.setSelected(false);
h{1}.LocalFieldPotentials.setSelected(false);
h{1}.SpikeTrainAnalysis.setSelected(false);
h{1}.SpikeRecognition.setSelected(false);
h{1}.IonChannelAnalysis.setSelected(false);
h{1}.EMG.setSelected(false);
h{1}.ECGorEvokedpotentials.setSelected(false);
h{1}.DataImportOnly.setSelected(false);

h{1}.Unsubscribe.setSelected(false);

h{1}.Windows32bit.setSelected(false);
h{1}.Windows64bit.setSelected(false);
h{1}.Linux32bit.setSelected(false);
h{1}.Linux64bit.setSelected(false);
h{1}.IntelMac32bit.setSelected(false);
h{1}.IntelMac64bit.setSelected(false);
h{1}.G3orG4Mac.setSelected(false);
h{1}.SunSolaris2SPARC.setSelected(false);
h{1}.SunSolaris.setSelected(false);

switch computer()
    case 'PCWIN'
        h{1}.Windows32bit.setSelected(true);
    case 'PCWIN64'
        h{1}.Windows64bit.setSelected(true);
    case 'GLNX86'
        h{1}.Linux32bit.setSelected(true);
    case 'GLNXA64'
        h{1}.Linux64bit.setSelected(true);
    case 'MACI'
        h{1}.IntelMac32bit.setSelected(true);
    case 'MACI64'
        h{1}.IntelMac64bit.setSelected(true);
    case 'MAC'
        h{1}.G3orG4Mac.setSelected(true);
    case 'SOL2'
        h{1}.SunSolaris2SPARC.setSelected(true);
    case 'SOL64'
        h{1}.SunSolaris.setSelected(true);
end

h{1}.ApplyToAll.setVisible(false);
h{1}.AckText.setEnabled(true);
h{1}.AckText.setText('Click OK to preview Email');
h{1}.AckText.setForeground(java.awt.Color(0,0,1));


uiwait();


% NOW BUILD THE MESSAGE
r=getappdata(fhandle, 'sigTOOLjvvalues');

if isempty(r)
    % User canceled
    return
end

% Build the preview
p=jvPanel('Title', 'Register sigTOOL', 'Position', [0.1 0.1 0.8 0.8]);

p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'From',...
    'Position', [0.1 0.9 0.8 0.155],'DisplayList', r.From);
p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'To',...
    'Position', [0.1 0.8 0.8 0.155],'DisplayList',r.To);
p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'Subject',...
    'Position', [0.1 0.7 0.8 0.155],'DisplayList',r.Subject);

str=sprintf('<<Affiliation=%s>>\n%s\n', r.University, r.Message);

names=fieldnames(r);
for k=3:length(names)-5
    if ~isempty(r.(names{k})) && isscalar(r.(names{k}))
    str=sprintf('%s<<%s=%d>>\n', str, names{k}, r.(names{k}));
    end
end

p=jvElement(p, 'Component', 'javax.swing.JScrollPane', 'Label', 'Message (Editable)',...
    'Position', [0.1 0.2 0.8 0.4], 'DisplayList',str);
h=jvDisplay(fhandle, p);

h{1}.ApplyToAll.setVisible(false);
h{1}.AckText.setText('Click OK to send Email');
h{1}.AckText.setForeground(java.awt.Color(0,0,1));

uiwait();

r=getappdata(fhandle, 'sigTOOLjvvalues');

if isempty(r)
    return
end

% Send the message

try
    % Requires MATLAB preferences to be set up for email
    sendmail(r.To,r.Subject,r.Message);
catch
    % Otherwise give message - N.B. web mailto: can cause problems so avoid
    % use
    clipboard('copy', r.Message);
    msgbox('Unable to send email. The message has been placed on your system clipboard. Paste this into your usual email utility and send to sigTOOL@kcl.ac.uk to register/subscribe/unsubscribe', 'Send Mail Failed');
end

return
end


