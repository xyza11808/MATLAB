win=50;
winlength=length(A1)/win;
dataselect=zeros(1,winlength);
for n=1:winlength
    datasection=A1(((n-1)*win+1):n*win);
    dataselect(n)=min(datasection);
end
datapoint=(win/2):win:length(A1);
figure;
plot(A1,'color','c');
hold on;
plot(datapoint,dataselect,'*','color','r');
hold off;

figure;
plot(datapoint,dataselect,'*','color','r');
hold on;
[p,s,mu]=polyfit(datapoint,dataselect,20);
f_y=polyval(p,(1:length(A1)),[],mu);
plot(f_y,'color','g');
hold off;
