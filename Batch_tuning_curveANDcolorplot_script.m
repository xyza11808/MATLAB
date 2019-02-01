% batched ROI morph plot
clearvars -except NormSessPathPass NormSessPathTask 
%
nSessPath = length(NormSessPathTask);
CusMap = blue2red_2(32,0.8);
ErrorSessNum = [];
ErrorMes = {};
k_sess = 0;
%%
for cSess = 1 : nSessPath
    %
%     if exist(fullfile(NormSessPathTask{cSess},'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'file')
%         continue;
%     end
    Passtline = NormSessPathPass{cSess};
    Tasktline = NormSessPathTask{cSess};
    IsErrorMes = SessTunANDColorPlotFun(Tasktline,Passtline);
    if ~isempty(IsErrorMes)
        ErrorSessNum = [ErrorSessNum,cSess];
        ErrorMes = {ErrorMes(:),ME};
    end
    %
end