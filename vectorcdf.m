function cdfSum = vectorcdf(Vdata,varargin)

isSort = 0;
if nargin > 1
    if ~isempty(varargin{1})
        isSort = varargin{1};
    end
end
if ~isvector(Vdata)
    error('Only a vector can be processed by current function.');
end
Vdata = Vdata(:);
if isSort
    vDataUsing = sort(Vdata);
else
    vDataUsing = Vdata;
end
nElements = length(vDataUsing);
Matrixdata = repmat(vDataUsing,1,nElements);
HalfData = triu(Matrixdata);
cdfSum = sum(HalfData);
