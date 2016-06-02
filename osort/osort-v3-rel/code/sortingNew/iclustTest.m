
load('/data/SF_032306/sort/5/A2_sorted_new.mat');

waveforms=newSpikesNegative(1:1000,:);


S = calcSimilarityMatrix( waveforms );

%mirror
for i=1:size(waveforms,1)   
    S(i+1:end,i) = S(i,i+1:end);
end

Sorig=S;

%diag
for i=1:size(waveforms,1)
    S(i,i)=0;
end


mVal=max(S(:));


Sinv = mVal - S ;


figure(2)
imagesc(Sinv);
colorbar;



