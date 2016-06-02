function idx=GenerateSectionIndices(x, xrange)

sections=floor(max(x)/xrange)+1;
idx=zeros(sections,2);
idx(1,1)=1;
idx(1,2)=find(x>xrange, 1)-1;
r=idx(1,2)-idx(1,1);
for k=2:sections
    idx(k,1)=idx(k-1,2)+1;
    idx(k,2)=idx(k,1)+r;
end
idx(end)=numel(x);

return
end
