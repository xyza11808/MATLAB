
nROIs = size(ROC_bootReal_alls,1);
cROI_boot_value = cell(nROIs,1);
for cR = 1 : nROIs
    cRDataROC = ROC_bootReal_alls{cR,1};
    cR_Revert_index = logical(ROC_bootReal_alls{cR,2});
    cRDataROC(cR_Revert_index) = 1 - cRDataROC(cR_Revert_index);
    cROI_boot_value{cR} = cRDataROC;
end

%%
BootMeanAUC = cellfun(@median,cROI_boot_value);

BootCenterMean = cellfun(@(x) mean(x(prctile(x,25) <= x & x <= prctile(x,75))),cROI_boot_value);

ROIReal_AUC = ROCarea;
ROIReal_AUC(logical(ROCRevert)) = 1 - ROIReal_AUC(logical(ROCRevert));
%% boot mean
figure;plot(ROIReal_AUC,BootMeanAUC,'ko')
cx = UniAxesScale(gca);
line(cx,cx,'linestyle','--','Color','r')
xlabel('Real')
ylabel('boot')

%% boot center mean
figure;plot(ROIReal_AUC,BootCenterMean,'ko')
cx = UniAxesScale(gca);
line(cx,cx,'linestyle','--','Color','r')
xlabel('Real')
ylabel('boot center')



