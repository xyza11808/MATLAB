function lickRate = lickrate_plot(lick_time,bins,frameTime)
%this function will be used for lick rate calculation and plot

% bins=100;
% datalength=length(lick_time);  %lick data in s form, but not in ms form
% MaxTime=ceil(max(lick_time));
lickRaterange=1/bins:frameTime/bins:frameTime;
bincounts=histc(lick_time,lickRaterange);
lickRate=bincounts/(frameTime/bins);
% figure;
% plot(lickRaterange,lickRate);