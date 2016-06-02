
function [FringRate]=HDspike_sort(data,time,fs,cond)
%HDspike_sort function is used for high dimensional data spike sorting(no more than four dimension)
%Tipically, this function works as HDspike_sort(data,time,fs,cond).the first two dimension data will be used as amplitude and
%timeline,the third dimension will be treated as tiral number or different
%conditions, the fouth will be trated as different trials with a default
%value of [].
%The fs can also stands for different condition
%Specially used for matrixs have more than three demensions
%the cond should given the stimuli used and will be further combind with
%firing rate result, the sequence of cond should be consistent with third
%dimension of data result


%%default value of input
if nargin<4
    cond=[];
    if nargin<3
        error(message('MATLAB:ode45:NotEnoughInputs'));
    end
end

data_size=size(data);

% %%data dimension test
% if(ndims(data)==3)
%     [~,~,TrialsSize]=size(data);
% elseif(ismatrix(data))
%         [n,~,~]=spike_sort(data,time);
%         FringRate=n/time;
%         disp('Only one trial exists, return the single firing rate of this trial');
%         return;
% end

%%high dimension data processing
FringRate=zeros(TrialsSize);
for i=1:data_size
  data_tem=data(i,:);
  [n,~,~]=spike_sort(data_tem,time);
  FringRate(i)=n/time;
end

figure;
plot(fs,FringRate);
title('The firing rate of different conditions');
xlabel('condition');
ylabel('firing rate');

if cond
    FringRate=[cond,FringRate];
end


end