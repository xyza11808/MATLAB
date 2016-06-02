%
%
%d: euclidean norm of distance between centers of two clusters
%
function [m1,m2, projectedResidual1,projectedResidual2,overlap,d] = projectionTest( spikes1,spikes2 )
m1 = mean(spikes1);
m2 = mean(spikes2);
d = norm(m1-m2);

projectedResidual1 = residualProjection( (m2-m1), m1, spikes1 );
projectedResidual2 = residualProjection( (m2-m1), m2, spikes2 );
projectedResidual2 = projectedResidual2 + d; 

%find overlap between two populations

overlap=[0 0];

edges=[-5:.2:d+5];

[n1]=histc(projectedResidual1,edges);
[n2]=histc(projectedResidual2,edges);

%edges that overlap with CL1
for i=1:length(edges)
    if n1(i) > 0 && n2(i) > 0  % if there is a conflict here
        if n1(i) < n2(i)
            overlap(1)=overlap(1)+n1(i);
        else
            overlap(2)=overlap(2)+n2(i);
        end
    end
end

overlap(1)=overlap(1)/sum(n1);
overlap(2)=overlap(2)/sum(n2);
