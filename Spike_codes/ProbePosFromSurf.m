function ProbePosFromSurf(allen_atlas_path,SlicePath,probechnfile,...
    curr_probe,ExpDepth)
% this function is used to recalculate the probe postion using experimental
% insertion depth and the surface postion, which is useful when the probe
% end is missing

% on laptop
% allen_atlas_path = 'E:\AllenCCF';
% probechnfile = 'E:\codes\matcodes\ks2_5\configFiles\neuropixPhase3B2_kilosortChanMap.mat';

% on office PC
% allen_atlas_path = 'E:\MatCode\AllentemplateData';
% probechnfile = 'E:\MatCode\MATLAB\sortingcode\Kilosort3\configFiles\neuropixPhase3B2_kilosortChanMap.mat';

tv = readNPY([allen_atlas_path filesep 'template_volume_10um.npy']);
av = readNPY([allen_atlas_path filesep 'annotation_volume_10um_by_index.npy']);
st = loadStructureTree([allen_atlas_path filesep 'structure_tree_safe_2017.csv']);


probeccf_strc = load(fullfile(SlicePath,'probe_ccf.mat'));

AlllabelPoints = [probeccf_strc.probe_ccf(curr_probe).points;...
    probeccf_strc.probe_ccf(curr_probe).endpoints];
%%
r0 = mean(AlllabelPoints,1);
xyz = bsxfun(@minus,AlllabelPoints,r0);
[U,S,V] = svd(xyz,0);
histology_probe_direction = V(:,1);
% (make sure the direction goes down in DV - flip if it's going up)
if histology_probe_direction(2) < 0
    histology_probe_direction = -histology_probe_direction;
end
ProbDirectionAll = histology_probe_direction; 

Online_probeDatapoints = U(:,1) * S(1,1) * (V(:,1))' + r0;
probe_fit_endpoint = Online_probeDatapoints(end,:);
%%
ChannelDepth = load(probechnfile,'ycoords');
Channel2IndsDis = ChannelDepth.ycoords/10;
chnposAll = (round((-1)*Channel2IndsDis * (ProbDirectionAll)'...
    + probeccf_strc.probe_ccf(curr_probe).trajectory_Ends));
%
% in case any channel position is out of index
chan_coords_outofbounds = ...
                any(chnposAll' < 1,1) | ...
                any(chnposAll' > size(av)',1);
%
if sum(chan_coords_outofbounds) % if channal out of index position exists
    ChnOutboundInds = chan_coords_outofbounds;
    chn_coords_idx = sub2ind(size(av), ...
        chnposAll(~ChnOutboundInds,1),chnposAll(~ChnOutboundInds,2),chnposAll(~ChnOutboundInds,3));
    chnposAll(chan_coords_outofbounds,:) = [];
else
    chn_coords_idx = sub2ind(size(av), ...
        chnposAll(:,1),chnposAll(:,2),chnposAll(:,3));
    ChnOutboundInds = [];
end
chn_areas = int16(av(chn_coords_idx));
%
LastRealAreaIndex = find(chn_areas>1, 1, 'last');
%%
if isempty(LastRealAreaIndex) % the probe depth is larger than probe length
    % increase the search length
    MaxLength = 6000; %um
    PesudoChannellocs = (2:2:MaxLength/10)';
    NewchnposAll = (round((-1)*PesudoChannellocs * (ProbDirectionAll)'...
         + probe_fit_endpoint));
    chan_coords_outofbounds = ...
                any(NewchnposAll' < 1,1) | ...
                any(NewchnposAll' > size(av)',1);
    %
    if sum(chan_coords_outofbounds) % if channal out of index position exists
        ChnOutboundInds = chan_coords_outofbounds;
        chn_coords_idx = sub2ind(size(av), ...
            NewchnposAll(~ChnOutboundInds,1),NewchnposAll(~ChnOutboundInds,2),...
            NewchnposAll(~ChnOutboundInds,3));
        NewchnposAll(chan_coords_outofbounds,:) = [];
    else
        chn_coords_idx = sub2ind(size(av), ...
            NewchnposAll(:,1),NewchnposAll(:,2),NewchnposAll(:,3));
        ChnOutboundInds = [];
    end
    chn_areas = int16(av(chn_coords_idx));
    LastRealAreaIndex = find(chn_areas>1, 1, 'last');
    
    SurfPosCord = NewchnposAll(LastRealAreaIndex,:);
    
else  
    % corrected depth
    % increase the search length
    MaxLength = 8000; %um
    PesudoChannellocs = (2:2:MaxLength/10)';
    NewchnposAll = (round((-1)*PesudoChannellocs * (ProbDirectionAll)'...
         + probe_fit_endpoint));
    chan_coords_outofbounds = ...
                any(NewchnposAll' < 1,1) | ...
                any(NewchnposAll' > size(av)',1);
    %
    if sum(chan_coords_outofbounds) % if channal out of index position exists
        ChnOutboundInds = chan_coords_outofbounds;
        chn_coords_idx = sub2ind(size(av), ...
            NewchnposAll(~ChnOutboundInds,1),NewchnposAll(~ChnOutboundInds,2),...
            NewchnposAll(~ChnOutboundInds,3));
        NewchnposAll(chan_coords_outofbounds,:) = [];
    else
        chn_coords_idx = sub2ind(size(av), ...
            NewchnposAll(:,1),NewchnposAll(:,2),NewchnposAll(:,3));
        ChnOutboundInds = [];
    end
    chn_areas = int16(av(chn_coords_idx));
    LastRealAreaIndex = find(chn_areas>1, 1, 'last');
    
    SurfPosCord = NewchnposAll(LastRealAreaIndex,:);
end

TargetDepthEndpointCord = round(ExpDepth/10*(ProbDirectionAll)' + SurfPosCord);

%% correct channel positions
chnposAllFinal = (round((-1)*Channel2IndsDis * (ProbDirectionAll)'...
    + TargetDepthEndpointCord));
% in case any channel position is out of index
chan_coords_outofbounds = ...
                any(chnposAllFinal' < 1,1) | ...
                any(chnposAllFinal' > size(av)',1);
%
if sum(chan_coords_outofbounds) % if channal out of index position exists
    ChnOutboundInds = chan_coords_outofbounds;
    chn_coords_idx = sub2ind(size(av), ...
        chnposAllFinal(~ChnOutboundInds,1),chnposAllFinal(~ChnOutboundInds,2),chnposAllFinal(~ChnOutboundInds,3));
else
    chn_coords_idx = sub2ind(size(av), ...
        chnposAllFinal(:,1),chnposAllFinal(:,2),chnposAllFinal(:,3));
    ChnOutboundInds = [];
end
chn_areas = int16(av(chn_coords_idx));

probeccf_strc.probe_ccf(curr_probe).IsProbeAdjusted = 1;
probeccf_strc.probe_ccf(curr_probe).AdjustEndpoints = TargetDepthEndpointCord;


% recalculate channel areas    
NearBoundExcludeInds = -2:2;
chn_area_boundaries = ...
        [1;find(diff(chn_areas) ~= 0);length(chn_areas)];
NearBoundChnInds = bsxfun(@minus,chn_area_boundaries,NearBoundExcludeInds);
NearBoundChnVec = unique(NearBoundChnInds(:));
NearBoundChnVec(NearBoundChnVec < 1 | NearBoundChnVec > numel(chn_coords_idx)) = []; % chn inds out of bound is excluded
channelPosAreaAll = cell(1,3);
if isempty(ChnOutboundInds)
    chn_areasAll = chn_areas;
    chn_areas(NearBoundChnVec) = -1;
    channelPosAreaAll{1} = chn_areas; % -1 indicates near-boundary-not-used channels
    channelPosAreaAll{2} = chn_areasAll;
    chn_area_centers = chn_area_boundaries(1:end-1) + diff(chn_area_boundaries)/2;
    chn_area_labels = st.safe_name(probeccf_strc.probe_ccf(curr_probe).trajectory_areas(uint16(round(chn_area_centers))));
    chnAllAreaNames = st.safe_name(chn_areasAll);
    channelPosAreaAll{3} = chnAllAreaNames;

else % adjust the probe depth if the aligned depth is too much
    OutBoundBoundaries = ChnOutboundInds(chn_area_boundaries);
    chn_area_boundaries(logical(OutBoundBoundaries)) = [];
    chn_area_centers = chn_area_boundaries(1:end-1) + diff(chn_area_boundaries)/2;
    
    chn_areasAll = int16(zeros(size(probechnpos)));
    chn_areasAll(ChnOutboundInds) = -2;
    Rawchn_areas = chn_areas;
    chn_areas(NearBoundChnVec) = -1;
    chn_areasAll(~ChnOutboundInds) = chn_areas; % exclude out-of-index chn and near-bound chn
    channelPosAreaAll{1} = chn_areasAll;

    chn_area_full = int16(zeros(size(probechnpos)));
    chn_area_full(ChnOutboundInds) = -2;
    chn_area_full(~ChnOutboundInds) = Rawchn_areas; % only out-of-index 
    channelPosAreaAll{2} = chn_area_full;

    chnAllAreaNames = st.safe_name(Rawchn_areas);
    chn_areaNameAll = cell(size(probechnpos));
    chn_areaNameAll(ChnOutboundInds) = {'NaN'};
    chn_areaNameAll(~ChnOutboundInds) = chnAllAreaNames;
    channelPosAreaAll{3} = chn_areaNameAll;
end
    
%% write data to older xls files
sliceSavefilePath = fullfile(SlicePath,'probe_chn_location.xlsx');

T = table(channelPosAreaAll{:},'VariableNames',{'UsedChnArea','AllChnArea','ChnAreaNames'});
writetable(T,sliceSavefilePath,'sheet',sprintf('Probe%d',curr_probe),...
    'WriteMode','overwritesheet');

fprintf('\n Over write probe %d channel area data in the xlsx file.\n',curr_probe);



