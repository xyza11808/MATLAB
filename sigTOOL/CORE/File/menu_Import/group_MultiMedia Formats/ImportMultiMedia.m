function matfilename=ImportMultiMedia(filename, targetpath)
% ImportMultiMedia load various multimedia formats (audio and video)
%
% ImportMultiMedia is a Windows only function. It calls mmread, which in
% turn calls the Windows DirectX functions.
%
% Example:
% matfilename=ImportMultiMedia(filename, targetpath)
%
% Inputs:   filename    full path/filename of source
%           targetpath  target folder for output
% Output:   matfilename name or the generated sigTOOL data file
%
% mmread was written by Micah Richert and is available at:
% <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8028&objectType=file">MATLAB Central (LinkOut)</a>
%
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________

%
% Revisions:
%   22.10.08    hdr.markerclass now initialized to uint8
%   12.09.09    check for empty video on audio files
%   27.01.10    Updated for use with more recent mmread versions

% Check version. First frame now appears to be 1, not 0.
d=dir(which('mmread.m'));
if d.datenum<7.340617145370371e+005
    error('sigTOOL: Please update your version of mmread to use this function');
end

% Set up MAT-file giving a 'kcl' extension
matfilename=scCreateKCLFile(filename, targetpath);
if isempty(matfilename)
    return
end

progbar=scProgressBar(0,'','Name', 'Using Micah Richert''s mmread function');
[video, audio]=mmread(filename, 1, [], [], [], '', false, true);%(filename, 1);
if ~isempty(video)
    nframe=1;
    if ~isempty(video)
        adc1=video.frames.cdata; %#ok<NASGU>
        tim1=zeros(video.nrFramesTotal,1);
        tim1(1)=video.times;
        save(matfilename, 'adc1', '-v6');
        AddDimension(matfilename,'adc1');
        warning('off', 'mmread:general');
        while true
            nframe=nframe+1;
            video=mmread(filename, nframe, [], [], [], '', false, true);
            if isempty(video.frames)
                nframe=nframe-1;
                break;
            end
            adc1=video.frames.cdata;
            tim1(nframe)=video.times;
            scProgressBar(video.nrFramesTotal/nframe, progbar, ...
                sprintf('sigTOOL is saving video frame %d',nframe));
            AppendMatrix(matfilename, 'adc1', adc1);
        end
        warning('on','mmread:general');
        head1.channeltype='Custom Video';
        head1.channel=1;
        head1.title='Video';
        head1.adc.TargetClass='adcarray';
        head1.channeltypeFcn='scViewImageData';
        head1.adc.Labels={'Multi Media'};
        head1.adc.SampleInterval=[NaN NaN];
        head1.adc.Func=[];
        head1.adc.Scale=1;
        head1.adc.DC=0;
        head1.adc.Units='';
        head1.adc.Multiplex=NaN;
        head1.adc.MultiInterval=[0 0];
        head1.adc.Npoints=nan(nframe,1);
        
        tim1=tim1*1e6; %#ok<NASGU>
        head1.tim.TargetClass='tstamp';
        head1.tim.Scale=1;
        head1.tim.Shift=0;
        head1.tim.Func=[];
        head1.tim.Units=1e-6;
        
        mrk1=uint32(1:nframe)'; %#ok<NASGU>
        head1.markerclass='uint32';
        save(matfilename, 'tim1', '-append', '-v6');
        save(matfilename, 'mrk1', '-append', '-v6');
        save(matfilename, 'head1', '-append', '-v6');
    end
end

if ~isempty(audio)
    if isempty(video)
        n=1;
    else
        n=2;
    end
    j=0;
    for chan=n:n+audio.nrChannels-1
        j=j+1;
        hdr.channeltype='Continuous Waveform';
        hdr.channel=chan;
        hdr.title=['Audio' num2str(j)];
        hdr.adc.TargetClass='adcarray';
        hdr.channeltypeFcn='';
        
        
        imp.adc=audio.data(:,j);
        hdr.adc.Labels={'Audio'};
        interval=1/audio.rate;
        hdr.adc.SampleInterval=[interval*10^6 1e-6];
        hdr.adc.Func=[];
        hdr.adc.Scale=1;
        hdr.adc.DC=0;
        hdr.adc.Units='';
        hdr.adc.Multiplex=1;
        hdr.adc.MultiInterval=[0 0];%not known from original format
        hdr.adc.Npoints=length(audio.data);
        hdr.adc.YLim=[min(audio.data) max(audio.data)];
        
        imp.tim=[0 (length(audio.data)-1)*1/audio.rate]*1e6;
        hdr.tim.TargetClass='tstamp';
        hdr.tim.Scale=1;
        hdr.tim.Shift=0;
        hdr.tim.Func=[];
        hdr.tim.Units=1e-6;
        
        imp.mrk=[];
        hdr.markerclass='uint8';
        
        scSaveImportedChannel(matfilename, chan, imp, hdr);
        clear('imp','hdr');
    end
end

sigTOOLVersion=scVersion('nodisplay'); %#ok<NASGU>
if ~isempty(audio) || ~isempty(video)
    save(matfilename,'sigTOOLVersion','-v6','-append');
end
close(progbar);

return
end
