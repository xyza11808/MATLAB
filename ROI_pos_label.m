function ROI_pos_label(h_position,nROI,handle)

figure(handle)
center_position=floor(mean(h_position));
text(center_position(1),center_position(2),num2str(nROI),'color','c','HorizontalAlignment','center');
line(h_position(:,1),h_position(:,2),'LineWidth',1.5,'color','r');
hold on
