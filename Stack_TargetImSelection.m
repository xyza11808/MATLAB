TargetTiffTag = Tiff('AVG_b55a01_test05_3x_200um_2afc_20180819_004.tif');
ImTarget = TargetTiffTag.read();
if strcmpi(class(ImTarget),'uint16')
    NewTargetIm = im2int16(ImTarget);
end
ImStacks = size(imData,3);
StackCorr = zeros(ImStacks,2);
for cStack = 1 : ImStacks
    cStackIm = squeeze(imData(:,:,cStack));
    [r,p] = corrcoef(double(cStackIm(:)),double(NewTargetIm(:)));
    StackCorr(cStack,:) = [r(1,2),p(1,2)];
end
[~,MaxInds] = max(StackCorr(:,1));
MaxStackFrame = squeeze(imData(:,:,MaxInds));
%%
figure('position',[100 100 1050 420]);
subplot(121);
imagesc(NewTargetIm,[-30 200])
colormap gray
title('target')

subplot(122)
imagesc(MaxStackFrame,[-30 200])
colormap gray
title('MaxCorrStack')