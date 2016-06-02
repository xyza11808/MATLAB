function folder=scGetBaseFolder
% scGetBaseFolder returns the sigTOOL base folder
% 
% Example:
% folder=scGetBaseFolder()
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

folder=fileparts(which('sigTOOL'));
idx=strfind(folder,'program');
folder=folder(1:idx-1);

return
end
