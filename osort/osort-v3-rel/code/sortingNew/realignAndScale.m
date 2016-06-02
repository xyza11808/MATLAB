function cluster1R = realignAndScale(cluster1R)

toMax=10000;
for i=1:size(cluster1R,1)

%realign
maxPos = find( cluster1R(i,:) == max(cluster1R(i,:)) );

if maxPos>95
    diff = maxPos-95;
    cluster1R(i,:) = [cluster1R(i,diff:maxPos) cluster1R(i,maxPos+1:end) zeros(1,diff-1)];
end

if maxPos<95
    diff = 95-maxPos;
    cluster1R(i,:) = [zeros(1,diff-1) cluster1R(i,1:maxPos) cluster1R(i,maxPos:end-diff)];   
end

%scale
%cluster1R(i,:) = cluster1R(i,:) * (toMax / max(cluster1R(i,:)));
    
end
