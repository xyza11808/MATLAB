close;
figure;
cPair = 10;
imagesc(OutDataStrc.BinCenters,OutDataStrc.BinCenters,CalResults{cPair,1} - CalResults{cPair,2})
title(sprintf('From %s to %s',CalResults{cPair,3},CalResults{cPair,4}))

%%
cPair = 15;
zus = cat(3,CalResults{cPair,1}{:});
[xx,yy] = meshgrid(OutDataStrc.BinCenters);
zz = mean(zus,3);
SMData = imgaussfilt(zz,'FilterSize',5);
figure('position',[100 200 660 440]);
surf(xx,yy,SMData,SMData,'facealpha',0.8,'FaceColor','interp','LineStyle','none');
hb = colorbar;

xlabel('(From) Time (s)');
ylabel('(To) Time (s)');
zlabel('Canonical Correlation');
view([-15 75])

title(sprintf('From %s to %s',CalResults{cPair,3},CalResults{cPair,4}))

