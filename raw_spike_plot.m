function raw_spike_plot(varargin)
%this function is used to plot the raw spike train position
%this can be used for pips response plot

if nargin==0
    fs=20000;
    disp('No sampling rate input, using default value as 20000Hz.\n');
else
    fs=varargin{1};
    if isempty(fs)
        fs=20000;
        disp('No sampling rate input, using default value as 20000Hz.\n');
    end
end

isTrialType=0;
if nargin>1
    if varargin{2}
        disp('Spike rater plot according to different trial types.\n');
        isTrialType=1;
    else
        disp('Plot all spike times.\n');
        isTrialType=0;
    end
end
    
disp('Please select the abf file that need to be analysized.\n');
[filename,file_path]=uigetfile('*.abf');
if isequal(filename,0)
   disp('User selected Cancel\n');
   return;
else
   disp(['User selected ', fullfile(file_path, filename) ', loading ...\n']);
   cd(file_path);
end
filename_save_base=filename(1:end-4);
[rawdata,~]=abfload(filename);
rawdata_shift=shiftdim(rawdata,2);  %after shift, the data should be a trial by tinme trace form
trace_time=size(rawdata_shift,2)/fs;
EP_Result=struct('Spike_raw',[],'Spike_Num',[],'Spike_Time',[],'Ava_Spike_Bin',[],'Spike_Aclcmp',[],'STA',[],'Bin_length',[]);

triger_time=input('Please input the triger time for each trial, default vaoue is 1(s).\n','s');
triger_time=str2num(triger_time);
if isempty(triger_time)
    triger_time=1;
end

% SpikeTimeAll=cell(size(rawdata_shift,1),1);
% start_pos=0;

parfor n=1:size(rawdata_shift,1) %#ok<PFUIX>
    EP_Result(n).Spike_raw=rawdata_shift(n,:);
    [spikecount,SpikeTime,SpikeAmp,FireRateBin,STA,bin,~]=spike_sort(rawdata_shift(n,:),trace_time,100);
    EP_Result(n).Spike_Num=spikecount;
    EP_Result(n).Spike_Time=SpikeTime;
    EP_Result(n).Ava_Spike_Bin=FireRateBin;
    EP_Result(n).Spike_Amp=SpikeAmp;
    EP_Result(n).STA=STA;
    EP_Result(n).Bin_length=bin;
%     for m=1:spikecount
%         line([SpikeTime(m) SpikeTime(m)],[start_pos+0.25 start_pos+0.75],'color',[.8 .8 .8]);
%     end
%     start_pos=start_pos+1;
end

h_dot_plot=figure('color','w');
hold on;
if ~isTrialType
    for n=1:size(rawdata_shift,1)
        SpikeTime = EP_Result(n).Spike_Time;
        SpikeCount = EP_Result(n).Spike_Num;
        for m=1:SpikeCount
            line([SpikeTime(m) SpikeTime(m)],[n-0.8 n-0.2],'color',[.8 .8 .8]);
        end
    end
    line([triger_time triger_time],[0 n],'color','y','linewidth',2);
else
    fprintf('Select your trial type definement file.\n');
    [filename,filepath,index]=uigetfile('*.txt','Select your trial type definition text file');
    if ~index
        return;
    end
    Trials=textread(fullfile(filepath,filename),'%d');
    TrialType=unique(Trials);
    TrialTypeNum=length(TrialType);
    
    for k=1:TrialTypeNum
        SelectTrialInds=Trials==TrialType(k);
        TrialNumber=sum(SelectTrialInds);
        EPStruct=EP_Result(SelectTrialInds);
        subplot(1,TrialTypeNum,k);
        for n=1:TrialNumber
            SpikeTime = EPStruct(n).Spike_Time;
            SpikeCount = EPStruct(n).Spike_Num;
            for m=1:SpikeCount
                line([SpikeTime(m) SpikeTime(m)],[n-0.8 n-0.2],'color',[.8 .8 .8]);
            end
        end
        line([triger_time triger_time],[0 n],'color','y','linewidth',2);
        title(sprintf('TrialType %d',TrialType(k)));
    end
end

% line([triger_time triger_time],[0 start_pos],'color','y','linewidth',2);
hold off;

if ~isdir('./EP_plot/')
    mkdir('./EP_plot/');
end
cd('./EP_plot/');
saveas(h_dot_plot,[filename_save_base '_dot_plot'],'png');
close;

save EP_summary.mat EP_Result -v7.3
cd ..;

%##########################################################################
%signal power analysis
if ~isdir('./EP_plot/')
    mkdir('./EP_plot/');
end
cd('./EP_plot/');

for n=1:size(rawdata_shift,1)
    wave_analysis(rawdata_shift(n,:),fs,trace_time,[filename_save_base '_trial_trace_num' num2str(n)]);
end

cd ..;