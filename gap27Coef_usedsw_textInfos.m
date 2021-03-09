filename = dir('*.txt');

TextInfo = {};
k = 1;
txtfids =  fopen(filename(1).name);
tline = fgetl(txtfids);
while ischar(tline)
    if contains(tline,'before') || contains(tline,'after') || contains(tline,'aftre') || ...
         contains(tline,'-70mv')   
        TextInfo{k,1} = tline;
        
        tline = fgetl(txtfids); % get next line
        UsedSweepStr = tline(5:end-1);
        if contains(UsedSweepStr,',')
            Nums = strsplit(UsedSweepStr,',');
            TotalNums = [];
            for cNumstr = 1 : length(Nums)
                cStr = Nums{cNumstr};
                if contains(cStr,'-')
                    cUsedInds = str2num(strrep(cStr,'-',','));
                    TotalNums = [TotalNums,cUsedInds(1):cUsedInds(2)];
                else
                    TotalNums = [TotalNums,str2num(cStr)];
                end
            end
            TextInfo{k,2} = TotalNums;
        else
            UsedSwInds = str2num(strrep(UsedSweepStr,'-',','));
            TextInfo{k,2} = UsedSwInds(1):UsedSwInds(2);
        end
        
        k = k + 1;
        
    end
    tline = fgetl(txtfids); % get next line
end
fclose(txtfids);
    