function [zsData,zs_mu,zs_sig] = ForceMultiOutput_zs(x,varargin)
[zsData,zs_mu,zs_sig] = zscore(x,varargin{:});