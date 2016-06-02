function RecptiveFieldAnalysis(fs)
%%This function is used to calculate the receptive field of given spike
%%train data
%this function need four based inputs:
% filename: given the filename of data needed to be processed, need intacted data path if this file doesn't inside current working dir
% time: given the time length of single trial, in seconds
% fs: given the sampling frequence of spike recording
% stimuli: given the stimuli type corresponding to the session recording
% may need to be adjusted for more calculation

%%initial anaalysis preparation
%firstly check if there are enough input arguments   
if nargin<1
    fs=20000;
end   
% EP_data_path=input('please input the full data path of recording abf file.\n','s');
% if exist(EP_data_path,'file')==0
%     error('error input file name. The input file name not exists.\n');
% end
% [~,endd]=regexp(EP_data_path,'\','split');
% file_path=EP_data_path(1:max(endd));
% filename_save=EP_data_path(max(endd+1):end-4);

disp('Please select the abf file that need to be analysized.\n');
[filename,file_path]=uigetfile('*.abf');
if isequal(filename,0)
   disp('User selected Cancel');
   return;
else
   disp(['User selected ', fullfile(file_path, filename)]);
   cd(file_path);
end
filename_save=filename(1:end-4);
[rawdata,~]=abfload(filename);
rawdata_shift=shiftdim(rawdata,2);  %after shift, the data should be a trial*points form
%the rawdata should be a three dimension data format where the third
%dimension refers the trial index of a session

%the returned FiringRate should be a two dimensional matrix 
%where the first col contains trial index and the second col contains the
%firingrate corresponding to each trial

%########################################################################################
%this part should be modified to satified the 
% fn=input('please input the full name path for sound stimulus.\n','s');
disp('Pleased select the relevent stimulus file.\n');
[fn_sound,path_sound]=uigetfile('*.*');
fn=[path_sound,'\',fn_sound];
soundarray=textread(fn);
exclude_index=input('please input the index number of excluded trials, separeted by '',''.\n');
if ~exclude_index
    soundarray(exclude_index,:)=[];
    rawdata_shift(exclude_index,:)=[];
end
frequency=soundarray(:,1);
intensity=soundarray(:,2);

data_size=size(rawdata_shift);
time=data_size(2)/fs;
%set up a new struct for storing the containts of spike analysis
EP_Result=struct('Spike_raw',[],'Firing_Num',[],'Spike_Time',[],'Ava_Spike_Bin',[],'Spike_Amp',[],'STA',[],'Bin_length',[],'Frequency',[],'Intensity',[]);

triger_time=input('Please input the time(s) before sound stimuli.\n');
if isempty(triger_time)
    triger_time=0.5;
elseif triger_time>10
    triger_time=triger_time/1000;
end

%%
% FiringRate=HDspike_sort(rawdata,time,fs);
% var_names=fieldnames(EP_Result);
if ~isdir('./STA_plot/')
    mkdir('./STA_plot/');
end
cd('./STA_plot/');
for i=1:data_size(1)
    EP_Result(i).Spike_raw=rawdata_shift(i,:);
    EP_Result(i).Frequency = frequency(i);
    EP_Result(i).Intensity = intensity(i);
    [n,SpikeTime,SpikeAmp,FireRateBin,STA,bin,~]=spike_sort(rawdata_shift(i,:),time);
    saveas(gcf,['STA plot of trial',num2str(i),'.png'],'png');
    close;
    EP_Result(i).Firing_Num=n;
    EP_Result(i).Spike_Time=SpikeTime;
    EP_Result(i).Ava_Spike_Bin=FireRateBin;
    EP_Result(i).Spike_Amp=SpikeAmp;
    EP_Result(i).STA=STA;
    EP_Result(i).Bin_length=bin;
end

% inds=regexp(EP_data_path,'\');
upper_path=file_path;
cd(upper_path);
if ~isdir('./total_result/')
    mkdir('./total_result/');
end
cd('./total_result/');

save TotalEPResult.mat EP_Result -v7.3;
cd ..;

%%
%single spike train plot
freq_type=unique(soundarray(:,1));
DB_type=unique(soundarray(:,2));
[~,I]=sortrows(soundarray,[1,2]);
h=figure;
for i=1:data_size(1)
    TimeLine=EP_Result(I(i)).Spike_Time;
%     TimeLine=EP_Result.Spike_Time;
    for j=1:length(TimeLine)
        line([TimeLine(j) TimeLine(j)],[i-1 i]);
        hold on;
    end
end
hh=axis;
triger_position=triger_time;
plot([triger_position,triger_position],[hh(3),hh(4)],'color','g','LineWidth',2);
hold off;
if ~isdir('./Dot_line_plot')
    mkdir('./Dot_line_plot');
end
cd('./Dot_line_plot');

saveas(h,['Dot line plot of ',filename_save,'.png'],'png');
close;
cd ..;

%%
if ~isdir('./color_map_plot')
    mkdir('./color_map_plot');
end
cd('./color_map_plot');
num_spon=zeros(data_size(1));
num_resp=zeros(data_size(1));
for i=1:data_size(1)
    num_spon(i)=sum(EP_Result(i).Spike_Time<triger_time);
    num_resp(i)=sum(EP_Result(i).Spike_Time>triger_time);
end

step=floor(max(freq_type)/(length(freq_type)));
freq_tick=step:step:max(freq_type);
freq_label=freq_type./1000;
mean_response=zeros(length(freq_type),length(DB_type));
mean_spon=zeros(length(freq_type),length(DB_type));
resp_change_rate=zeros(length(freq_type),length(DB_type));
for i=1:length(DB_type)
    for j=1:length(freq_type)
        inds=find(soundarray(:,1)==freq_type(j)&soundarray(:,2)==DB_type(i));
        mean_response(j,i)=mean(num_resp(inds));
        mean_spon(j,i)=mean(num_spon(inds));
        if  mean_spon(j,i)==0
            spon=1;
        else
            spon=mean_spon(j,i);
        end
        resp_change_rate(j,i)=mean_response(j,i)/spon;
    end
end

%raw response plot
clim_min=min(mean_response(:));
clim_max=max(mean_response(:));
h2=figure;
imagesc(freq_type,DB_type,mean_response,[clim_min clim_max]);
colormap(hot);
 xlabel('frequency(KHz)');
    set(gca,'XTick',freq_tick);
    set(gca,'xticklabel',sprintf('%.1f|',freq_label));
    ylabel('Intensity(Volume)');
    set(gca,'YTick',DB_type);
    colorbar;
    set(get(colorbar,'Title'),'string',{'FR'; 'magnification'});
saveas(h2,['Response plot of ',filename_save,'.png'],'png');
close;

%rate change plot
clim_min=min(resp_change_rate(:));
clim_max=max(resp_change_rate(:));
h2=figure;
imagesc(freq_type,DB_type,resp_change_rate,[clim_min clim_max]);
colormap(hot);
 xlabel('frequency(KHz)');
    set(gca,'XTick',freq_tick);
    set(gca,'xticklabel',sprintf('%.1f|',freq_label));
    ylabel('Intensity(DB)');
    set(gca,'YTick',DB_type);
    colorbar;
    set(get(colorbar,'Title'),'string',{'FR change'; 'magnification'});
saveas(h2,['FR rate change plot of ',filename_save,'.png'],'png');
close;
cd ..;
%%
%the following parts only used for stimulus input analysis
% ReceptiveFieldMatrix=[stimuli,FiringRate(:,2)];
% %ReceptiveFieldMatrix should be a matrix which the first col contains the
% %DB value of the stimuli and the second col contains the freqency value of
% %the stimuli, the third col contains the response firing rate corresponding to the given DB and frequency stimuli
% %this matrix can be used to plot the final figure
% SortRFMatrix=sortrows(ReceptiveFieldMatrix,[1,2]);
% %gere we gain a sequencial matrix
% 
% disp('we may need some basic inputs for further calculation.');
% MinDB=input('Please input the min DB value: ');
% MaxDB=input('Please input the Max DB value: ');
% StepDB=input('please input the step of DB gradient: ');
% MinFreq=input('please input the Min freq value (octave): ');
% MaxFreq=input('please input the Max freq valye (octave): ');
% StepFreq=input('please input the step of frequency gradient (octave): ');
% 
% DBcol=MinDB:StepDB:MaxDB;
% Freqrow=MinFreq:StepFreq:MaxFreq;
% 
% if((length(DBcol))*(length(Freqrow))~=(length(SortRFMatrix(:,3))))
%        error(message('error input, the input parameters do not correspond to the trial length.'));
% end
% 
% %next generate the matrix taht to be used in imagesc functions
% ResponseVector=SortRFMatrix(:,3);
% SortRFMatrixPlot=zeros(length(Freqrow),length(DBcol));
% 
% for i=1:length(DBcol)
%     j=(i-1)*Freqrow+1:i*Freqrow;
%     SortRFMatrixPlot(:,i)=ResponseVector(j);
% end
% 
% imagesc(DBcol,Freqrow,SortRFMatrixPlot);
% title('Receptive Field mapping');
% %if more image properties are needed, can add a set function
end