% x=0:.5:5;
% x_left=-1;x_right=5;   %X������޺�����
% y_down=-5;y_up=10;   %Y������޺�����
% figure;
% 
% axis on;
% for a=0.02:0.05:2;
%     y1=a.^x;                 %ָ������
%     y2=log(y1)/log(a);   %��ָ���������Ӧ�Ķ���������ע���Ǹ�ָ�������ķ�����
%     set(gca,'XLim',[x_left x_right]);
%     set(gca,'YLim',[x_left y_up]);
%     plot(x,y1);    %��ָ������
%     plot(y1,y2);  %����������
%     pause(0.2);
%     %axis([-1 5 0 10]);
% end


clear;
clc;
x_left=-5;x_right=5;   %X������޺�����
y_down=-5;y_up=5;   %Y������޺�����

x=(x_left:0.01:x_right);  %����X������
y0=x;

figure; %����һ��ͼ��
axis on;
title('�ݺ����仯ͼ','FontName','Tahoma','FontWeight','Bold','FontSize',14);
xlabel('X��','FontName','Tahoma','FontSize',12);
ylabel('Y��','FontName','Tahoma','FontSize',12,'Rotation',0);
set(gca,'FontName','Tahoma','FontSize',10);
set(gca,'XLim',[x_left x_right]);
set(gca,'YLim',[x_left y_up]);
axis square;   %ʹ��X���Y�᳤����ʾ��һ��
hold on;
plot(0,0,'.k');       %ԭ��
plot(x,0,'-k');       %X��
plot(0,y0,'-k');     %Y��
%plot(x,1,'-k');       %ֱ��y=1��
%plot(x,y0,'-r');      %ֱ��y=x�����ڹ۲췴�����ĶԳ���ͼ�� 
pause;

for a=0.25:0.25:3;
    y1=x.^a;      %�ݺ���
    plot(x,y1);    %���ݺ���
    pause(1);
end