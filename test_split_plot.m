z=peaks(100);

% If you want to delete a certain amount of rows/cols
z2=z;
z2(:,10:15)=NaN;
z2(:,50:55)=NaN;
z2(:,75:80)=NaN;

% If you want to separate you data without deleting anything

z3=z;

z3=[z3(:,1:15) nan(size(z3,1),5) z3(:,16:75) nan(size(z3,1),5) z3(:,75:100) ];


% This last bit is only for plotting, so you can try it in your computer 
subplot(131)
title('Original')
surf(z,'edgecolor','interp')
axis off
view(2)
axis equal
subplot(132)
title('Deleted columns')
surf(z2,'edgecolor','interp')
axis off
view(2)
axis equal
subplot(133)
title('Separatedd data')
surf(z3,'edgecolor','interp')
axis off
view(2)

axis equal