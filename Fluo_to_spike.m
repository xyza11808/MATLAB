function Fluo_to_spike(FluoChangeData,varargin)
%this function will be used for spike train extraction to be used for
%further analysis

DataSize=size(FluoChangeData);
STrainData=zeros(DataSize);

if nargin>1
    ROIstd=varargin{1};
else
    ROIstd=zeros(1,DataSize(2));
    for n=1:DataSize(2)
        temmp_data=FluoChangeData(:,n,:);
        ROIstd(n)=mad(temmp_data(:))*1.4826;
    end
    clearvars temmp_data
end

if nargin>2
    LeftOinds=varargin{2};
    RightOinds=varargin{3};
else
    
%initial function parameters
V.dt=1/55;

P.a     = 1;    % observation scale
P.b     = 0;    % observation bias
tau     = 1.5;    % decay time constant
P.gam   = 1-V.dt/tau; % C(t) = gam*C(t-1)
P.lam   = 10;  % firing rate = lam*dt firing rate in Hz

% P.sig   = 0.1;  % standard deviation of observation noise, this para will
% be reassigned in later calculations

for n=1:DataSize(2)
    P.sig = ROIstd(n);
    for m = DataSize(1)
        TimeTrace=squeeze(FluoChangeData(m,n,:));
        TimeTrace(TimeTrace<ROIstd(n))=ROIstd(n);  %below threshold values will be assigned to threshold value to denoise
        [NSp,~]=fast_oopsi(TimeTrace,V,P);
        NSp(1:3)=0;
        STrainData(m,n,:)=NSp;
    end
end

%considering setting a threhold to make the spike train result becomes
%binary for more simplyfication
