function projectedResidual = residualProjection( centerDiff, m, spikes )
projectedResidual = zeros(1,size(spikes,1));

%diff between centers, normalize (unit vector)
%centerDiff = m2-m1;
centerDiff = centerDiff/norm(centerDiff);
%norm(centerDiff)

for i=1:size(spikes,1)
    projectedResidual(i) = dot ( (spikes(i,:)-m), centerDiff ) ;
end