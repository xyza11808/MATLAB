function scPlaySound(fhandle, channel1, channel2, start, stop)
% scPlaySound sets up channel selection uipanel and plays channels as audio
%
% Example:
% scPlaysound(fhandle, channel1, channel2, start, stop)
% where handle points to a sigTOOL data view

% Set up the user-interface panel and get the use input in s
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © The Author & King’s College London 2007-
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:


[fhandle, channels]=scParam(fhandle);
% 05.11.09 Change from referencing channels{1}: may be empty
start=start/channels{channel1}.tim.Units;
stop=stop/channels{channel1}.tim.Units;

idx=findVectorIndices(channels{channel1}, start, stop);
try
    % This plays the audios
    ms=msgbox('Streaming audio...','sigTOOL','non-modal');
    audio=channels{channel1}.adc(idx(1):idx(2));
    if ~isempty(channel1) && channel2~=0
        audio(:,2)=channels{channel2}.adc(idx(1):idx(2));
    end
    soundsc(audio, 1/prod(channels{channel1}.hdr.adc.SampleInterval));
    delete(ms);
catch
    % Catch any errors - most likely to be an out of memory error if the
    % channel(s) is too large
    errortype=lasterror();
    str='Failed to play audio';
    if strcmp(errortype.identifier,'MATLAB:nomem')
        % Out of memory...
        str=[str ': Insufficient free memory to play these channels over the specified period'];
    else
        % ... or something else
        str=[str ': ' errortype.message];
    end
    if ishandle(ms)
        delete(ms);
    end
    msgbox(str ,'sigTOOL: Audio','createNode','replace');
    lasterror('reset');
end
return
end




