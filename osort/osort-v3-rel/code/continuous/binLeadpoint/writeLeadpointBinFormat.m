%
%write a leadpoint bin file
%converts all data to 16 bit unsigned integers using 2-complement.
%thus,effective range is +- 2^(N-1)  with N=16
%
%urut/april09
function count = writeLeadpointBinFormat( filename, data)

N=16;
gainFact=100;

%dataConv=dec2bin(data,N);
%data=(randn(1,100)*10);

%binary inversion
value = int16(data*gainFact);

%conv all neg numbers to 
%2 complement to implement neg numbers

%value is signed int 16
%dataConv is unsigned int 16
indsNeg = find(value<0);
indsPos = find(value>=0);
dataConv=zeros(1,length(value));
dataConv=uint16(dataConv);

dataConv(indsPos) = value(indsPos);
dataConv(indsNeg) =  bitcmp( uint16(-1*value(indsNeg)), N) + 1 ;  % bitwise complement, add 1

[fid, message] = fopen(filename, 'w', 'l');
[count] = fwrite(fid, dataConv, 'uint16');

if count~=length(dataConv)
    warning('writing error to bin file -- ');
end

fclose(fid);


%valueRec = TwosComplement(uint16(dataConv), 16);
%figure(30);
%plot(valueRec);

%% for debugging
% dataRead = readLeadpointBinFormat( filename, N, gainFact);
% 
% figure(222);
% subplot(3,1,1);
% plot(1:100,data, 1:100, value);
% title('orig');
% 
% subplot(3,1,2);
% plot(dataRead);
% title('read from file');
% 
% subplot(3,1,3);
% plot(dataConv);
% title('written to file');