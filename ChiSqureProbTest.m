function ChiSquare_p = ChiSqureProbTest(Data_x,Data_y)
% this function is used for performing a 2*2 table chi-square test, 
% to determine the difference of probability for two datasets

if numel(unique(Data_x)) ~= numel(unique(Data_y)) || numel(unique(Data_y)) ~= 2
    error('The input data should only have two types.');
end
if ~issame(unique(Data_x),unique(Data_y)) 
    error('Input data should have same category');
end

xCategs = unique(Data_x);
ChiTables = [sum(Data_x == xCategs(1)),sum(Data_x == xCategs(2));...
    sum(Data_y == xCategs(1)),sum(Data_y == xCategs(2))];
%
ChiRowSum = sum(ChiTables);
ChiColSum = sum(ChiTables,2);
TotalTableNum = sum(ChiRowSum);

ChiEXPTable = (ChiColSum/TotalTableNum) * ChiRowSum;

ChiSquare = sum(sum((ChiTables - ChiEXPTable).^2 ./ ChiEXPTable));

ChiSquare_p = chi2pdf(ChiSquare,1);
