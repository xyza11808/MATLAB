%
%realign spikes (after they were upsampled to 100KHz).
%
%input:
%allSpikes: spikes before realignment
%allTimestamps: timestamps of those (will be adjusted).
%alignParam:   this param is only considered if peakAlignMethod=1.
%      1: positive (peak is max)
%      2: negative (peak is min)
%      3: mixed
%stdEstimate: std estimate of the raw signal. only used if peakAlignMethod=1.
%peakAlignMethod: (same as in detectSpikesFromPower.m, see for details).  1-> findPeak, 2 ->none, 3-> peak of power signal
%
%returns:
%newSpikes
%newTimestamps
%shifted -> by how many samples was the spike shifted. can be used to adjust the timestamp.
%
%urut/2004
%urut/april 2007: revised. now supports multiple peakAlignMethods.
%
%
function [newSpikes,newTimestamps, shifted] = realigneSpikes(allSpikes, allTimestamps, alignParam, stdEstimate, peakAlignMethod)
if nargin<=4
    peakAlignMethod=1;
end

shifted=[];

newSpikes=allSpikes;

excludeCounter=0;
excludeInds=[];

shouldMax=95; %for upsampled spikes

if size(allSpikes,2)<256  %for raw spikes  ==64
    shouldMax=24;
end


%old, findPeak, method; based on values of the raw signal
diff=0;
for i=1:size(allSpikes,1)
    currentSpike=allSpikes(i,:);

    switch(peakAlignMethod)
        case 1 %normal
            maxPos=0;
            maxPos = findPeak( currentSpike(50:200), stdEstimate, alignParam );
            maxPos=maxPos+50;
        case 3 %peak power
            %spikes were, before upsampling, already aligned with power peak finding method. peak only needs to be refined after upsampling.

            tollerance=5;

            %only look arround the known peak to see if it changed due to upsampling
            peakSegment = abs( currentSpike( shouldMax-tollerance:shouldMax+tollerance ));

            indPeak = find( max(peakSegment) == peakSegment );
            indPeak = indPeak(1);

            maxPos = indPeak + shouldMax-tollerance-1;
        otherwise
            error('unknown peakAlignMethod');
    end

    %==debugging
    %figure; 
    %plot( 1:256, currentSpike, '-xr', maxPos, max(currentSpike), 'rd' );
    
    
    changed=false;
    diff=0;

    if maxPos==-1
        maxPos=95;
    end

    if maxPos>shouldMax
        diff = maxPos-shouldMax;
        currentSpike = [currentSpike(diff:maxPos) currentSpike(maxPos+1:end) currentSpike(end)*ones(1,diff-1)];
        changed=true;
        
        shifted(i) = diff;         
    else if maxPos<shouldMax
        diff = shouldMax-maxPos;
        currentSpike = [currentSpike(1)*ones(1,diff-1) currentSpike(1:maxPos) currentSpike(maxPos:end-diff)];
        changed=true;

        shifted(i) = -1 * diff;       
        else
            shifted(i)=0;
        end
    end

    
    if changed && diff<shouldMax/2
        newSpikes(i,:) = currentSpike;
    end

    %spikes that need to be shifted to much are excluded (problem in
    %extraction)
    %if changed && diff>90 && type<3
    %   excludeCounter=excludeCounter+1;
    %   excludeInds(excludeCounter)=i;
    %end
end



indsToKeep = setdiff(1:size(allSpikes,1),excludeInds);
newSpikes=newSpikes(indsToKeep,:);
if length(allTimestamps)>0
    newTimestamps=allTimestamps(indsToKeep);
else
    newTimestamps=[];
end
