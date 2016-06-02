function grp=getGroupNumber(varargin)

grp=zeros(size(varargin));
for k=1:length(varargin)
    if isempty(varargin{k})
        grp(k)=0;
    else
        grp(k)=varargin{k}.hdr.Group.Number;
    end
end