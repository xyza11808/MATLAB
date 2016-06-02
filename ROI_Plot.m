function ROI_Plot(varargin)
%this function will be used for plot ROI position at the real image captured by two photon imaging
%by XIN Yu, june, 24th, 2015

if nargin>0
    image_data=varargin{1}; %this is a three dimensional data which is the raw output from load_scim_data function
end
if nargin==0 || isempty(image_data)
    disp('Please select your imaging data from the two photon imaging result.\n');
    [filename,filepath,~]=uigetfile('*.tif','Select you two photon data file');
    cd(filepath);
    [image_data,~]=load_scim_data(filename);
end

if nargin>1
    ROIinfo=varargin{2};
end
if nargin<2 || isempty(ROIinfo)
    disp('please select your ROI analysis result data, the mat file contains ROI position infomation.\n');
    [filename,filepath,~]=uigetfile('*.mat','Select your ROI analysis result');
    cd(filepath);
    load(filename);
end
if nargin>2
    ROISChoice=varargin{3};
else
    ROISChoice=0;
end

if nargin<3 || ~ROISChoice
    disp('Only plot all ROI position at the raw image data.\n');
else
    disp('Only plot ROIs show response to left or right stimulus.\n');
    LeftRespOInds=varargin{4};
    RightRespOInds=varargin{5};
end

if ~isempty(ROIinfo)
    ROI_position=ROIinfo(1).ROIpos;
else
    ROI_position=ROIinfoBU.ROIpos;
end
if ROISChoice
%     [Dfilename,Dfilepath,~]=uigetfile('*.mat','Select response inds data');
%     if ~Dfilename
%         disp('user selection canceled, quit this function.\n');
%         return;
%     end
%     fullname=fullfile(Dfilepath,Dfilename);
%     load(fullname);
%     LeftRespInds=find(LeftRespOInds);
%     RightRespInds=find(RightRespOInds);
    LeftROIPosition=ROI_position(LeftRespOInds);
    RightROIPosition=ROI_position(RightRespOInds);
    LeftROIIndex = find(LeftRespOInds);
    RightROIIndex = find(RightRespOInds);
end
% h=figure;
im=mean(image_data(:,:,:),3);
clims=[];
clims(1)=max([0,min(im(:))]);
clims(2)=min([max(im(:)),600]);
h=imshow(im,clims,'Border','tight');
hold on;
if ~ROISChoice
    for n=1:length(ROI_position)
        single_roi_position=ROI_position{n};
        center_pos=mean(single_roi_position);
        line(single_roi_position(:,1),single_roi_position(:,2),'color','r','Linewidth',0.2);
        text(center_pos(1),center_pos(2),num2str(n),'color','g','FontSize',8,'HorizontalAlignment','center');
    end
    hold off;
    start_path=pwd;
    save_path=uigetdir(start_path,'Please select the image save path');
    cd(save_path);
    saveas(h,'ROI position plot.png');
    close;
else
    im=mean(image_data(:,:,:),3);
    h=imshow(im,clims,'Border','tight');
    hold on;
    %plot left responsive ROI inds
    for n=1:length(LeftROIPosition)
        single_roi_position=LeftROIPosition{n};
        center_pos=mean(single_roi_position);
        line(single_roi_position(:,1),single_roi_position(:,2),'color','r','Linewidth',0.5);
        text(center_pos(1),center_pos(2),num2str(LeftROIIndex(n)),'color','c','FontSize',8,'HorizontalAlignment','center');
    end
    %plot right responsive ROI inds
    for n=1:length(RightROIPosition)
        single_roi_position=RightROIPosition{n};
        center_pos=mean(single_roi_position);
        line(single_roi_position(:,1),single_roi_position(:,2),'color','g','Linewidth',0.5);
        text(center_pos(1),center_pos(2),num2str(RightROIIndex(n)),'color','c','FontSize',8,'HorizontalAlignment','center');
    end
    hold off;
    title({'ROI respose to 2afc stimulus';'Left responsive(red) right responsive(green)'});
    save_path=uigetdir(pwd,'Please select the image save path');
    cd(save_path);
    saveas(h,'ROI position plot.png');
    close;
end