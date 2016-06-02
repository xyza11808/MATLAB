function obj=sigTOOLResultData(varargin)
% sigTOOLResultData constructor
%
% Overloaded methods:
%
%
%
% Revisions:
% 11.09.09 Add datasourcetitle field 

if nargin==0
    s.acktext='';
    s.data={};
    s.datasource= [];
    s.datasourcetitle= '';
    s.description= [];
    s.details= [];
    s.displaymode='Single Frame';
    s.options=[];
    s.plotstyle=@line;
    s.title='';
    s.userdata=[];
    s.viewstyle='2D';
    s.zzID='';
elseif ischar(varargin{1})
    for i=1:2:length(varargin)
        s.(varargin{i})=varargin{i+1};
    end
    s=CheckFieldNames(s);
elseif isstruct(varargin{1})
    s=varargin{1};
    s=CheckFieldNames(s);
end   

% Add a unique identifier
[a b]=fileparts(tempname());
s.zzID=b;

s=orderfields(s);

% 11.09.09 Field added - only fill this if given explicitly
% 26.09.09   Check not empty
if ~isempty(s.datasource) && ishandle(s.datasource) && isempty(s.datasourcetitle)
        s.datasourcetitle=get(s.datasource, 'Name');
end

for i=2:size(s.data,1)
    for k=2:size(s.data,2)
        
        % Make sure vectors in data are column vectors
        if isempty(s.data{i,k})
            continue
        end
        if isobject(s.data{i,k})
            continue
        end
        if isvector(s.data{i,k}.rdata)
            s.data{i,k}.rdata=s.data{i,k}.rdata(:)';
        end
        if isvector(s.data{i,k}.tdata)
            s.data{i,k}.tdata=s.data{i,k}.tdata(:)';
        end
        if isvector(s.data{i,k}.odata)
            s.data{i,k}.odata=s.data{i,k}.odata(:)';
        end
        
        % Create scresult objects from structures
%         if isstruct(s.data{i,k})
%             s.data{i,k}=scresult(s.data{i,k});
%         end
    
    end
end


obj=class(s, 'sigTOOLResultData');
return
end


function s=CheckFieldNames(s)
fnames={'acktext' 'data', 'details' 'plotstyle', 'viewstyle', 'displaymode', 'datasource', 'datasourcetitle', 'title', 'options', 'zzID',...
    'description', 'userdata'};
for i=1:length(fnames)
    if ~isfield(s, fnames{i})
        s.(fnames{i})=[];
    end
end
return
end