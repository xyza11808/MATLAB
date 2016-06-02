function scBugReport(fhandle)
% scBugReport utility to email bug reports to sigTOOL
% 
% Example:
% scBugReport(fhandle)
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

% Panel
p=jvPanel('Title', 'sigTOOL:Bug Report', 'Position', [0.1 0.1 0.8 0.8]);


% Addresses/subject
p=StandardEmailDetails(p, 'sigTOOL:Bug Report');



% System Info
str=sprintf('%s\n%s\n%s\n%s\n',computer(), getPlatform(), version(), version('-java'));
a=ver();
a={a.Name}';
for k=1:numel(a)
    str=sprintf('%s\n<<%s>>', str, a{k});
end
str=sprintf('%s\n<<sigTOOL Version=%g>>\n', str, scVersion('nodisplay'));
p=jvElement(p, 'Component', 'javax.swing.JScrollPane', 'Label', 'System Info',...
    'Position', [0.1 0.4 0.4 0.2], 'DisplayList',str);

p=jvElement(p, 'Component', 'javax.swing.JScrollPane', 'Label', 'Attach Files (N.B. These willed be zip compressed)',...
    'Position', [0.525 0.4 0.375 0.2], 'DisplayList','');

p=jvElement(p, 'Component', 'javax.swing.JButton', 'Label', 'Add',...
    'Position', [0.5+0.2/2 0.45 0.2 0.1], 'DisplayList','');

str=sprintf('\nWHAT DID YOU EXPECT TO HAPPEN?\nWHAT REALLY HAPPENED?\nPASTE IN ANY COMMAND WINDOW ERROR MESSAGES\nPLEASE PROVIDE ENOUGH DETAIL FOR US TO REPRODUCE THE ERROR\n');
p=jvElement(p, 'Component', 'javax.swing.JScrollPane', 'Label', 'Message (Type or paste your message here)',...
    'Position', [0.1 0.12 0.8 0.23], 'DisplayList',str);

warning('off', 'MATLAB:namelengthmaxexceeded');
h=jvDisplay(fhandle, p);
warning('off', 'MATLAB:namelengthmaxexceeded');

h{1}.Add.MouseClickedCallback={@EmailBrowse, h{1}.AttachFiles.getViewport.getView()};


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
Attachments=eval(['{' r.AttachFiles '}']);

% Build the preview
p=jvPanel('Title', 'sigTOOL:Bug Report', 'Position', [0.1 0.1 0.8 0.8]);

p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'From',...
    'Position', [0.1 0.9 0.8 0.155],'DisplayList', r.From);
p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'To',...
    'Position', [0.1 0.8 0.8 0.155],'DisplayList',r.To);
p=jvElement(p, 'Component', 'javax.swing.JTextField', 'Label', 'Subject',...
    'Position', [0.1 0.7 0.8 0.155],'DisplayList',r.Subject);


if ~isempty(Attachments)
    p=jvElement(p, 'Component', 'javax.swing.JLabel', 'Label', 'Attachments included (these will be sent in sgbug.zip)',...
    'Position', [0.1 0.05 0.8 0.155],'DisplayList','');
end

str=sprintf('<<Affiliation=%s>>\n%s%s%s\n', r.University, r.SystemInfo, r.Message, repmat('-',1,80));


p=jvElement(p, 'Component', 'javax.swing.JScrollPane', 'Label', 'Message',...
    'Position', [0.1 0.2 0.8 0.4], 'DisplayList',str);
h=jvDisplay(fhandle, p);

h{1}.ApplyToAll.setVisible(false);
h{1}.AckText.setText('Click OK to send Email');
h{1}.AckText.setForeground(java.awt.Color(0,0,1));

uiwait();


% SEND THE MESSAGE
r=getappdata(fhandle, 'sigTOOLjvvalues');
try
    % Requires MATLAB preferences to be set up for email
    if ~isempty(Attachments)
        filename=fullfile(tempdir(), 'sgbug.zip');
        zip(filename, Attachments);
        sendmail(r.To, r.Subject, r.Message, filename);
    else
        sendmail(r.To, r.Subject, r.Message);
    end
    
catch
    % Otherwise give message - N.B. web mailto: can cause problems so avoid
    % use
    if isfield(r, 'Message')
    clipboard('copy', r.Message);
    str=sprintf('Unable to send email. The message has been placed on your system clipboard. Paste this into your usual email utility and send to sigTOOL@kcl.ac.uk to continue\n\nAttachments have been zipped in:\n%s', filename);
    msgbox(str, 'Send Mail Failed');
    end
end

return
end



