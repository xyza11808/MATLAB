function scInsertLogo(varargin)
% scInsertLogo places the sigTOOL logo in a data view

if ishandle(varargin{1}) && ~strcmp(get(varargin{1},'type'), 'figure')
    C=imread('Logo.bmp');
    logo(varargin{1}, C);
end

if ~strcmp(class(varargin{1}),'timer')
    fhandle=varargin{1};
    if isempty(findobj(gcf,'Tag','sigTOOL:Logo'))
        try
            C=imread('Logo.bmp');
        catch %#ok<CTCH>
            delete(fhandle);
            lasterror('reset'); %#ok<LERR>
            error('The sigTOOL logo appears to have been removed');
        end
        logo(fhandle, C);
    end
else
    h=findobj(0,'Tag','sigTOOL:DataView');
    if isempty(h)
        stop(varargin{1});
        delete(varargin{1})
    else
        for i=1:length(h)
            if isempty(findobj(h(i),'Tag','sigTOOL:Logo'))
                scInsertLogo(h(i));
            end
        end
    end
end
return
end


function logo(fhandle, C)
str=sprintf('sigTOOL:\nDeveloped by Malcolm Lidierth at King''s College London');
str=sprintf('%s\n%c %s',str,169,'King''s College London 2006');
str=sprintf('%s\n%s',str,'Click here for website');
set(fhandle,'Units','pixels');
pos=get(fhandle,'position');
h=uicontrol(fhandle, 'Tag','Logo',...
    'Units','pixels',...
    'Position',[pos(3)-84,pos(4)-42,80,40],...
    'CData',C,...
    'ToolTipString',str,...
    'Callback','web http://sourceforge.net/projects/sigtool/ -browser',...
    'Tag','sigTOOL:Logo');
set(fhandle,'Units','normalized');
set(h,'Units','normalized');
set(fhandle,'ResizeFcn','scResizeFigControls');
return
end