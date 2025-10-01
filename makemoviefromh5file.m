simapath = 'Z:\yu\imaging\SLMtable\b005a05\b005a05_20231218-001\b005a05_20231218-001.sima';
matfilepath = fullfile(simapath,'PrepareFrameData4MATLAB.mat');
h5filepath = strrep(strrep(simapath,'Z:\yu\imaging\SLMtable\','F:\b005_h5file\'),'.sima','.h5');
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
data = h5read(h5filepath,'/imaging');
disp(size(data));

%%

% frames info
plotStimTime = 1; 
UsedOnsetFrame = OptoTrigInfo.PointOnOffFrames(:,plotStimTime,1);
% cOnsetFrame_lapbin = unique(lapbinIndex(UsedOnsetFrame));
cOnsetFrame_lapbin = 3;
Relocs = [400,2500]/3000;
plotPointNum = size(OptoTrigInfo.PointPosLocs,1);
Pointpixelloc = OptoTrigInfo.PointPosLocs(:,1:2);

%
lapStartBin = find(lapbinIndex == cOnsetFrame_lapbin & IsVROn,1,'first');
lapEndBin = find(lapbinIndex == cOnsetFrame_lapbin & IsVROn,1,'last');
UsedOffsetFrame = OptoTrigInfo.PointOnOffFrames(:,plotStimTime,2);
scaleRange = [200,5000];
MinMaxFrames = [min(OptoTrigInfo.PointOnOffFrames(:)),max(OptoTrigInfo.PointOnOffFrames(:))];
FullFrameIndex = lapStartBin:lapEndBin;
FulllapframePoint = zeros([length(FullFrameIndex),1],"int8");

for cP = 1:plotPointNum
    cPointFInds = FullFrameIndex>UsedOnsetFrame(cP) & FullFrameIndex<UsedOffsetFrame(cP);
    FulllapframePoint(cPointFInds) = cP;
end
DispStr = 'Stimlap';
if lapStartBin>MinMaxFrames(2) 
    DispStr = 'Postlap';
elseif lapEndBin<MinMaxFrames(1)
    DispStr = 'Prelap';
end

filename = sprintf('%s example videos',DispStr);
v = VideoWriter(fullfile('D:\',filename),'Motion JPEG AVI');
v.Quality = 100;
% status bar datas
plotwidth = 0.02;
plotHeight=0.1;
RTlocColor = [1,0,0];
if max(FulllapframePoint)<1
    StimColor = [0.5,0.5,0.5];
    Circstyle = '--';
else
    StimColor = [0,0.9,0];
    Circstyle = '-';
end
bgColor = [0.7,0.7,0.1];
ReColor='m';
StimOnPos = lapNorPos(UsedOnsetFrame);

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
    cfData = squeeze(data(2,:,:,1,cfInds));
    
    cshift = [xoff(cfInds),yoff(cfInds)];

    cfDataAlign = ImageTranslation_2d(cfData, cshift, [0,0,0,0]);

    imagesc(cax,cfDataAlign',scaleRange);
    colormap gray
    if strcmpi(DispStr,'Stimlap')
        if FulllapframePoint(ccInds)>0
            cPoint=FulllapframePoint(ccInds);
            plot(cax,Pointpixelloc(cPoint,1),Pointpixelloc(cPoint,2),'ro','MarkerSize',15,...
                'linewidth',1.0,'LineStyle','-');
            patch(cax,[10,60,60,10],[10,10,60,60],1,'facecolor','g',...
                'EdgeColor','None','Facealpha',1);
            text(cax,Pointpixelloc(cPoint,1)+20,Pointpixelloc(cPoint,2),num2str(cPoint,'%d'),"FontSize",10,'color','c');
        end
    else
        if strcmpi(DispStr,'Postlap')
            lnColor='m';
        else
            lnColor='c';
        end
        for cPoint = 1:plotPointNum
            plot(cax,Pointpixelloc(cPoint,1),Pointpixelloc(cPoint,2),'o','MarkerSize',15,...
                'linewidth',1.0,'LineStyle','-','color',lnColor);
            text(cax,Pointpixelloc(cPoint,1)+20,Pointpixelloc(cPoint,2),num2str(cPoint,'%d'),"FontSize",10,'color','c');
        end
    end
    set(cax,'XLim',[0.5,512.5],'YLim',[0.5,512.5],'YDir','reverse');
    axis(cax,'off');
    % background
    patch(NewAxpos,[0,1,1,0],[0,0,plotHeight,plotHeight],1,'facecolor',bgColor,...
        'EdgeColor',[.7,.7,.7],'Facealpha',0.4);
    % stim locs
    for cInds = 1:length(StimOnPos)
        patch(NewAxpos,[StimOnPos(cInds)-plotwidth,StimOnPos(cInds)+plotwidth,StimOnPos(cInds)+plotwidth,StimOnPos(cInds)-plotwidth],...
            [-0.05,-0.05,plotHeight,plotHeight],1,'facecolor',StimColor,...
            'EdgeColor','None','Facealpha',0.8);
        text(NewAxpos,StimOnPos(cInds),plotHeight/2,num2str(cInds,'%d'),"FontSize",10,'color','k');
    end
    % rewardloc
    for cInds = 1:length(StimOnPos)
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
