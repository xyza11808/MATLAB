function [IDX,C,SUMD,K]=kmeans_opt(X,varargin)
%%% [IDX,C,SUMD,K]=kmeans_opt(X,varargin) returns the output of the k-means
%%% algorithm with the optimal number of clusters, as determined by the ELBOW
%%% method. this function treats NaNs as missing data, and ignores any rows of X that
%%% contain NaNs.
%%%
%%% [IDX]=kmeans_opt(X) returns the cluster membership for each datapoint in
%%% vector X.
%%%
%%% [IDX]=kmeans_opt(X,MAX) returns the cluster membership for each datapoint in
%%% vector X. The Elbow method will be tried from 1 to MAX number of
%%% clusters (default: square root of the number of samples)
%%% [IDX]=kmeans_opt(X,MAX,CUTOFF) returns the cluster membership for each datapoint in
%%% vector X. The Elbow method will be tried from 1 to MAX number of
%%% clusters and will choose the number which explains a fraction CUTOFF
%%% of
%%% the variance (default: 0.95)
%%% [IDX]=kmeans_opt(X,MAX,CUTOFF,REPEATS) returns the cluster membership for each datapoint in
%%% vector X. The Elbow method will be tried from 1 to MAX number of
%%% clusters and will choose the number which explains a fraction CUTOFF of
%%% the variance, taking the best of REPEATS runs of k-means (default: 3).
%%% [IDX,C]=kmeans_opt(X,varargin) returns in addition, the location of the
%%% centroids of each cluster.
%%% [IDX,C,SUMD]=kmeans_opt(X,varargin) returns in addition, the sum of
%%% point-to-cluster-centroid distances.
%%% [IDX,C,SUMD,K]=kmeans_opt(X,varargin) returns in addition, the number of
%%% clusters.
%%% sebastien.delandtsheer@uni.lu
%%% sebdelandtsheer@gmail.com
%%% Thomas.sauter@uni.lu
[m,~]=size(X); %getting the number of samples
ToTest=ceil(sqrt(m));
if nargin>1
   if ~isempty(varargin{1})
    ToTest=varargin{1}; 
   end
end
Cutoff=0.95; 
if nargin>2
    if ~isempty(varargin{2})
        Cutoff=varargin{2};
    end
end
Repeats=10; 
if nargin>3
    if ~isempty(varargin{3})
        Repeats=cell2mat(varargin(3));
    end
end
if nargin>4
    kmeansOption = 1;
else
    kmeansOption = 0;
end
%unit-normalize
MIN=min(X); MAX=max(X); 
X=(X-MIN)./(MAX-MIN);
D=zeros(ToTest,1); %initialize the results matrix
for c=1:ToTest %for each sample
    if kmeansOption
        [~,~,dist]=kmeans(X,c,'emptyaction','drop', varargin{4:end}); %compute the sum of intra-cluster distances
    else
        [~,~,dist]=kmeans(X,c,'emptyaction','drop'); %compute the sum of intra-cluster distances
    end
    tmp=sum(dist); %best so far
    
    for cc=2:Repeats %repeat the algo
        if kmeansOption
            [~,~,dist]=kmeans(X,c,'emptyaction','drop', varargin{4:end});
        else
            [~,~,dist]=kmeans(X,c,'emptyaction','drop');
        end
        tmp=min(sum(dist),tmp);
    end
    D(c,1)=tmp; %collect the best so far in the results vecor
end
Var=D(1:end-1)-D(2:end); %calculate %variance explained
PC=cumsum(Var)/(D(1)-D(end));
[r,~]=find(PC>Cutoff); %find the best index
K=1+r(1,1); %get the optimal number of clusters
if kmeansOption
    [IDX,C,SUMD]=kmeans(X,K, varargin{4:end}); %now rerun one last time with the optimal number of clusters
else
    [IDX,C,SUMD]=kmeans(X,K);
end
C=C.*(MAX-MIN)+MIN;
end