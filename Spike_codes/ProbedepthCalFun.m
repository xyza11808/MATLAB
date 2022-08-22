function ProbeDepth = ProbedepthCalFun(allen_atlas_path,probe_ccf)
% this function is used to recalculate the probe postion using experimental
% insertion depth and the surface postion, which is useful when the probe
% end is missing

% on laptop
% allen_atlas_path = 'E:\AllenCCF';
% probechnfile = 'E:\codes\matcodes\ks2_5\configFiles\neuropixPhase3B2_kilosortChanMap.mat';

% on office PC
% allen_atlas_path = 'E:\MatCode\AllentemplateData';
% probechnfile = 'E:\MatCode\MATLAB\sortingcode\Kilosort3\configFiles\neuropixPhase3B2_kilosortChanMap.mat';

% tv = readNPY([allen_atlas_path filesep 'template_volume_10um.npy']);
av = readNPY([allen_atlas_path filesep 'annotation_volume_10um_by_index.npy']);
% st = loadStructureTree([allen_atlas_path filesep 'structure_tree_safe_2017.csv']);


% probeccf_strc = load(fullfile(SlicePath,'probe_ccf.mat'));
NumofProbes = length(probe_ccf);
ProbeDepth = zeros(NumofProbes,1);
for curr_probe = 1 : NumofProbes
    AlllabelPoints = [probe_ccf(curr_probe).points;...
        probe_ccf(curr_probe).endpoints];
%
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
   
    % using large search length to find surface
    MaxLength = 8000; %um
    PesudoChannellocs = (1:(MaxLength/10))';
    NewchnposAll = (round((-1)*PesudoChannellocs * (ProbDirectionAll)'...
         + probe_ccf(curr_probe).trajectory_Ends));
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
    
    ProbeDepth(curr_probe) = sqrt(sum((probe_fit_endpoint - SurfPosCord).^2));
end
