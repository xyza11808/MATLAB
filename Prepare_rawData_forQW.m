
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
DataSavagePath = 'F:\21SessionData_withraw';
nROIsAll = [];
%%
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
    clearvars behavResults frame_rate start_frame data_aligned nnspike SpikeAligned
    cd(tline);
    load('CSessionData.mat','behavResults', 'data_aligned','frame_rate', 'start_frame','data');
    load('EstimateSPsaveNewMth.mat','SpikeAligned')
%     
    save(fullfile(DataSavagePath,sprintf('Sess%d_data_save.mat',k)),'behavResults', 'data_aligned',...
        'frame_rate', 'start_frame','data','SpikeAligned','-v7.3'); 
    
%     % load passive datas
%     clearvars SelectData SelectSArray frame_rate nnspike
%     cd(PassPathline);
%     load('rfSelectDataSet.mat');
%     load('EstimatedSPDatafilter.mat','nnspike');
%     
%     save(fullfile(DataSavagePath,sprintf('Passive_Sess%d_data_save.mat',k)),'SelectData','SelectSArray','frame_rate','nnspike','-v7.3');
    
    nROIsAll = [nROIsAll,size(data_aligned,2)];
    tline = fgetl(fids);
    k = k + 1;
end

%% Summarize data for boundary shift datas
cclr
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file'); 
if ~fi
    return; 
end 
fPath = fullfile(fp,fn); 
%
fid = fopen(fPath);
tline = fgetl(fid);
SessType = 0;
SessPathAll = {};
m = 1;
while ischar(tline)
    if ~isempty(strfind(tline,'######')) % new section flag
        SessType = SessType + 1;
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        SessPathAll{m,2} = SessType;
        
        [~,EndInds] = regexp(tline,'test\d{2,3}');
        cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');

        [~,InfoDataEndInds] = regexp(tline,'result_save');
        PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
        SessPathAll{m,3} = PassPathline;
        
        m = m + 1;
    end
    tline = fgetl(fid);
end
SessIndexAll = cell2mat(SessPathAll(:,2));

%%  another section for population decoding
Sess7_28_Inds = SessIndexAll == 4;
Sess7_28PathAll = SessPathAll(Sess7_28_Inds,1);
Sess7_28PathAll_Pass = SessPathAll(Sess7_28_Inds,3);

Sess4_16_Part2_Inds = SessIndexAll == 3;
Sess4_16_Part2_PathAll = SessPathAll(Sess4_16_Part2_Inds,1);
Sess4_16_Part2_PathAllPass = SessPathAll(Sess4_16_Part2_Inds,3);

if length(Sess4_16_Part2_PathAll) ~= length(Sess7_28PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end

ErrorMess = {};
DataSavagePath_728 = 'N:\Documents\Mendeley data\Figure_BoundaryShiftData\7_28Sess';
DataSavagePath_416 = 'N:\Documents\Mendeley data\Figure_BoundaryShiftData\4_16Sess';

nROIsAll = [];
%%
for cSess = 1 : length(Sess7_28PathAll)
    
    %
    c728_line = Sess7_28PathAll{cSess};
    c728_Passline = Sess7_28PathAll_Pass{cSess};
    
    % load task datas
    clearvars behavResults frame_rate start_frame data_aligned nnspike SpikeAligned
    cd(c728_line);
    load('CSessionData.mat','behavResults', 'data_aligned','frame_rate', 'start_frame');
    load('EstimateSPsaveNewMth.mat','SpikeAligned')
	load('.\Tunning_fun_plot_New1s\SelectROIIndex.mat');
    
    save(fullfile(DataSavagePath_728,sprintf('Sess%d_data_save.mat',cSess)),'behavResults', 'data_aligned',...
        'frame_rate', 'start_frame','SpikeAligned','ROIIndex','-v7.3'); 
    
    % load passive datas
    clearvars SelectData SelectSArray frame_rate nnspike
    cd(c728_Passline);
    load('rfSelectDataSet.mat');
    load('EstimatedSPDatafilter.mat','nnspike');
    
    save(fullfile(DataSavagePath_728,sprintf('Passive_Sess%d_data_save.mat',cSess)),'SelectData','SelectSArray','frame_rate','nnspike','-v7.3');
   
    %#######################################################################
    % another session
    c416_line = Sess4_16_Part2_PathAll{cSess};
    c416_Passline = Sess4_16_Part2_PathAllPass{cSess};
    
    % load task datas
    clearvars behavResults frame_rate start_frame data_aligned nnspike SpikeAligned
    cd(c416_line);
    load('CSessionData.mat','behavResults', 'data_aligned','frame_rate', 'start_frame');
    load('EstimateSPsaveNewMth.mat','SpikeAligned')
	load('.\Tunning_fun_plot_New1s\SelectROIIndex.mat');
    
    save(fullfile(DataSavagePath_416,sprintf('Sess%d_data_save.mat',cSess)),'behavResults', 'data_aligned',...
        'frame_rate', 'start_frame','SpikeAligned','ROIIndex','-v7.3'); 
    
    % load passive datas
    clearvars SelectData SelectSArray frame_rate nnspike
    cd(c416_Passline);
    load('rfSelectDataSet.mat');
    load('EstimatedSPDatafilter.mat','nnspike');
    
    save(fullfile(DataSavagePath_416,sprintf('Passive_Sess%d_data_save.mat',cSess)),'SelectData','SelectSArray','frame_rate','nnspike','-v7.3');
    
    
    
end
