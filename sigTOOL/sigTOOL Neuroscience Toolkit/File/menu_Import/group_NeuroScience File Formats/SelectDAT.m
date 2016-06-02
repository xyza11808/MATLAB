function matfilename=ImportDAT(filename, targetpath)

endian='ieee-le';
fh=fopen(filename, 'r', endian);
fseek(fh, 0, 'bof');
signature=deblank(fread(fh, 8, 'uint8=>char')');

switch signature
    case {'DATA' 'DAT1' 'DAT2'}
        % HEKA DAT file
        matfilename=ImportHEKA(filename, targetpath);
    otherwise
        % CONSAM DAT file
        matfilename=ImportSSD(filename, targetpath);
end
        
