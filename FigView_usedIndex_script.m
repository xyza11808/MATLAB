
clearvars -except NormSessPathTask
nSess = length(NormSessPathTask);
SessUsedIndex = zeros(nSess,1);
for cSS = 1 : nSess
    %
    tline = NormSessPathTask{cSS};
    SessBehavPath = fullfile(tline,'RandP_data_plots','Behav_fit plot.png');
    cim = imread(SessBehavPath);
    
    hu = figure('KeyPressFcn',@ViewerKeyPFun);
    imshow(cim);
    
    w = waitforbuttonpress;
    if w == 1
    %     disp('Button click')
    % else
    %     disp('Key press')

        hData = guidata(hu);
        if hData.Output
            fprintf('Current session was included.\n');
        else
            fprintf('Current session was excluded.\n');
        end
    end
    SessUsedIndex(cSS) = hData.Output; 
    close(hu);
end

