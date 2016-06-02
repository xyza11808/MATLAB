function matfilename=ImportSSD(filename, targetpath)
% ImportSSD imports CONSAM SSD files.
% The file created is a sigTOOL compatible version 6 MAT-file with the kcl
% extension
%
% Example:
% OUTPUTFILE=ImportSSD(FILENAME)
% OUTPUTFILE=ImportSSD(FILENAME, TARGETPATH)
%
% FILENAME is the path and name of the file to import.
%
% The kcl file generated will be placed in TARGETPATH if supplied. If not,
% the file will be created in the directory taken from FILENAME.
%
% Author: Malcolm Lidierth 11/09
% Copyright © The Author & King's College London 2009-



% Set up MAT-file giving a 'kcl' extension
if nargin<2
    % 22.11.09 Add filesep
    targetpath=[fileparts(filename) filesep()];
end
matfilename=scCreateKCLFile(filename, targetpath);
if isempty(matfilename)
    return
end


fh=fopen(filename, 'r', 'l');
% Read the SSD file header
h.iver=fread(fh, 1, 'int16=>int16');        % file version
h.title=fread(fh, 70, 'uint8=>char')';      % experiment name
h.cdate=fread(fh, 11, 'uint8=>char')';      % sampling date
h.adctime=fread(fh, 8, 'uint8=>char')';     % file time

h.idt=fread(fh, 1, 'int16=>int16');         % 
h.ioff=fread(fh, 1, 'int32=>int32');        % header length
h.ilen=fread(fh, 1, 'int32=>int32');        % data length (bytes)
h.inchan=fread(fh, 1, 'int16=>int16');      % number of channels
h.id1=fread(fh, 1, 'int16=>int16');         %
h.id2=fread(fh, 1, 'int16=>int16');         %
h.cctrig=fread(fh, 3, 'uint8=>char')';      % 'H' or 'HT' for triggered sampling

h.calfac=fread(fh, 1, 'single=>single');    % Calibration factor Channel 0 (converts to pA)
h.srate=fread(fh, 1, 'single=>single');     % Sample Rate
h.filt=fread(fh, 1, 'single=>single');      % filter Channel 0
h.filt1=fread(fh, 1, 'single=>single');     % filter Channel 1
h.calfac1=fread(fh, 1, 'single=>single');   % Calibration factor Channel 1 (converts to pA)

h.expdate=fread(fh, 11, 'uint8=>char')';    % Experiment date
h.defname=fread(fh, 6, 'uint8=>char')';     % Sample name
h.tapeID=fread(fh, 24, 'uint8=>char')';     % Tape details

h.ipatch=fread(fh, 1, 'int32=>int32');      % Patch type
h.npatch=fread(fh, 1, 'int32=>int32');      % Patch number

h.Emem=fread(fh, 1, 'single=>single');      % Membrane potential
h.temp=fread(fh, 1, 'single=>single');      % Temperature (degrees C)

h=orderfields(h);

fseek(fh, 512, 'bof');
[data count]=fread(fh, double(h.ilen)/2, 'int16=>int16');
if h.inchan==2
    % Put each channel in a separate column
    if mod(count,2)==0
        % Odd sample number: Lose the last sample
        count=count-1;
    end
    data=[data(1:2:count-1) data(2:2:count-1)];
end
    
for k=1:h.inchan
    % Create header
    hdr=scCreateChannelHeader();
        hdr.channel=k;
    hdr.source=dir(filename);
    hdr.source.name=filename;
    hdr.title=sprintf('Chan%d', k);
    if k==1
        cutoff=h.filt;
    else
        cutoff=h.filt1;
    end
    hdr.comment=sprintf('%s %s %s Patch Type=%d Patch Number=%d Em=%g Temp= %g Celsius Filter=%gHz',...
        deblank(h.expdate),deblank(h.defname),deblank(h.tapeID),h.ipatch,h.npatch, h.Emem, h.temp, cutoff);
    hdr.channeltype='Continuous Waveform';
    
    % Details
    hdr.Patch.Type=patchType(h.ipatch);
    hdr.Patch.Em=h.Emem;
    hdr.Environment.Temperature=h.temp;
    
    % Channel data
    hdr.adc.Units='pA';
    imp.adc=data(:,k);
    hdr.adc.SampleInterval=[4e6/double(h.srate) 2.5e-7]; % 4MHz clock
    hdr.adc.Npoints=length(imp.adc);
    if k==1
        hdr.adc.Scale=double(h.calfac); % Scaling for pA
    else
        hdr.adc.Scale=double(h.calfac1);
    end
    hdr.adc.YLim=double([min(imp.adc) max(imp.adc)])*hdr.adc.Scale;
    hdr.adc.TargetClass='adcarray';
    
    % Timestamps
    imp.tim(1,1)=0;
    imp.tim(1,2)=(length(imp.adc)-1);
    hdr.tim.Class='tstamp';
    hdr.tim.Scale=prod(hdr.adc.SampleInterval);
    hdr.tim.Shift=0;
    hdr.tim.Func=[];
    hdr.tim.Units=1;
    
    % Store the ssd file header
    hdr.DCProgs=h;
    
    % Save to disc
    scSaveImportedChannel(matfilename, k, imp, hdr, 0)
    clear('imp','hdr');
end

FileSource.name='DC Progs';
FileSource.header=h;
save(matfilename, 'FileSource', '-v6', '-append');

sigTOOLVersion=scVersion('nodisplay');
save(matfilename,'sigTOOLVersion','-v6','-append');

fclose(fh);
return
end



function str=patchType(n)
switch n
    case 1
        str='Outside-out';
    case 2
        str='Inside-out';
    case 3
        str='Cell-attached';
    case 4
        str='Whole-cell';
    case 5
        str='Simulated';
    otherwise
        str=[];
end
return
end