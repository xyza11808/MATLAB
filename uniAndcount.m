function [Types,Counts] = uniAndcount(Datas)
% same function as unique(), but also returns the number of each types
% Very slow when Datas is large, use "accumarray" for fast calculation
% https://www.mathworks.com/matlabcentral/answers/459851-fastest-way-to-find-number-of-times-a-number-occurs-in-an-array
% for string count, see: https://www.mathworks.com/matlabcentral/answers/582929-speed-up-count-of-unique-elements-matching-a-given-condition-in-table

Types = unique(Datas);
NumTypes = length(Types);
Counts = zeros(NumTypes,1);
for ct = 1 : NumTypes
    Counts(ct) = sum(Datas == Types(ct));
end



