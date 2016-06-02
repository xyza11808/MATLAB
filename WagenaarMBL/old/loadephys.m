function [dat,tms] = loadephys(fn,frq)
% LOADEPHYS - Load electrophysiology traces
%    dat = LOADEPHYS(fn) loads the electrophysiology file FN and returns
%    the data as DAT as an LxN array, where L is the length of the recording
%    and N is the number of channels recorded.
%    [dat,tms] = LOADEPHYS(fn) returns a vector of time stamps as well.

idx = find(fn == '.');
if isempty(idx)
    ext='';
    fnbase=fn;
else
    idx=idx(end);
    ext=fn(idx+1:end);
    fnbase=fn(1:idx-1);
end

if nargin<2
    frq=5;
    frqwarn=1;
else
    frqwarn=0;
end

switch ext
    case 'abf'
        if ~exist(fn)
            error(sprintf('File "%s" not found\n',fn));
        end
        if frqwarn
                fprintf(1,'Warning: Assuming sampling frequency was 2 kHz.\n');
                fprintf(1,'         If this was not the case, call LOADEPHYS as\n\n');
                fprintf(1,'           ... = loadephys(''%s'',freq);\n\n',fn);
                fprintf(1,'         where FREQ is the sampling frequency in kHz.\n');
        end
        matfn = sprintf('%s_0.mat',fnbase);
        if ~exist(matfn)
            abf2mat(fnbase,300*60*frq*1e3);
        end
        matfn = sprintf('%s_%i.mat',fnbase,0);
        load(matfn);
        dat=data0;
        len=length(data0);
        clear data0
        if nargout>=2
            tms=[1:len]'/(1e3*frq);
        end
        skp1=std(diff(dat(1:2:1e3,1)));
        skp2=std(diff(dat(2:2:1e3,1)));
        skp=std(diff(dat(1:1e3,1)));
        if skp1<skp & skp2<skp
            % This must be interleaved min/max data
            fprintf(1,'Assuming min/max data\n');
            C=size(dat,2);
            for c=1:C
                mn=dat(1:2:end,c);
                mx=dat(2:2:end,c);
                usemx=abs(mx)>abs(mn);
                mn(usemx) = mx(usemx);
                dat(1:2:end,c) = mn;
            end
            dat=dat(1:2:end,:);
            tms=tms(1:2:end);
        end
    case 'daq'
        if nargout>=2
          [dat,tms]=daqread(fn);
        else
          dat = daqread(fn);
        end
    otherwise
        error('loadephys: Unknown file format');
end

