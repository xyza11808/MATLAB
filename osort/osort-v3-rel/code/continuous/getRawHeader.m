%
%get header, scale factor from there
%
%urut/may06
function [headerInfo, scaleFact, fileExists] = getRawHeader( filename )
scaleFact=0;
headerInfo='';

if exist(filename)==0
    fileExists=0;
    return;
end
fileExists=1;

%isContinous=false;

FieldSelection(1) = 0;%timestamps
FieldSelection(2) = 0;
FieldSelection(3) = 0;%sample freq
FieldSelection(4) = 0;
FieldSelection(5) = 0;

ExtractHeader = 1;

ExtractMode = 1;

%ExtractMode = 2; % 2 = extract record index range; 4 = extract timestamps range.
%ModeArray(1)=1;
%ModeArray(2)=2;
if ispc
    [headerInfo] = Nlx2MatCSC(filename, FieldSelection, ExtractHeader, ExtractMode);
else
    [headerInfo] = Nlx2MatCSC_v3(filename, FieldSelection, ExtractHeader, ExtractMode);    
end

%tmp=headerInfo{15};
%pos= strfind(tmp,'0.');
%scaleFact = str2num( tmp(pos:end) );

%adjusted for new format
scaleFact = str2num(getNumFromCSCHeader(headerInfo, 'ADBitVolts'));

%tmp=headerInfo{15};
%pos= strfind(tmp,'0.');
%scaleFact = str2num( tmp(pos:end) );

scaleFact = str2double( getNumFromCSCHeader(headerInfo, 'ADBitVolts') );
