function address=GetEmailAddress()
% GetEmailAddress returns the email address
% 
% Example
% address=GetEmailAddress()
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

server = getpref('Internet','SMTP_Server','');
address = javax.mail.internet.InternetAddress(server);
end