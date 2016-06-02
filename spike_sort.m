
function [n,SpikeTime,SpikeAmp,FireRateBin,STA,bin,data_backup]=spike_sort(data,t,bin)
%%spike sorting
%the same function as spike_sort_im,but wih no image plot

%%default value of input
if nargin<3
    bin=0.02*length(data)/t;
    if nargin<2
        error(message('MATLAB:NotEnoughInputs'));
    end
end


%%vector length check
if (length(data)<=2)
    %disp('Not enough length of vector')
    error('Not enough length of vector');
end

%#################################
%default output value
data_norm=data-min(data);
n=0;
SpikeTime=[];
SpikeAmp=[];
FireRateBin=[];
STA=[];
data_backup=data;

%%init of some varience
spike_num=0;
m=1;
step=t/(length(data));
%TimeLine=0:step:t;
data_backup=data;
% figure;
% plot(TimeLine,data);

%%
%threshold deletion of the raw
% SignalNoise=2*std(data);
% data=data-SignalNoise;
% UnderThresIndex= data<0;
% data(UnderThresIndex)=0;
% % figure;
% % %data=data(find(data<0));
% % %St=step*(length(data)-1);
% % %TimeLine=0:step:St;
% % plot(TimeLine,data);

% %%test of a peak
% Spike=zeros(length(data));
% %SpikeTime=[];
% SpikeAmp=zeros(length(data));
% m=1;
% for i=2:(length(data)-1)
%     if (data(i)>data(i-1)&&data(i)>data(i+1))
%         spike_num=spike_num+1;
%         SpikeAmp(m)=data_backup(i);
%         Spike(m)=i;
%         %SpikeTime(m)=i*step;
%         m=m+1;
%     end
% end
% SpikeAmp=SpikeAmp(SpikeAmp>0);
% Spike=Spike(Spike>0);
% SpikeTime=Spike*step;
%%
%second way of spike number detection, use the half maxium response as
%threshold to delete data size
SignalNoise=3*std(data);
thres=0.5*max(data);
if thres<SignalNoise
    disp('No significant spike shape exists, return to caller function.\n');
    return;
end
inds=find(data>thres);
if inds(1)==1
    inds=inds(2:end);
end
if inds(end)==length(data);
    inds=inds(1:end-1);
end

SpikeAmp=zeros(1,length(inds));
Spike=zeros(1,length(inds));
for i=1:length(inds)
    j=inds(i);
    if (data_norm(j)>data_norm(j-1)&&data_norm(j)>data_norm(j+1))
        spike_num=spike_num+1;
        SpikeAmp(i)=data_norm(j);
        Spike(i)=j;
        %SpikeTime(m)=i*step;
        m=m+1;
    end
end
SpikeAmp=SpikeAmp(SpikeAmp~=0);
Spike=Spike(Spike~=0);
SpikeAmp=SpikeAmp(SpikeAmp>0);
Spike=Spike(Spike>0);
SpikeTime=Spike*step;
%%
%test of the result
if (spike_num == 0)
    disp('There is no spike in this vector');
    n=0;
%     error('There is no spike in this vector');
else
    n=spike_num;
end

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

FireRateBin=zeros(1,LengthBin);

for j=1:LengthBin
    bin_low_lim=bin*(j-1)+1;
    bin_high_lim=bin*j;
    FireRateBin(j)=sum(Spike>bin_low_lim & Spike<bin_high_lim);
    %FireRateBin(j)=0;
%     m=bin*(j-1)+1;
%   for k=m+1:m+bin-1
%         if (data(k)>data(k-1) && data(k)>data(k+1))
%              FireRateBin(j)=FireRateBin(j)+1;
%         end
%   end
%   
end

% spike_num
% SpikeTimeNorm=SpikeTime/step
% length(SpikeTime)

% 
%%plot of spike triggered avrage
AllStimus=zeros(bin,n);
data_bin=zeros(1,bin);
% length(data_back(Spike(i)-bin:Spike(i)))
for i=1:n
    if (Spike(i)-bin/2+1)<1
        outer_lim=bin/2-Spike(i);
        data_bin(1:outer_lim)=SignalNoise;
        data_bin(outer_lim+1:bin)=data_backup(1:Spike(i)+bin/2);
    elseif Spike(i)+bin/2>length(data_backup)
        outer_lim=bin/2+Spike(i)-length(data_backup);
        data_bin(1:bin-outer_lim)=data_backup(Spike(i)-bin/2+1:end);
        data_bin(bin-outer_lim+1:bin)=SignalNoise;
    else
        data_bin=data_backup(Spike(i)-bin/2+1:Spike(i)+bin/2);
    end
        
    AllStimus(:,i)=data_bin;
end
%the first calculate method of STA---algorithm get online
%AllStimus(:,i)=data_back(Spike(i)+1:Spike(i));
AvgStimus=mean(AllStimus,2);
meansig=mean(data_backup);
STA=(AvgStimus-meansig) ./meansig;
% %STA=flipud((AvgStimus-meansig) ./meansig);
% normSTA=(STA-mean(STA))./mean(STA);

% %second method of STA calculate---self understanding
% % STA=mean(AllStimus,2);
% normSTA=(STA-mean(STA))./mean(STA);
% 
% %plot of the sta result
% time_inds=-bin/2:bin/2-1;
% time=time_inds*step;
% h=figure;
% % time=-1*(bin-1)*step:step:0;
% [hAx,~,~]=plotyy(time,STA,time,normSTA);
% title('STA plot');
% xlabel('time(s)');
% ylabel(hAx(1),'STA'); % left y-axis
% ylabel(hAx(2),'normalized STA'); % right y-axis
% pause(1);
% close;
% plot(time,STA,'Color','blue');
% hold on;
% plot(time,normSTA,'Color','red');
% hold off;

% % FireRateBin(1:10)
% % length(FireRateBin)
% xp=bin:bin:bin*LengthBin;
% xp=xp*step;
% % length(FireRateBin)
% figure;
% plot(xp,FireRateBin,'k-o','linewidth',2,'markersize',4);
% title('The firing rate of give data');
% xlabel('Time');
% ylabel('firing rate with bin');

end


