function matfilename=ImportSTA(filename, targetpath)
% ImportSTA imports .....
%
% FIRST VERSION: Subject to change
%
% Example:
% OUTPUTFILE=ImportSTA(FILENAME)
% OUTPUTFILE=ImportSTA(FILENAME, TARGETPATH)
%
% FILENAME is the path and name of the STAM file to import.
%
% The kcl file generated will be placed in TARGETPATH if supplied. If not,
% the file will be created in the directory taken from FILENAME.
%
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 05/09
% Copyright © The Author & King's College London 2009-
%


% Set up MAT-file giving a 'kcl' extension
if nargin<2
    targetpath=fileparts(filename);
end
matfilename=scCreateKCLFile(filename, targetpath);
if isempty(matfilename)
    return
end


X=staread(filename);

chan=1;
for n=1:length(X.sites)
    % Load data for each site
    elapsedtime=0;
    switch X.sites(n).recording_tag{:}
        % Check if episodic or continuous
        case 'episodic'
            % Episodic so create pseudocontinuous data
            
            % The spikes
            hdr.channel=chan;
            hdr.source=dir(filename);
            hdr.source.name=filename;
            hdr.title=strrep(X.sites(n).label{:},'_','-');% Avoid subscripts with Tex Interpreter
            hdr.comment='';
            hdr.markerclass=class(X.categories(n).label{:});
            
            % Classifiers
            hdr.classifier.By=chan+1;
            hdr.classifier.For=[];
            
            hdr.Group.Number=floor(chan/2)+1;
            hdr.Group.Label=sprintf('Group %d', hdr.Group.Number);
            hdr.Group.SourceChannel=0;
            hdr.Group.DateNum=datestr(now());
            
            spikecount=0;
            for j=1:length(X.categories)
                for k=1:length(X.categories(j).trials)
                    if ~isempty(X.categories(j).trials(k).list)
                        for spk=1:length(X.categories(j).trials(k).list)
                            spikecount=spikecount+1;
                            imp.tim(spikecount,1)=elapsedtime+X.categories(j).trials(k,n).list(spk);
                        end
                            elapsedtime=elapsedtime+(2*X.categories(j).trials(k,n).end_time);
                    end
                end
            end
            imp.mrk=uint8(zeros(size(imp.tim,1),4));
            res=X.sites(n).time_resolution;
            sc=X.sites(n).time_scale;
            if res==0
                res=1;
            end
            if sc==0
                sc=1;
            end
            fac=res*sc;
            hdr.tim.Scale=sc;
            hdr.tim.Units=res;
            imp.tim=imp.tim/fac;
            
            hdr.channeltype='Edge';
            imp.adc=[];
            hdr.channeltypeFcn='';
            hdr.adc=[];
            hdr.tim.Class='tstamp';
            
            hdr.tim.Shift=0;
            hdr.tim.Func=[];
            
            if hdr.tim.Units==0
                hdr.tim.Units=1;
            end
            scSaveImportedChannel(matfilename, chan, imp, hdr, 0);
            clear('imp','hdr');
            
            % Create the trigger channel
            % High levels indicate periods of sampling. The intervals
            % between these periods is set to
            % 2*X.categories(j).trials(k,n).end_time
            elapsedtime=0;
            trigchan=chan+1;
            
            % Classifiers
            hdr.classifier.By=[];
            hdr.classifier.For=chan;
         
            hdr.Group.Number=floor(chan/2)+1;
            hdr.Group.Label='';
            hdr.Group.SourceChannel=0;
            hdr.Group.DateNum=datestr(now());
        
            hdr.channel=chan+1;
            hdr.source=dir(filename);
            hdr.source.name=filename;
            hdr.title=sprintf('Episodes Chan %d',chan);
            hdr.comment='';
            hdr.markerclass=class(X.categories(n).label{:});
            
            episodes=0;
            for j=1:length(X.categories)
                for k=1:length(X.categories(j).trials)
                    episodes=episodes+1;
                    imp.tim(episodes,1)=elapsedtime;
                    imp.tim(episodes,2)=elapsedtime+X.categories(j).trials(k,n).end_time;
                    imp.mrk(episodes,1:length(X.categories(j).label{:}))=X.categories(j).label{:};
                    elapsedtime=elapsedtime+(2*X.categories(j).trials(k,n).end_time);
                end
            end
            
            res=X.sites(n).time_resolution;
            sc=X.sites(n).time_scale;
            if res==0
                res=1;
            end
            if sc==0
                sc=1;
            end
            fac=res*sc;
            hdr.tim.Scale=sc;
            hdr.tim.Units=res;
            imp.tim=imp.tim/fac;
            
            hdr.channeltype='Pulse';
            imp.adc=[];
            hdr.channeltypeFcn='';
            hdr.adc=[];
            hdr.tim.Class='tstamp';
            
            hdr.tim.Shift=0;
            hdr.tim.Func=[];
            
            if hdr.tim.Units==0
                hdr.tim.Units=1;
            end
            scSaveImportedChannel(matfilename, trigchan, imp, hdr, 0);
            clear('imp','hdr');
                        
            chan=chan+2;
      
    end
end

% Now add dataview details
sigTOOLDataView.XLim=[0 5*X.categories(1).trials(1,1).end_time];
sigTOOLDataView.CursorPositions=[];
save(matfilename, 'sigTOOLDataView', '-v6', '-append');

sigTOOLVersion=scVersion('nodisplay');
save(matfilename,'sigTOOLVersion','-v6','-append');

return
end
