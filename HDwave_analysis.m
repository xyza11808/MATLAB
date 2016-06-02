
function HDwave_analysis(data,fs,time,filename,chioce)
%HDwave_analysis used for high dimension data which contains multi-trial
%analysis and return the overall results of overall result in the given
%filename make under the active path
%the given data should no more than three dimensions
%origin from XIN Yu

if nargin<5
    chioce=1;
    if nargin<4
        filename=datestr(now,30);
       if nargin<3
           error(message('MATLAB:ode45:NotEnoughInputs'));
       end
    end  
end

%%thedefault path of the file saving under D:\\filename\
filename=strcat('D:\',filename,'\');
mkdir(filename);

if(ndims(data)==3)
    [~,~,TrialNum]=size(data);
else
    wave_analysis(data,fs,time,filename);
    return;
end


if(chioce==1)
    %stands for default choose which will save each data in a line and
    %return the sum plot of the result
    for i=1:TrialNum
        wave_analysis(data(:,:,i),fs,time,filename);
    end
elseif(chioce==2)
end

disp('All data plots are saved in the folder');
disp(filename);

%the chioce option will be added is further requirement are needed
%used for different output options

end

