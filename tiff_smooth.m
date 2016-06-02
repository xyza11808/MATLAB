function tiff_smooth
tic;
%%
% filepath=input('please input the file path need to be somoothed.\n','s');
%file='xy_ai5_20141030_soma1_tones_016.tif';
[filenames,filepath,~]=uigetfile('*.tif','Select your files that need to be smoothed','MultiSelect','on');
cd(filepath);

files=dir('*.tif');
filesavepath_gif='.\result_gif\';
if (isdir(filesavepath_gif))~=1
    mkdir(filesavepath_gif);
end

filesavepath_avi='.\result_avi\';
if (isdir(filesavepath_avi))~=1
    mkdir(filesavepath_avi);
end

filesavepath_tiff='.\result_tiff\';
if (isdir(filesavepath_tiff))~=1
    mkdir(filesavepath_tiff);
end

savenamePre='Combined_smooth';
%%
for j=1:length(filenames);
    filename=filenames{j};
    trialNum=str2num(filename(end-6:end-4));
    StimOnTime=behavResults.Time_stimOnset(trialNum);
    RewardTime=behavResults.Time_reward(trialNum);
    StimOnFrame=floor((double(StimOnTime)/1000)*55);
    RewardFrame=floor((double(RewardTime)/1000)*55);
    SideStr={'Low Freq Sound','High Freq Sound'};
    TrialSide=behavResults.Trial_Type(trialNum);
    
    InfoImage=imfinfo(filename);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    Number_Images=length(InfoImage);
    
    if j==1
        mov(1:Number_Images*length(filenames)) = struct('cdata', [],...
            'colormap', []);
    end
    
    % %first way of tiff files read
    % finalImage=zeros(mImage,nImage,Number_Images,'uint16');
    % for i=1:Number_Images
    %     finalImage(:,:,i)=imread(filename,'Index',i);
    % end
    % %finalImageSmooth=zeros(mImage,nImage,Number_Images,'double');
    % finalImage=im2double(finalImage);
    %
    % finalImageSmooth=filter_design(finalImage);
    % % for i=1:mImage
    % %     for k=1:nImage
    % %         finalImageSmooth(i,k,:)=smooth(finalImage(i,k,:),5);
    % %     end
    % % end
    % finalImageSmooth=im2uint16(finalImageSmooth);
    % %filename_smooth=[file(1:end-4),'_smooth','tif'];
    % %filename_smooth='smoothed_file.gif';
    
    
    %second way of tiff files read
    [finalImage2,~]=load_scim_data(filename);
    finalImage=double(finalImage2);
    finalImageSmooth=filter_design(finalImage);
    finalImageSmooth=int16(finalImageSmooth);
    
    
    
    % filename_smooth=[filename(1:end-4),'_smoothed'];
    % %imshow(finalImageSmooth(:,:,1),[0,1000])
    
    % %%
    % %generate new tiff file after smoothed
    % cd(filesavepath_tiff);
    % time=now;
    % time_str=datestr(time,30);
    %
    % % raw_t=Tiff(filename,'r');
    % % tagstruct.ImageLength = getTag('ImageLength');
    % % tagstruct.ImageWidth = getTag('ImageWidth');
    % % tagstruct.Photometric = getTag('Photometric');
    % % tagstruct.ImageDescription=getTag('ImageDescription');
    % % tagstruct.SampleFormat = 1;
    % % tagstruct.Compression = Tiff.Compression.None;
    % % tagstruct.BitsPerSample = 16;
    % % tagstruct.SamplesPerPixel = 1;
    % % tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    % % tagstruct.Software = 'MATLAB';
    % % %
    % % raw_t.close();
    %
    % % filename_smooth_tiff=[filename_smooth,'.tif'];
    % filename_smooth_tiff=filename;
    % %firstly set up a tiff file tag
    %
    % % % tagstruct=InfoImage(1);
    %
    % disp('writing into tiff file...\n');
    % t=Tiff(filename_smooth_tiff,'w');
    % setTag(t,'ImageLength',mImage)
    % setTag(t,'ImageWidth',nImage)
    % setTag(t,'Photometric',1)
    % setTag(t,'BitsPerSample',16)
    % setTag(t,'SampleFormat',1)
    % setTag(t,'SamplesPerPixel',1)
    % setTag(t,'ImageDescription',InfoImage(1).ImageDescription)  %must be added, used for ROI processing
    % % setTag(t,'TileWidth',128)
    % % setTag(t,'TileLength',128)
    % setTag(t,'RowsPerStrip',16) %must declare, or the imageJ can not recognize the exported tiff file
    % setTag(t,'Compression',1)
    % % t.setTag(tagstruct)
    % setTag(t,'Copyright','modified from XY')
    % setTag(t,'DateTime',time_str)
    % setTag(t,'PlanarConfiguration',Tiff.PlanarConfiguration.Chunky)
    % setTag(t,'Software','MATLAB')
    %
    % %t.setTaf(tagstrcut);
    % t.write(finalImageSmooth(:,:,1));
    % t.close;
    % %t.write(finalImageSmooth);
    % for i=2:Number_Images
    %         %imwrite(finalImageSmooth(:,:,i),filename_smooth_tiff);
    %         t=Tiff(filename_smooth_tiff,'a');
    %         setTag(t,'ImageLength',mImage)
    %         setTag(t,'ImageWidth',nImage)
    %         setTag(t,'Photometric',1)
    %         setTag(t,'BitsPerSample',16)
    %         setTag(t,'SampleFormat',1)
    %         setTag(t,'SamplesPerPixel',1)
    %         %         setTag(t,'TileWidth',128)
    %         %         setTag(t,'TileLength',128)
    %         setTag(t,'RowsPerStrip',16)
    %         setTag(t,'Compression',1)
    %         % t.setTag(tagstruct)
    %         setTag(t,'Copyright','modified from XY')
    %         setTag(t,'ImageDescription',InfoImage(i).ImageDescription)  %must be added, used for ROI processing
    %         setTag(t,'DateTime',time_str)
    %         setTag(t,'PlanarConfiguration',Tiff.PlanarConfiguration.Chunky)
    %         setTag(t,'Software','MATLAB')
    %         imshow(finalImageSmooth(:,:,i),[0,500],'Border','tight');
    %         t.write(finalImageSmooth(:,:,i));
    %         t.close();
    %         %imwrite(finalImageSmooth(:,:,i),filename_smooth_tiff,'WriteMode','append');
    %         %disp(['write num ',num2str(i),' images into tiff file.\n']);
    %         %pause(0.02);
    %
    % end
    % disp('tiff file generated successfully!\n');
    % %t.close();
    % close();
    % cd(filepath);
    %
    %gif file generation
    % filename_smooth_gif=[filename_smooth, '.gif'];
    % cd(filesavepath_gif);
    % disp('writing images into GIF files...\n');
    % for i=1:Number_Images
    %     imshow(finalImageSmooth(:,:,i),[0,500],'Border','tight');
    %     frame=getframe(gcf);
    %     im=frame2im(frame);
    %     [I,map]=rgb2ind(im,mImage);
    %     if i==1
    %         imwrite(I,map,filename_smooth_gif,'Loopcount',1,'DelayTime',0.017);
    %     else
    %         imwrite(I,map,filename_smooth_gif,'WriteMode','append','DelayTime',0.017);
    %     end
    % end
    % disp(['Image', files(j).name,' smoothed done.\n']);
    % disp('GIF file exported successfully!\n');
    % close;
    % cd(filepath);
    % %%
    %
    % filename_smooth_avi=[filename_smooth, '.avi'];
    % cd(filesavepath_avi);
    % %finalImageSmooth=im2double(finalImageSmooth);
    % aviobj=VideoWriter(filename_smooth_avi);
    % aviobj.Quality=80;
    % %aviobj.CompressionRatio=1;
    % aviobj.FrameRate=60;
    % open(aviobj);
    %
    % for i=1:Number_Images
    %     imshow(finalImageSmooth(:,:,i),[0,1000],'Border','tight');
    %     frame=getframe;
    %     writeVideo(aviobj,frame);
    % end
    % close(aviobj);
    % %imwrite(finalImageSmooth,filename_smooth);
    % disp(['Image', files(j).name,' smoothed done.\n']);
    % disp('Avi file exported successfully!\n');
    % close;
    % cd(filepath);
    
    %
    %another way of avi file generation
%     filename_smooth_avi2=[savenamePre, '_02','.avi'];
    % cd(filesavepath_avi);
%     disp('writing files into AVI files...\n');
    %%
    for i=135:225
        imshow(finalImageSmooth(:,:,i),[0,400],'Border','tight');
        if i>=StimOnFrame && i<(StimOnFrame+15)
            patch([5 25 25 5],[30 30 10 10],'r');
%             text(5,15,SideStr{TrialSide+1},'color','red','FontSize',10);
        end
        if i>=RewardFrame && i<(RewardFrame+10)
            patch([220 240 240 220],[30 30 10 10],'g')
%             text(180,15,'Reward On','color','g','FontSize',10);
        end
        mov(i+(j-1)*Number_Images)=getframe(gcf);
    end
%     movie2avi(mov,filename_smooth_avi2,'compression','none','fps',55);
%     disp('GVI files exported successfully!\n');
    close;
%     cd(filepath);
    
end

%%
filename_smooth_avi2=[savenamePre, '_022','.avi'];
cd(filesavepath_avi);
disp('writing files into AVI files...\n');
movie2avi(mov,filename_smooth_avi2,'compression','none','fps',55);
disp('GVI files exported successfully!\n');

%%
close;

totaltime=toc;
%disp('All done.');
disp(['All ', num2str(length(files)), ' files smoothed done in ', num2str(totaltime),' seconds\n']);

