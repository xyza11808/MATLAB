function varargout = ROIResponseFrac(varargin)
% this function is mainly used to load manually selected ROI response type
% storage file and load ROI's response type for further analysis
% ROI response type definition:
%       0: not responsive
%       1: Sound response
%       2: Choice or other behavior parameter response
%       3: mixed response

[fn,fp,fi] = uigetfile({'*.xlsx';'*.xls';'*.*'},'Please Select your ROI response type data file');
if fi
    PathName = {fullfile(fp,fn)};
    Nums = xlsread(fullfile(fp,fn));
    if sum(isnan(Nums(:)))
        fprintf('NaN exists within current file, please check your raw input data file.\n');
        return;
    end
%     [Rows.Cols] = size(Nums);
    if max(Nums(:,2)) > 3 || min(Nums(:,2)) < 0
        fprintf('Response type out of defined range, please check your raw data file.\n');
    end
    if nargout > 0
        varargout(1) = {Nums};
        varargout(2) = {PathName};
    end
end