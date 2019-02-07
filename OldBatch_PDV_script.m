%/Volumes/XIN-Yu-potable-disk/OldBatchData/
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessPathAll = {};
m = 1;
while ischar(tline)
    if ispc
        if ~isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
            SessPathAll{m,1} = tline;

            [~,EndInds] = regexp(tline,'test\d{2,3}');
            cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');

            [~,InfoDataEndInds] = regexp(tline,'result_save');
            PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
            SessPathAll{m,2} = PassPathline;

            m = m + 1;
        end
    elseif ismac
        if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
            MacSessPath = strrep(fullfile('/Volumes/XIN-Yu-potable-disk/OldBatchData/',tline(4:end)),'\','/');
            
            SessPathAll{m,1} = MacSessPath;

            [~,EndInds] = regexp(MacSessPath,'test\d{2,3}');
            cPassDataUpperPath = fullfile(sprintf('%srf',MacSessPath(1:EndInds)),'im_data_reg_cpu','result_save');

            [~,InfoDataEndInds] = regexp(MacSessPath,'result_save');
            PassPathline = fullfile(sprintf('%srf%s',MacSessPath(1:EndInds),MacSessPath(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
            SessPathAll{m,2} = PassPathline;

            m = m + 1;
        end
    end
    tline = fgetl(fid);
end

%%
nSessions = size(SessPathAll,1);
for cSess = 1 : nSessions
    cSessPath = SessPathAll{cSess,1};
    cd(cSessPath);
    clearvars data_aligned behavResults
    load('CSessionData.mat');
    
    RandNMTChoiceDecoding(data_aligned,behavResults,trial_outcome,start_frame,frame_rate,1);
end

