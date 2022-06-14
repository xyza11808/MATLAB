
AnatomySessFolderFile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\AnatomySessFolders.xlsx';
SessionFoldersC = readcell(AnatomySessFolderFile,'Range','B:B',...
        'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);
SessionFolders = SessionFoldersAll(UsedFolderInds);
NumprocessedNPSess = length(SessionFolders);


%% read anatomy session folder path data for final plot
AllSessProbeDatas = cell(NumprocessedNPSess,2);

for cf = 1 : NumprocessedNPSess

    cfPath = SessionFolders{cf};
    
    FullfilePath = fullfile(cfPath,'probe_ccf.mat');
    clearvars probe_ccf
    
    load(FullfilePath);
    % load session probe data and saved
    nProbes = length(probe_ccf);
    ProbePlotDatas = cell(nProbes,2);
    IsProbeShort = zeros(nProbes,1);
    for curr_probe = 1:length(probe_ccf)
        % Plot points and line of best fit
        MergedPoints = [probe_ccf(curr_probe).points;probe_ccf(curr_probe).endpoints];
        if max(pdist(MergedPoints)) < 350 % the maximum distance should be larger than probe length
            IsProbeShort(curr_probe) = 1;
        end
        r0 = mean(MergedPoints,1);
        xyz = bsxfun(@minus,MergedPoints,r0);
        [U,S,V] = svd(xyz,0);
        histology_probe_direction = V(:,1);
        % (make sure the direction goes down in DV - flip if it's going up)
        if histology_probe_direction(2) < 0
            histology_probe_direction = -histology_probe_direction;
        end

        line_eval = [-700,700];
        probe_fit_line = bsxfun(@plus,bsxfun(@times,line_eval',histology_probe_direction'),r0);
    %     probe_fit_endpoint = ((probe_ccf(curr_probe).endpoints - r0)' .* histology_probe_direction) + r0';
        Online_probeDatapoints = U(:,1) * S(1,1) * (V(:,1))' + r0;
        probe_fit_endpoint = Online_probeDatapoints(end,:);

        ProbePlotDatas(curr_probe,:) = {histology_probe_direction, probe_fit_line};
    %     hcl = line(probe_fit_line(:,1),probe_fit_line(:,3),probe_fit_line(:,2), ...
    %         'color',gui_data.probe_color(curr_probe,:),'linewidth',2);
    end
 
    AllSessProbeDatas(cf,:) = {ProbePlotDatas, IsProbeShort};
end

%%

ProbesLineData_AllCell = cat(1,AllSessProbeDatas{:,1});
ProbesLineData_IsShort = cat(1,AllSessProbeDatas{:,2});
nProbes = size(ProbesLineData_AllCell,1);

% define colors for each probe
nProbeColors = lines(nProbes);
%% 
hTraj = figure('Name','Probe trajectories');
axes_atlas = axes;
[~, brain_outline] = plotBrainGrid([],axes_atlas); % plot brain outlines
set(axes_atlas,'ZDir','reverse');
hold(axes_atlas,'on');
axis vis3d equal off manual
view([-30,25]);
caxis([0 300]);
allen_atlas_path = 'E:\AllenCCF';
tv = readNPY([allen_atlas_path filesep 'template_volume_10um.npy']);
[ap_max,dv_max,ml_max] = size(tv);
xlim([-10,ap_max+10])
ylim([-10,ml_max+10])
zlim([-10,dv_max+10])

%% plot all probes

for cprobe = 1 : nProbes
    if ProbesLineData_IsShort(cprobe) == 0
        cProbeLines = ProbesLineData_AllCell{cprobe,2};
        line(axes_atlas,cProbeLines(:,1),cProbeLines(:,3),cProbeLines(:,2),...
            'Color',nProbeColors(cprobe,:),'linewidth',1.0);
    end
end
xscales = get(axes_atlas,'xlim');
yscales = get(axes_atlas,'ylim');
zscales = get(axes_atlas,'zlim');
axis vis3d
%% create Gif to show all plots

GifNames = fullfile('E:\sycDatas\Documents\me\projects\NP_reversaltask','AllProbeLinesPlot.gif');
for cf = -180:10:180
    view(axes_atlas,cf,45);
    set(axes_atlas,'xlim',xscales,'ylim',yscales,'zlim',zscales);
    
    if cf == -180
        gif(GifNames,'DelayTime',1/5,'LoopCount',Inf,'frame',hTraj,'resolution',650);
    else
        gif;
    end
end

%%  
figsaveName = fullfile('E:\sycDatas\Documents\me\projects\NP_reversaltask','AllProbeLinesPlot');
saveas(hTraj,figsaveName);
print(hTraj,figsaveName,'-dpng','-r860'); % -r indicates the output resolution

DataSaveName = fullfile('E:\sycDatas\Documents\me\projects\NP_reversaltask','AllProbeLinesData.mat');
save(DataSaveName,'AllSessProbeDatas','SessionFolders','-v7.3');


