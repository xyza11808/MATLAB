
function BaseFluoCorrection(varargin)
%this function is used for correction the fluorescence change during the
%whole imaging session, using the mean value for each frame as the raw
%signal to do the correction
%with the largest input option as: BaseFluoCorrection(winNumber,)

if nargin>=1
    winNumber=varargin{1};
else
    winNumber=200;
end

[~,RawID]=BaseFluoshift;
%in default, we use the raw signal to do the correction
Adchoice=input('According to the fluorescence change trace across this session,\ndo you still want to do the baseline correction?\n','s');
if strcmpi(Adchoice,'n')
    disp('Skip baseline fluorescence change correction.\n');
    close all;
    return;
else
    disp('Performing baseline correction using SWT method.\n');
end

RawSigSize=length(RawID);
%resample the raw data for swt analysis
RSrawdata=resample(RawID,64000,RawSigSize);
RSRawSigSize=length(RSrawdata);
%preforming SWT analysis to extract the baseline from peak signal
%using level 9
[swa,swd]=swt(RSrawdata,9,'db1');
mzeros=zeros(size(swa));
A=mzeros;
A(9,:)=iswt(swa,mzeros,'db1');

D=mzeros;
for n=1:9
    swcfs=mzeros;
    swcfs(n,:)=swd(n,:);
    D(n,:)=iswt(mzeros,swcfs,'db1');
end

for n=1:8
    A(9-n,:)=A(10-n,:)+D(10-n,:);
end
A1=A(1,:);

%using window to fit the baseline level that will be further used for
%correction
win=RSRawSigSize/winNumber;
% winlength=length(A1)/win;
dataselect=zeros(1,winNumber);
for n=1:winNumber
    datasection=A1(((n-1)*win+1):n*win);
    dataselect(n)=min(datasection);
end
datapoint=(win/2):win:length(A1);
h1=figure;
plot(A1,'color','c');
hold on;
plot(datapoint,dataselect,'*','color','r');
hold off;
saveas(h1,'Baseline signal and selected points','png');

h2=figure;
plot(datapoint,dataselect,'*','color','r');
hold on;
[p,s,mu]=polyfit(datapoint,dataselect,20);
f_y=polyval(p,(1:length(A1)),[],mu);
plot(f_y,'color','g');
hold off;
saveas(h2,'Fitted baseline for correction','png');

ffy=resample(f_y,RawSigSize,64000);
if ~isdir('./baseline_correction_result/')
    mkdir('./baseline_correction_result/');
end

files=dir('*.tif');

for n=1:length(files)
    filename=files(n).name;
    disp(['loading file' filename '...\n']);
    [imdata,imheader]=load_scim_data(filename);
    datasize=size(imdata);
    newimdata=zeros(datasize);
    for m=1:datasize(3)
        newimdata(:,:,m)=imdata(:,:,m)-ffy(((n-1)*datasize(3)+m));
    end
    file_name=filename(1:end-4);
    filenamenew=[file_name(1:end-3) 'postCT' file_name(end-3:end) '.tif'];
    imTagStruct = get_tiff_tag_to_struct(filename);
    savepath=fullfile(pwd,'baseline_correction_result',filenamenew);
    disp(['baseline correction trial result save to ' savepath '\n']);
    write_data_to_tiff(savepath, int16(newimdata), imTagStruct);
end
disp('All trial correction complete!\n');
BaseFluoshift;