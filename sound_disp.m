function sound_disp(varargin)
%three types of sound will be player according to user input

if nargin==0
    disp_type=input('Please select the type of sound that will be displayed.\n1 for pure tone.\2 for SAM tone.\3 for white noise.\n4 for pure tone added with white noise.\n5 for band_limited noise.');
    disp_type=str2num(disp_type);
    inputs_cell=inputdlg({'Signal Frequency:','Modu frequency:','Stim duration:'},'Please input the following parameters.');
    disp_freq=str2num(inputs_cell{1});
    modu_freq=str2num(inputs_cell{2});
    stim_dur=str2num(inputs_cell{3});   %the unit of this value is ms
else
    disp_type=varargin{1};
    disp_freq=varargin{2};
    modu_freq=varargin{3};
    stim_dur=varargin{4};
end

real_time=double(stim_dur)/1000;
real_time_step=real_time/(10*disp_freq);
sample_rate=10*disp_freq;
time_point=0:real_time_step:real_time;
if disp_type==1
    disp('playing pure tone...\n');
    Amp_value=sin(2*pi*disp_freq*time_point);
    sound(Amp_value);
    pause(real_time);
    clear sound;
    disp('End of pure tone display.\n');
elseif disp_type==2
    disp('playing SAM tone...\n');
    Amp_value=sin(2*pi*modu_freq*time_point);
    real_value=Amp_value.*sin(2*pi*disp_freq*time_point);
    sound(real_value);
    clear sound;
    disp('End of SAM tone.\n');
elseif disp_type==3
    Amp_value=wgn(1,length(time_point),0);
    sound(Amp_value);
    pause(real_time);
    clear sound;
    disp('End of white noise display.\n');
elseif disp_type==4
    disp('playing pure tone with white noise added.\n');
    noise_sound(disp_freq,20,stim_dur);
elseif disp_type==5
    disp('Playing band limited noise.\nPlease input the frequency band range.\n');
    band_range=inputdlg({'Low frequency limit','High frequency limit'},'Please input the frequency band range');
    fd=band_range{1};
    fu=band_range{2};
    [B,A]=fir1(44,[fd fu]/(sample_rate/2));
    limited_noise=filter(B,A,rand(length(time_point),1));
    sound(limited_noise);
    pause(real_time);
    clear sound;
    h=figure;
    subplot(2,1,1);
    plot(rand(length(time_point),1));
    title('white noise');
    subplot(2,1,2);
    plot(limited_noise);
    title('Band limited noise');
    disp('Band limited sound finish playing.\n');
else
    error('Error input type, end of sound display.\n');
end