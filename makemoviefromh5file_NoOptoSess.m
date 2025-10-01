
cclr

%%

simapath = 'E:\temp2\b006a03_20231216-001';
matfilepath = fullfile(simapath,'PrepareFrameData4MATLAB.mat');
h5filepath = 'E:\temp2\b006a03_20231216-001\b006a03_20231216-001.h5';
%%
suite2pfile=fullfile(simapath,'ImAlignShift.mat');
% ops = readNPY(suite2pfile);
% xshifts = ops.xoff;
% yshifts = ops.yoff;
load(suite2pfile);
%%
load(matfilepath);


%%
% load h5 file
h5infos = h5info(h5filepath);
h5datapath = '/imaging';
% data = h5read(h5filepath,);
% disp(size(data));

%%

% frames info

% cOnsetFrame_lapbin = unique(lapbinIndex(UsedOnsetFrame));
cOnsetFrame_lapbin = 9;
Relocs = [400,2500]/3000;

lapStartBin = find(lapbinIndex == cOnsetFrame_lapbin & IsVROn,1,'first');
lapEndBin = find(lapbinIndex == cOnsetFrame_lapbin & IsVROn,1,'last');
scaleRange = [500,5000];
FullFrameIndex = lapStartBin:lapEndBin;
data = squeeze(h5read(h5filepath,h5datapath,[2,1,1,1,lapStartBin],[1,Inf,Inf,1,length(FullFrameIndex)]));

DispStr = 'Behavlap';

filename = sprintf('%s lap %d example videos',DispStr,cOnsetFrame_lapbin);
v = VideoWriter(fullfile('E:\temp2\b006a03_20231216-001\',filename),'Motion JPEG AVI');
v.Quality = 100;

% status bar
plotwidth = 0.02;
plotHeight=0.1;
RTlocColor = [1,0,0];

bgColor = [0.7,0.7,0.1];
ReColor='m';

close
hf = figure('position',[100 100,380 340]);
cax = gca;
axis(cax,'equal');
caxpos = get(cax,'Position');
NewAxpos = axes('Position',[caxpos(1),caxpos(2)+caxpos(4)+0.02,caxpos(3),0.05]);
f = waitbar(0,'Please wait...');
open(v);
for cfInds = lapStartBin:lapEndBin %disprange(1):disprange(2)
    cla(cax);
    cla(NewAxpos);
    hold(cax,'on')
    ccInds = cfInds-lapStartBin+1;
    cfData = squeeze(data(:,:,ccInds));
    
    cshift = [xoff(cfInds),yoff(cfInds)];

    cfDataAlign = ImageTranslation_2d(cfData, cshift, [0,0,0,0]);

    imagesc(cax,cfDataAlign',scaleRange);
    colormap gray
    
    set(cax,'XLim',[0.5,512.5],'YLim',[0.5,512.5],'YDir','reverse');
    axis(cax,'off');
    % background
    patch(NewAxpos,[0,1,1,0],[0,0,plotHeight,plotHeight],1,'facecolor',bgColor,...
        'EdgeColor',[.7,.7,.7],'Facealpha',0.4);
    
    % rewardloc
    for cInds = 1:length(Relocs)
        patch(NewAxpos,[Relocs(cInds)-plotwidth,Relocs(cInds)+plotwidth,Relocs(cInds)+plotwidth,Relocs(cInds)-plotwidth],...
            [-0.05,-0.05,plotHeight,plotHeight],1,'facecolor',ReColor,...
            'EdgeColor','None','Facealpha',0.8);
    end
    % real time location
    cloc = lapNorPos(cfInds);
    patch(NewAxpos,[cloc-plotwidth,cloc+plotwidth,cloc+plotwidth,cloc-plotwidth],...
        [0,0,plotHeight,plotHeight],1,'facecolor',RTlocColor,...
        'EdgeColor','None','Facealpha',0.8);
    set(NewAxpos,'XLim',[0,1],'YLim',[0,plotHeight]);
    axis(NewAxpos,'off');
    
    frame = getframe(hf);
    writeVideo(v,frame);

    waitbar((cfInds-lapStartBin)/(-lapStartBin+lapEndBin),f,'Generating video...');
    pause(1/30)
end

close(f)
close(v)
