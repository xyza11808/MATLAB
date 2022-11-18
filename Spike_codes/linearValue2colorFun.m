function valueColors = linearValue2colorFun(Values, Type, Bound)
% function used to transfer values into colors, using linear neiboring
% methods, but not simply sorting the values, so that the color will make
% more things of their values

if ~exist('Type','var') || isempty(Type)
    Type = 'BlueRed';
end
IsBounded = 1;
if ~exist('Bound','var') || isempty(Type)
    IsBounded = 0;
end

ValueSampleNums = 100;
if ~IsBounded
    ValueLns = linspace(min(Values(:)),max(Values(:)),ValueSampleNums);
    ValueSpace = (ValueLns(2) - ValueLns(1));
    RealValue2Inds = round((Values-min(Values))/ValueSpace)+1; % convert values to matlab index
else
    Values = Values - Bound;
    LinMinMaxV = max(abs(Values(:)));
    ValueLns = linspace(-LinMinMaxV,LinMinMaxV,ValueSampleNums);
    cLim = [-LinMinMaxV,LinMinMaxV];
    ValueSpace = (ValueLns(2) - ValueLns(1));
    RealValue2Inds = round((Values+LinMinMaxV)/ValueSpace)+1; % convert values to matlab index
end
switch lower(Type)
    case 'bluered'
        AllScaleColors = blue2red_2(ValueSampleNums,0.8);
    case 'orangegreen'
        AllScaleColors = Green2Orange_2(ValueSampleNums,0.8);
    otherwise
        warning('Unkown color map types.');
        return;
end
if isvector(Values)
    valueColors = AllScaleColors(RealValue2Inds,:);
else
    valueColors = {RealValue2Inds, AllScaleColors, cLim};
end




