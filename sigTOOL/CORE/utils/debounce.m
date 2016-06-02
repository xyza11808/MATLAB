function trig2=debounce(trig, dur, pt)
% debounce: sigTOOL function called to debounce triggers
%
% Example:
% trig=debounce(trig, duration, pretime)
%     returns triggers that do not fall within (duration-pretime) of the 
%     preceding trigger(s)
%
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
trig2=trig;
n=1;
% Check elements 2:end-1
for k=2:length(trig)-1
    if trig(k+n)<=trig(k)+dur-pt
        trig2(k)=NaN;
        if (k+n)<length(trig)-1
            n=n+1;
        else
            break
        end
    else
        n=1;
    end
end
% Check end entry
if trig(end)<=trig(end-1)+dur-pt
    trig2(end)=NaN;
end
% Return result
trig2=trig2(~isnan(trig2));

% Slower version

% i=1;
% while i<length(trig)
%     k=i;
%     while k<length(trig) && trig(k+1)<=trig(k)+dur-pt
%         trig(k+1)=[];
%     end
%     i=i+1;
% end
% trig2=trig;
% return
% end

