function matfilename=ImportCFS(filename, targetpath)
% ImportCFS imports Cambridge Electronic Design Signal for Windows files.
% The file created is a sigTOOL compatible version 6 MAT-file with the kcl
% extension
%
% Example:
% OUTPUTFILE=ImportCFS(FILENAME)
% OUTPUTFILE=ImportCFS(FILENAME, TARGETPATH)
%
% FILENAME is the path and name of the Signal file to import.
%
% The kcl file generated will be placed in TARGETPATH if supplied. If not,
% the file will be created in the directory taken from FILENAME.
%
% Note that the CFS file format used by Signal is versatile and CFS files
% written by other applications may not load fully or properly.
%
% For waveform channels, marker values correspond to the Signal FrameState
% setting (first marker) and to the DS Flags (second marker).
% Bit 9 of the DS Flags is the Signal "Tag" (set for on, cleared for off).
%
% Signal keyboard markers are stored with the keystroke as the marker.
%
% Toolboxes required: None
%
% The CFS filing system is copyright Cambridge Electronic Design, UK
%
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
%
% Acknowledgements:
% Revisions:
%   01.10.08    Fixed scaling when yScale not constant

% Load the CED son32.dll Windows library
if libisloaded('CFS32')==0
    % Switch off R2008a warning for now
    % TODO: Need to generate new cfs.m for future release
    warning('off', 'MATLAB:loadlibrary:OldStyleMfile');
    loadlibrary('CFS32.DLL',@cfs);
    warning('on', 'MATLAB:loadlibrary:OldStyleMfile');
end

% Open the CFS file via cfs32.dll
fid=CFSOpenCFSFile(filename);
if fid<0
    unloadlibrary('CFS32');
    warning('Unable to open %s', filename);
    matfilename='';
    return
end

% Set up MAT-file giving a 'kcl' extension
if nargin<2
    targetpath=fileparts(filename);
end
matfilename=scCreateKCLFile(filename, targetpath);
if isempty(matfilename)
    return
end

% get list of valid channels
[time, date, comment]=CFSGetGenInfo(fid);
[nchan, nVars, nDSVars, nDS]=CFSGetFileInfo(fid);

progbar=scProgressBar(0,'','Name', 'Import File');

nchan=double(nchan);
for chan=0:nchan-1
    msg=[];
    scProgressBar(0, progbar, ...
        sprintf('Importing data on Channel %d',chan+1));

    % Get channel information
    [chanName, yUnits, xUnits, dataType, dataKind, spacing, other]=CFSGetFileChan(fid, chan);
    hdr.channel=chan+1;
    hdr.source=dir(filename);
    hdr.source.name=filename;
    hdr.title=chanName;
    hdr.comment=comment;
    hdr.adc.Units=yUnits;

    switch dataKind
        case 0
            % Standard adc channel
            % Set up buffers
            chOffset=zeros(1,nDS);
            points=zeros(1,nDS);
            yScale=zeros(1,nDS);
            yOffset=zeros(1,nDS);
            xScale=zeros(1,nDS);
            xOffset=zeros(1,nDS);
            for DS=1:nDS
                [chOffset(DS), points(DS), yScale(DS),...
                    yOffset(DS), xScale(DS), xOffset(DS)]=CFSGetDSChan(fid, chan, DS);
            end

            imp.tim=zeros(nDS,3);

            % Now read each frame
            minimum=Inf;
            maximum=-Inf;
            for DS=1:nDS
                [starttime imp.mrk(DS, :)]=GetFrameInfo(fid, DS, nDSVars);
                [npoints, buf]=CFSGetChanData(fid, chan, DS, chOffset(DS), points(DS));%%%%%
                pg=double(DS)/double(nDS);
                if rem(double(DS),20)==0
                scProgressBar(pg, progbar, ...
                        sprintf('Importing data on Channel %d',chan+1));
                end
                imp.adc(1:npoints,DS)=buf(1:npoints);%%%%%
                % Start
                if ~isempty(starttime)
                    imp.tim(DS,2)=starttime; %seconds
                else
                    imp.tim(DS,2)=0;
                end
                % Trigger
                imp.tim(DS,1)=imp.tim(DS,2)+(xOffset(DS));
                % End of sweep
                imp.tim(DS,3)=imp.tim(DS,1)+(xScale(DS)*(npoints-1));
                % TODO: mixed class - is it backwards compatible?
                minimum=min([minimum; buf]);
                maximum=max([maximum; buf]);
            end
            hdr.adc.Npoints=double(points);
            
            % If the scale factor is constant for each segment
            if numel(unique(yScale))==1 && numel(unique(yOffset))==1
                hdr.adc.Scale=yScale(1);
                hdr.adc.DC=yOffset(1);
                hdr.adc.YLim=[double(minimum)*yScale(1)+yOffset(1)...
                    double(maximum)*yScale(1)+yOffset(1)];
            else
                % Bug fix 01.10.08
                imp.adc=single(imp.adc);
                for DS=1:nDS
                    imp.adc(:,DS)=imp.adc(:,DS)*yScale(DS)+yOffset(DS);
                end
                minimum=min(imp.adc(:));
                maximum=max(imp.adc(:));
                hdr.adc.YLim=double([minimum maximum]);
                hdr.adc.Scale=1;
                hdr.adc.DC=0;
            end

            % Complete for adc data
            hdr.adc.TargetClass='adcarray';

            % If constant sample rate
            if numel(unique(xScale))==1
                hdr.adc.SampleInterval=[xScale(1)*10^6 10^-6];
            else
                error('ImportCFS: Variable sample rates not supported');
            end

            % If the data is frame based (i.e. constant length &
            % pre-trigger)
            if numel(unique(points))==1 && numel(unique(xOffset))==1
                hdr.channeltype='Framed Waveform';
                hdr.adc.Labels={'Time' 'Frame'};
            else
                hdr.channeltype='Episodic Waveform';
                hdr.adc.Labels={'Time' 'Epoch'};
            end

            hdr.adc.Func=[];
            hdr.adc.Units=yUnits;
            hdr.adc.Multiplex=1;
            hdr.adc.MultiInterval=[0 0];
            


            hdr.tim.Class='tstamp';
            if numel(unique(xScale))==1
                hdr.tim.Scale=1;
            else
                error('ImportCFS: Multiple sample rates on one channel not presently supported');
            end
            hdr.tim.Shift=0;
            hdr.tim.Func=[];
            hdr.tim.Units=1;

            hdr.channeltypeFcn='';
            hdr.markerclass=class(imp.mrk);
            
            
            if any(imp.tim(2:end,2)==0)
                % Absolute start time not available for all frames:
                % may be a CFS file created offline. 
                % Convert to arbitrary frame spacing
                warning(sprintf('ImportCFS: Frame start times not available from file.Was it created offline?\nUsing arbitrary start times')); %#ok<SPWRN,WNTAG>
                hdr.comment=sprintf('%s\n Frame start times are arbitrary', hdr.comment);
                spacing=ceil(max(imp.tim(:,3)-imp.tim(:,1)))*1.5;
                imp.tim(:,2)=spacing:spacing:spacing*size(imp.tim,1);
                for DS=1:nDS
                    % Trigger
                    imp.tim(DS,1)=imp.tim(DS,2)+(xOffset(DS));
                    % End of sweep
                    imp.tim(DS,3)=imp.tim(DS,1)+(xScale(DS)*(npoints-1));
                end
            end
                         
        case 1
            % This deals with the marker channel, the corresponding key
            % strokes are stored in channel 'other'.
            % Other matrix channels are not presently supported.
            if strcmpi(chanName,'Marker time')
                count=0;
                for DS=1:nDS
                    starttime=GetFrameInfo(fid, DS, nDSVars);
                    [chOffset(DS), points(DS), yScale(DS),...
                        yOffset(DS), xScale(DS), xOffset(DS)]=CFSGetDSChan(fid, chan, DS);
                    [npoints1, temp1]=CFSGetChanData(fid, chan, DS, chOffset(DS), points(DS));
                    [npoints2, temp2]=CFSGetChanData(fid, other, DS, chOffset(DS), points(DS));
                    if npoints1>0
                        for k=1:npoints1
                            count=count+1;
                            imp.tim(count,1)=double(temp1(k))*yScale(DS)+yOffset(DS)+starttime;
                            imp.mrk(count,:)=uint8([temp2(k) 0 0 0]);
                        end
                    end
                end
                
                if count==0
                    continue
                end
                hdr.channeltype='Rising Edge';
                hdr.adc.Labels={'Time'};
                imp.adc=[];
                hdr.adc=[];

                hdr.tim.Class='tstamp';
                hdr.tim.Scale=1;
                hdr.tim.Shift=0;
                hdr.tim.Func=[];
                hdr.tim.Units=1;
                hdr.channeltypeFcn='';
                hdr.markerclass='char';
            end
    end
    % Save the data
    scProgressBar((chan+1)/nchan, progbar, ...
        sprintf('Saving data on Channel %d',chan));
    if exist('imp','var') && exist('hdr','var')
        scSaveImportedChannel(matfilename, chan+1, imp, hdr, 0)
        clear('imp','hdr');
    end
end
% Finish off
sigTOOLVersion=scVersion('nodisplay');
save(matfilename,'sigTOOLVersion','-v6','-append');
CFSCloseCFSFile(fid);
delete(progbar);
if ishandle(msg)
    delete(msg);
end
unloadlibrary('CFS32');
end