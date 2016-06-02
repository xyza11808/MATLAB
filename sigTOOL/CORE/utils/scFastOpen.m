function new=scFastOpen()
% scFastOpen loads data files saved using scFastSave
% 
% Example
% fhandle=scFastOpen()
%     fhandle is the handle (or a vector of handles, to the opened data views
%     
%     Returns empty if no selected files could be opened
%
% See also: scFastSave
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/10
% Copyright © The author and King’s College London 2010-
%--------------------------------------------------------------------------
    

[name]=uigetfile([tempdir() '*.kclf'],...
    'MultiSelect', 'on');
if isnumeric(name) && name==0
    return
end

if ~iscell(name)
    name={name};
end

new=zeros(1, numel(name));
for k=1:numel(name)
    fullname=fullfile(tempdir(), name{k});
    s=load(fullname, '-mat');
    if ~isValid(s) 
        % Not on same host. Refuse to load file as function handles and
        % paths may be invalid
        msgbox(sprintf('%s is out of date or source files have been moved/deleted\n', fullname),'Fast Open');
        continue
    else
        try
            new(k)=plot(s.channels{:});
            set(new, 'Name', name{k});
            scProcessDataView(new, s.DataView);
            if ~isempty(s.resultarray)
                newr=zeros(1,numel(s.resultarray));
                for n=1:numel(s.resultarray)
                    newr(n)=plot(s.resultarray{n});
                end
                setappdata(new, 'sigTOOLResultViewList', newr)
            end
        catch
            % May have deleted a temporary file
            new(k)=0;
            message=lasterror(); %#ok<LERR>
            fprintf('%s\n...while loading %s\n', message.message, fullname);
        end
    end
end

new=new(new>0);
return
end


%--------------------------------------------------------------------------
function flag=isValid(s)
%--------------------------------------------------------------------------
flag=true;
if strcmpi(s.host,java.net.InetAddress.getLocalHost())==0
    % Not the same host PC
    return
end
for k=1:numel(s.channels)
    if ~isempty(s.channels{k})
        % Return false if one or more files have changed since Fast Save
        f=s.channels{k}.tim.Map.Filename;
        if isempty(f)
            return
        end
        d=dir(f);
        if isempty(d) || d.datenum>datenum(s.t)
            flag=false;
            return
        end
    end
end
return
end
%--------------------------------------------------------------------------

        