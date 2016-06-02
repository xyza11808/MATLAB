% x=0:.5:5;
% x_left=-1;x_right=5;   %X轴的左限和右限
% y_down=-5;y_up=10;   %Y轴的上限和下限
% figure;
% 
% axis on;
% for a=0.02:0.05:2;
%     y1=a.^x;                 %指数函数
%     y2=log(y1)/log(a);   %与指数函数相对应的对数函数，注意是该指数函数的反函数
%     set(gca,'XLim',[x_left x_right]);
%     set(gca,'YLim',[x_left y_up]);
%     plot(x,y1);    %画指数函数
%     plot(y1,y2);  %画对数函数
%     pause(0.2);
%     %axis([-1 5 0 10]);
% end


clear;
clc;
x_left=-5;x_right=5;   %X轴的左限和右限
y_down=-5;y_up=5;   %Y轴的上限和下限

x=(x_left:0.01:x_right);  %生成X数据组
y0=x;

figure; %生成一个图像
axis on;
title('幂函数变化图','FontName','Tahoma','FontWeight','Bold','FontSize',14);
xlabel('X轴','FontName','Tahoma','FontSize',12);
ylabel('Y轴','FontName','Tahoma','FontSize',12,'Rotation',0);
set(gca,'FontName','Tahoma','FontSize',10);
set(gca,'XLim',[x_left x_right]);
set(gca,'YLim',[x_left y_up]);
axis square;   %使得X轴和Y轴长短显示的一样
hold on;
plot(0,0,'.k');       %原点
plot(x,0,'-k');       %X轴
plot(0,y0,'-k');     %Y轴
%plot(x,1,'-k');       %直线y=1线
%plot(x,y0,'-r');      %直线y=x，用于观察反函数的对称性图像 
pause;

for a=0.25:0.25:3;
    y1=x.^a;      %幂函数
    plot(x,y1);    %画幂函数
    pause(1);
end