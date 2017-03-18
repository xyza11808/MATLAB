
m = 1;
[fn,fp,fi] = uigetfile('*.txt','Please select your text file that contains the data file path for multisession data savage');
%%
if ~fi
    return;
else
    Filepath = fullfile(fp,fn);
    ff = fopen(Filepath);
    tline = fgetl(ff);
    while ischar(tline)
        if isempty(strfind(tline,'Session_Sum_plot\MaxRespCompData.mat;'))
            tline = fgetl(ff);
            continue;
        else
            if m == 1
                PPTname = input('Please input the PPT file name:\n','s');
                pptSavePath = uigetdir(pwd,'Please select the data path that will be used for saving pptx file');
            end 
            cSessionPath = strrep(tline,'\MaxRespCompData.mat;','\All_ROI_comparePlot_PassMax\');
            cd(cSessionPath);
            cSessionFolders = dir('Time_scale*_AllFreq_plot');
            nTimeScales = length(cSessionFolders);
            fprintf('Totally %d time scales being found within current session data path.\n',nTimeScales);
            for nfolders = 1 : nTimeScales
                cfolderNames = cSessionFolders(nfolders).name;
                cd(cfolderNames);
                folderFigureExtraction(pwd,'Freq*','.png',PPTname,cfolderNames,pptSavePath);
                cd ..;
            end
            m = m + 1;
        end
        tline = fgetl(ff);
    end
end

%%
if ~fi
    return;
else
    Filepath = fullfile(fp,fn);
    ff = fopen(Filepath);
    tline = fgetl(ff);
    while ischar(tline)
        if isempty(strfind(tline,'binnedCoefDataSave.mat;'))
            tline = fgetl(ff);
            continue;
        else
            if m == 1
                PPTname = input('Please input the PPT file name:\n','s');
                pptSavePath = uigetdir(pwd,'Please select the data path that will be used for saving pptx file');
            end 
            if ~isempty(strfind(tline,'Correlation_distance_coefPlot\binnedCoefDataSave.mat;'))
                folderName = 'Correlation_distance_coefPlot\binnedCoefDataSave.mat;';
            elseif ~isempty(strfind(tline,'CorrCoefDis_Plot\binnedCoefDataSave.mat;'))
                folderName = 'CorrCoefDis_Plot\binnedCoefDataSave.mat;';
            end
                
            cSessionSCPath = strrep(tline,folderName,...
                '\Popu_signalCorr_Plot\');
            cSessionNCPath = strrep(tline,folderName,...
                '\Popu_Corrcoef_save_NOS\TimeScale 0_1500ms noise correlation\');
            cSessSpikeSCPath = strrep(tline,folderName,...
                '\SpikeData\Popu_signalCorr_Plot');
            cSessSpikeNCPath = strrep(tline,folderName,...
                '\SpikeData\Popu_Corrcoef_save_NOS\TimeScale 0_1500ms noise correlation');
            PPTfname = fullfile(pptSavePath,[PPTname,'.pptx']);
            if exist(PPTfname,'file')
                exportToPPTX('open',PPTfname);
                NewFileExport = 0;
            else
                exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Test export of frequency response data');
                 NewFileExport = 1;
            end
            SCFFigPath = fullfile(cSessionSCPath,'Signal_correlation_of_current_session.png');
            SCSFigPath = fullfile(cSessSpikeSCPath,'Signal_correlation_of_current_session.png');
            NCFFigPath = fullfile(cSessionNCPath,'Population Modified zscored Mean corrcoef distribution.png');
            NCSFigPath = fullfile(cSessSpikeNCPath,'Population Modified zscored Mean corrcoef distribution.png');
            
            % export to pptx
            exportToPPTX('addslide');
            h_SCF = imread(SCFFigPath);
            h_SCS = imread(SCSFigPath);
            
            % write signal correlation
            exportToPPTX('addpicture',h_SCF,'Position',[0 2 8 6]);
            exportToPPTX('addtext','SC_Fluo','Position',[3 1 2 1],'FontSize',18);
            exportToPPTX('addpicture',h_SCS,'Position',[8 2 8 6]);
            exportToPPTX('addtext','SC_Spike','Position',[11 1 2 1],'FontSize',18);
            exportToPPTX('addnote',{SCFFigPath;SCSFigPath});
            
            % write noise correlation
            exportToPPTX('addslide');
            h_NCF = imread(NCFFigPath);
            h_NCS = imread(NCSFigPath);
            exportToPPTX('addpicture',h_NCF,'Position',[0 2 8 6]);
            exportToPPTX('addtext','NC_Fluo','Position',[3 1 2 1],'FontSize',18);
            exportToPPTX('addpicture',h_NCS,'Position',[8 2 8 6]);
            exportToPPTX('addtext','NC_Spike','Position',[11 1 2 1],'FontSize',18);
            exportToPPTX('addnote',{NCFFigPath;NCSFigPath});
            
            if NewFileExport
                 saveFname = exportToPPTX('saveandclose',PPTfname);
            else
                saveFname = exportToPPTX('saveandclose');
            end
            fprintf('Current figures saved in file:\n%s\n',saveFname);
            
            m = m + 1;
        end
        tline = fgetl(ff);
    end
end