function DataStrc = LoadXlsxfileData(fname,sheet,Ftype)

switch Ftype
    case 1
        % load data files in pattern 1
       [~,~,raw] = xlsread(fname,sheet);
       EnvNum = raw{1,1};
       TimeLen = raw{1,end};
       TargetFields = {'Rise (ms)','Amplitude','Decay (ms)','10-90Rise','HalfWidth',...
           'Area','Baseline','Noise','Rise50','10-90Slope'};
       UsedFieldNum = length(TargetFields);
       DataStrc = struct();
       for cfields = 1 : UsedFieldNum
           cfStr = TargetFields{cfields};
           StrInds = find(strcmpi(cfStr,raw(1,2:end-1)));
           if ~isempty(StrInds)
              fieldNames = strrep(cfStr,' ','_');
              fieldNames = strrep(fieldNames,'(ms)','ms');
              fieldNames = strrep(fieldNames,'-','_');
              DataStrc.(['F_',fieldNames]) = cell2mat(raw(2:end,StrInds+1));
           end
       end
       DataStrc.EventNum = EnvNum;
       DataStrc.TimeLen = TimeLen;
    case 2
        % wait for code
        
    otherwise
        return;
end