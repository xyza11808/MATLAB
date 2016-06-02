inds=[800 1100 1326 1302];

inds=[ 1 4 5];
IDs = [7 12 15]
ns=[20 126 456];



%inds=[ 6 7 4];
%IDs = [17 18 12]
%ns=[104 543 126];

s1=baseSpikes(inds(1),:);
s2=baseSpikes(inds(2),:);
s3=baseSpikes(inds(3),:);

figure(83712)
plot( 1:64,s1,'r',1:64,s2,'b',1:64,s3,'g' )

legend('S1','S2','S3');


%--- calc
id1=1;
id2=2;
p=64;

sp1=baseSpikes(inds(id1),:)*1;
sp2=baseSpikes(inds(id2),:)*1;

n1=ns( id1 );
n2=ns( id2 );

n1=200;
n2=200;

allS1 = spikeWaveformsUp(find(assigned==IDs(id1)),:);
allS2 = spikeWaveformsUp(find(assigned==IDs(id2)),:);

S1 = allS1'*allS1;
S1 = S1/(n1-1);
S1 = allS2'*allS2;
S2 = S2/(n2-1);

Spooled = ((n1-1)/(n1+n2-2)) * S1 + ((n2-1)/(n1+n2-2)) * S2;

est = (1/n1+1/n2)* Spooled;
for ii=1:p
    for jj=1:p
        if abs(ii-jj)>1
            est(ii,jj)=0;
        end
    end
end

%est=eye(64);

Dmean = (sp1-sp2) * inv( est ) * (sp1-sp2)'

Dmean = (sp1-sp2) * Cinv * (sp1-sp2)'

thresF = (n1+n2-2)*p/(n1+n2-p-1) * finv(0.95, p, n1+n2-p-1)

D=calculateDistanceChi2(sp1, sp2, eye(p)*0.04 )       