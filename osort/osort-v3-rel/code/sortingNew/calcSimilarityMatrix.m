function S = calcSimilarityMatrix( waveforms )

N = size(waveforms,1);

II = ones(256,1);

S=zeros(N,N);
for i=1:N
    for j=i:N
        
        S(i,j) = ( waveforms(i,:) - waveforms(j,:) ).^2 * II;
        
    end
    if mod(i,200)==0
        disp(num2str(i));
    end
end 

