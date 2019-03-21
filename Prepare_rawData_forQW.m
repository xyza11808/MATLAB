
cclr

[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
%%
fids = fopen(fPath);
tline = fgetl(fids);
k = 1;
ErrorMess = {};
DataSavagePath = 'F:\21Sessions_Data';

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fids);
        continue;
    end
    %
    clearvars cLine PassPathline;
    [StartInds,EndInds] = regexp(tline,'test\d{2,3}');
    
    if EndInds-StartInds > 5
        EndInds = EndInds - 1; % in case of a repeated session sub imaging serial number
    end
    [~,MatfileEnd] = regexp(tline,'result_save');
    cPassDataUpperPath = fullfile(sprintf('%srf%s',tline(1:EndInds),tline((EndInds+1):MatfileEnd)));
    PassPathline = fullfile(cPassDataUpperPath,'plot_save','NO_Correction');
    
    % load task datas
    clearvars behavResults frame_rate start_frame data_aligned
    cd(tline);
    load('CSessionData.mat');
    
    save(fullfile(DataSavagePath,sprintf('Sess%d_data_save.mat',k)),'behavResults', 'data_aligned',...
        'frame_rate', 'start_frame','-v7.3'); 
    
    % load passive datas
    clearvars SelectData SelectSArray frame_rate
    cd(PassPathline);
    load('rfSelectDataSet.mat');
    
    save(fullfile(DataSavagePath,sprintf('Passive_Sess%d_data_save.mat',k)),'SelectData','SelectSArray','frame_rate','-v7.3');
    
    tline = fgetl(fids);
    k = k + 1;
end

