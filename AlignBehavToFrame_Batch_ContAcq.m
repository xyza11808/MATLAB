% scripts calling for 'AlignBehavToFrame_script_ContAcq.m'
% used for multisession computation
clear
clc
[fn,fp,fi] = uigetfile('*.txt','PLease select your session data path');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
ffid = fopen(fPath);
tline = fgetl(ffid);
nError = 0;
ErrorSessPath = {};
%%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ffid);
        continue;
    end
    %%
    cd(tline);
    IsExcludeInds = 0;
    [~,EndInds] = regexp(tline,'result_save');
    SessSavePath = tline(1:EndInds);
    % loading behavior data
    BehavDataPath = dir(fullfile(SessSavePath,'*strc.mat'));
    load(fullfile(SessSavePath,BehavDataPath.name));
    % loading imaging data
    ImageDataPath = dir(fullfile(SessSavePath,'CaTrials*dftReg_.mat'));
    load(fullfile(SessSavePath,ImageDataPath.name));
    if exist(fullfile(SessSavePath,'cSessionExcludeInds.mat'),'file')
        load(fullfile(SessSavePath,'cSessionExcludeInds.mat'));
        IsExcludeInds = 1;
    end
    
    if exist(fullfile(tline,'EstimateSPsaveNew.mat'),'file')
        load(fullfile(tline,'EstimateSPsaveNew.mat'),'nnspike');
    elseif exist(fullfile(tline,'EstimateSPsave.mat'),'file')
        load(fullfile(tline,'EstimateSPsave.mat'),'nnspike');
    else
        nError = nError + 1;
        ErrorSessPath{nError} = tline;
        tline = fgetl(ffid);
%         continue;
    end
    
    if iscell(SavedCaTrials.f_raw)
        AlignBehavToFrame_script_ContAcq;
    else
        AlignBehavToFrame_script_new;
    end
    %%
    tline = fgetl(ffid);
end
     
        