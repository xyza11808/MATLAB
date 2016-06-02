function pos=getPosition(tp)
% getPosition private function for the Result Manager
% 
% getPosition(tp)
%     positions the Result Manager
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
n=length(fieldnames(tp));
pos=[0.05 0.975-(n*0.05) 0.9 0.025];
return
end
