function varargout=menu_ImportMultiMediaMATLAB(varargin)
% menu_ImportMultiMediaMATLAB sigTOOL gateway
%
%
% Revisions:
%
% Author: Malcolm Lidierth 01/10
% Copyright © King’s College London 2010-


% Called as menu_ImportMultimedia(0)
if nargin==1 && varargin{1}==0
    if ispc==1
        varargout{1}=true;
    else
        varargout{1}=false;
    end
    varargout{2}='MATLAB MultiMedia [no audio]';
    varargout{3}=[];
    return
end


if nargin>=2
    scImport(@ImportMultiMediaMATLAB, '*.mpg;*.asf;*.asx;*.avi;*.wmv;*.mp3;*.mp4;' );
end
end

