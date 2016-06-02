function [varargout]=BaseFluoshift
disp('please select the behavior session that need to do the baseline adjustment.\n');
filepath=uigetdir(pwd,'Selection two-photon session data path');
cd(filepath);
files=dir('*.tif');
for n=1:length(files)
    FileName=files(n).name;
    disp(['loading file ' FileName '...']);
    [imdata,~]=load_scim_data(FileName);  %imata is a three dimensional data with nrows*ncols*nframes
    uimdata=uint16(imdata);
    if n==1
        AvgFrameValue=zeros(1,(length(files)*size(uimdata,3)));
        SingleTrialFrames=size(uimdata,3);
        RawImdata=zeros(1,(length(files)*size(uimdata,3)));
    end
    imdata1=squeeze(mean(uimdata));
    imdata2=squeeze(mean(imdata1));
    AvgFrameValue((SingleTrialFrames*(n-1)+1):(SingleTrialFrames*n))=imdata2;
    
    Rimdata1=squeeze(mean(imdata));
    Rimdata2=squeeze(mean(Rimdata1));
    RawImdata((SingleTrialFrames*(n-1)+1):(SingleTrialFrames*n))=Rimdata2;
end
figure;
plot(AvgFrameValue);
title('Avg fluo value within a session');
h2=figure;
plot(RawImdata);
title('Raw imdata plot');
save TestSessionAVG.mat AvgFrameValue RawImdata -v7.3
saveas(h2,'Raw signal across session','png');
if nargout==1
    varargout{1}={{AvgFrameValue},{RawImdata}};
elseif nargout==2
    varargout{1}=AvgFrameValue;
    varargout{2}=RawImdata;
end

    