function [time, date, comment]=CFSGetGenInfo(fid)
% CFSGetGenInfo - gateway to cfs32.dll GetGenIfo function
%
% The CFS filing system is copyright Cambridge Electronic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------

time='012345678';
date='012345678';
comment=char(ones(1, 72));
[time, date, comment]=calllib('CFS32','GetGenInfo',...
    fid, time, date, comment);
return
end