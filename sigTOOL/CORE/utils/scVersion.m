function [ver dated]=scVersion(varargin)
% scVersion returns/displays the version number of sigTOOL
% 
% VER=scVersion
%       returns and displays the version while
% VER=scVersion('nodisplay')
%       suppresses the display
%
% Author: malcolm Lidierth 08/06
% © King’s College London 2006-
%



title='sigTOOL';
ver=0.95;
dated='20-Feb-2011';
if nargin==0 || strcmpi(varargin{1},'nodisplay')~=1
st=sprintf('Author:Malcolm Lidierth\nmalcolm.lidierth@kcl.ac.uk\n Copyright %c King%cs College London 2002-\n Version:%3.2f %s',169,39,ver,dated);
(msgbox( st,title,'modal'));
end;
