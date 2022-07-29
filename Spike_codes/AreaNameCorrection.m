function AdjAreaStrings = AreaNameCorrection(UsedAreaString, st)
% check whether the given brain region is standard allen area names or not,
% and replace the error ones

KnownErrors = {'Mos', 'Amv', 'Amd'};
ErrCorrects = {'MOs','AMv','AMd'};

TotalAreaNums = length(UsedAreaString);
AdjAreaStrings = UsedAreaString;
for cA = 1:TotalAreaNums
    cA_Str = UsedAreaString{cA};
    Name2treeInds = find(strcmp(st.acronym,cA_Str), 1);
    if isempty(Name2treeInds)
        % check whether the area already in Error list
        Name2errInds = find(strcmpi(KnownErrors,cA_Str));
        if isempty(Name2errInds)
            warning('Unkown area from input: %s',cA_Str);
            Adj_str = '';
        else
            Adj_str = ErrCorrects{Name2errInds};
            fprintf('Adjust AreaName %s to %s...\n',cA_Str,Adj_str);
        end
        AdjAreaStrings{cA} = Adj_str;
    end
end

        
