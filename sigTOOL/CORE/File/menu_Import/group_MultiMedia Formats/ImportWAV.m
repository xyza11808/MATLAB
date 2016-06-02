function matfilename=ImportWAV(filename, targetpath)
% ImportWAV load wav formats audio files
%
% Example:
% matfilename=ImportWAV(filename, targetpath)
%
% Inputs:   filename    full path/filename of source
%           targetpath  target folder for output
% Output:   matfilename name of the generated sigTOOL data file 
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________

%
% Revisions:
%   22.10.08    hdr.markerclass now initialized


% Call MATLAB builtin wavread
[audio, Fs]=wavread(filename);

if isempty(audio)
    matfilename='';
    return
else
    % Set up MAT-file giving a 'kcl' extension
    matfilename=scCreateKCLFile(filename, targetpath);
    if isempty(matfilename)
        return
    end
end

% Save data to sigTOOL file
% One sigTOOL channel for each audio channel

    for chan=1:size(audio,2)
        hdr=scCreateChannelHeader();
        hdr.channeltype='Continuous Waveform';
        hdr.channel=chan;
        hdr.title=['Audio' num2str(chan)];

        data.adc=audio(:,chan);
        
        hdr.adc.Labels={'Audio'};
        interval=1/Fs;
        hdr.adc.SampleInterval=[interval*10^6 1e-6];
        hdr.adc.Npoints=length(audio);
        hdr.adc.YLim=[min(audio(:,chan)) max(audio(:,chan))];
        hdr.adc.TargetClass='adcarray';

        data.tim=[0 (length(audio)-1)/Fs]*1e6;
        hdr.tim.TargetClass='tstamp';
        hdr.tim.Units=1e-6;

        data.mrk=[];
        hdr.markerclass='';

        scSaveImportedChannel(matfilename, chan, data, hdr);
        clear('data','hdr');
    end


sigTOOLVersion=scVersion('nodisplay');
save(matfilename,'sigTOOLVersion','-v6','-append');

return
end