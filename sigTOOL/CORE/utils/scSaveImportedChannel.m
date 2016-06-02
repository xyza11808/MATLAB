function scSaveImportedChannel(matfilename, chan, data, header, Mode)
% scSaveImportedChannel saves a channel to a sigTOOL kcl file
%
% scSaveImportedChannel is called by various file import functions to save
% data to a mat file using the kcl naming convention for variables
%
% Some standard fields are added to the header by this function:
% header.embeddeddata=true;% flag for embedded(true)/external(false) data
% header.mapstructure.file='';% Name of the file
% header.mapstructure.datatype=[]; % Data type on disc
% header.mapstructure.dimensions=[]; % Array dimensions
% header.mapstructure.offset=[]; % Offset in file
%
% Example:
% scSaveImportedChannel(matfilename, chan, data, header, mode)
%
% scSaveImportedChannel does not return any values
%
%
% Author: Malcolm Lidierth 10/06
% Copyright © King’s College London 2006
% Toolboxes required: None
%
% Acknowledgements:
% Revisions: 25.07.07   Mixed mode added
%            25.07.08   mappedfile/dataisembedded fields added to header
%            26.07.07   mapfunc field added
%            21.06.09   add classifier field to header

% Order fields in data alphabetically
data=orderfields(data);
% Save data
if nargin<5 || Mode==0
    % Mode 0
    if ~isfield(data, 'mrk') ||isempty(data.mrk) || isnumeric(data.mrk)
        % Simple Mode 0
        vname=['chan' num2str(chan)];
        eval(sprintf('%s=data;',vname));
        try
            save(matfilename,vname,'-v6','-append');
        catch
            save(matfilename,vname,'-v6');
        end
    else
        % Mixed mode data.mrk - is a structure, cell array, object etc.
        % Save it as a separate variable
        vname=['mrk' num2str(chan)];
        eval(sprintf('%s=data.mrk;',vname));
        try
            save(matfilename,vname,'-v6','-append');
        catch
            save(matfilename,vname,'-v6');
        end
        % Now save the remaining fields
        data=rmfield(data, 'mrk'); %#ok<NASGU>
        vname=['chan' num2str(chan)];
        eval(sprintf('%s=data;',vname));
        try
            save(matfilename,vname,'-v6','-append');
        catch
            save(matfilename,vname,'-v6');
        end
    end
elseif Mode==1
    % Mode 1: Fields that have already been written to disc should be left
    % empty
    if ~isempty(data.mrk)
        vname=['mrk' num2str(chan)];
        eval(sprintf('%s=data.mrk;',vname));
        try
            save(matfilename,vname,'-v6','-append');
        catch
            save(matfilename,vname,'-v6');
        end
    end
    if ~isempty(data.tim)
        vname=['tim' num2str(chan)];
        eval(sprintf('%s=data.tim;',vname));
        save(matfilename,vname,'-v6','-append');
    end
    if ~isempty(data.adc)
        vname=['adc' num2str(chan)];
        eval(sprintf('%s=data.adc;',vname));
        save(matfilename,vname,'-v6','-append');
    end
end

%--------------------------------------------------------------------------
% These fields support mapping of data in external files. They are not
% currently used or supported.
% If embeddeddata==true, data are embedded in the file currently being
% written.
% If embeddeddata==false, data are in the file named in mapstructure which
% also provides the variable name, data type, dimensions and offset of the
% data array. If varname is specified, the remaining entries may be
% determined on-the-fly by extracting them from the file.
% The data type is a scalar corresponding to the index into the cell array
% of types defined by the MATLAB MAT-file spec - see StandardMiCodes in the 
% MAT-file utilities:
% codes={'int8' 'uint8' 'int16' 'uint16' 'int32' 'uint32' 'single'...
%     'unknown' 'double' 'unknown' 'unknown' 'int64' 'uint64'...
%     'matrix' 'compressed' 'UTF8' 'UTF16' 'UTF32'};

% Notes:
% Indexing above is ZERO-based.
% 'unknown', 'matrix' and 'compressed' are not valid in this context.
% UTF formats are unicode. 
% This feature may change in subsequent releases. 
% Data saved outside of MATLAB may need to be reshaped to comply with
% MATLAB/Fortran columnwise matrix organization
header.embeddeddata=true;% flag for embedded(true)/external(false) data
header.mapstructure.file='';% Name of the file
header.mapstructure.varname='';% Name of the variable in the file
header.mapstructure.datatype=[]; % Data type on disc
header.mapstructure.dimensions=[]; % Array dimensions
header.mapstructure.offset=[]; % Offset in file
%--------------------------------------------------------------------------


% Version 0.9 onwards - add classifier field if absent
if ~isfield(header,'classifier')
    % This fields allows stimuli on another channel to be classified
    header.classifier.By=[];% This channel is classified by the specified channels
    header.clasifier.For=[];% This channel is the classifier for the specified channel
end

% Version 0.93 onwards - add channel group info if not supplied
if ~isfield(header, 'Group')
    header.Group.Number=1;
    header.Group.Label='';
    header.Group.SourceChannel=0;
    header.Group.DateNum=datestr(now());
end

    
% Sort header field order
header=orderfields(header);
if isfield(header,'adc') && ~isempty(header.adc)
    header.adc=orderfields(header.adc);
end
if isfield(header,'tim') && ~isempty(header.tim)
    header.tim=orderfields(header.tim);
end
            
% Save the header
vname=['head' num2str(chan)];
eval(sprintf('%s=header;',vname));
save(matfilename,vname,'-v6','-append');

return
end