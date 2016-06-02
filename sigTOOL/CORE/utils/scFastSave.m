function fastfile=scFastSave(fhandle)
% scFastSave saves a sigTOOL data view and its associated result views
% 
% Example:
% fastfile=scFastSave(fhandle)
%         where fhandle is the handle of a sigTOOL data view
%               fastfile is the path and name of the output file
%
% scFastSave can be used to back up data quickly and to save analysis
% results. Use it for temporary storage only. For permanent storage of
% data, use scSaveAs.
%
% scFastSave writes to a standard MATLAB data file (a MAT-file) in the system
% temporary folder. The file will be given the .kclf extension. The MAT-file
% version used will depend on the settings in the MATLAB preferences.
% Level 5 Version 7 MAT-files and above will use data compression.
%
% scFastSave saves:
%       The channel cell array associated with a sigTOOL data view
%       Details about the view, x-axis and cursor settings
%       Any result objects associated with the view
% Re-loading a kclf file using scFastOpen will restore the analysis of
% a file to the point where scFastSave was called.
%
% scFastSave is fast beacuse it typically saves the objects and not the
% raw data represented in them. However, note that:
%   For any temporary channels that contain data in RAM, those data will
%       be saved directly to the kclf file 
%   Temporary channels on disc are also saved to the system temporary
%       folder. If these are deleted during a disc cleanup or using
%       sigTOOL('cleanup') in MATLAB, any kclf files dependent upon them
%       will fail to load.
%
%--------------------------------------------------------------------------
% The following restrictions apply when reloading kclf files:
%       *[1] They can safely be re-loaded only on the computer on which they
%                   were saved
%      *$[2] Any data files referenced within the scchannel cell array must
%                still exist and should not have been modified since the the
%                call to scFastSave
%        [3] As the file contains objects, it may not be compatible across
%               sigTOOL or MATLAB versions
%
%    * These restrictions are enforced within the scFastOpen function
%    $ If a file has been modified, you may end up loading garbage as data 
%       from it.
%--------------------------------------------------------------------------
%
% See also: scFastOpen, scSaveAs
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/10
% Copyright © The author and King’s College London 2010-
%--------------------------------------------------------------------------

channels=getappdata(fhandle, 'channels');

name=get(fhandle, 'Name');

[path name ext]=fileparts(name);

fastfile=fullfile(tempdir, [name '.kclf']);

results=getappdata(fhandle, 'sigTOOLResultViewList');
results=results(ishandle(results));

if ~isempty(results)
    resultarray=cell(size(results));
    
    % For each result view
    for k=1:length(results)
        resultarray{k}=getappdata(results(k), 'sigTOOLResultData');
        if ishandle(results(k))
            [spath, sname]=fileparts(resultarray{k}.datasourcetitle);
            if strcmpi(sname, name)==0
                % Clear if the result handle no longer belongs to this data
                % file...
                resultarray{k}=[];
            elseif ~isa(resultarray{k}.options, 'function_handle') && ...
                    ~iscell(resultarray{k}.options)
                %... or if we do not have a function handle (e.g. we
                %have a uicontextmenu
                resultarray{k}.options=[];
            end
        end
    end
else
    resultarray={};
end

% Now add dataview details
h=findobj(fhandle, 'Type', 'axes');
XLim=get(h(end), 'XLim');
DataView.XLim=XLim;
cursors=getappdata(fhandle, 'VerticalCursors');
cursorpos=cell(1,length(cursors));
for i=1:length(cursors)
    if ~isempty(cursors)
        cursorpos{i}=GetCursorLocation(fhandle, i);
    end
end
DataView.CursorPositions=cursorpos;


host=char(java.net.InetAddress.getLocalHost());
sigTOOLVersion=scVersion('nodisplay');
MATLABVersion=version;

t=datestr(now());
save(fastfile, 't', 'MATLABVersion', 'sigTOOLVersion', 'host',...
    'channels', 'DataView', 'resultarray');

return
end