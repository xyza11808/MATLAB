%
%calculates various statistics for a putative cell
%
%returns:
%percentageBelow(1): % below 3.0ms in range 0...70
%percentageBelow(2): % below 3.0ms in range 0...700
%
%urut/04
function [f,Pxxn,tvect,Cxx,edges1,n1,yGam1,edges2,n2,yGam2,mGlobal,m1,m2,percentageBelow,CV] = getStatsForCluster(spikes, timestamps)

d = diff(timestamps);
d = d/1000; %in ms
m1=mean(d(find(d<=70)));
m2=mean(d(find(d<=700)));
mGlobal=mean(d);
stdGlobal=std(d);

edges1=0:1:201;
n1=histc(d,edges1);
edges2=0:5:800;
n2=histc(d,edges2);

below = length( find(d <= 3.0) );
percentageBelow=[];
percentageBelow(1) = (below*100) / length(find(d<=70));	
percentageBelow(2) = (below*100) / (length(find(d<=70))*10);	
percentageBelow(3) = (below*100) / (length(find(d<=1000)));

CV= stdGlobal/mGlobal;

parm1 = gamfit(d(find(d<=70 & d>=0)));
yGam1 = gampdf(edges1, parm1(1),parm1(2));
yGam1 = yGam1*length(find(d<=70));

parm2 = gamfit(d(find(d<=700 & d>=0)));
yGam2 = gampdf(edges2, parm2(1),parm2(2));
yGam2 = yGam2*length(find(d<=700));
yGam2 = yGam2*5; %binsize

n = convertToSpiketrain(timestamps);
[f,Pxxn,tvect,Cxx] = calculatePowerspect(n);
