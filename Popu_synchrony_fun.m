function SyncValue = Popu_synchrony_fun(ROidatas,varargin)
MethodType = 1;
if nargin == 1
    MethodType = 1; % using default type for synchrony calculation
else
    if ~isempty(varargin{1})
        MethodType = varargin{1};
    end
end

switch MethodType
    case 1 % using calculation method from wiki
        % http://www.scholarpedia.org/article/Neuronal_synchrony_measures
        AvgTrace = mean(ROidatas);
        ROIAvgStd = std(AvgTrace);

        ROISingle_Std = std(ROidatas,[],2);

        SyncValue = sqrt(ROIAvgStd^2/(sum(ROISingle_Std.^2)/numel(ROISingle_Std)));
        
    case 2 % using calculation method from another paper
        % https://www.cell.com/trends/ecology-evolution/comments/S0169-5347(99)01677-8
        % Spatial population dynamics: analyzing patterns and processes of population synchrony
        %%
        % CoVarience Matrix
        CoefMtx = corrcoef(ROidatas');
%         ROISingle_Std = std(ROidatas,[],2);
        
%         [Rows, ~] = size(ROidatas);
%         FullSelf_stdMtx = repmat(ROISingle_Std,1,Rows);
%         VarPairedproduct = FullSelf_stdMtx .* FullSelf_stdMtx';
        
        CoVar_pdistform = AntiSquareform(CoefMtx);
%         PairedProduct_pdistform = AntiSquareform(VarPairedproduct);
%         SyncValue = sum(CoVar_pdistform ./ PairedProduct_pdistform) * 2/ (Rows * (Rows - 1));
        SyncValue = mean(CoVar_pdistform);
%         %%
%         AllrauValues = zeros(Rows*(Rows-1)/2, 1);
%         k = 1;
%         for ci = 1 : Rows
%             for cj = ci : Rows
%                 AllrauValues(k) = CoefMtx(cj, ci) / (ROISingle_Std(ci) * ROISingle_Std(cj));
%                 k = k + 1;
%             end
%         end
        
        %%
    otherwise
        error('unknow method type.');
end
