function varargout=menu_ImportWAV(varargin)
% menu_ImportWAV gateway to ImportWav from the sigTOOL GUI
%
% ImportWAV provides a platform-independent route to read Windows WAV files
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 07/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportWAV(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Microsoft wave file (WAV)';
    varargout{3}=sprintf(...
        'Author: Malcolm Lidierth\n© 2006 King’s College London');
    return
end


if nargin>=2
    scImport(@ImportWAV, '*.wav');
end
end

