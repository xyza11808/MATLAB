function [temp_data]=ava_data(data,index,win)
%%
%calculate avarage value of given data
[m,n,p]=size(data);
temp_data=zeros(m,n);
if index>p
    error('out of range index');
elseif index==1
    temp_data=(data(:,:,1)+data(:,:,2))/2;
elseif index==p
    temp_data=(data(:,:,p)+data(:,:,p))/2;
elseif index==2
    if win==2
        temp_data=(data(:,:,1)+data(:,:,2))/2;
    else
        for i=1:ceil(win/2)
            temp_data=data(:,:,i)+temp_data;
        end
        temp_data=temp_data/(ceil(win/2));
    end
else
    if (index-ceil(win/2))<0
        for i=1:win
            temp_data=data(:,:,i)+temp_data;
        end
        temp_data=temp_data/win;
    elseif (index+win-floor(win/2))>p
        for i=p-win:p
            temp_data=temp_data+data(:,:,i);
        end
        temp_data=temp_data/win;
    else
        
        for i=(index-floor(win/2)):(index+win-floor(win/2))
            temp_data=temp_data+data(:,:,i);
        end
        temp_data=temp_data/win;
    end
end

