function scLineSmoothing(varargin)
% scLineSmoothing sets line smoothing on or off
%
% Example:
% scLineSmoothing(fhandle, flag)
% scLineSmoothing(flag)
%  where fhandle is the target figure handle (default gcf) and flag is
%  true/false for smoothing on/off respectively.
%
% Line smoothing is a largely unsupported/undocumented feature of MATLAB
% implemented via OpenGL. See help opengl for some details.
%
% This is a What You See Is All You Get function. With MATLAB 7.1 or
% earlier setting smoothing to on will have unexpected side-effects.
% Smoothing always sets the renderer to OpenGL.
%
% In general, do not use smoothing when exporting in vector formats - the
% drivers/target software will have their own smoothing algorithms.
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/06
% Copyright © The Author & King's College London 2006
%--------------------------------------------------------------------------

switch nargin
    case 1
        fhandle=gcf;
        flag=varargin{1};
    case 2
        fhandle=varargin{1};
        flag=varargin{2};
end

button=findobj(fhandle, 'Type', 'uimenu', 'Callback', @menu_ToggleSmoothing);
h=findobj(fhandle, 'Type', 'line');

if isempty(h)
    return
end

switch flag
    case true
        set(fhandle, 'RendererMode', 'manual');
        set(fhandle, 'Renderer', 'opengl');
        set(h,'LineSmoothing','on');
        set(button,'Label','Jagged Lines');
    case false
        set(fhandle, 'RendererMode', 'auto');
        set(h,'LineSmoothing','off');
        set(button,'Label','Smooth Lines');
end