function [NeuAmp_avgs,AstAmp_avgs,varargout] = fieldwiseAmpCalFun(ROIAmpsCell,ROITypes)
% function used for calculate the field wise amplitude datas

ROIAmp_ROIAvgs = cellfun(@mean,ROIAmpsCell);
ROI_celltypes = cellfun(@(x) strcmpi(x,'Neu'),ROITypes);

Neu_Amps = ROIAmp_ROIAvgs(ROI_celltypes);
Neu_Amps(isnan(Neu_Amps)) = [];
Ast_Amps = ROIAmp_ROIAvgs(~ROI_celltypes);
Ast_Amps(isnan(Ast_Amps)) = [];

NeuAmp_avgs = [mean(Neu_Amps),numel(Neu_Amps),std(Neu_Amps)/sqrt(numel(Neu_Amps))];
AstAmp_avgs = [mean(Ast_Amps),numel(Ast_Amps),std(Ast_Amps)/sqrt(numel(Ast_Amps))];
if nargout > 2
    varargout{1} = Neu_Amps;
    varargout{2} = Ast_Amps;
end
    
