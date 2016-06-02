function History=StandardHeader()
% StandardHeader private function used in history recording
% 
% Example:
% History=StandardHeader()
%     returns a standard history header 
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

History.main='function thisview=MyFunctionName(varargin)';
History.functions={};
History.main=sprintf('%s\n%% scHistory m-file generated from sigTOOL.\n%% Author: Malcolm Lidierth © 2006 King%cs College London\n\n',...
    History.main, 39);
History.main=sprintf('%s%% Standard call to open file specified by first input argument\n',History.main);
History.main=sprintf('%sif nargin>=1\nthisview=sigTOOL(varargin{1});\nelse\nerror(''%%s: no input file was specified'', mfilename())\nend\n\n',History.main);

return
end
