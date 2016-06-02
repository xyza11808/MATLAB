function scSendToExcel(hObject)
% scSendToExcel exports data to an Excel spreadsheet
%
% Example:
% scSendToExcel(hObject)
% where hObject is the handle of the source axes/uipanel/figure
%
% For details see 'Examples of using MATLAB as an automation client' in the
% MATLAB help
%
% All data are exported to Excel from the clicked axes, uipanel or figure.
%
% If the data from the exported axes include only a single frame, data will
% be exported to a single worksheet. With multiple frames, data from
% each set of axes will be exported to a separate worksheet.
%
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-2007
% -------------------------------------------------------------------------

% Revised   01.08   Multiple frames/worksheets supported
%           01.09   Deal with cases of fewer than 3 worksheets
%                       present by default

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


% First, open an Excel Server.
e=actxserver('excel.application');
% Insert a new workbook.
eWorkbook = e.Workbooks.Add; %#ok<NASGU>
e.Visible = 1;
% Make the first sheet active.
eSheets = e.ActiveWorkbook.Sheets;
eSheet1 = eSheets.get('Item', 1);
eSheet1.Activate;

result=getappdata(fhandle, 'sigTOOLResultData');

[rows,cols]=size(AxesList);
count=1;
nsheets=1;
for i=1:rows
    for j=1:cols
        if AxesList(i,j)~=0
            % Get the data and set up labels
            sub=getappdata(AxesList(i,j),'AxesSubscript');
            data=result.data{sub(1), sub(2)};
            channelnumbers=getappdata(AxesList(i,j),'ChannelNumbers');
            str=[num2str(channelnumbers(1)) ',' num2str(channelnumbers(2))] ;

            % Label the x column in the Excel worksheet
            eActivesheetRange = e.Activesheet.get('Range',...
                sprintf('%s1:%s1',ExcelColumnLetter(count),ExcelColumnLetter(count)));
            eActivesheetRange.Value = get(get(AxesList(i,j), 'XLabel'),'String');

            % Now put in the data

            % Column or worksheet name
            ViewStyle=getappdata(ancestor(gca,'figure'), 'sigTOOLViewStyle');
            if strcmp(ViewStyle, '3D')
                lbl='ZLabel';
            else
                lbl='YLabel';
            end
            name=[num2str(nsheets) ' ',...
                get(get(AxesList(i,j), lbl),'String') '{' str '}'];
            % Select target range
            if size(data.rdata, 1)>1
                % Multiple worksheets
                % Name worksheet
                set(eSheet1, 'Name', name);
                % Label the y columns in the Excel worksheet
                if isvector(data.odata)
                    firstdatacol=count+1;
                else
                    firstdatacol=count;
                end
                for k=firstdatacol:firstdatacol+size(data.rdata, 1)-1
                    try
                        eActivesheetRange = e.Activesheet.get('Range',...
                            sprintf('%s1:%s1',ExcelColumnLetter(k+1), ExcelColumnLetter(k+1)));
                    catch
                        LocalProcessError(k)
                    end
                    eActivesheetRange.Value =['Frame ' num2str(k-firstdatacol+1)];
                end
            else
                % Single sheet
                % Label the y columns in the Excel worksheet
                eActivesheetRange = e.Activesheet.get('Range',...
                    sprintf('%s1:%s1',ExcelColumnLetter(count+1), ExcelColumnLetter(count+1)));
                eActivesheetRange.Value =[get(get(AxesList(i,j), lbl),'String') '{' str '}'];
            end

            % Put the data in the sheet
            eActivesheetRange = e.Activesheet.get('Range',...
                sprintf('%s2:%s%s', ExcelColumnLetter(count), ExcelColumnLetter(count),...
                num2str(length(data.tdata))));
            eActivesheetRange.Value = data.tdata(:);
            if isvector(data.odata)
                eActivesheetRange=e.Activesheet.get('Range',...
                    sprintf('%s1:%s1', ExcelColumnLetter(count+1), ExcelColumnLetter(count+1)));
                eActivesheetRange.Value = 'Y';
                eActivesheetRange = e.Activesheet.get('Range',...
                    sprintf('%s2:%s%s', ExcelColumnLetter(count+1), ExcelColumnLetter(count+1),...
                    num2str(length(data.odata))));
                eActivesheetRange.Value = data.odata(:);
                count=count+1;
            end
            eActivesheetRange = e.Activesheet.get('Range',...
                sprintf('%s2:%s%s',ExcelColumnLetter(count+1), ExcelColumnLetter(count+size(data.rdata, 1)),...
                num2str(length(data.tdata))));
            eActivesheetRange.Value = full(data.rdata(1:size(data.rdata, 1),:)');


            if size(data.rdata, 1)>1
                % New worksheet
                nsheets=nsheets+1;
                % Assume 3 worksheets in the file by default
                if nsheets>3
                    % Add a new worksheet
                    eSheet1=eSheets.Add([], eSheet1);
                else
                    try
                        % Use one of the 3 default worksheets
                        eSheet1=eSheets.get('Item', nsheets);
                    catch %#ok<CTCH>
                        % That failed - assumption of 3 worksheets by
                        % default may be wrong so add as new
                        eSheets.Add([], eSheet1);
                        eSheet1=eSheets.get('Item', nsheets);
                    end
                end
                eSheet1.Activate();
            else
                % Use same worksheet
                count=count+2;
            end
        end
    end
end
eSheet1 = eSheets.get('Item', 1);
eSheet1.Activate
end

%--------------------------------------------------------------------------
function y=ExcelColumnLetter(col)
%--------------------------------------------------------------------------
% Convert column numbers to Excel style letters (maximum ZZZZ)
% NB Excel default for the maximum number of columns is 256 (IV) in
% Excel 2003. Recent versions have no limit. This code accommodates 475254
% columns.
if col<1 || col>26+26^2+26^3+26^4 || rem(col,1)~=0
    error('Column number must be whole number between 1 and %d', 26+26^2+26^3+26^4);
elseif col>=1 && col<=26
    y=rem(col-1, 26);
elseif col>26 && col<=26+26^2
    x=col-26-1;
    y=[x/26 rem(x,26)];
elseif col>26+26^2 && col<=26+26^2+26^3
    x=col-26^2-26-1;
    y=[x/26^2 rem(x/26,26) rem(x,26)];
elseif col>26+26^2+26^3 && col<=26+26^2+26^3+26^4
    x=col-26^3-26^2-26-1;
    y=[x/26^3 rem(x/26^2,26) rem(x/26,26) rem(x,26)];
end
y=char(y+65);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalProcessError(k)
%--------------------------------------------------------------------------
m=lasterror(); %#ok<LERR>
if strcmp(m.message, 'Error: Object returned error code: 0x800A03EC')
    str=sprintf('The maximum number of columns in the Excel spreadsheet has been exceeded (%d:%d)\n', k, k+1);
    str=[str 'You may be able to increase this limit within newer versions of Excel.'];
    st=dbstack();
    if strcmp(st(end).name, 'menu_SendToExcel')
        errordlg(str, 'sigTOOL');
    end
end
rethrow(lasterror) %#ok<LERR>
end
%--------------------------------------------------------------------------

