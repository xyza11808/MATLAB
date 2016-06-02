function [data_smooth]=filter_design(data,win)
%%
%%default value of input
if nargin<2
    win=5;
    if nargin<1
        error(message('MATLAB:ode45:NotEnoughInputs'));
    end
end

[m,n,p]=size(data);
data_smooth=zeros(m,n,p);

% if ~isdouble(data)
    data=double(data);
% end

if win==1
    error('error filter window!');
else
    data_smooth(:,:,1)=data(:,:,1);
    data_smooth(:,:,2)=ava_data(data,2,win);
    for i=3:p
      data_smooth(:,:,i)=ava_data(data,i,win);
    end
end
