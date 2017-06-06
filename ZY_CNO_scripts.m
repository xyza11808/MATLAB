%% control Session data
[fn,fp,fi] = uigetfile('Controlsession_sum.mat','Please select your control session data');
if ~fi
    return;
else
    fpath = fullfile(fp,fn);
    Datastrc = load(fpath);
    fieldNall = fieldnames(Datastrc.control_session);
    ContSessionCorr = zeros(length(fieldNall),2); % first column is non-miss trials correct frac., the second column is 
                                              % include miss trials correct
                                              % frac.                                       
    for nn = 1 : length(fieldNall)
        cSessStrc = Datastrc.control_session.(fieldNall{nn});
        cChoice = double(cSessStrc.choice_trials);
        cTrType = double(cSessStrc.Trial_type);
        MissInds = cChoice == 2;
        IMCorrFrac = mean(cChoice == cTrType);
        NMCorrFrac = mean(cChoice(~MissInds) == cTrType(~MissInds));
        ContSessionCorr(nn,:) = [NMCorrFrac,IMCorrFrac];
    end
end

%% saline session data
[fn,fp,fi] = uigetfile('Salinesession_sum.mat','Please select your saline session data');
if ~fi
    return;
else
    fpath = fullfile(fp,fn);
    Datastrc = load(fpath);
    fieldNall = fieldnames(Datastrc.saline_session);
    SalineSessionCorr = zeros(length(fieldNall),2); % first column is non-miss trials correct frac., the second column is 
                                              % include miss trials correct
                                              % frac.                                       
    for nn = 1 : length(fieldNall)
        cSessStrc = Datastrc.saline_session.(fieldNall{nn});
        cChoice = double(cSessStrc.choice_trials);
        cTrType = double(cSessStrc.Trial_type);
        MissInds = cChoice == 2;
        IMCorrFrac = mean(cChoice == cTrType);
        NMCorrFrac = mean(cChoice(~MissInds) == cTrType(~MissInds));
        SalineSessionCorr(nn,:) = [NMCorrFrac,IMCorrFrac];
    end
end

%% CNO session data
[fn,fp,fi] = uigetfile('CNOsession_sum.mat','Please select your CNO session data');
if ~fi
    return;
else
    fpath = fullfile(fp,fn);
    Datastrc = load(fpath);
    fieldNall = fieldnames(Datastrc.cno_session);
    CNOSessionCorr = zeros(length(fieldNall),2); % first column is non-miss trials correct frac., the second column is 
                                              % include miss trials correct
                                              % frac.                                       
    for nn = 1 : length(fieldNall)
        cSessStrc = Datastrc.cno_session.(fieldNall{nn});
        cChoice = double(cSessStrc.choice_trials);
        cTrType = double(cSessStrc.Trial_type);
        MissInds = cChoice == 2;
        IMCorrFrac = mean(cChoice == cTrType);
        NMCorrFrac = mean(cChoice(~MissInds) == cTrType(~MissInds));
        CNOSessionCorr(nn,:) = [NMCorrFrac,IMCorrFrac];
    end
end

%%
save CorrFracSum.mat ContSessionCorr SalineSessionCorr CNOSessionCorr -v7.3
