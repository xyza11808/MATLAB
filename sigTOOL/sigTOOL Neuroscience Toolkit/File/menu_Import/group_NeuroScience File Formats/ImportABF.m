function matfilename=ImportABF(filename, targetpath)
% ImportABF imports Molecular Devices (Axon Instruments) ABF files
% The file created is a sigTOOL compatible version 6 MAT-file with the kcl
% extension
%
% Example:
% OUTPUTFILE=ImportABF(FILENAME)
% OUTPUTFILE=ImportABF(FILENAME, TARGETPATH)
%
% FILENAME is the path and name of the ABF file to import.
%
% The kcl file generated will be placed in TARGETPATH if supplied. If not,
% the file will be created in the directory taken from FILENAME.
%
%
% ImportABF calls three mex files ABFGetADCChannel, ABFGetDACChannel  and
% ABFGetFileInfo that in turn call the manufacturer's DLL to load the data.
% ImportABF is therefore a Windows only function.
%
% Toolboxes required: None
%
% The ABF filing system is copyright Molecular Devices
%
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007-
%
% Acknowledgements:
% Revisions:
% 16.08.08  Recompile mex files with Borland C++ for back compat to R2006a.
%           Sledge-hammer termination of units string for Borland.
% 22.10.08  Rare memory overflows from ABFGetADCChannel fixed
% 09.01.09  Correct out-by-one sample error or pre-time calculation
% 20.12.09  Now retrieve entire ABF file header

% Set up MAT-file giving a 'kcl' extension
if nargin<2
    targetpath=fileparts(filename);
end
matfilename=scCreateKCLFile(filename, targetpath);
if isempty(matfilename)
    return
end

% Some constants
dll=which('abffio.dll');
MAXADC=16;
MAXDAC=4;
tbase=[];

[s ABFFileHeader]=ABFGetFileInfo(dll, filename);


% Fill with -1 if not done by dll
% TODO: Check Axon doc about this
seq=s.ADCSamplingSeq(2:end);
seq(seq==0)=-1;
s.ADCSamplingSeq(2:end)=seq;

progbar=scProgressBar(0,'','Name', filename);

for idx=0:MAXADC+MAXDAC-1
    msg=[];
    hdr.title='';
    hdr.units='';
    % Get channel information
    if idx<=MAXADC-1
        % ADC channels (0-15)
        if s.ADCSamplingSeq(idx+1)<0
            continue
        end
        scProgressBar(idx/MAXADC, progbar, ...
            sprintf('Importing data on ADC Channel %d',idx));
        
        [imp.adc, time, npoints]=ABFGetADCChannel(dll, filename, s.ADCSamplingSeq(idx+1));

        if npoints==0
            continue
        end

        if idx==0
            % Store the timebase of the first sampled channel for use
            % with the DAC channels
            tbase=time;
        end
        if ~isempty(ABFFileHeader.sADCChannelName)
            hdr.title=ABFFileHeader.sADCChannelName{idx+1};
        end
        if ~isempty(ABFFileHeader.sADCUnits)
        hdr.adc.Units=ABFFileHeader.sADCUnits{idx+1};
        end
        if isempty(hdr.title)
            hdr.title=sprintf('ADC%d',idx);
        end
        hdr.channel=s.ADCSamplingSeq(idx+1);
        thischan=s.ADCSamplingSeq(idx+1)+1;
    else
        % DAC channels (0-3)
        [imp.adc, npoints]=ABFGetDACChannel(dll, filename, idx-MAXADC);
        if sum(npoints)>0
            time=tbase;
            if ~isempty(ABFFileHeader.sDACChannelName)
                hdr.title=ABFFileHeader.sDACChannelName{idx-MAXADC+1};
            end
            if ~isempty(ABFFileHeader.sADCUnits)
                hdr.adc.Units=ABFFileHeader.sADCUnits{idx-MAXADC+1};
            end
            if isempty(hdr.title)
                hdr.title=sprintf('DAC%d',idx-MAXADC);
            end
        end
        hdr.channel=idx-MAXADC;
        thischan=idx+1;
    end

    if sum(npoints)==0 || isempty(time)
        continue
    end

    
    hdr.source=dir(filename);
    hdr.source.name=filename;
    hdr.adc.TargetClass='adcarray';

    % Continuous/frame based/uneven epochs
    if isscalar(npoints)
        hdr.channeltype='Continuous Waveform';
        hdr.adc.Labels={'Time'};
    else
        if numel(unique(npoints))==1
            hdr.channeltype='Framed Waveform';
            hdr.adc.Labels={'Time' 'Frame'};
        else
            hdr.channeltype='Episodic Waveform';
            hdr.adc.Labels={'Time' 'Epoch'};
        end
    end

    % Timestamps
    imp.tim(:,1)=time(1,:);
    % 09.01.09 Change from s.PreTriggerSamples-1
    imp.tim(:,2)=imp.tim(:,1)+(s.PreTriggerSamples)*(time(2)-time(1));
    for i=1:size(imp.adc,2)
        imp.tim(i,3)=time(npoints(i),i);
    end 
    % Convert to integer if no loss of precision
    if all(rem(imp.tim(:),1)==0) && max(imp.tim(:)<2^31)
        imp.tim=int32(imp.tim);
    end
    
    % Markers
    imp.mrk=zeros(size(imp.adc,2), 4, 'uint8');

    % Convert to int16
    hdr.adc.Scale=double(max(imp.adc(:))-min(imp.adc(:)))/65535;
    hdr.adc.DC=double(min(imp.adc(:))+max(imp.adc(:)))/2;
    imp.adc=int16((imp.adc-hdr.adc.DC)/hdr.adc.Scale);

    hdr.adc.Func=[];
    hdr.adc.SampleInterval=[(time(2,1)-time(1,1))*10^3 10^-6];
    hdr.adc.Multiplex=1;
    hdr.adc.MultiInterval=[0 0];
    hdr.adc.Npoints=double(npoints);
    hdr.adc.YLim=[double(min(imp.adc(:)))*hdr.adc.Scale+hdr.adc.DC...
        double(max(imp.adc(:)))*hdr.adc.Scale+hdr.adc.DC];


    hdr.tim.Scale=1;
    hdr.tim.Shift=0;
    hdr.tim.Func=[];
    hdr.tim.Units=1e-3;

    hdr.channeltypeFcn='';
    hdr.markerclass='';

    hdr.Patch.Type=patchType(ABFFileHeader.nExperimentType);
    hdr.Patch.isLeakSubtracted=logical(ABFFileHeader.nLeakSubtractType);
    
    % Save the data
    scProgressBar(idx/MAXADC, progbar, ...
        sprintf('sigTOOL is saving data on Channel %d',idx+1));
    if exist('imp','var') && exist('hdr','var')
        scSaveImportedChannel(matfilename, thischan, imp, hdr, 0)
        clear('imp','hdr');
    end
end

% Finish off
sigTOOLVersion=scVersion('nodisplay'); %#ok<NASGU>
close(progbar);
if ishandle(msg)
    delete(msg);
end
try
    FileSource.name=ABFFileHeader.sCreatorInfo;
    FileSource.header=orderfields(ABFFileHeader);
    save(matfilename,'FileSource','-v6','-append');
    save(matfilename,'sigTOOLVersion','-v6','-append');
catch %#ok<CTCH>
    error('No data has been written to the output file');
end
end

function str=patchType(n)
switch n
    case 0
        str='Voltage-clamp';
    case 1
        str='Current-clamp';
    case 2
        str='Simple aquisition';
    otherwise
        str='';
end
return
end