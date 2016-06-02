function matfilename=ImportMultiMediaMATLAB(filename, targetpath)
% ImportMultiMediaMATLAB load various multimedia formats (video only)
%
%
% Example:
% matfilename=ImportMultiMediaMATLAB(filename, targetpath)
%
% Inputs:   filename    full path/filename of source
%           targetpath  target folder for output
% Output:   matfilename name or the generated sigTOOL data file
%
%
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 01/10
% Copyright © The Author & King's College London 2010-
%__________________________________________________________________________



% Set up MAT-file giving a 'kcl' extension
matfilename=scCreateKCLFile(filename, targetpath);
if isempty(matfilename)
    return
end

progbar=scProgressBar(0,'','Name', 'Importing MultiMedia');
obj=mmreader(filename);

interval=(1/obj.FrameRate);
if ~isempty(obj.BitsPerPixel)
    nframe=1;
        adc1=read(obj,1); %#ok<NASGU>
        tim1=zeros(obj.NumberOfFrames,1);
        tim1(1)=0;
        save(matfilename, 'adc1', '-v6');
        AddDimension(matfilename,'adc1');
        for nframe=2:obj.NumberOfFrames
            adc1=read(obj, nframe);
            tim1(nframe)=(nframe-1)*interval;
            scProgressBar(0, progbar, ...
                sprintf('sigTOOL is saving video frame %d',nframe));
            AppendMatrix(matfilename, 'adc1', adc1);
        end
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

% if obj.hasAudio
%     % TODO: if TMW support audio input
% end


sigTOOLVersion=scVersion('nodisplay'); %#ok<NASGU>
save(matfilename,'sigTOOLVersion','-v6','-append');

close(progbar);

return
end
