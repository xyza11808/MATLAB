%
%this is for comparing different methods of extracting the number/shape of
%neurons from data; kmeans, lle, pca etc
%
%
%

figure(22)
colors={'r.','b.','g.','y.','m.'};
tillInd=1000;
spike=newSpikesPositive(1:tillInd,:) 

subplot(3,3,1)
plot( spike' , 'b');



subplot(3,3,2);

nrKMeans=3;

[IDX,C] = kmeans(spike, nrKMeans) ;
plot(C');
title('kmeans');

subplot(3,3,3)

n=256;
F=fft( spike',n );
Fs=100000;
f = Fs*(0:128)/n;
Pyy = F.* conj(F)/n;


for i=1:nrKMeans
    if i>1
        hold on
    end
    
    plot( imag(F(:,find(IDX==i))), real(F(:,find(IDX==i))),colors{i} );


    if i>1
        hold off
    end
end


subplot(3,3,4)
plot(f/4,Pyy(1:129,:));

xlim([0 1000]);

%figure(999)
%plot(1:30,F(1:30,5:10))




subplot(3,3,5)

for i=1:nrKMeans
    if i>1
        hold on
    end
    
    Fmean=mean(F(1:10,find(IDX==i)));
    plot( real(Fmean), imag(Fmean), colors{i})

    if i>1
        hold off
    end
end


title('mean freq power');

subplot(3,3,6)

for i=1:nrKMeans
    if i>1
        hold on
    end
    
    plot( newdata(find(IDX==i),1), newdata(find(IDX==i),2), colors{i});

    if i>1
        hold off
    end
end

title('PCA, coloring with k-means');

subplot(3,3,7)

for i=1:length(unique(assignedPositive))
    if i>1
        hold on
    end
    
    plot( newdata(find(assignedPositive(1:tillInd)==i),1), newdata(find(assignedPositive(1:tillInd)==i),2), colors{i});

    if i>1
        hold off
    end
end
title('PCA, coloring with our algorithm');

subplot(3,3,8)
m=[];
inds=unique(assignedPositive);
for i=1:length(inds)
    if inds(i)==999
        break;
    end
    m(i,:) = mean( spike(find(assignedPositive(1:tillInd)==inds(i)),:) );
    
end

for i=1:length(unique(assignedPositive))
    if inds(i)==999
        break;
    end

    if i>1
        hold on
    end
    
    plot( m(i,:), colors{i});

    if i>1
        hold off
    end
end
title('mean waveforms our algorithm');
