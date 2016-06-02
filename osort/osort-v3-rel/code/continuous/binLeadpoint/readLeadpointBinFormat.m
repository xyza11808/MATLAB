%reads the binary format of the leadpoint system. these files are created
%by the "Leadpoint Export Utility"
%
%N: nr bits (16 or 32)
%gainFact: 100,10,1
%
%urut/jan08
function vals = readLeadpointBinFormat( filename, N, gainFact)
if nargin==1
    N=16; %how many bits
    gainFact=100;
end
if ~exist(filename)
    error(['file does not exist: ' filename]);
end

%read the file (little-endian format).
[fid, message] = fopen(filename, 'r', 'l');
[vals,count] = fread(fid,inf,'uint16');
fclose(fid);

%these numbers are stored as negative complement.
%find the negative numbers and replace them with a signed decimal
%representation.
indsNeg = find(vals>2^(N-1));
vals(indsNeg) = vals(indsNeg)-2^N;
vals = vals./gainFact;

