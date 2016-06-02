starttime=clock;

pathOut='/scratch/urut/data/HM_102304/';

%pathOut='f:/data/new/GD_112504/';

pathRaw=[pathOut '/raw/'];
pathFigs=[pathOut '/figs/'];
patientID='P3 S1';

fromFile=1;
toFile=24;
thres=7;
tillBlocks=500;

%automatic from here on
%-------------------------------------------------------------------
%-------------------------------------------------------------------

allMeans=[];
c=0;

for i=fromFile:toFile
	handles=[];

        handles.correctionFactorThreshold=0;
        handles.paramExtractionThreshold=thres;

	
		handles.basepath=pathOut;
		handles.prefix='A';
		handles.from=num2str(i);
		[handles,fileExists] = GUIloadFromFile([],handles, 2);
		handles.filenamePrefix=[pathOut 'A' num2str(i)];
   
	        if fileExists==0
        	    ['File does not exist: ' handles.filenamePrefix];
            	    continue;
        	end
        
	clusters=handles.useNegative;
	for i=1:length(clusters)
		c=c+1;
		allMeans(c,1:256)=mean( handles.newSpikesNegative(find(handles.assignedClusterNegative==clusters(i)),:));
	end	
end
save([pathOut 'allMeans.mat'], 'allMeans', '-v6');

etime(clock,starttime)	
