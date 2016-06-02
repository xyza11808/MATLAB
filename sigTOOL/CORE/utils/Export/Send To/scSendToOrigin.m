function scSendToOrigin(hObject)
% scscSendToOriginSendToExcel exports data to an Oigin project
%
% Example:
% scSendToOrigin(hObject)
% where hObject is the handle of the source axes/uipanel/figure
%
% For details see 'Examples of using MATLAB as an automation client' in the
% MATLAB help and the OriginLabs example file located at
% ...Origin Root folder.../Samples/Automation Server/MATLAB/CreatePlotInOrigin.m
%
% All data are exported to Excel from the clicked axes, uipanel or figure.
%
% If the data from the exported axes include only a single frame, data will
% be exported to a single worksheet. With multiple frames, data from
% each set of axes will be exported to a separate worksheet. All sheets
% will be contained in one Work Book (Book1). Sheet1 is always left empty.
%
% Origin supports only one open project. If there are unsaved changes in a
% current project you will be prompted to save them.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

% Revised   01.08   Multiple frames/worksheets supported

fhandle=ancestor(hObject, 'figure');
% Axes or figure?
switch get(hObject, 'Type')
    case 'uipanel'
        AxesList=getappdata(ancestor(hObject,'figure'),'AxesList');
    case 'figure'
        % Send data from all axes to Excel
        AxesList=getappdata(hObject,'AxesList');
    case 'axes'
        % Send data for the current axes only
        AxesList=hObject;
end


try
    originObj=actxserver('Origin.ApplicationSI');
catch %#ok<CTCH>
    disp('Origin does not appear to be available on this PC');
    rethrow(lasterror); %#ok<LERR>

end

% Check Origin status
status=invoke(originObj, 'IsModified');
if status
    answer=questdlg('The current project has changed. Do you wish to save it',...
        'sigTOOL/Origin interface','Yes','No','Yes');
    if strcmp(answer,'Yes')
        % Save the project
        invoke(originObj, 'Save');
    else
        % Clear the Origin flag - stop Origin repeating this question
        invoke(originObj, 'IsModified', 'false');
    end
end

invoke(originObj, 'Load');

invoke(originObj, 'Execute', 'doc -mc 1;');
result=getappdata(fhandle, 'sigTOOLResultData');

[rows,cols]=size(AxesList);
count=0;
nsheets=1;
nmax=length(AxesList(AxesList>0));

name='Book1';

% Build the data array
for i=1:rows
    for j=1:cols
        if AxesList(i,j)~=0
           
            % Get the data and set up labels
            sub=getappdata(AxesList(i,j),'AxesSubscript');
            data=result.data{sub(1), sub(2)};
            channelnumbers=getappdata(AxesList(i,j),'ChannelNumbers');
            str=[num2str(channelnumbers(1)) ':' num2str(channelnumbers(2))] ;

            % Set up  worksheet
            ViewStyle=getappdata(ancestor(gca,'figure'), 'sigTOOLViewStyle');
            if strcmp(ViewStyle, '3D')
                lbl='ZLabel';
            else
                lbl='YLabel';
            end
            val=[num2str(nsheets) ':', get(get(AxesList(i,j), lbl),'String')];
            idx1=strfind(val,'(');
            idx2=strfind(val,')');
            if ~isempty(idx1) && ~isempty(idx2)
                yunits=val(idx1+1:idx2-1);
                val=val(1:idx1-1);
            end
            wsname=[deblank(val) ':' str];
            
            invoke(originObj, 'Execute', sprintf('newsheet name:="%s"',wsname));
            
            % Label the x column in the  worksheet
            val=get(get(AxesList(i,j), 'XLabel'),'String');
            idx1=strfind(val,'(');
            idx2=strfind(val,')');
            if ~isempty(idx1) && ~isempty(idx2)
                tunits=val(idx1+1:idx2-1);
                val=val(1:idx1-1);
            end
            invoke(originObj, 'Execute', sprintf('col(1)[L]$="%s"',val));
            invoke(originObj, 'Execute', sprintf('col(1)[U]$="%s"',tunits));

             % Select target range
            if size(data.rdata, 1)>1
                % Multiple worksheets
                % Label the y columns in the Excel worksheet
                if isvector(data.odata)
                    firstdatacol=count+1;
                else
                    firstdatacol=count;
                end
                for k=firstdatacol:firstdatacol+size(data.rdata, 1)-1
                    invoke(originObj, 'Execute', sprintf('col(%d)[L]$="Frame %s"', k+1+1, num2str(k-firstdatacol+1)));
                    invoke(originObj, 'Execute', sprintf('col(%d)[U]$="%s"', k+1+1, yunits));
                end
            else
                val=[get(get(AxesList(i,j), lbl),'String') '{' str '}'];
                idx1=strfind(val,'(');
                idx2=strfind(val,')');
                if ~isempty(idx1) && ~isempty(idx2)
                    val=val(1:idx1-1);
                end
                invoke(originObj, 'Execute', sprintf('col(%d)[L]$="%s"', count+1+1, val ));
                invoke(originObj, 'Execute', sprintf('col(%d)[U]$="%s"', count+1+1, yunits));
            end
            
            % Add the data
            invoke(originObj, 'PutWorksheet', name, num2cell(data.tdata(:)), 0, count);
            if isvector(data.odata)
                invoke(originObj, 'Execute', sprintf('col(%d)[L]$="Y"',count+1+1));
                val=data.olabel;
                idx1=strfind(val,'(');
                idx2=strfind(val,')');
                if ~isempty(idx1) && ~isempty(idx2)
                    units=val(idx1+1:idx2-1);
                end
                invoke(originObj, 'Execute', sprintf('col(%d)[U]$="%s"',count+1+1,units));
                invoke(originObj, 'PutWorksheet', name, num2cell(data.odata(:)), 0, count+1);
                count=count+1;
            end
            invoke(originObj, 'PutWorksheet', name, num2cell(data.rdata(1:end,:)'), 0, count+1);
            
           if size(data.rdata, 1)>1 && nsheets<nmax
                % New worksheet
                nsheets=nsheets+1;
                count=0;
            else
                % Use same worksheet
                count=count+2;
            end
        end
    end
end


delete(originObj);
return
end