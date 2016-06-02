function scSendToSigmaPlot(hObject)
% scSendToSigmaPlot sends data from a sigTOOL result view to SigmaPlot
%
% Example:
% scSendToSigmaPlot(hObject)
%
% hObject is either:
%            the handle of a figure (data on all axes will be plotted)
%            the handle of a single set of axes to plot
%
% scSendToSigmaPlot invokes SigmaPlot and passes the data 
% scSendToSigmaPlot requires Windows ActiveX support
%
% If the data from the exported axes include only a single frame, data will
% be exported to a single worksheet. With multiple frames, data from 
% each set of axes will be exported to a separate worksheet.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-2007
% -------------------------------------------------------------------------
%
% Revised   01.08   Multiple frames/worksheets supported

fhandle=ancestor(hObject, 'figure');

% Axes or figure?
switch get(hObject, 'Type')
    case 'uipanel'
        AxesList=getappdata(ancestor(hObject, 'figure'),'AxesList');
    case 'figure'
        AxesList=getappdata(hObject,'AxesList');
    case 'axes'
        AxesList=hObject;
end

try
    SPApp=actxserver('SigmaPlot.Application.1');
catch %#ok<CTCH>
    disp('Link to SigmaPlot failed. Is it present? Is your licence out of date?');
    m=lasterror(); %#ok<LERR>
    error(m.ans);
end

set(SPApp,'Visible',1);
SPNotebooks=get(SPApp,'Notebooks');
invoke(SPNotebooks,'Add');
CurrentNotebook=get(SPApp,'ActiveDocument');

result=getappdata(fhandle, 'sigTOOLResultData');

[rows,cols]=size(AxesList);
count=0;
nsheets=1;
nmax=length(AxesList(AxesList>0));


for i=1:rows
    for j=1:cols
        if AxesList(i,j)~=0
            
            % Set up section with worksheet
            SPData=invoke(CurrentNotebook,'CurrentDataItem');
            SPTable=get(SPData,'DataTable');
            SPItems=invoke(CurrentNotebook,'NotebookItems');
                
            % Get the data and set up labels
            sub=getappdata(AxesList(i,j),'AxesSubscript');
            data=result.data{sub(1), sub(2)};
            channelnumbers=getappdata(AxesList(i,j),'ChannelNumbers');
            str=[num2str(channelnumbers(1)) ',' num2str(channelnumbers(2))];
            % Label the x column in the Excel worksheet
            val={get(get(AxesList(i,j), 'XLabel'),'String')};
            invoke(SPTable, 'PutData', val, count, -1);
            % Now put in the data
            % Column or worksheet name
            ViewStyle=getappdata(ancestor(gca,'figure'), 'sigTOOLViewStyle');
            if strcmp(ViewStyle, '3D')
                lbl='ZLabel';
            else
                lbl='YLabel';
            end

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
                    invoke(SPTable, 'PutData', {['Frame ' num2str(k-firstdatacol+1)]},k+1,-1);
                end
            else
                val={[get(get(AxesList(i,j), lbl),'String') '{' str '}']};
                invoke(SPTable, 'PutData', val, count+1, -1);
            end
            % Add the data
            invoke(SPTable, 'PutData', num2cell(data.tdata(:))', count, 0);
            if isvector(data.odata)
                invoke(SPTable, 'PutData', {'Y'}, count+1, -1);
                invoke(SPTable, 'PutData', num2cell(data.odata(:))', count+1, 0);
                count=count+1;
            end
            invoke(SPTable, 'PutData', num2cell(data.rdata(1:end,:)')', count+1, 0);
            
            if size(data.rdata, 1)>1 && nsheets<nmax
                % Name the present sheet
                name=[num2str(nsheets) ' ',...
                get(get(AxesList(i,j), lbl),'String') '{' str '}'];
                set(SPData, 'Name', name);
                % New worksheet
                nsheets=nsheets+1;
                count=0;
                invoke(SPItems,'Add','1');
            else
                % Use same worksheet
                count=count+2;
            end
        end
    end
end

% If only one sheet, name it
if nsheets==1
    set(SPData, 'Name', get(ancestor(hObject, 'figure'),'Name'));
end

delete(SPApp);
return
end