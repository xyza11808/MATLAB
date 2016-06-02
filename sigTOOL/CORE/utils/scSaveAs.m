function matfilename=scSaveAs(fhandle)
% scSaveAs saves data to a new sigTOOL data file
%
% Example:
% matfilename=scSaveAs(fhandle)
%
% fhandle is the handle of the figure for the source data
% matfilename is the generated .kcl file
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------
%
% Revisions:
%   05.11.09    Line 174. Final test should be for ~any   
%               Line 178. Index of 1 corrected to i.
%   26.01.10    See within

if ishandle(fhandle)
    channels=getappdata(fhandle, 'channels');
end


Filing=getappdata(fhandle,'Filing');
if isempty(dir(Filing.OpenSaveDir))
    Filing.OpenSaveDir='';
end

[filename, targetpath]=uiputfile(fullfile(Filing.OpenSaveDir, '*.kcl'));
if filename==0
    return
end
matfilename=scCreateKCLFile(filename, targetpath);
if isempty(matfilename)
    return
end

% Loop through channels
progbar=scProgressBar(0, filename, 'Name', 'Save As', 'Step', 1);

nchan=0;
for i=1:length(channels)
    if ~isempty(channels{i})
        nchan=nchan+1;
    end
end

for i=1:length(channels)

    % Ignore if empty
    if isempty(channels{i})
        continue
    end

    scProgressBar(i/nchan, progbar, sprintf('<HTML><CENTER>%s<P>Channel %d...</P></CENTER></HTML>',filename,i));

    % Get the header info
    hdr=channels{i}.hdr;

    %---------------------------------------------------------------------
    % Adc data
    %---------------------------------------------------------------------
    if ~isempty(hdr.adc)
        if ~isempty(strfind(channels{i}.hdr.channeltype,'Custom')) &&...
                isa(channels{i}.adc, 'adcarray') &&...
                isempty(channels{i}.adc.Func) &&...
                channels{i}.adc.Scale==1 &&...
                channels{i}.adc.DC==0
            % Custom channel - preserve disc class
            if isa(channels{i}.adc, 'adcarray')
                hdr.adc=UpdateFields(hdr.adc, channels{i}.adc, {'Scale' 'DC' 'Func' 'Units'}, i);
            end
            try
                copy.adc=channels{i}.adc.Map.Data.Adc();
            catch
                CatchErr(i);
            end
        else
            % Waveform data
            switch class(channels{i}.adc)
                case'double'
                    % Temporary channel in IEEE double precision.
                    % This format is not used any longer
                    % Compress to int16
                    warning('Data stored in unsupported format %s- debugging?', class(channels{i}.adc));
                    try
                        copy.adc=channels{i}.adc;
                        % Rescale the data
                        dataminimum=min(copy.adc(:));
                        datamaximum=max(copy.adc(:));
                        hdr.adc.YLim=[dataminimum datamaximum];
                        hdr.adc.Scale=(datamaximum-dataminimum)/65535;
                        hdr.adc.DC=(dataminimum+datamaximum)/2;
                        copy.adc=int16((copy.adc-hdr.adc.DC)/hdr.adc.Scale);
                    catch %#ok<CTCH>
                        % Out of memory?
                        CatchErr(i);
                        continue
                    end

                case 'single'
                    warning('Data stored in unsupported format %s- debugging?', class(channels{i}.adc));
                    try
                        copy.adc=channels{i}.adc;
                        % Rescale the data
                        dataminimum=min(copy.adc(:));
                        datamaximum=max(copy.adc(:));
                        hdr.adc.YLim=[dataminimum datamaximum];
                        hdr.adc.Scale=1;
                        hdr.adc.DC=0;
                    catch %#ok<CTCH>
                        % Out of memory?
                        CatchErr(i);
                        continue
                    end

                case 'adcarray'
                    switch (channels{i}.adc.Map.Format{1})
                        case {'double'}
                            % Temporary channel in double precision adcarray.
                            % Compress to int16
                            try
                                % Rescale the data
                                dataminimum=min(channels{i}.adc.Map.Data.Adc(:));
                                datamaximum=max(channels{i}.adc.Map.Data.Adc(:));
                                hdr.adc.YLim=[dataminimum datamaximum];
                                hdr.adc.Scale=(datamaximum-dataminimum)/65535;
                                hdr.adc.DC=(dataminimum+datamaximum)/2;
                                copy.adc=zeros(size(channels{i}.adc.Map.Data.Adc), 'int16');
                                copy.adc=int16((channels{i}.adc.Map.Data.Adc-hdr.adc.DC)/hdr.adc.Scale);
                            catch %#ok<CTCH>
                                % Out of memory?
                                CatchErr(i);
                                continue
                            end
                        otherwise
                            hdr.adc=UpdateFields(hdr.adc, channels{i}.adc, {'Scale' 'DC' 'Func' 'Units'}, i);
                            try
                                copy.adc=channels{i}.adc.Map.Data.Adc();
                            catch %#ok<CTCH>
                                % Out of memory?
                                CatchErr(i);
                                continue
                            end
                    end
                otherwise
                    % All other data types
                    warning('Data stored in unsupported format %s- debugging?', class(channels{i}.adc));
                    copy.adc=channels{i}.adc;
            end
        end
        % Check size: if downsampled we may be able to save some disc space
        if prod(channels{i}.adc.Map.Format{2}) ~= sum(hdr.adc.Npoints) &&...
                ~any(isnan(hdr.adc.Npoints)) 
            buffer=zeros(max(hdr.adc.Npoints), size(copy.adc,2), class(copy.adc));
            for kk=1:size(copy.adc,2)
                buffer(1:hdr.adc.Npoints(kk), kk)=copy.adc(1:hdr.adc.Npoints(kk), kk);
            end
            copy.adc=buffer;
        end
    else
        copy.adc=[];
        hdr.adc=[];
    end



    % [End of ADC data code]

    %---------------------------------------------------------------------
    % Timestamps
    %---------------------------------------------------------------------
    if isa(channels{i}.tim, 'tstamp') && isempty(channels{i}.tim.Func) &&...
            ~isempty(channels{i}.tim.Map.Format) &&...
            ~any(any(rem(channels{i}.tim()-channels{i}.tim.Shift, channels{i}.tim.Scale)))
        % If tim can be cast to tim.Map.Format without loss of precision - do so...
        hdr.tim=UpdateFields(hdr.tim, channels{i}.tim, {'Scale', 'Shift', 'Func', 'Units'}, i);
        % Bug Fix 05.11.09
        copy.tim=cast((channels{i}.tim()-channels{i}.tim.Shift)/channels{i}.tim.Scale,...
            channels{i}.tim.Map.Format{1});
    else
        % ...otherwise use double precision
        copy.tim=channels{i}.tim();
        hdr.tim.Scale=1;
        hdr.tim.Shift=0;
    end

    %---------------------------------------------------------------------
    % Markers
    %---------------------------------------------------------------------
    copy.mrk=channels{i}.mrk;

    % Save the channel
    siz=prod(size(copy.adc)); %#ok<PSIZE>
    if siz>10e6
        scProgressBar(i/nchan, progbar, sprintf('<HTML><CENTER>%s<P>Saving data (%d samples)...</P></CENTER></HTML>',...
            filename, siz));
    end

    % Get rid of temp/RAM channel markers
    hdr.title=strrep(hdr.title ,'*', '');
    
    % 26.01.10 Make sure we do not have a function handle in
    % hdr.channeltypeFcn
    % Not needed because sigTOOL does not support function handles here (but
    % it may do in future).
    if isa(hdr.channeltypeFcn, 'function_handle')
        hdr.channeltypeFcn=func2str(hdr.channeltypeFcn);
    end        
    
    scSaveImportedChannel(matfilename, i, copy, hdr, 0);
    copy=[];
end


% Now add dataview details
h=findobj(fhandle, 'Type', 'axes');
XLim=get(h(end), 'XLim');
sigTOOLDataView.XLim=XLim;

cursors=getappdata(fhandle, 'VerticalCursors');
cursorpos=cell(1,length(cursors));
for i=1:length(cursors)
    if ~isempty(cursors)
        cursorpos{i}=GetCursorLocation(i);
    end
end
sigTOOLDataView.CursorPositions=cursorpos;
save(matfilename, 'sigTOOLDataView', '-v6', '-append');

% Version
sigTOOLVersion=scVersion('nodisplay'); %#ok<NASGU>
save(matfilename,'sigTOOLVersion','-v6','-append');
close(progbar);

sigTOOL(matfilename);

return
end

%---------------------------------------------------------------------
function target=UpdateFields(target, source, fields, chan)
%---------------------------------------------------------------------
for k=1:length(fields)
    if isnumeric(target.(fields{k}))
        if target.(fields{k})~=source.(fields{k})
            warning('scSaveAs: Channel %d, "%s" entry in header and %s object do not match.\nUsing %s entry.',...
                chan, fields{k}, class(source), class(source)); %#ok<WNTAG>
            target.(fields{k})=source.(fields{k});
        end
    elseif ischar(target.(fields{k}))
        if ~strcmp(target.(fields{k}), source.(fields{k}))
            warning('scSaveAs: Channel %d, "%s" entry in header and %s object do not match.\nUsing %s entry.',...
                chan, fields{k}, class(source), class(source)); %#ok<WNTAG>
            target.(fields{k})=source.(fields{k});
        end
    end
end

return
end
%---------------------------------------------------------------------

%---------------------------------------------------------------------
function CatchErr(chan)
%---------------------------------------------------------------------
%TODO: This needs to be replaced with a Mode 1 save to the MAT file
% to cope with lengthy data channels. But let's see if anyone needs that.
msg=lasterror();
warning('scSaveAs: Unable to save channel %d.\n', chan)  %#ok<WNTAG>
sprintf ('%s.\n Skipping channel', msg.message );
return
end
%---------------------------------------------------------------------
