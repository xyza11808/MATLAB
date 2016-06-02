function out=getSourceName(varargin)
% getSourceName method for the scchannel class
%
% Examples
% out=getSourceName(obj);
% out=getSourceName(channels{:});
% out=getSourceName(channels{:}, mode);
% out=getSourceName(channels{:}, ext, mode);
%
% Returns the names of the original source files from which the data were
% read as a cell column of strings
% If ext is specified as a string, only files with that extension will be
% returned. Note that wildcards are not supported.
%
% If mode is false or empty:
% Where the source file is not specified in scchannel object, or does not
% match ext, the entry for that channel will be returned as an empty string.
%
% If mode is true:
% Empty entries will be removed from the returned cell array
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/10
% Copyright © The Author & King's College London 2010-
% -------------------------------------------------------------------------

mode=false;

if islogical(varargin{end})
    mode=varargin{end};
    m=numel(varargin)-1;
else
    m=numel(varargin);
end

if ischar(varargin{m})
    ext=varargin{m};
    if ~strcmpi(ext(1), '.')
        ext=['.' ext];
    end
    n=m-1;
else
    ext='';
    n=m;
end

out=cell(n,1);
for k=1:n
    if isempty(varargin{k})
        out{k}='';
    else
        out{k}=varargin{k}.hdr.source.name;
    end
end

if ~isempty(ext)
    for k=1:numel(out)
        [pname fname fext]=fileparts(out{k}); %#ok<ASGLU>
        if ~strcmpi(ext, fext)
            out{k}='';
        end
    end
end
        
if mode==true
    for k=numel(out):-1:1
        if isempty(out{k})
            out(k)=[];
        end
    end
end

return
end