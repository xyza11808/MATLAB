function varargout=menu_ImportMultiMedia(varargin)
% menu_ImportMultiMedia sigTOOL gateway to Micah Richert's mmread function
%
% You may need to download these files from
% %<a href="http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8028&objectType=file">LinkOut</a>
%
% Toolboxes required: Uses Windows DirectX - therefore Windows only
%
%
% Acknowledgements: This simply links to Micah Richert's code via
% ImportMultiMedia
%
% Revisions:
%
% Author: Malcolm Lidierth 11/06
% Copyright © King’s College London 2006


% Called as menu_ImportMultimedia(0)
if nargin==1 && varargin{1}==0
    if ispc==1
        varargout{1}=true;
    else
        varargout{1}=false;
    end
    varargout{2}='MultiMedia via mmread [with audio]';
    varargout{3}=[];
    return
end

if isempty(which('mmread'))
    str=sprintf('To import multimedia files you need to download Michah Richert''s mmread function\n');
    str=sprintf('%sThe files are available at:\nhttp://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8028&objectType=file\n',str);
    str=sprintf('%sPlace the files in the ...sigTOOL\\CORE\\File\\menu_Import\\group_MultiMedia Formats\\Micah Richert''s mmread folder or place them elsewhere\nand set up the MATLAB path manually',str);
    errordlg(str, 'Download needed');
    disp('http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8028&objectType=file');
    return
end

if nargin>=2
    scImport(@ImportMultiMedia, '*.mpg;*.avi;*.wmv;*.asf;*.wav;*.mp3;*.gif;*.jpg' );
end
end

