function out=isreal(varargin)
% ISREAL method overloaded for adcarray objects
%
% The builtin ISREAL returns false for adcarray objects. As this is called
% by some Mathworks supplied functions it can be a nuisance.
% This routine fixes the problem by returning true - adcarrays are always 
% real valued
%
% Author: Malcolm Lidierth 02/07
% Copyright © The Author & King's College London 2007

out=true;




