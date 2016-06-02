function P=wvOnesided(P)
% wvOnesided returns one-sided PSD given two-sided input
%
% Example:
% P=wvOnesided(P);
% where P is a cell array of two-sided PSDs

for idx1=1:size(P,1)
    for idx2=1:size(P,2)
        if ~isempty(P{idx1,idx2})
            % Only need the first half of P (channels must be real valued)
            % x2 except DC and Nyquist
            if rem(length(P{idx1,idx2}.tdata),2)
                % nfft odd
                last=(length(P{idx1,idx2}.tdata)+1)/2;
                odd=0;
            else
                % nfft even
                last=length(P{idx1,idx2}.tdata)/2+1;
                odd=1;
            end
            P{idx1, idx2}.rdata(:,2:last-odd)=2*P{idx1, idx2}.rdata(:,2:last-odd);
            P{idx1, idx2}.rdata(:,last+1:end)=[];
            P{idx1,idx2}.tdata=P{idx1,idx2}.tdata(1:last);

        end
    end
end
return
end
