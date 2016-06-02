function matfilename=ImportNS(filename, targetpath)
% ImportNS uses the NeuroShare library to import a data file under Windows
%
% ImportNS is called to load various proprietary file formats where the
% manufacturers have provided a NeuroShare compliant DLL. Communication
% with the file occurs via Neuroshare mexprog.dll
%
% ImportNS should not be called direcly but via one of the format specific
% import routines .ImportNS assumes that the appropriate NeuroShare dll
% has already been selected by a previous call to ns_SetLibrary and that
% the NeuroShare mexprog.dll (or mexprog.mexw32) is available.
%
% Example:
% MATFILENAME=ImportNS(FILENAME, TARGETPATH)
%
% FILENAME is the path and name of the Spike2 file to import.
%
% The sigTOOL (*.kcl) file generated will be placed in TARGETPATH if
% supplied. If not, the file will be created in the directory taken
% from FILENAME.
%
%
% Toolboxes required: None
%
% Acknowledgements: This routine calls the NeuroShare mexprog.dll and
% associated m-files to communicate with the various manufacturer specific
% NeuroShare DLLs
%
% Author: Malcolm Lidierth 10/06
% Copyright © The Author & King's College London 2006-2007
%
% Revisions:
% 25.09.09  Explicit double precision for hdr.adc.YLim (needed for low values of
%           adcscale)
% 05.11.09  See within
%           Change to nanoseconds for sample interval
% 17.11.09  Change to calculation of imp.tim(:,2)

% Load data file
[nsresult, hfile] = ns_OpenFile(filename);
if (nsresult ~= 0)
    fprintf('Data file did not open. Neuroshare returned error code %d', nsresult);
    return
end

%-------------------------------------------------------------------------
% Pass back the NeuroShare handle to allow the file to be closed manually
% while debugging
assignin('base','hfile',hfile);
%-------------------------------------------------------------------------

matfilename=scCreateKCLFile(filename, targetpath);
if isempty(matfilename)
    return
end

% Get source file information
[nsresult, FileInfo] = ns_GetFileInfo(hfile);
% Gives you EntityCount, TimeStampResolution and TimeSpan
if (nsresult ~= 0)
    fprintf('Data did not load. Neuroshare returned error code %d', nsresult);
    return
end


% Build catalogue of entities
[nsresult, EntityInfo] = ns_GetEntityInfo(hfile, 1:FileInfo.EntityCount);

progbar=scProgressBar(0,'','Name', filename);

for chan=1:length(EntityInfo)
    imp=[];
    hdr=[];
    clear('ScaleFlag');
    % Check there is data
    if EntityInfo(chan).ItemCount==0
        continue
    end
    
    % 25.09.09
    hdr=scCreateChannelHeader();

    hdr.channel=chan;
    hdr.source=dir(filename);
    hdr.source.name=filename;
    hdr.title=EntityInfo(chan).EntityLabel;

    switch EntityInfo(chan).EntityType
        case 1
            %--------------------------------------------------------------
            % Event channel
            %--------------------------------------------------------------
            [nsresult, EventInfo] = ns_GetEventInfo(hfile,chan);
            
            if nsresult<0 
                continue
            end
            
            hdr.channeltype='Edge';
            hdr.channeltypeFcn='';
            hdr.markerclass=GetMatlabClass(EventInfo.EventType);

            [nsresult, timestamps, data, datasize] =...
                ns_GetEventData(hfile, chan, 1:EntityInfo(chan).ItemCount); %#ok<NASGU>

            if nsresult<0 || isempty(timestamps)
                continue
            end
          
            imp.tim=zeros(EntityInfo(chan).ItemCount,1);
            imp.tim(:,1)=ConvertTimeStamps(timestamps,FileInfo.TimeStampResolution);
            hdr.tim.Class='tstamp';
            hdr.tim.Scale=1;
            hdr.tim.Shift=0;
            hdr.tim.Func=[];
            hdr.tim.Units=FileInfo.TimeStampResolution;

            if iscell(data)
                % Nex may return cell in data: ignore it
                imp.mrk=[];
            else
                % Otherwise...
                imp.mrk=zeros(size(imp.tim,1), 4, hdr.markerclass);
                imp.mrk(:,1)=cast(data,hdr.markerclass);
            end

            hdr.adc=[];
            imp.adc=[];

            hdr.Neuroshare.Type='Event';
            hdr.Neuroshare.Info=EventInfo;

        case 2
            %--------------------------------------------------------------
            % Continuous Waveform Channel
            %--------------------------------------------------------------
            [nsresult, AnalogInfo] = ns_GetAnalogInfo(hfile,chan);
            
            if nsresult<0
                continue
            end
            
            % Standard check - have the data already been scaled by the
            % manufacturer's dll?
            hdr.channeltype='Continuous Waveform';
            hdr.channeltypeFcn='';

            imp.tim(1,1)=0;
            % 05.11.09 Better IEEE performance?
            imp.tim(1,2)=(EntityInfo(chan).ItemCount-1)...
                /FileInfo.TimeStampResolution...
                /AnalogInfo.SampleRate;       
            hdr.tim.Class='tstamp';
            hdr.tim.Scale=1;
            hdr.tim.Shift=0;
            hdr.tim.Func=[];
            hdr.tim.Units=FileInfo.TimeStampResolution;


            blocksize=1e6;
            imp.adc=zeros(EntityInfo(chan).ItemCount,1,'int16');
            nblocks=floor(EntityInfo(chan).ItemCount/blocksize);
            tail=rem(EntityInfo(chan).ItemCount, blocksize);
            % Read the data
            for k=1:nblocks
                [nsresult, count, data]=ns_GetAnalogData(hfile, chan,...
                    (k-1)*blocksize+1, blocksize);
                ScaleFlag=CheckScale(data);
                if ScaleFlag==1
                    % Scale to int16
                    adcscale=double(max(data(:))-min(data(:)))/65535;
                    adcoffset=(min(data(:))+max(data(:)))/2;
                    data=int16((data-adcoffset)/adcscale);
                else
                    adcscale=AnalogInfo.Resolution;
                    adcoffset=0;
                    data=int16(data);
                end
                imp.adc((k-1)*blocksize+1:(k-1)*blocksize+count)=data;
            end
            if tail>0
                [nsresult, count, data]=ns_GetAnalogData(hfile, chan,...
                    max(0,(nblocks-1))*blocksize+1, tail);
                ScaleFlag=CheckScale(data);
                if ScaleFlag==1
                    % Scale to int16
                    adcscale=double(max(data(:))-min(data(:)))/65535;
                    adcoffset=(min(data(:))+max(data(:)))/2;
                    data=int16((data-adcoffset)/adcscale);
                else
                    adcscale=AnalogInfo.Resolution;
                    adcoffset=0;
                    data=int16(data);
                end
                imp.adc((nblocks)*blocksize+1:(nblocks)*blocksize+tail)=...
                    int16(data);
            end

            hdr.adc.TargetClass='adcarray';
            hdr.adc.Labels={'Time'};
            % 05.11.09
            hdr.adc.SampleInterval=[1e9/AnalogInfo.SampleRate 1e-9];
            hdr.adc.Scale=adcscale;
            hdr.adc.DC=adcoffset;
            hdr.adc.Func=[];
            hdr.adc.Units=AnalogInfo.Units;
            hdr.adc.Multiplex=1;
            hdr.adc.MultiInterval=[0 0];
            hdr.adc.Npoints=EntityInfo(chan).ItemCount;
            hdr.adc.YLim=[double(min(imp.adc(:)))*adcscale+adcoffset double(max(imp.adc(:)))*adcscale+adcoffset];
            hdr.markerclass='uint8';

            hdr.Neuroshare.Type='Analog';
            hdr.Neuroshare.Info=AnalogInfo;
        case 3
            %--------------------------------------------------------------
            % Segment Data
            %--------------------------------------------------------------
            [nsresult, SegmentInfo] = ns_GetSegmentInfo(hfile,chan);
            
            if nsresult<0
                continue
            end

            hdr.channeltype='Framed Waveform (Spike)';
            hdr.channeltypeFcn='';
            hdr.markerclass='uint8';

            data=zeros(SegmentInfo.MaxSampleCount*SegmentInfo.SourceCount,...
                EntityInfo(chan).ItemCount, 'int16');
            hdr.adc.Npoints=zeros(1,EntityInfo(chan).ItemCount);

            for k=1:SegmentInfo.SourceCount
                [nsresult, SegmentSourceInfo] = ns_GetSegmentSourceInfo(hfile,chan,k);
                [nsresult, timestamps, temp, samplecount, UnitID]=...
                    ns_GetSegmentData(hfile, chan, 1:EntityInfo(chan).ItemCount);
                if nsresult<0
                    continue
                else
                    hdr.adc.Npoints=hdr.adc.Npoints+samplecount';
                    ScaleFlag=CheckScale(temp);
                    if ScaleFlag==1
                        % Scale to int16
                        adcscale=double(max(temp(:))-min(temp(:)))/65535;
                        adcoffset=(min(temp(:))+max(temp(:)))/2;
                        temp=int16((temp-adcoffset)/adcscale);
                    else
                        adcscale=SegmentSourceInfo.Resolution;
                        adcoffset=0;
                        temp=int16(temp);
                    end
                    data(k:SegmentInfo.SourceCount:end,:)=temp;
                end
                hdr.comment='';
                imp.tim(:,1)=ConvertTimeStamps(timestamps,FileInfo.TimeStampResolution);
                % 17.11.09 Use samplecount instead of size(data,1)
                imp.tim(:,2)=(timestamps+...
                    ((samplecount/SegmentInfo.SourceCount)-1)*(1/SegmentInfo.SampleRate))...
                    /FileInfo.TimeStampResolution;

                hdr.tim.Class='tstamp';
                hdr.tim.Scale=1;
                hdr.tim.Shift=0;
                hdr.tim.Func=[];
                hdr.tim.Units=FileInfo.TimeStampResolution;

                imp.adc=data;
                hdr.adc.TargetClass='adcarray';
                hdr.adc.Labels={'Time'};
                % 05.11.09
                hdr.adc.SampleInterval=[1e9/SegmentInfo.SampleRate 1e-9];
                hdr.adc.Scale=adcscale;
                hdr.adc.DC=adcoffset;
                hdr.adc.Func=[];
                if isfield(SegmentInfo,'Units')
                    hdr.adc.Units=SegmentInfo.Units;
                else
                    hdr.adc.Units='';
                end
                hdr.adc.Multiplex=SegmentInfo.SourceCount;
                hdr.adc.MultiInterval=[0 0];
                hdr.adc.YLim=[double(min(imp.adc(:)))*adcscale+adcoffset double(max(imp.adc(:)))*adcscale+adcoffset];
                imp.mrk=uint8(UnitID);
                hdr.markerclass='uint8';
                
                hdr.Neuroshare.Type='Segment';
                hdr.Neuroshare.Info=SegmentInfo;
                
            end
        case 4
            %--------------------------------------------------------------
            % Neural Data
            %--------------------------------------------------------------
            [nsresult, NeuralInfo] = ns_GetNeuralInfo(hfile, chan);

            if nsresult<0
                continue
            end

            hdr.channeltype='Edge';
            hdr.channeltypeFcn='';
            hdr.markerclass='uint16';
            [nsresult, NeuralData] = ns_GetNeuralData(hfile, chan,...
                1, EntityInfo(chan).ItemCount);
            if nsresult<0
                continue
            else
                imp.tim=zeros(EntityInfo(chan).ItemCount,1);
                imp.tim(:,1)=ConvertTimeStamps(NeuralData,FileInfo.TimeStampResolution);
                hdr.tim.Class='tstamp';
                hdr.tim.Scale=1;
                hdr.tim.Shift=0;
                hdr.tim.Func=[];
                hdr.tim.Units=FileInfo.TimeStampResolution;

                imp.adc=[];
                imp.mrk=zeros(size(imp.tim,1), 4, hdr.markerclass);
                imp.mrk(1:length(NeuralData),1)=NeuralInfo.SourceUnitID;
                hdr.adc=[];
                
                hdr.Neuroshare.Type='Neural';
                hdr.Neuroshare.Info=NeuralInfo;
            end

        otherwise
            continue
    end
    scProgressBar(chan/length(EntityInfo), progbar, ...
        sprintf('sigTOOL is saving data on Channel %d',chan));
    scSaveImportedChannel(matfilename, chan, imp, hdr);
    clear('imp','hdr','data');
end

sigTOOLVersion=scVersion('nodisplay'); %#ok<NASGU>
save(matfilename,'sigTOOLVersion','-v6','-append');
close(progbar);
ns_CloseFile(hfile);
end

%--------------------------------------------------------------------------
function c=GetMatlabClass(nsClass)
%--------------------------------------------------------------------------
% Adapted from ns.h:
if ischar(nsClass)
    switch nsClass
        case {'ns_EVENT_TEXT' 'ns_EVENT_CSV' 'ns_EVENT_BYTE'}
            c='uint8';
        case 'ns_EVENT_WORD'
            c='uint16';
        case 'ns_EVENT_DWORD'
            c='uint32';
        otherwise
            c='unknownclass';
    end
end
return
end

%--------------------------------------------------------------------------
function ts=ConvertTimeStamps(timestamps, units)
%--------------------------------------------------------------------------
% Convert to base time units, cast to int32
% Note MATLAB does rounding
ts=int32(timestamps*(1/units));
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function ScaleFlag=CheckScale(data)
%--------------------------------------------------------------------------
% This overcomes a problem with the way different manufacturers have
% interpreted the NeuroShare standard.
% Some return the integer values from the ADC while others return
% pre-scaled floating point data from ns_GetAnalogData and
% ns_GetSegmentData

if all(rem(data(:),1)==0)
    ScaleFlag=0;
    return
else
    ScaleFlag=1;
end
return
end

