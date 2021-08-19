v = VideoReader('GCAMP0619_deeper1mm_005.avi');
N=16;
avi_end_frame=16000;
x_min=342;
x_max=503;
y_min=241;
y_max=400;
threshold=100;
eye_size=[];
for ii=1:1000
    if ii*N<=avi_end_frame
        video_frames=read(v,[(ii-1)*N+1 ii*N]);
    else
        video_frames=read(v,[(ii-1)*N+1 avi_end_frame]);
    end
    video_frames=double(squeeze(video_frames(y_min:y_max,x_min:x_max,1,:)));
    for jj=1:N
        video_frame=video_frames(:,:,jj);
        video_frame_logical=video_frame<threshold;
        eye_size=[eye_size;sum(video_frame_logical(:)==1)];
    end
    ii
end
%%
tiff_frame=((1:size(eye_size,1))/size(eye_size,1)*1000)';
figure;plot(tiff_frame,eye_size);
xlabel('tiff frame number');
ylabel('pupil size/[a.u.]');

%%
v = VideoReader('GCAMP0619_deeper1mm_005.avi');
N=16;
avi_end_frame=16000;
x_min=342;
x_max=503;
y_min=241;
y_max=400;
threshold=100;
eye_size=[];
for ii=1:1000
    if ii*N<=avi_end_frame
        video_frames=read(v,[(ii-1)*N+1 ii*N]);
    else
        video_frames=read(v,[(ii-1)*N+1 avi_end_frame]);
    end
    video_frames=double(squeeze(video_frames(y_min:y_max,x_min:x_max,1,:)));
    for jj=1:N
        video_frame=video_frames(:,:,jj);
        video_frame_logical=video_frame<threshold;
        CC = bwconncomp(video_frame_logical);
        video_frame_logical=zeros(size(video_frame_logical));
        video_frame_logical(CC.PixelIdxList{idx})=1;
        BW = imbinarize(video_frame_logical);
        BW = imclearborder(BW);
        BW = bwareafilt(BW,1);
        s = regionprops(BW,{'Centroid','Orientation','MajorAxisLength','MinorAxisLength'});
        eye_size=[eye_size;pi*s.MajorAxisLength*s.MinorAxisLength];
    end
    ii
end