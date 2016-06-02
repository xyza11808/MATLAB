function varargout=menu_aaOpenResult(varargin)
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 10/09
% Copyright © The Author & King's College London 2009-
%
% Acknowledgements:
% Revisions: 08.08 Support for multiple files 

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='Load Result';
    varargout{3}=[];
    return
end



if nargin>=2
    [fname,pname] = uigetfile('*.mat', 'Open sigTOOL Result');
    if ischar(fname)
        load(fullfile(pname, fname));
        if exist('sigTOOLResultStructure')==1
            obj=sigTOOLResultData(sigTOOLResultStructure);
            plot(obj);
        else
            errordlg('No data, the MAT-file may not contain a sigTOOL result',...
                'sigTOOL Open');
        end
    end
    return
end
    
end



