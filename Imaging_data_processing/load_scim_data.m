function [im, header] = load_scim_data(filename,varargin)
% function [im, header] = load_scim_data(filename,varargin)
% varargin{1}, frame_range, 1x2 array specifying start and end frame to
% load. If not specified, load all frames
% 
% -NX 2013-5-30
%
% varargin{2}, offset_to_mode_flag. ScanImage4 data has negative value.
% The peak of data distribution is often negative. This option is to offset
% the image baseline to 0.
%
% -NX 2013-11-6


%% Parse image header
if ~exist(filename,'file')
    error('''%s'' is not a recognized flag or filename. Aborting.',filename);
end

info=imfinfo(filename);
numImages = length(info);
headerString = info(1).ImageDescription;

if isempty(varargin) || isempty(varargin{1})
    frame_inds = 1: numImages;
else
    frame_inds = varargin{1}(1): varargin{1}(2);
end

offset_to_mode_flag = 0;
if length(varargin)>1
    if ~isempty(varargin{2})
        % Whether offset the loaded image data to its mode
        offset_to_mode_flag = varargin{2};
    end
end
% whetehr loading the imaging data
IsDataLoad = 1;
if nargin > 3
    if ~isempty(varargin{3})
        IsDataLoad = varargin{3};
    end
end
try
    if strncmp('state',headerString,5) 
        fileVersion = 3;
        header = parseHeader(headerString);
    elseif ~isempty(strfind(headerString,'SI.'))
        fileVersion = 4;
        header = assignments2StructOrObj(headerString);
    elseif isempty(strfind(headerString,'SI.')) && isfield(info(1),'Software')
        fileVersion = 2023;
        header = parseStr2Struct2023({headerString,info(1).Software});
    end
    header.SoftVer = fileVersion;
%     IsScanim = 1;
catch
    header = [];
%     IsScanim = 0;
end

if IsDataLoad
    %Extracts header info required by scim_openTif()
%     if IsScanim
%         hdr = extractHeaderData(header,fileVersion);
% 
%         % %VI120910A: Detect/handle header-only operation (don't read data)
%         % if nargout <=1 % && ~forceOutput 
%         %     return;
%         % end
%         im = zeros(hdr.numLines, hdr.numPixels, length(frame_inds), 'int16');
%     else
        xx = info(1);
        im = zeros(xx.Height, xx.Width, length(frame_inds), 'int16');
%     end
    hTif = Tiff(filename,'r');
    
    for i = 1:length(frame_inds)
        hTif.setDirectory(frame_inds(i));
        im(:,:,i) = hTif.read();
    end

    if offset_to_mode_flag == 1
        % offset to mode, then remove negative values
        im = im - mode(im(:));
        im(im<0) = 0;
    end
else
    im = [];
end
end
%==============================================================================================================
function s = extractHeaderData(header,fileVersion)
    %% Constants/Inits
    maxNumChans = 4;

       
        if fileVersion == 3
            localHdr = header;
            
            s.savedChans = [];
            for i=1:maxNumChans
                if isfield(localHdr.acq,['savingChannel' num2str(i)])
                    if localHdr.acq.(['savingChannel' num2str(i)]) && localHdr.acq.(['acquiringChannel' num2str(i)])
                        s.savedChans = [s.savedChans i];
                    end
                end
            end
            
            s.numPixels = localHdr.acq.pixelsPerLine;
            s.numLines = localHdr.acq.linesPerFrame;
            
            if isfield(localHdr.acq,'slowDimDiscardFlybackLine') && localHdr.acq.slowDimDiscardFlybackLine
                s.numLines = s.numLines - 1;
            end
            
            s.numSlices = localHdr.acq.numberOfZSlices;
            
            if ~localHdr.acq.averaging
                s.numFrames = localHdr.acq.numberOfFrames;
            else
                s.numFrames = 1;
            end
            
            if  ~isfield(localHdr.internal,'lowPixelValue1')
                s.acqLUT = {};
            else
                s.acqLUT = cell(1,maxNumChans);
                for i=1:length(s.acqLUT)
                    s.acqLUT{i} = [localHdr.internal.(['lowPixelValue' num2str(i)]) localHdr.internal.(['highPixelValue' num2str(i)])];
                end
            end            
            
        elseif fileVersion == 4
            localHdr = header.SI4;
            
            s.savedChans = localHdr.channelsSave;
            s.numPixels = localHdr.scanPixelsPerLine;
            s.numLines = localHdr.scanLinesPerFrame;
            
            if isfield(localHdr,'acqNumAveragedFramesSaved')
                saveAverageFactor = localHdr.acqNumAveragedFramesSaved;
            elseif isfield(localHdr,'acqNumAveragedFrames')
                saveAverageFactor = localHdr.acqNumAveragedFrames;
            else
                assert(false);
            end

            s.numFrames = localHdr.acqNumFrames / saveAverageFactor;
            
            s.numSlices = localHdr.stackNumSlices;
            
            s.acqLUT = cell(1,size(localHdr.channelsLUT,1));
            for i=1:length(s.acqLUT)
                s.acqLUT{i} = localHdr.channelsLUT(i,:);
            end                
            
        else 
            assert(false);
        end

    end
%==============================================================================================================
function s = assignments2StructOrObj(str,s)
%ASSIGNMENTS2STRUCTOROBJ Create a struct, or configure a handle object,
%from a string generated by structOrObj2Assignments.
% s = assignments2Struct(str,s)
% 
% str: string generated by structOrObj2Assignments
% s [input]: (optional, scalar handle object). Object to configure.
% s [output]: If a handle object is supplied as s, that object is returned
% in s. If no object is supplied, a structure is created and returned in s.

if nargin < 2
    s = struct();
end

rows = textscan(str,'%s','Delimiter','\n');
rows = rows{1};

if isempty(rows)
    return;
end

for c = 1:numel(rows)
    row = rows{c};
    
    % replace top-level name with 'obj'
    [~, rmn] = strtok(row,'.');
    if isempty(rmn)
        continue;
    end
    row = ['s' rmn];
    
    % deal with nonscalar nested structs/objs
    pat = '([\w]+)__([0123456789]+)\.';
    replc = '$1($2).';
    row = regexprep(row,pat,replc);
    
    % handle unencodeable value or nonscalar struct/obj.
    % Note: structOrObj2Assignments, assignments2StructOrObj, and toString
    % (all in Dabs.Programming.Utilities) are in cahoots with respect
    % to these hardcoded strings.
    unencodeval = '<unencodeable value>';
    if strfind(row,unencodeval)
        row = strrep(row,unencodeval,'[]');
    end
    nonscalarstructobjstr = '<nonscalar struct/object>';
    if strfind(row,nonscalarstructobjstr)
        row = strrep(row,nonscalarstructobjstr,'[]');
    end
    
    % handle ND array format produced by array2Str
    try 
        if ~isempty(strfind(row,'&'))
            equalsIdx = strfind(row,'=');
            [dimArr rmn] = strtok(row(equalsIdx+1:end),'&');
            arr = strtok(rmn,'&');
            arr = reshape(str2num(arr),str2num(dimArr)); %#ok<NASGU,ST2NM>
            eval([row(1:equalsIdx+1) 'arr;']);
        else
            eval([row ';']);
        end
    catch ME %Warn if assignments to no-longer-extant properties are found
        if strcmpi(ME.identifier,'MATLAB:noPublicFieldForClass')
            equalsIdx = strfind(row,'=');
            fprintf(1,'WARNING: Property ''%s'' was specified, but does not exist for class ''%s''\n', deblank(row(3:equalsIdx-1)),class(s));
        else
            ME.rethrow();
        end
    end
end

end

function s = parseStr2Struct2023(InputStrsCell)
% {headerString,info(1).Software}
s = struct();
NumStrs = length(InputStrsCell);
for cStr = 1:NumStrs
    cStrs = InputStrsCell{cStr};
    NumAssignStrs = strsplit(cStrs,newline);
    for cAssigns = 1 : length(NumAssignStrs)
        try 
            eval(['s.',NumAssignStrs{cAssigns},';']);
        catch
            % do nothing
        end
    end
end


end
