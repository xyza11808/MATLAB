function [n,SpikeTime,FireRateBin]=spike_sort_im(data,t,bin)
%This function is used to sort soikes from the spike train and then plot
%the spike place on the raw data
%need at least two inputs the raw data and record time, the default spike
%bin is 100 recording points

%%default value of input
if nargin<3
    bin=100;
    if nargin<2
        error(message('MATLAB:ode45:NotEnoughInputs'));
    end
end


%%vector length check
if (length(data)<=2)
    %disp('Not enough length of vector')
    error(message('Not enough length of vector'));
end


%%init of some varience
spike_num=0;
step=t/(length(data)-1);
TimeLine=0:step:t;
figure;
plot(TimeLine,data);
data_backup=data;
%may use the saveas function for auto saving of the plotting figure
%h=figure(1);
% plot(TimeLine,data);
% saveas(h,'filename','format');


%%threshold deletion of the raw
SignalNoise=2*std(data);
data=data-SignalNoise;
UnderThresIndex= data<0;
data(UnderThresIndex)=0;
figure;
%data=data(find(data<0));
%St=step*(length(data)-1);
%TimeLine=0:step:St;
plot(TimeLine,data);


%%test of a peak
SpikeTime=zeros(length(data));
SpikeIndex=zeros(length(data));
m=1;
for i=2:(length(data)-1)
    if (data(i)>data(i-1)&&data(i)>data(i+1))
        spike_num=spike_num+1;
        SpikeTime(m)=i*step;
        SpikeIndex(m)=i;
        m=m+1;
    end
end
SpikeTime=SpikeTime(SpikeTime>0);
SpikeIndex=SpikeIndex(SpikeIndex>0);


%%test of the result
if (spike_num == 0)
    %disp('There is no spike in this vector');
    error(message('There is no spike in this vector'));
else
    n=spike_num;
end

%%plot of the spike position
figure;
plot(TimeLine,data_backup);
hold on;
plot(SpikeTime,data_backup(SpikeIndex)+0.05,'k^','markerfacecolor',[1 0 0]);


%%firing rate plot with bin
if (mod(length(data),bin)==0)
     LengthBin=length(data)/bin;
else
    LengthBin=(length(data)/bin)+1;
    %data=[data,repmat([0],LengthBin*bin-length(data),1)];
    data=[data,zeros(LengthBin*bin-length(data))];
    disp('outlier bin number will be replaced as zero');
%     for i=length(data):LengthBin*bin
%         data(i)=0;
%     end
end

FireRateBin=zeros(LengthBin);

for j=1:LengthBin
    %FireRateBin(j)=0;
    m=bin*(j-1)+1;
  for k=m+1:m+bin-1
        if (data(k)>data(k-1) && data(k)>data(k+1))
             FireRateBin(j)=FireRateBin(j)+1;
        end
  end
  
end

% FireRateBin(1:10)
% length(FireRateBin)
xp=bin:bin:bin*LengthBin;
xp=xp*step;
% length(FireRateBin)
figure;
plot(xp,FireRateBin,'k-o','linewidth',2,'markersize',4);
title('The firing rate of give data');
xlabel('Time');
ylabel('firing rate with bin');

end


