%
%  function abf2load
%    this was created for loading abf 2.0 files from axoscope 10
%    it uses a windows exe file called Abf2Tmp which creates two output
%    files.  First the data file .txt and second the metadata file -md.txt.
%    Written by Ryan Thompson. bigryan@users.sourceforge.net

function [data, metadata] = abf2load(fn)
% ** function [data, metadata]=abf2load(fn)
%   this will load abf 2.0 files
%   in order for it to work you must have Abf2Tmp.exe and the dll in your
%   active directory.

    cmd = sprintf('Abf2Tmp %s',fn);
    system(cmd);
    tmpfname = sprintf('%s.txt',fn);
    data = load(tmpfname,'v1');

    metaDataFName = sprintf('%s-md.txt',fn);
    tabchar = sprintf('\t');
    fid = fopen (metaDataFName,'r');
    metadata = struct();  %start as an empty struct
    while 1
        %cycle through all the lines in the file and add all data to the
        %metadata struct
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        valOffset = findstr(tline, tabchar);
        
        mdName = tline(1:valOffset-1);
        c = mdName(1);
        valOffset=[valOffset, size(tline,2)];
        for i=1:size(valOffset,2)-1
            mdVal = tline(valOffset(i)+1:valOffset(i+1));
            if (strcmp(c,'f') || strcmp(c,'n') || strcmp(c,'l') || strcmp(c,'u') || strcmp(c,'b') )
                val = str2num(mdVal);
            else
                val = {mdVal};
            end
            if (i > 1)
                metadata.(mdName) = [metadata.(mdName),val];
            else
                metadata.(mdName) = val;
            end
        end
    end
    
    fclose(fid);
    %clean up
    cmd = sprintf('del %s', tmpfname);  %command to delete the temp data file
    system(cmd);
    cmd = sprintf('del %s', metaDataFName); % command to delete the metadata file
    system(cmd);

