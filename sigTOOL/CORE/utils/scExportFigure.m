function scExportFigure(fhandle, varargin)
% scExportFigure - exports a sigTOOL view to a graphics file
%
% Example:
% scExportFigure(fhandle, varargin)
% where fhandle is the handle of the data view or sigTOOL result figure
%     varargin{1}, optionally, contains the default target file extension
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 06/08
% Copyright � The Author & King's College London 2008-
% -------------------------------------------------------------------------

SmoothState=[];

if nargin==2
    init=[tempdir() 'temp' '.' varargin{1}];
    switch varargin{1}
        case 'ai'
            FilterSpec='temp.ai';
        case 'pdf'
            FilterSpec='temp.pdf';
        case 'bmp'
            FilterSpec='temp.bmp';
        case 'eps'
            FilterSpec='temp.eps';
        case {'tiff', 'tif'}
            FilterSpec='temp.tif';
    end
else
    init=tempdir();
    FilterSpec={'*.ai' '*.pdf' '*.bmp' '*.eps'  '*.tiff;*.tif';...
    'Adobe Illustrator (*.ai)',...
    'Adobe PDF (*.pdf)',...
    'Bitmap (*.bmp)',...
    'Encapsulated PS (*.eps)',...
    'Tagged Image (*.tiff; *.tif)'}';
end

[filename pathname]=uiputfile(FilterSpec, 'Save Figure As', init);
if filename==0
    return
end
[dum1 dum2 format]=fileparts(filename);
if isempty(format)
    filename=[filename '.pdf'];
end
filename=fullfile(pathname, filename);


mode=get(fhandle, 'PaperPositionMode');
orientation=get(fhandle, 'PaperOrientation');
set(fhandle, 'PaperPositionMode', 'manual');
set(fhandle, 'PaperUnits', 'normalized');
set(fhandle, 'PaperPosition', [0 0 1 1]);
set(fhandle, 'RendererMode', 'auto');


dmode=[];
if strcmp(get(fhandle, 'Tag'), 'sigTOOL:ResultView')        
    [fhandle, AxesPanel, annot, pos, dmode]=printprepare(getappdata(fhandle, 'sigTOOLResultView'));
elseif strcmp(get(fhandle, 'Tag'), 'sigTOOL:DataView') 
    [fhandle, AxesPanel, annot, pos]=printprepare(getappdata(fhandle, 'sigTOOLDataView'));
end

if strcmp(get(fhandle, 'Tag'), 'sigTOOL:DataView') &&...
        any(strcmp(format, {'ai' 'pdf' 'eps'}))
        % Render at high-res if a vector format is required
        scDataViewDrawData(fhandle, false)
end

% Switch off line smoothing
lines=findobj(fhandle, 'Type', 'line');
if ~isempty(lines)
    SmoothState=get(lines(1), 'Linesmoothing');
    set(lines, 'Linesmoothing', 'off');
end

if strcmp(format,'.ai')
    orient(fhandle, 'portrait');    
else
    orient(fhandle, 'landscape');
end

try
    switch format
        case '.ai'
            print(fhandle, '-dill', '-noui', filename);
        case '.pdf'
            print(fhandle, '-dpdf', '-noui', filename);
        case '.eps'
            print(fhandle, '-depsc', '-tiff', '-noui', filename);
        case '.bmp'
            print(fhandle, '-dbmp', '-noui',  '-r300', filename);
        case {'.tif' '.tiff'}
            print(fhandle, '-dtiff', '-noui', '-r300', filename);
        otherwise
    end
catch %#ok<CTCH>
    m=lasterror(); %#ok<LERR>
    if strcmp(m.identifier,'MATLAB:Print:CannotCreateOutputFile')
        warning('%s may be open in another application', filename); %#ok<WNTAG>
    else
        warning('Could not open/create %s', filename); %#ok<WNTAG>
    end
end

set(fhandle, 'PaperPositionMode', mode);
set(fhandle, 'PaperOrientation', orientation);
tidy(fhandle, AxesPanel, annot, pos, dmode);

status=0;
if ispc
    winopen(filename);
elseif ismac
    status=system(sprintf('open "%s"', filename));
elseif isunix
    % Load application name from scPreferences.mat
    s=load([scGetBaseFolder() 'program' filesep 'scPreferences.mat'], 'Filing');
    switch format
        case {'.pdf' '.eps'}
            % Document Viewer (set to evince by default)
            status=system(sprintf('%s "%s"', s.Filing.ExportVector, filename));
        case {'.bmp' '.tif' }
            % Bitmap viewer (set eof, Eye of Gnome, by default);
            status=system(sprintf('%s "%s"', s.Filing.ExportBitmap, filename));
    end
    if status~=0
        fprintf('scExportFigure: Failed to open with "%s" or "%s"\n%s\n',...
            s.Filing.ExportVector, s.Filing.ExportBitmap, filename);
    end
end

if status~=0
    fprintf('scExportFigure: Failed to open by all routes\n%s\n', filename);
end

if ~isempty(SmoothState) && ~isempty(lines)
    set(lines, 'Linesmoothing', SmoothState);
end

% Restore
if strcmp(get(fhandle, 'Tag'), 'sigTOOL:DataView') &&...
        any(strcmp(format, {'ai' 'pdf' 'eps'}))
        scDataViewDrawData(fhandle, true)
end

% Copy output filename to system clipboard (for manual open)
clipboard('copy', filename);

return
end

function tidy(fhandle, AxesPanel, annot, pos, dmode)
if strcmp(get(fhandle, 'Tag'), 'sigTOOL:ResultView')
    postprinttidy(getappdata(fhandle, 'sigTOOLResultView'), AxesPanel, annot, pos, dmode);
elseif strcmp(get(fhandle, 'Tag'), 'sigTOOL:DataView') 
    postprinttidy(getappdata(fhandle, 'sigTOOLDataView'), AxesPanel, annot, pos);
end
return
end