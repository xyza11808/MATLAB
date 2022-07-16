function valueColors = linearValue2colorFun(Values, Type)
% function used to transfer values into colors, using linear neiboring
% methods, but not simply sorting the values, so that the color will make
% more things of their values

if ~exist('Type','var') || isempty(Type)
    Type = 'BlueRed';
end

ValueSampleNums = 100;
ValueLns = linspace(min(Values),max(Values),ValueSampleNums);
switch lower(Type)
    case 'bluered'
        AllScaleColors = blue2red_2(ValueSampleNums,0.8);
    case 'orangegreen'
        AllScaleColors = Green2Orange_2(ValueSampleNums,0.8);
    otherwise
        warning('Unkown color map types.');
        return;
end

ValueSpace = (ValueLns(2) - ValueLns(1));

RealValue2Inds = round((Values-min(Values))/ValueSpace)+1; % convert values to matlab index

valueColors = AllScaleColors(RealValue2Inds,:);





