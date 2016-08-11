close all
clc
%% Input the data
x=[-8 -3.2 -1.28 -0.51 0 0.51 1.28 3.2 8];%Heading direction
y= [0 0 2 4 5 6 7 9 10 ];%Number when subjects chose the right target
n=[10 10 10 10 10 10 10 10 10];%Total trials number for each direction
%% call up a function to fit a culmulative function
%This function return a bias and threshold
[Bias,Threshold]=cum_gaussfit_max1([x',(y./n)',n']);
%% plot the figure
figure % open a new figure
color = 'k'; % set the line color to be black
x1=min(x):0.1:max(x);%range of x for plotting
plot(x1, cum_gaussfit([Bias,Threshold], x1),color,'Linewidth',3) % plot the solid curve
hold on 
scatter(x,y./n, n/mean(n)*200,color,'filled'); % plot those experimental data
box off
hold on
xlabel('Heading Direction(degree)');
ylabel('Proportion of rightward choices');
title(['Bias = ' num2str(Bias) ', Threshold = ' num2str(Threshold)])
