%determines the options for figure export, according to the file suffix (i.e. png, eps)
%
%
function [outputEnding,outputOption] = determineFigExportFormat( outputFormat )
%determine output format for exported figures
outputOption = ['-d' outputFormat];
if outputFormat=='eps'
	outputOption = [ outputOption 'c2'];
end
outputEnding = [ '.' outputFormat];
