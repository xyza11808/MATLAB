%
%plots various steps of the spike extraction process.
%
%input:
%spiketimestamps -> of the detected spikes (which are in rawTraceSpikes).
%blockOffsets -> absolute timestamp of the beginning of this plotted block (returned from processRaw)
%
%
%from top to bottom:
%raw signal
%filtered signal
%thresholded signal (if available - some detection methods dont threshold a signal)
%spikes extracted
%uncorrected raw signal (only if ground re-normalization is enabled)
%
%urut/april04
function plotSpikeExtraction(label,rawSignal, rawSignalUncorrected, rawMean, filteredSignal, rawTraceSpikes, runStd2, upperlim, plotLimit,Fs, handles, spiketimestamps, blockOffsets, ADbitVolts)
if nargin<=9
	Fs=25000; %default sampling rate is 25kHz
end

if nargin<=8
	plotLimit=[1 5]; %plot how many seconds (default is 4s)
end

plotFrom=Fs*plotLimit(1);
plotTo=Fs*plotLimit(2);

%if nothing to plot, return.
if length(rawSignal)==0
    return;
end

%% raw trace
ax(1)=subplot(5,1,1)
plot ( [plotFrom:plotTo]/Fs, rawSignal(plotFrom:plotTo) );


stdEstimate=std(rawSignal(plotFrom:plotTo));
title(['Raw signal ' label ' sd=' num2str(stdEstimate)]);
set(gca,'XTickLabel',{})

minVal=min(rawSignal(plotFrom:plotTo))*0.9;
maxVal=max(rawSignal(plotFrom:plotTo))*1.1;
if maxVal==minVal
    maxVal=minVal+10;
end
ylim([minVal maxVal]);

%% bandpass filtered raw trace
ax(2)=subplot(5,1,2)

stdFiltered = std( filteredSignal(plotFrom:plotTo) );

plot ( [plotFrom:plotTo]/Fs, filteredSignal(plotFrom:plotTo) )
set(gca,'XTickLabel',{})
ylabel(['[uV] sd=' num2str(stdFiltered) ] );

%--> compare to simple thresholding method
thresRaw =  4 * median(abs(filteredSignal(plotFrom:plotTo))/0.6745);
thresRaw

length(find ( filteredSignal(plotFrom:plotTo) > 2*thresRaw ))

h=line([plotFrom plotTo]/Fs,[thresRaw thresRaw]);
set(h,'color','r');
set(h,'linewidth',2);

h=line([plotFrom plotTo]/Fs,[-thresRaw -thresRaw]);
set(h,'color','r');
set(h,'linewidth',2);

h=line([plotFrom plotTo]/Fs,[thresRaw*2 thresRaw*2]);
set(h,'color','m');
set(h,'linewidth',2);

minVal=min(filteredSignal(plotFrom:plotTo))*0.9;
maxVal=max(filteredSignal(plotFrom:plotTo))*1.1;
if maxVal==minVal
    maxVal=minVal+10;
end

ylim([minVal maxVal]);

%% thresholding signal, if available
ax(3)=subplot(5,1,3)
if length(runStd2)>0
  plot( [plotFrom:plotTo]/Fs, runStd2(plotFrom:plotTo ),'b' )
  hold on
  plot( [plotFrom:plotTo]/Fs, upperlim(plotFrom:plotTo),'-r','linewidth',2 );
  hold off
end
set(gca,'XTickLabel',{})
set(gca,'YTickLabel',{})

%% extracted spikes
ax(4)=subplot(5,1,4)

gray=[192 192 192]./255;

%plot all of them at once
plot([plotFrom:plotTo]/Fs, rawTraceSpikes(plotFrom:plotTo),'color',gray)
hold on

tmpStr='';

spikesMarked=[]; %from to ClNr
%if sorting has been done already,mark biggest clusters with color
if isfield(handles,'useNegative') & isfield(handles,'assignedClusterNegative')
    colorsClusters={'r','g','b','k','y','m','c'};

    clusters = flipud( handles.useNegative );
    assigned = handles.assignedClusterNegative;
    timestampsClusters = handles.allSpikesTimestampsNegative;
    for i=1:length(clusters)
        if i>length(colorsClusters)
            break;
        end

        inds = find( assigned == clusters(i) );
        timesThisCl = timestampsClusters(inds);
        
        %how many of these are plotted here
        indsPlotted=[];
        %for j=1:length(spiketimestamps)            
        %    indsPlotted = [indsPlotted find( timesThisCl ==  spiketimestamps(j) )];
        %end
	if isempty(spiketimestamps)  %in case nospikes were detected in this block, skip
		continue;
	end

        indsPlotted = find( timesThisCl >= min(spiketimestamps) & timesThisCl<max(spiketimestamps) );

        timesThisCl = timesThisCl(indsPlotted);
       
	col = colorsClusters{i};

	%map timepoints to index in raw trace
        for j=1:length(timesThisCl)
            offset=4*1000; %in us; how much to plot per spike.
            uSecPerStep=(1/Fs)*1e6;
            fromTmp = round( (timesThisCl(j)-blockOffsets-offset)/uSecPerStep);
            toTmp = round( (timesThisCl(j)-blockOffsets+offset)/uSecPerStep);

	
            if fromTmp<=0
		fromTmp=1;
	    end

	    if toTmp < length(rawTraceSpikes) 
            	plot( [fromTmp:toTmp]/Fs, rawTraceSpikes(fromTmp:toTmp), 'color', col);
		spikesMarked=[spikesMarked; [fromTmp toTmp clusters(i)]];
	    end
        end

        tmpStr = [ tmpStr ' ' col '=' num2str(length(inds)) ]; 
    end 
end
hold off
ylabel('amp');
title(tmpStr);

%% plot the uncorrected signal (before subtraction of virtual ground) -- only plot this if ground normalization is enabled
if length( rawSignalUncorrected ) > 0 
  ax(5)=subplot(5,1,5)
  plot([plotFrom:plotTo]/Fs, rawSignalUncorrected(plotFrom:plotTo),'b' )
  ylabel('uncorrected');
end

%-- for debugging only,set manual ylims
% subplot(5,1,2);
% ylim([-40 40]);
% subplot(5,1,4);
% ylim([-1000 1000]);

%for debugging only, plot theta
debugPlotTheta=0;

if debugPlotTheta
    FsDown = 1000;  % reduced rate
    [P,Q] = designDownsampleFactors( Fs, FsDown );
    dataRawTrial = downsampleRawTrace( rawSignal(plotFrom:plotTo), P, Q ); %FS now 1000Hz
    [dataFiltered] = filterLFPofTrial( dataRawTrial, 94, FsDown );

    ax(5)=subplot(5,1,5)
    plot ( [1:length(dataFiltered{1})]./1000, dataFiltered{1});
    xlim([1 length(dataFiltered{1})]./1000);
end



%%% temporary - to plot theta
toStore = rawSignal(plotFrom:plotTo);
toStoreFiltered=filteredSignal(plotFrom:plotTo);
toStoreSpikes = rawTraceSpikes(plotFrom:plotTo);

%enable manually to export raw data for plotting of figures [EXPORT]
%save(['/tmp/raw' label '.mat'], 'toStore','toStoreFiltered', 'toStoreSpikes', 'plotFrom', 'plotTo', 'spikesMarked');

timePerStep=1e6/Fs;
xlabel(['Time [' num2str(timePerStep) 'uS/step]'],'FontSize',12);

linkaxes(ax,'x');


%----------only for figure in paper
%for i=1:3
%subplot(5,1,i)
%xlim([plotFrom plotTo]/Fs);
%end
%for i=4:4
%subplot(5,1,i);
%xlim([plotFrom/Fs plotTo/Fs]);
%end
%subplot(5,1,5);
%xlim([plotFrom/FsDown plotTo/FsDown]);

