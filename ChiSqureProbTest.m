function varargout = ChiSqureProbTest(varargin)
% this function is used for performing a 2*2 table chi-square test, 
% to determine the difference of probability for two datasets
if nargin > 1
    Data_x = varargin{1};
    Data_y = varargin{2};
    if numel(unique(Data_x)) ~= numel(unique(Data_y)) %|| numel(unique(Data_y)) ~= 2
        error('The input data should only have two types.');
    end
    if issame(unique(Data_x),unique(Data_y)) 
    %     error('Input data should have same category');
        xCategs = unique(Data_x);
        ChiTables = [sum(Data_x == xCategs(1)),sum(Data_x == xCategs(2));...
            sum(Data_y == xCategs(1)),sum(Data_y == xCategs(2))];
    else
        ChiTables = [Data_x(:),Data_y(:)];
    end
elseif nargin == 1
    ChiTables = varargin{1};
end
ChiRowSum = sum(ChiTables,2);
ChiColSum = sum(ChiTables);
TotalTableNum = sum(ChiRowSum);
v = (size(ChiTables,1) - 1);

ChiEXPTable = ChiRowSum * (ChiColSum/TotalTableNum);

chi2stat = sum(sum((ChiTables - ChiEXPTable).^2 ./ ChiEXPTable));

ChiSquare_p = 1 - chi2cdf(chi2stat,v);

if nargout == 1
    varargout{1} = ChiSquare_p;
elseif nargout == 2
    varargout{1} = ChiSquare_p;
    varargout{2} = chi2stat;
end