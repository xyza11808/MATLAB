
files = dir('*.abf');
numfiles = length(files);
filenames = cell(numfiles,1);
EPSCAndBADatas = zeros(numfiles,2);
for cf = 1 : numfiles
    filenames{cf} = files(cf).name(1:end-4);
    if contains(files(cf).name,'-70mv')
        EPSCAndBADatas(cf,1) = 1;
    end
    if contains(files(cf).name,'after') &&  contains(files(cf).name,'gap27')
        EPSCAndBADatas(cf,2) = 1; % after
    elseif contains(files(cf).name,'before')
        EPSCAndBADatas(cf,2) = -1; % before
    end
end


%%
% analysis EPSC datas

% before folder
EPBeforeFDInds = EPSCAndBADatas(:,1) == 0 & EPSCAndBADatas(:,2) == -1;
EPBeforeFD = fullfile(pwd,filenames{EPBeforeFDInds});
EPBfcoefinfos = folderCoefExtraction(EPBeforeFD);

% after folder
EPAfterFDInds = EPSCAndBADatas(:,1) == 0 & EPSCAndBADatas(:,2) == 1;
EPAfterFD = fullfile(pwd,filenames{EPAfterFDInds});
EPAfcoefinfos = folderCoefExtraction(EPAfterFD);

%%
FRate = 10000;
hf = figure('position',[200 200 720 350]);
ax1 = subplot(121);
hold on
plot(EPBfcoefinfos.align_rlags/FRate,EPBfcoefinfos.rCoefs,'k','linewidth',1.2);
plot(EPBfcoefinfos.align_rlags/FRate,EPBfcoefinfos.shufr_coefs,...
    'Color',[.4 .4 .4],'linewidth',1,'linestyle','--');
plot(EPAfcoefinfos.align_rlags/FRate,EPAfcoefinfos.rCoefs,'r','linewidth',1.2);
plot(EPAfcoefinfos.align_rlags/FRate,EPAfcoefinfos.shufr_coefs,...
    'Color',[1 .4 .4],'linewidth',1,'linestyle','--');
Maxcoefs = {num2str(EPBfcoefinfos.rPeakInds);num2str(EPAfcoefinfos.rPeakInds)};
yscales = get(gca,'ylim');
text(0.1,yscales(2)*0.9,Maxcoefs{1},'Color','k');
text(0.1,yscales(2)*0.8,Maxcoefs{2},'Color','r');
xlabel('Time(s)');
ylabel('Coef');
title('Minievet coefs');

ax2 = subplot(122);
hold on
plot(EPBfcoefinfos.align_rsiclags/FRate,EPBfcoefinfos.rSICCoefs,'k','linewidth',1.2);
plot(EPBfcoefinfos.align_rsiclags/FRate,EPBfcoefinfos.shufrsic_coefs,...
    'Color',[.4 .4 .4],'linewidth',1,'linestyle','--');
plot(EPAfcoefinfos.align_rsiclags/FRate,EPAfcoefinfos.rSICCoefs,'r','linewidth',1.2);
plot(EPAfcoefinfos.align_rsiclags/FRate,EPAfcoefinfos.shufrsic_coefs,...
    'Color',[1 .4 .4],'linewidth',1,'linestyle','--');
Maxcoefs = {num2str(EPBfcoefinfos.rsicPeakInds);num2str(EPAfcoefinfos.rsicPeakInds)};
yscales = get(gca,'ylim');
text(0.1,yscales(2)*0.9,Maxcoefs{1},'Color','k');
text(0.1,yscales(2)*0.8,Maxcoefs{2},'Color','r');
xlabel('Time(s)');
ylabel('Coef');
title('SIC coefs');





