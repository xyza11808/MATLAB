% Example pipeline for processing histology
cclr
%% 1) Load CCF and set paths for slide and slice images

% Load CCF atlas
% allen_atlas_path = 'E:\MatCode\AllentemplateData';
allen_atlas_path = 'E:\AllenCCF';
tv = readNPY([allen_atlas_path filesep 'template_volume_10um.npy']);
av = readNPY([allen_atlas_path filesep 'annotation_volume_10um_by_index.npy']);
st = loadStructureTree([allen_atlas_path filesep 'structure_tree_safe_2017.csv']);

% Set paths for histology images and directory to save slice/alignment
im_path = 'E:\datas\anatomy\b106a04_RGBfiles';
slice_path = [im_path filesep 'slices'];

%% 2) Preprocess slide images to produce slice images

% Set white balance and resize slide images, extract slice images
% (Note: this resizes the images purely for file size reasons - the CCF can
% be aligned to histology no matter what the scaling. If pixel size is
% available in metadata then automatically scales to CCF resolution,
% otherwise user can specify the resize factor as a second argument)

% Set resize factor
% resize_factor = []; % (slides ome.tiff: auto-resize ~CCF size 10um/px)
ImageSizeInfo = 5559.24/2138; % um/px for the real image
resize_factor = ImageSizeInfo/10; % um/px is the allen reference size
% resize_factor = 1; % (slides tiff: resize factor)

% Set slide or slice images
% slice_images = false; % (images are slides - extract individual slices)
slice_images = true; % (images are already individual slices)

% Preprocess images
AP_process_histology(im_path,resize_factor,slice_images);
% (optional) Rotate, center, pad, flip slice images
AP_rotate_histology(slice_path);

%% 3) Align CCF to slices

% Find CCF slices corresponding to each histology slice
AP_grab_histology_ccf(tv,av,st,slice_path);
%%
% Align CCF slices and histology slices
% (first: automatically, by outline)
AP_auto_align_histology_ccf(slice_path);
% (second: curate manually)
AP_manual_align_histology_ccf(tv,av,st,slice_path);

%% 4) Utilize aligned CCF

% Display aligned CCF over histology slices
AP_view_aligned_histology(st,slice_path);

% Display histology within 3D CCF
AP_view_aligned_histology_volume(tv,av,st,slice_path,2);
%%
% Get probe trajectory from histology, convert to CCF coordinates
% input probe channel file location, and extract each channel's area
% loation
% probechnfile = 'E:\MatCode\MATLAB\sortingcode\Kilosort3\configFiles\neuropixPhase3B2_kilosortChanMap.mat';
% probechnfile = 'E:\codes\matcodes\MATLAB\sortingcode\Kilosort3\configFiles\neuropixPhase3B2_kilosortChanMap.mat';
probechnfile = 'E:\codes\matcodes\ks2_5\configFiles\neuropixPhase3B2_kilosortChanMap.mat';
AP_get_probe_histology(tv,av,st,slice_path,probechnfile);
%%
ksFolderPath = 'G:\b106a05\cat_data\b106a05_2afc_test01_20211016_g0_cat\catgt_b106a05_2afc_test01_20211016_g0\Cat_b106a05_2afc_test01_20211016_g0_imec0\ks2_5';
ksRawfileFolder = 'G:\b106a05\cat_data\b106a05_2afc_test01_20211016_g0_cat\catgt_b106a05_2afc_test01_20211016_g0\Cat_b106a05_2afc_test01_20211016_g0_imec0';
LFPfilePathStrc = dir(fullfile(ksRawfileFolder,'*.lf.bin'));
LFPfilePath = fullfile(ksRawfileFolder,LFPfilePathStrc(1).name);
llfpfs = 2500;
UsedcorrTimes = 5*60; % seconds, use the first 5mins data as baseline data for correlation calculation
% lfpData = memmapfile(LFPfilePath, 'Format', {'int16', [obj.NumChn obj.Numsamp], 'x'});
ftempid = fopen(LFPfilePath);
status = fseek(ftempid,0,'bof');
if ~status
    % correct offset value is set
    AllChnDatas = fread(ftempid,[385 UsedcorrTimes*llfpfs],'int16');
end
load(probechnfile);
channel_positions = [xcoords,ycoords];
lfp = AllChnDatas;

% load spike time datas
spike_templates = readNPY(fullfile(ksFolderPath,'spike_templates.npy'));
spike_times = readNPY(fullfile(ksFolderPath,'spike_times.npy'));
spike_times = double(spike_times)/30000;
TemplateChns = readNPY(fullfile(ksFolderPath,'templates_maxChn.npy'));
UsedTemplates = unique(spike_templates);
template_depths = ycoords(TemplateChns(UsedTemplates+1)+1);


%%
% Align histology to electrophysiology
use_probe = 1;
AP_align_probe_histology(st,slice_path, ...
    spike_times,spike_templates,template_depths, ...
     lfp,channel_positions(:,2),...
    use_probe);

% Extract slices from full-resolution images
% (not worth it at the moment, each slice is 200 MB)
% AP_grab_fullsize_histology_slices(im_path)













