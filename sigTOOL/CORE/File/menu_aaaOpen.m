function varargout=menu_aaaOpen(varargin)
% menu_aaaOpen is the sigTOOL menu gateway to the scOpen function
%
% scOpen is called to load data from a kcl file into sigTOOL using memory 
% mapping via the MATLAB memmapfile function
%
% Examples:
% menu_aaaOpen(0) passes back details needed to populate the File/Open menu
% item in the sigTOOL main figure window
%
% menu_aaaOpen() with no input arguments invokes uigetfile to open a sigTOOL
% kcl file. The function then populates the figure window with data from 
% the opened file or, if the figure is already populated,invokes another
% instance of sigTOOL. This is the format of the call to menu_aaaOpen from
% the sigTOOL menu bar (i.e. the menu item's 'callback')
%
% The sigTOOL channel array is placed in the figure's application data area
% in a field labeled 'channels'.
% 
% See also sigTOOL, scOpen, memmapfile, uigetfile
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 10/06
% Copyright © The Author & King's College London 2006-
%
% Acknowledgements:
% Revisions: 08.08 Support for multiple files 

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='Open';
    tmp.Icon=scGetIcon('FileOpen.png');
    tmp.Tip='Open sigTOOL data file';
    varargout{3}=tmp;
    return
end



if nargin>=2
    [button fhandle]=gcbo;
    Filing=getappdata(fhandle,'Filing');
    if isempty(Filing) || isempty(dir(Filing.OpenSaveDir))
        Filing.OpenSaveDir='';
    end
    [name, pathname]=uigetfile([Filing.OpenSaveDir '*.kcl'],...
        'MultiSelect', 'on');
    if isnumeric(name) && name==0
        return
    end
    Filing.OpenSaveDir=pathname;
    setappdata(fhandle,'Filing',Filing);
    save(getappdata(fhandle,'PreferencesFile'),'-append','Filing');
    
    if ~iscell(name)
        name={name};
    end
    
    % Single file or first in list
    if isappdata(fhandle,'channels')==0
        % The current figure is empty...
        set(fhandle,'Name', name{1});
        [channels DataView]=scOpen([pathname name{1}]);
        setappdata(fhandle,'channels',channels);
        scCreateDataView(fhandle);
        scProcessDataView(fhandle, DataView);
    else
        %... or not, so invokes a new instance of sigTOOL
        fhandle=sigTOOL([pathname name{1}]);
        set(fhandle,'Name', name{1});
    end
    
    % Any others
    if length(name)>1
        for k=2:length(name)
            fh=sigTOOL([pathname name{k}]);
            set(fh,'Name', name{k});
            scRemap()
        end
    end
    
    figure(fhandle);
    
end



