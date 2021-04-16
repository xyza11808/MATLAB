function [Types,Counts] = uniAndcount(Datas)
% same function as unique(), but also returns the number of each types
Types = unique(Datas);
NumTypes = length(Types);
Counts = zeros(NumTypes,1);
for ct = 1 : NumTypes
    Counts(ct) = sum(Datas == Types(ct));
end



