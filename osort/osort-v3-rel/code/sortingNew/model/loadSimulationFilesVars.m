%
%loads a list of variables instead of all variables.
%
%urut/may07
function varargout = loadSimulationFilesVars(simNr,levelNr,varargin)

loadSimulationFiles;

for k = 1:nargout
   varargout{k} = eval(varargin{k});
end