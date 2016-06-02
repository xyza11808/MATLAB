function [s1 s2]=ABFGetFileInfo(dllname, filename)
% ABFGetFileInfo returns some header data from an Axon Instruments ABF file
% 
% Examples:
% s1=ABFGetFileInfo(dllname, filename);
% [s1 s2]=ABFGetFileInfo(dllname, filename);
%
%       s1 is returned with limited information (obsolete: maintained for
%           for backwards compatibility only)
%       s2 contains the full ABF header (see ABFHEADR.PDF for details)
%
% Inputs: 
% dllname: the full path and name of the Axon Instruments ABFFIO.DLL
% filename: the path and file name of the ABF file to read
%     
% 
% This routine calls the Axon Instruments DLL and is therefore Windows only
%     
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 06/07
% Copyright © The Author & King's College London 2007
%
% Acknowledgements:
% Revisions:
%       12.09   Modified to call ABFGetFileInfo2 and return full ABF header
%--------------------------------------------------------------------------

[s1 s2]=ABFGetFileInfo2(dllname, filename);

s2.sProtocolPath=localchar(s2.sProtocolPath);
s2.sCreatorInfo=localchar(s2.sCreatorInfo);
s2.sModifierInfo=localchar(s2.sModifierInfo);
s2.sFileComment=localchar(s2.sFileComment);


s2.sADCChannelName=localchar(organise(s2.sADCChannelName));
s2.sADCUnits=localchar(organise(s2.sADCUnits));
s2.sDACChannelName=localchar(organise(s2.sDACChannelName));
s2.sDACChannelUnits=localchar(organise(s2.sDACChannelUnits));

s2.nEpochType=organise(s2.nEpochType);
s2.fEpochInitLevel=organise(s2.fEpochInitLevel);
s2.fEpochLevelInc=organise(s2.fEpochLevelInc);
s2.lEpochInitDuration=organise(s2.lEpochInitDuration);
s2.lEpochDurationInc=organise(s2.lEpochDurationInc);


s2.sDACFilePath=localchar(organise(s2.sDACFilePath));


s2.sULParamValueList=localchar(organise(s2.sULParamValueList));

s2.sArithmeticOperator=deblank(char(s2.sArithmeticOperator));
s2.sArithmeticUnits=deblank(char(s2.sArithmeticUnits));

s2.lEpochPulsePeriod=organise(s2.lEpochPulsePeriod);
s2.lEpochPulseWidth=organise(s2.lEpochPulseWidth);

return
end

function m=localchar(m)
if iscell(m)
    [r c]=size(m);
    for k=1:r
        m{k,:}=deblank(char(m{k,:}));
    end
else
    m=deblank(char(m));
end
return
end


function out=organise(m)
% Reorganize matrices from C style row-based indexing to MATLAB column-based
% indexing
[a b]=size(m);
m=reshape(m, b, a)';
if a>1
    out=cell(a,1);
    for k=1:a
        out{k}=m(k,:);
    end
else
    [a b]=size(m);
    out=reshape(m, b, a)';
end
return
end