data = LowDimDatas;
NumROIs = size(data,1);
Dist = 1-(1+similarity_pearson(data'))/2;
% DataCorrs = similarity_pearson(data');
% 
% % DataCorrsUsed = DataCorrs;
% UsedDataInds = abs(DataCorrs) >= 0.2;
% DataCorrs_Norm = (DataCorrs + 1)/2;
% DataCorrsUsed = DataCorrs_Norm - diag(diag(DataCorrs_Norm));
% DataCorrsUsed(UsedDataInds) = 0;
%
Dist = Dist - diag(diag(Dist));
dissim = Dist(logical(triu(ones(size(Dist)),1)));

MaxClusNum = 15;
classlabel = zeros(NumROIs, MaxClusNum);
for cClusNum = 1 : MaxClusNum
    Scluster = pam(dissim, cClusNum);  %Scluster = pam(data, i, vtype);
    classlabel(:,cClusNum) = double(Scluster.ncluv)';
    
    Q = ind2cluster(classlabel(:,cClusNum));
    % less than 4 data points in one cluster, stop !
    ns = zeros(numel(Q),1);
    for j =1:numel(Q)
        ns(j) = numel(Q{j});
    end
    if min(ns) < 4
        MaxClusNum = cClusNum-1;
        break;
    end
end
% evalclusters() function can also be useful
%%
N = MaxClusNum;
NC = 3:N;
labels = classlabel;
Sil = zeros(1,N);
DB = zeros(1,N);
CH = zeros(1,N);
KL = zeros(1,N);
Ha = zeros(1,N);
Hom = zeros(1,N);
Sep = zeros(1,N);
wtertra = zeros(1,N);

Re = strcmp(Rd, 'euclidean');
% (2) Internal validity indices when true labels are unknown
for i = NC
   R = silhouette(data, labels(:,i), Rd);
   Sil(i) = mean(R);        % average Silhouette
   % Davies-Bouldin, Calinski-Harabasz, Krzanowski-Lai
   [DB(i), CH(i), KL(i), Ha(i), ST] = ...
       valid_internal_deviation(data,labels(:,i), Re);
   S = ind2cluster(labels(:,i));
   [Hom(i), Sep(i), wtertra(i)] ...           % weighted inter/intra ratio
       = valid_internal_intra(Dist, S, Re, dmax);
end

kl = KL(NC);
ha = Ha(NC);
nl = length(NC);
S = trace(ST);
kl = [S kl];
ha = [S ha];
R = abs(kl(1:nl)-kl(2:nl+1));
S = [R(2: end) R(end)];
kl = R./S;
kl(nl) = kl(nl-1);
R = ha(1:nl)./ha(2:nl+1);
ha = (R-1).*(nrow-[NC(1)-1 NC(1:nl-1)]-1); 
KL(NC) = kl;
Ha(NC) = ha;
%%

% (3) plotting indices
SR = [Sil; DB; CH; KL; Ha; wtertra];
kfind = [2 1 2 2 5 2]; 
FR = {'Silhouette (Sil)'...
    'Davies-Bouldin (DB)', 'Calinski-Harabasz (CH)', 'Krzanowski-Lai (KL)', ...
     'Hartigan', 'weighted inter-intra (Wint)'};

valid_index_plot(SR(:,NC), NC, kfind, FR); 



