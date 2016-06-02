function [out DataView]=scOpen(filename)
% scOpen maps a sigTOOL compatible MATLAB Level 5 v6 MAT-file 
% These will have a .kcl extension if created by sigTOOL
%
% Example:
% channels=scOpen(filename)
% where filename is a fully qualified file name including path
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-2007
% -------------------------------------------------------------------------
%
% Check version - not always maintaining backwards compatability until sigTOOL
% is released
% load(filename,'sigTOOLVersion','-mat');
% if ~exist('sigTOOLVersion','var') || sigTOOLVersion<scVersion('nodisplay')
%     disp('This is an old kcl file');
% end

%--------------------------------------------------------------------------

[pathname fname]=fileparts(filename);
progbar=scProgressBar(0,'Collecting information....','Name', 'Open File');

% PROCESS CHANNEL HEADERS
h=whos('-file',filename,'head*');

% Memory pre-allocation
clist=zeros(length(h),1);
out=cell(length(h),1);

% Get the channel headers.
for i=1:length(h)
    eval(sprintf('load(filename,''%s'',''-mat'')',h(i).name));
    idx=str2double(strrep(h(i).name,'head',''));
    eval(sprintf('out{%d}.hdr=%s;',idx, h(i).name));
    eval(sprintf('clist(i)=%d;', idx));
end
scProgressBar(0, progbar, sprintf('Preparing to map %d channels....', numel(h)));
clear('h');
% Sort clist numerically - alphabetical above as created by
% whos: head1, head11, head2, head21 etc
clist=sort(clist);

% CLIST contains a list of used channels
% OUT is a 1xN cell array, the Nth entry contains the header for channel N
%--------------------------------------------------------------------------
% NOW MAP THE DATA
% Get details for all variables in the file
[s, swap]=where(filename);
[pathname fname]=fileparts(filename);
% Loop for each potential channel
for i=1:length(clist)
    chan=clist(i);
    str=sprintf('<HTML><CENTER>%s<P>Mapping data on Channel %d</P></CENTER></HTML>',fname, chan);
    scProgressBar(i/length(clist), progbar, str);
    
    varname=['chan' num2str(chan)];
    ws=findchanneldetails(s, varname);
    if ~isempty(ws)
        % MODE 0: chanxxx is a structure containing tim, adc and, maybe, mrk
        % fields
        % Mixed mode: mrk is saved separately
        % Timestamp field
        ws2=findchannelfield(ws,'tim');
        out=GetTimeStamps(filename, ws2, out, chan, swap);
        if isempty(out{chan})
            continue
        end

        % Adc field
        if ~isempty(out{chan}.hdr.adc)
            %Map the data
            ws2=findchannelfield(ws,'adc');
            out=GetAdcData(filename, ws2, out, chan, swap);
        else
            out{chan}.adc=[];
        end
        
        % Marker field
        ws2=findchannelfield(ws,'mrk');
        if ~isempty(ws2)
            % Pure Mode 0
            out=GetMarkerData(filename, ws2, out, chan, swap);
        else
            % Mixed Mode - or no mrk field
            varname=['mrk' num2str(chan)];
            if isempty(whos('-file',filename, varname))
                out{chan}.mrk=[];
            else
            temp=load(filename, varname, '-mat');
                out{chan}.mrk=temp.(varname);
            end
        end
    else
        % MODE 1: data are stored in timxxx, adcxxx and mrkxxx
        % variables. This mode is used for very large data sets
        % and allows the tim, adc and mrk data to be loaded separately
        % by the standard load command, and saved in blocks using the
        % sigTOOL MAT-file utilities

        % tim variable
        varname=['tim' num2str(chan)];
        ws=findchanneldetails(s, varname);
        out=GetTimeStamps(filename, ws, out, chan, swap);
        if isempty(out{chan})
            continue
        end
        % adc data
        varname=['adc' num2str(chan)];
        ws=findchanneldetails(s, varname);
        out=GetAdcData(filename, ws, out, chan, swap);
        % mrk data
        varname=['mrk' num2str(chan)];
        ws=findchanneldetails(s, varname);
        out=GetMarkerData(filename, ws, out, chan, swap);

    end
% Set the channel change flags and alphabetically order the fields
    out{chan}.channelchangeflag.hdr=false;
    out{chan}.channelchangeflag.adc=false;
    out{chan}.channelchangeflag.tim=false;
    out{chan}.channelchangeflag.mrk=false;
    out{chan}=orderfields(out{chan});
    
    if ~isempty(out{chan}.hdr.adc) && isempty(out{chan}.hdr.adc.Units)
        out{chan}.hdr.adc.Units='Units';
        if isa(out{chan}.adc, 'adcarray')
            out{chan}.adc.Units='Units';
        end
    end
    
    % TODO: Delete this for release - used as temp update for old kcl 
    % files
    if strcmp(out{chan}.hdr.channeltype,'Triggered Waveform')
        out{chan}.hdr.channeltype='Episodic Waveform';
    end
    
    % Cast to object
    out{chan}=scchannel(out{chan});
end

if nargout>1
    % Suppress warning for old files
    warning('off', 'MATLAB:load:variableNotFound');
    temp=load(filename, 'sigTOOLDataView', '-mat');
    warning('on', 'MATLAB:load:variableNotFound');
    if numel(fieldnames(temp))>0
        DataView=temp.sigTOOLDataView;
    else
        DataView=[];
    end
end

% Do some basic checks on the data
errm=scCheckChannels(out);
if ~isempty(errm)
    warning(errm);
end

delete(progbar);
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function out=GetTimeStamps(filename, s, out, chan, swap)
%--------------------------------------------------------------------------
% scOpen:GetTimeStamps maps the timestamps data
FormatString={s.DiscClass{1} s.size 'Stamps'};
if prod(s.size)==0
    out{chan}={};
    return;
end
map=memmapfile(filename,...
    'Repeat',1,...
    'Format',FormatString,...
    'Offset',s.DataOffset{1}.DiscOffset);
out{chan}.tim=tstamp(map,...
    out{chan}.hdr.tim.Scale,...
    out{chan}.hdr.tim.Shift,...
    out{chan}.hdr.tim.Func,...
    out{chan}.hdr.tim.Units,...
    swap);
end

%--------------------------------------------------------------------------
function out=GetAdcData(filename, s, out, chan, swap)
%--------------------------------------------------------------------------
% scOpen:GetAdcData maps the adc data
FormatString={s.DiscClass{1} s.size 'Adc'};
if prod(s.size)==0
    out{chan}.adc=[];
    return
end
map=memmapfile(filename,...
    'Repeat',1,...
    'Format',FormatString,...
    'Offset',s.DataOffset{1}.DiscOffset);
% Create adcarray if it is one
if strcmp(out{chan}.hdr.adc.TargetClass,'adcarray')
    out{chan}.adc=adcarray(map,...
        out{chan}.hdr.adc.Scale,...
        out{chan}.hdr.adc.DC,...
        out{chan}.hdr.adc.Func,...
        out{chan}.hdr.adc.Units,...
        out{chan}.hdr.adc.Labels,...
        swap);
else
    % Otherwise return as a standard class
    if swap==true
        temp=swapbytes(map.Data.Adc());
    else
        temp=map.Data.Adc();
    end
    % If it is text data, cast to standard char class
    if ~isempty(strfind(out{chan}.hdr.channeltype,'Text'))
        temp=char(temp);
    end
    out{chan}.adc=adcarray(temp,...
        1,...
        0,...
        [],...
        out{chan}.hdr.adc.Units,...
        out{chan}.hdr.adc.Labels,...
        swap);
end
end

%--------------------------------------------------------------------------
function out=GetMarkerData(filename, s, out, chan, swap)
%--------------------------------------------------------------------------
if isempty(s) || prod(s.size)==0
    out{chan}.mrk=[];
    return
end

% scOpen:GetMarkerData maps the marker data
FormatString={s.DiscClass{1} s.size 'mrk'};
map=memmapfile(filename,...
    'Repeat',1,...
    'Format',FormatString,...
    'Offset',s.DataOffset{1}.DiscOffset);
% Return to sigTOOL as a standard MATLAB matrix
out{chan}.mrk=map.Data.mrk;
if swap==true
    out{chan}.mrk=swapbytes(out{chan}.mrk);
end
end

%--------------------------------------------------------------------------
function out=findchanneldetails(in, varname)
%--------------------------------------------------------------------------
% scOpen:findchanneldetails finds the element relating to this variable in
% a structure returned by where
for i=1:length(in)
    if strcmp(in(i).name,varname)==1
        out=in(i);
        return
    end
end
out=[];
return
end

%--------------------------------------------------------------------------
function out=findchannelfield(in, name)
%--------------------------------------------------------------------------
% scOpen:findchannelfield finds the adc, tim or mrk field in an element
% returned by where, if IN is the element relating to a structure
for i=1:length(in.DataOffset)
    if strcmp(in.DataOffset{i}.name, name)==1
        out=in.DataOffset{i};
        return
    end
end
out=[];
return
end
