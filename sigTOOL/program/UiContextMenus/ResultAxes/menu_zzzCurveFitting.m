function varargout=menu_zzzCurveFitting(varargin)
% menu_ViewDetails opens the result in the MATLAB variable editor
% 
% menu_ViewDetails(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='EzyFit Curve Fitting';
    varargout{3}=[];
    return
end


[button fhandle]=gcbo;
CurrentAxes=gca;
result=getappdata(fhandle, 'sigTOOLResultData');
idx=getappdata(gca, 'AxesSubscript');
data=result.data{idx(1),idx(2)};
try
    newf=figure('Name', get(fhandle,'Name'));
    subplot(1,1,1);
    plot(data.tdata,data.rdata(1,:), 'o', 'Tag', 'sigTOOL:ExportedData');
    efmenu;
catch %#ok<CTCH>
    button=questdlg('Error in curve fitting: EzyFit may not be installed', 'Curve Fitting',...
        'Visit website', 'Continue', 'Continue');
    if strcmp(button,'Visit website')
        web('http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=10176&objectType=file');
    else
        delete(newf);
        return
    end
end
% Stop EzyFit appearing in all windows
set(0,'DefaultFigureCreateFcn','');
h=findobj(newf, 'Type', 'uimenu', 'Label', 'EzyFit');
uimenu(h, 'Label', 'Export To sigTOOL', 'Callback', {@GetFit, CurrentAxes},...
    'Separator', 'on', 'ForegroundColor',[0 0 1]);

return
end


