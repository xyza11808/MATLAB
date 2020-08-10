function [bootstat, Stats] = bootstrpDiffTest(DataGr1, DataGr2, BootRepeat, pCalType)
% test the group difference using boot strap method
% Ref: https://doi.org/10.1038/s41593-020-0598-6

% In practice, the BootRepeat should be larger than 5000 for the p value to
% be consistant between different calculation methods

% 'StaticP' method is ref from: 
% https://stats.stackexchange.com/questions/136661/using-bootstrap-under-h0-to-perform-a-test-for-the-difference-of-two-means-repl

% pCalType: string could either be 'CICalp' or 'StaticP'
% for small size data, the 'CICalp' may not suitable for calculation (less
% than 60), so we will use 'StaticP' even 'CICalp' is given
if isempty(pCalType)
    pCalType = 'CICalp';
end
    
if numel(DataGr1) < 60 || numel(DataGr2) < 60
    pCalType = 'StaticP';
end

switch pCalType
    case 'CICalp'
        
        if numel(DataGr1) == numel(DataGr2)
            bootstat = bootstrp(BootRepeat, @(x, y) mean(x) - mean(y), DataGr1, DataGr2);
        else
            bootstat_1 = bootstrp(BootRepeat, @mean, DataGr1);  %, DataGr2
            bootstat_2 = bootstrp(BootRepeat, @mean, DataGr2);  %, DataGr2
            bootstat = bootstat_2 - bootstat_1;
        end
        
        CI = prctile(bootstat, [2.5, 97.5]);
        p = pAndEst2CI(CI, mean(bootstat), 'pcal');

        Stats = {CI, p};
    case 'StaticP' 
        Data1_number = numel(DataGr1);
        Data2_number = numel(DataGr2);
        OverAllMean = (mean(DataGr1) * Data1_number + mean(DataGr2) * Data2_number) / ...
            (Data1_number + Data2_number);
        
        DataGr1_t = DataGr1 - mean(DataGr1) + OverAllMean;
        DataGr2_t = DataGr2 - mean(DataGr2) + OverAllMean;
        
        BootStatic = zeros(BootRepeat, 1);
        bootstat = zeros(BootRepeat, 1);
        for cBoot = 1 : BootRepeat
            cBoot_Data1_Inds = randsample(Data1_number,Data1_number,true);
            cBoot_Data2_Inds = randsample(Data2_number,Data2_number,true);
            cBoot_Data1 = DataGr1_t(cBoot_Data1_Inds);
            cBoot_Data2 = DataGr2_t(cBoot_Data2_Inds);
            
            [~,~,~,stats] = ttest2(cBoot_Data1, cBoot_Data2);
            
            BootStatic(cBoot) = stats.tstat;
            bootstat(cBoot) = mean(DataGr1(cBoot_Data1_Inds)) - mean(DataGr2(cBoot_Data2_Inds));
        end
        
        [~,~,~,statsRaw] = ttest2(DataGr1, DataGr2);
        
        p_h0 = (1 + sum(abs(BootStatic) > abs(statsRaw.tstat)))/(BootRepeat + 1); % add 1 to avoid a zero p value
        
        CI = prctile(bootstat, [2.5 97.5]);
        
        Stats = {CI, p_h0};
            
    otherwise
        error('Unknowed p value calculation method.');
end


        
        
