function usable = classifyClusters( spikes,timestamps,assigned )

clusters = unique(assigned);
usable=zeros(1,length(clusters));

for i=1:length(clusters)
	clNr = clusters(i);
	
	spikesCluster = spikes(find(assigned==clNr));
	timestampsCluster = spikes(find(assigned==clNr));
	
	%isis
	isis = diff(timestampsCluster);
	isis = d/1000; %in ms
	
	below = length( find(isis <= 2.0) );
	percentageBelow = (below*100) / length(isis);	
	
	if percentageBelow<=3.0
		continue;		%not usable if below 3%
	end
		
	%powerspect
	n = converToSpiketrain(timestampsCluster);
	[f,Pxxn,tvect,Cxx] = calculatePowerspect(n);

   	[isOk2]= checkPowerspectrum(Pxxn,f, 20.0, 100.0);  %check for peaks in powerspectrum in 20.0 ... 100.0 range

	if isOk2==false
		continue;
	end
	
	%std


	%if it makes it till here --> usable
	usable(i)=1;
	
end

