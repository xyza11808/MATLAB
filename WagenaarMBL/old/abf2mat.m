function abf2mat( filename, step )
% abf2mat( filename, step )
%
% converts Axon binary format file to a sequence of MAT-files,
% each of which contains STEP samples from the .abf file [default 1e7]
%
% requires import_abf()
% only works correctly for gap-free recordings
%
% JAB 6/26/07

if nargin < 2, step = 1e7; end

% figure out input and output filenames
if ~strcmp( filename(end-3:end), '.abf' )
    infile = [filename '.abf'];
    outfile_stub = filename;
else
    infile = filename;
    outfile_stub = filename(1:end-4);
end

offset = 0;
% read first section, don't catch errors
fprintf( 1, 'reading section %d', offset )
data = import_abf( infile, offset*step, step );
try
    while 1
        % save current section of data in a MAT-file
        fprintf( 1, '; writing section %d\n', offset )
        outfile = [outfile_stub '_' num2str( offset ) '.mat'];
        eval( sprintf( 'data%d = data;', offset ) )
        eval( sprintf( 'save( outfile, ''data%d'' )', offset ) )
        eval( sprintf( 'clear data%d', offset ) )
        offset = offset + 1;

        % read next section
        fprintf( 1, 'reading section %d', offset )
        warning off % suppress warnings about file size!
        data = import_abf( infile, offset*step, step );
        warning backtrace
    end
catch
    fprintf( 1, '...failed -- done\n' )
end
