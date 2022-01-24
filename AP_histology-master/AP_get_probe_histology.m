function AP_get_probe_histology(tv,av,st,slice_im_path,chnposfile)
% AP_get_probe_histology(tv,av,st,slice_im_path)
%
% Get probe trajectory in histology and convert to ccf
% Andy Peters (peters.andrew.j@gmail.com)

% Initialize guidata
gui_data = struct;
gui_data.tv = tv;
gui_data.av = av;
gui_data.st = st;

% Query number of probes from user
gui_data.n_probes = str2num(cell2mat(inputdlg('How many probes?')));

% Load in slice images
gui_data.slice_im_path = slice_im_path;
slice_im_dir = dir([slice_im_path filesep '*.tif']);
slice_im_fn = natsortfiles(cellfun(@(path,fn) [path filesep fn], ...
    {slice_im_dir.folder},{slice_im_dir.name},'uni',false));
gui_data.slice_im = cell(length(slice_im_fn),1);
for curr_slice = 1:length(slice_im_fn)
    gui_data.slice_im{curr_slice} = imread(slice_im_fn{curr_slice});
end

% Load corresponding CCF slices
ccf_slice_fn = [slice_im_path filesep 'histology_ccf.mat'];
load(ccf_slice_fn);
gui_data.histology_ccf = histology_ccf;

% Load histology/CCF alignment
ccf_alignment_fn = [slice_im_path filesep 'atlas2histology_tform.mat'];
load(ccf_alignment_fn);
gui_data.histology_ccf_alignment = atlas2histology_tform;

% Warp area labels by histology alignment
gui_data.histology_aligned_av_slices = cell(length(gui_data.slice_im),1);
for curr_slice = 1:length(gui_data.slice_im)
    curr_av_slice = gui_data.histology_ccf(curr_slice).av_slices;
    curr_av_slice(isnan(curr_av_slice)) = 1;
    curr_slice_im = gui_data.slice_im{curr_slice};
    
    tform = affine2d;
    tform.T = gui_data.histology_ccf_alignment{curr_slice};
    tform_size = imref2d([size(curr_slice_im,1),size(curr_slice_im,2)]);
    gui_data.histology_aligned_av_slices{curr_slice} = ...
        imwarp(curr_av_slice,tform,'nearest','OutputView',tform_size);
end

% Create figure, set button functions
gui_fig = figure('KeyPressFcn',@keypress);
gui_data.curr_slice = 1;

% Set up axis for histology image
gui_data.histology_ax = axes('YDir','reverse');
hold on; colormap(gray); axis image off;
gui_data.histology_im_h = image(gui_data.slice_im{1}, ...
    'Parent',gui_data.histology_ax);

% Create title to write area in
gui_data.histology_ax_title = title(gui_data.histology_ax,'','FontSize',14);

% Initialize probe points
gui_data.probe_color = lines(gui_data.n_probes);
gui_data.probe_points_histology = cell(length(gui_data.slice_im),gui_data.n_probes);
gui_data.probe_Endpoints_histology = cell(length(gui_data.slice_im),gui_data.n_probes);
gui_data.probe_lines = gobjects(gui_data.n_probes,1);
gui_data.probe_Endpoints = gobjects(gui_data.n_probes,1);
gui_data.probe_chndepth_file = chnposfile;
% Upload gui data
guidata(gui_fig,gui_data);

% Update the slice
update_slice(gui_fig);

end

function keypress(gui_fig,eventdata)

% Get guidata
gui_data = guidata(gui_fig);
EndPoint2probmap = {'q','w','e','r','t','y','u','i','o','p'}; % corresponded to 1 to 10 probs
switch eventdata.Key
    
    % left/right: move slice
    case 'leftarrow'
        gui_data.curr_slice = max(gui_data.curr_slice - 1,1);
        guidata(gui_fig,gui_data);
        update_slice(gui_fig);
        
    case 'rightarrow'
        gui_data.curr_slice = ...
            min(gui_data.curr_slice + 1,length(gui_data.slice_im));
        guidata(gui_fig,gui_data);
        update_slice(gui_fig);
    case EndPoint2probmap
        % add end points for each prob, characters corrsponded to prob nums
        curr_probe = find(strcmpi(eventdata.Key(end),EndPoint2probmap));
        if curr_probe > gui_data.n_probes
           disp(['Probe ' eventdata.Key ' selected, only ' num2str(gui_data.n_probes) ' available']);
           return
        end
        set(gui_data.histology_ax_title,'String',['Click to place end points for probe ' num2str(curr_probe)]);
        curr_point = impoint;
        pointConfirm = questdlg('Confirm current point?','confirm click','Yes','No','Yes');
        if strcmpi(pointConfirm,'Yes')
            gui_data.probe_Endpoints_histology{gui_data.curr_slice,curr_probe} = ...
                curr_point.getPosition;
            set(gui_data.histology_ax_title,'String', ...
                ['Arrows to move, Number to draw probe [' num2str(1:gui_data.n_probes) '], Esc to save/quit']);
            
        else
            set(gui_data.histology_ax_title,'String', ...
                ['Arrows to move, Number to draw probe [' num2str(1:gui_data.n_probes) '], Esc to save/quit']);
            curr_point.delete;
            return;
        end
        
        % Delete movable points, draw point object
        curr_point.delete;
        gui_data.probe_Endpoints(curr_probe) = ...
            plot(gui_data.probe_Endpoints_histology{gui_data.curr_slice,curr_probe}(1), ...
            gui_data.probe_Endpoints_histology{gui_data.curr_slice,curr_probe}(2), 'o',...
            'linewidth',2,'MarkerEdgeColor',[1 0.8 0.2],'MarkerSize',10);
        
        % Upload gui data
        guidata(gui_fig,gui_data);
        
        
    % Number: add coordinates for the numbered probe
    case [cellfun(@num2str,num2cell(1:9),'uni',false),cellfun(@(x) ['numpad' num2str(x)],num2cell(1:9),'uni',false)]
        curr_probe = str2num(eventdata.Key(end));
        
        if curr_probe > gui_data.n_probes
           disp(['Probe ' eventdata.Key ' selected, only ' num2str(gui_data.n_probes) ' available']);
           return
        end
        
        set(gui_data.histology_ax_title,'String',['Draw probe ' eventdata.Key]);
        curr_line = imline;
        pointConfirm = questdlg('Confirm current line?','confirm click','Yes','No','Yes');
        if strcmpi(pointConfirm,'Yes') 
            % If the line is just a click, don't include
            curr_line_length = sqrt(sum(abs(diff(curr_line.getPosition,[],1)).^2));
            if curr_line_length == 0
                return
            end
            gui_data.probe_points_histology{gui_data.curr_slice,curr_probe} = ...
                curr_line.getPosition;
            set(gui_data.histology_ax_title,'String', ...
                ['Arrows to move, Number to draw probe [' num2str(1:gui_data.n_probes) '], Esc to save/quit']);
        else
            set(gui_data.histology_ax_title,'String', ...
                ['Arrows to move, Number to draw probe [' num2str(1:gui_data.n_probes) '], Esc to save/quit']);
            curr_line.delete;
            return;
        end
        % Delete movable line, draw line object
        curr_line.delete;
        gui_data.probe_lines(curr_probe) = ...
            line(gui_data.probe_points_histology{gui_data.curr_slice,curr_probe}(:,1), ...
            gui_data.probe_points_histology{gui_data.curr_slice,curr_probe}(:,2), ...
            'linewidth',3,'color',gui_data.probe_color(curr_probe,:));
        
        % Upload gui data
        guidata(gui_fig,gui_data);
        
    case {'a','z'}
        % press to add probe index larger than 9
        % press 'a' to add probe inds larger than 0, press 'd' to add
        % probeEnd larger than 9
        curr_probe = str2num(cell2mat(inputdlg('Please input the probe number:')));
        if isempty(curr_probe) 
            error('Please input a number to continue.');
        end
        if curr_probe < 0 || curr_probe > gui_data.n_probes
            error('Input value %d is invalid',curr_probe);
        end
        if strcmpi(eventdata.Key(end),'a') % add prob 
            IsProbeAdd = 1;
            set(gui_data.histology_ax_title,'String',['Draw probe ' num2str(curr_probe)]);
            curr_obj = imline;
        else
            IsProbeAdd = 0;
            set(gui_data.histology_ax_title,'String',['Click to place end points for probe ' num2str(curr_probe)]);
            curr_obj = impoint;
        end
        pointConfirm = questdlg('Confirm current point?','confirm click','Yes','No','Yes');
        if strcmpi(pointConfirm,'No')
            set(gui_data.histology_ax_title,'String', ...
                ['Arrows to move, Number to draw probe [' num2str(1:gui_data.n_probes) '], Esc to save/quit']);
            curr_obj.delete;
            return;
        else
            if IsProbeAdd % add probe location
                % If the line is just a click, don't include
                curr_line_length = sqrt(sum(abs(diff(curr_obj.getPosition,[],1)).^2));
                if curr_line_length == 0
                    return
                end
                gui_data.probe_points_histology{gui_data.curr_slice,curr_probe} = ...
                    curr_obj.getPosition;
                set(gui_data.histology_ax_title,'String', ...
                    ['Arrows to move, Number to draw probe [' num2str(1:gui_data.n_probes) '], Esc to save/quit']);
                curr_obj.delete;
                gui_data.probe_lines(curr_probe) = ...
                    line(gui_data.probe_points_histology{gui_data.curr_slice,curr_probe}(:,1), ...
                    gui_data.probe_points_histology{gui_data.curr_slice,curr_probe}(:,2), ...
                    'linewidth',3,'color',gui_data.probe_color(curr_probe,:));
                
            else
                gui_data.probe_Endpoints_histology{gui_data.curr_slice,curr_probe} = ...
                    curr_obj.getPosition;
                set(gui_data.histology_ax_title,'String', ...
                    ['Arrows to move, Number to draw probe [' num2str(1:gui_data.n_probes) '], Esc to save/quit']);
                
                curr_obj.delete;
                gui_data.probe_Endpoints(curr_probe) = ...
                    plot(gui_data.probe_Endpoints_histology{gui_data.curr_slice,curr_probe}(1), ...
                    gui_data.probe_Endpoints_histology{gui_data.curr_slice,curr_probe}(2), 'o',...
                    'linewidth',2,'MarkerEdgeColor',[1 0.8 0.2],'MarkerSize',10);
            end
            
        end
        guidata(gui_fig,gui_data);
        
    case 'escape'
        opts.Default = 'Yes';
        opts.Interpreter = 'tex';
        user_confirm = questdlg('\fontsize{15} Save and quit?','Confirm exit',opts);
        if strcmp(user_confirm,'Yes')
            
            % Initialize structure to save
            probe_ccf = struct( ...
                'points',cell(gui_data.n_probes,1), ...
                'trajectory_coords',cell(gui_data.n_probes,1), ....
                'trajectory_areas',cell(gui_data.n_probes,1),...
                'endpoints',cell(gui_data.n_probes,1),...
                'EndpointAreas',cell(gui_data.n_probes,1));
            
            % Convert probe points to CCF points by alignment and save   
            % if there are empty probes, exclude the extra probe index
            EmptyProbs = zeros(gui_data.n_probes,1);
            for curr_probe = 1:gui_data.n_probes             
                for curr_slice = find(~cellfun(@isempty,gui_data.probe_points_histology(:,curr_probe)'))
                    
                    % Transform histology to atlas slice
                    tform = affine2d;
                    tform.T = gui_data.histology_ccf_alignment{curr_slice};
                    % (transform is CCF -> histology, invert for other direction)
                    tform = invert(tform);
                    
                    % Transform and round to nearest index
                    [probe_points_atlas_x,probe_points_atlas_y] = ...
                        transformPointsForward(tform, ...
                        gui_data.probe_points_histology{curr_slice,curr_probe}(:,1), ...
                        gui_data.probe_points_histology{curr_slice,curr_probe}(:,2));
                    
                    probe_points_atlas_x = round(probe_points_atlas_x);
                    probe_points_atlas_y = round(probe_points_atlas_y);
                    
                    % Get CCF coordinates corresponding to atlas slice points
                    % (CCF coordinates are in [AP,DV,ML])
                    use_points = find(~isnan(probe_points_atlas_x) & ~isnan(probe_points_atlas_y));
                    for curr_point = 1:length(use_points)
                        ccf_ap = gui_data.histology_ccf(curr_slice). ...
                            plane_ap(probe_points_atlas_y(curr_point), ...
                            probe_points_atlas_x(curr_point));
                        ccf_ml = gui_data.histology_ccf(curr_slice). ...
                            plane_ml(probe_points_atlas_y(curr_point), ...
                            probe_points_atlas_x(curr_point));
                        ccf_dv = gui_data.histology_ccf(curr_slice). ...
                            plane_dv(probe_points_atlas_y(curr_point), ...
                            probe_points_atlas_x(curr_point));
                        probe_ccf(curr_probe).points = ...
                            vertcat(probe_ccf(curr_probe).points,[ccf_ap,ccf_dv,ccf_ml]);
                    end
                    
                    % align end point position to CCF atlas
                    if ~isempty(gui_data.probe_Endpoints_histology{curr_slice,curr_probe})
                        % if find endpoint data at current slice
                        % Transform and round to nearest index
                        [endpoints_atlas_x,endpoints_atlas_y] = ...
                            transformPointsForward(tform, ...
                            gui_data.probe_Endpoints_histology{curr_slice,curr_probe}(1), ...
                            gui_data.probe_Endpoints_histology{curr_slice,curr_probe}(2));

                        endpoints_atlas_x = round(endpoints_atlas_x);
                        endpoints_atlas_y = round(endpoints_atlas_y);
                        
                        ccf_ap_ed = gui_data.histology_ccf(curr_slice). ...
                            plane_ap(endpoints_atlas_y, ...
                            endpoints_atlas_x);
                        ccf_ml_ed = gui_data.histology_ccf(curr_slice). ...
                            plane_ml(endpoints_atlas_y, ...
                            endpoints_atlas_x);
                        ccf_dv_ed = gui_data.histology_ccf(curr_slice). ...
                            plane_dv(endpoints_atlas_y, ...
                            endpoints_atlas_x);
                        probe_ccf(curr_probe).endpoints = ...
                            [ccf_ap_ed,ccf_dv_ed,ccf_ml_ed];
                        
                    end
                    
                end
                
                if isempty(probe_ccf(curr_probe).points)
                    EmptyProbs(curr_probe) = 1;
                else
                    % Sort probe points by DV (probe always top->bottom)
                    [~,dv_sort_idx] = sort(probe_ccf(curr_probe).points(:,2));
                    probe_ccf(curr_probe).points = probe_ccf(curr_probe).points(dv_sort_idx,:);
                end
            end
            % remove extra probe if exists
            if sum(EmptyProbs)
                EmptyIndslogi = logical(EmptyProbs);
                probe_ccf(EmptyIndslogi) = [];
                gui_data.probe_lines(EmptyIndslogi) = [];
                gui_data.probe_Endpoints(EmptyIndslogi) = [];
                gui_data.probe_Endpoints_histology(:,EmptyIndslogi) = [];
                gui_data.probe_points_histology(:,EmptyIndslogi) = [];
                gui_data.n_probes = gui_data.n_probes - sum(EmptyProbs);
                
            end
            %%
            % Get areas along probe trajectory            
            for curr_probe = 1:gui_data.n_probes
                
                %% Get best fit line through points as probe trajectory
                r0 = mean([probe_ccf(curr_probe).points;probe_ccf(curr_probe).endpoints],1);
                xyz = bsxfun(@minus,probe_ccf(curr_probe).points,r0);
                Endxyz = probe_ccf(curr_probe).endpoints - r0;
                [U,S,V] = svd([xyz;Endxyz],0);
                histology_probe_direction = V(:,1);
                % (make sure the direction goes down in DV - flip if it's going up)
                if histology_probe_direction(2) < 0
                    histology_probe_direction = -histology_probe_direction;
                end
                %
                line_eval = [-1000,1000];
                probe_fit_line = bsxfun(@plus,bsxfun(@times,line_eval',histology_probe_direction'),r0)';
                pointOnlineProj = U(:,1) .* S(1,1) .* (V(:,1))'+r0;
                prob_end_point = round(pointOnlineProj(end,:));
                % Get the positions of the probe trajectory
                trajectory_n_coords = max(abs(diff(probe_fit_line,[],2)));
                [trajectory_ap_ccf,trajectory_dv_ccf,trajectory_ml_ccf] = deal( ...
                    round(linspace(probe_fit_line(1,1),probe_fit_line(1,2),trajectory_n_coords)), ...
                    round(linspace(probe_fit_line(2,1),probe_fit_line(2,2),trajectory_n_coords)), ...
                    round(linspace(probe_fit_line(3,1),probe_fit_line(3,2),trajectory_n_coords)));
                %%
                trajectory_coords_outofbounds = ...
                    any([trajectory_ap_ccf;trajectory_dv_ccf;trajectory_ml_ccf] < 1,1) | ...
                    any([trajectory_ap_ccf;trajectory_dv_ccf;trajectory_ml_ccf] > size(gui_data.av)',1);
                              
                trajectory_coords = ...
                    [trajectory_ap_ccf(~trajectory_coords_outofbounds)' ...
                    trajectory_dv_ccf(~trajectory_coords_outofbounds)', ...
                    trajectory_ml_ccf(~trajectory_coords_outofbounds)'];
                
                trajectory_coords_idx = sub2ind(size(gui_data.av), ...
                    trajectory_coords(:,1),trajectory_coords(:,2),trajectory_coords(:,3));
                
                trajectory_areas_uncut = gui_data.av(trajectory_coords_idx)';
                Traj_end_area = gui_data.av(prob_end_point(1),prob_end_point(2),prob_end_point(3));
                
                % Get rid of NaN's and start/end 1's (non-parsed)
                trajectory_areas_parsed = find(trajectory_areas_uncut > 1);
                use_trajectory_areas = trajectory_areas_parsed(1): ...
                    trajectory_areas_parsed(end);
                trajectory_areas = reshape(trajectory_areas_uncut(use_trajectory_areas),[],1);
                
                probe_ccf(curr_probe).trajectory_coords = double(trajectory_coords(use_trajectory_areas,:));
                probe_ccf(curr_probe).trajectory_areas = double(trajectory_areas);
                probe_ccf(curr_probe).trajectory_Ends = prob_end_point;
                probe_ccf(curr_probe).EndpointAreas = Traj_end_area;
            end
            
            % Save probe CCF points
            save_fn = [gui_data.slice_im_path filesep 'probe_ccf.mat'];
            save(save_fn,'probe_ccf');
            disp(['Saved probe locations in ' save_fn])
            
            % Close GUI
%             close(gui_fig)
            
            % Plot probe trajectories
            plot_probe(gui_data,probe_ccf);
            %%
        end
end

end


function update_slice(gui_fig)
% Draw histology and CCF slice

% Get guidata
gui_data = guidata(gui_fig);

% Set next histology slice
set(gui_data.histology_im_h,'CData',gui_data.slice_im{gui_data.curr_slice})

% Clear any current lines, draw probe lines
gui_data.probe_lines.delete;
gui_data.probe_Endpoints.delete;
for curr_probe = find(~cellfun(@isempty,gui_data.probe_points_histology(gui_data.curr_slice,:)))
    gui_data.probe_lines(curr_probe) = ...
        line(gui_data.probe_points_histology{gui_data.curr_slice,curr_probe}(:,1), ...
        gui_data.probe_points_histology{gui_data.curr_slice,curr_probe}(:,2), ...
        'linewidth',3,'color',gui_data.probe_color(curr_probe,:));
end
for curr_probe = find(~cellfun(@isempty,gui_data.probe_Endpoints_histology(gui_data.curr_slice,:)))
    gui_data.probe_Endpoints(curr_probe) = ...
        plot(gui_data.probe_Endpoints_histology{gui_data.curr_slice,curr_probe}(1), ...
        gui_data.probe_Endpoints_histology{gui_data.curr_slice,curr_probe}(2), ...
        'ro','MarkerSize',10,'linewidth',3);
end


set(gui_data.histology_ax_title,'String', ...
            ['Arrows to move, Number to draw probe [' num2str(1:gui_data.n_probes) '], Esc to save/quit']);
        
% Upload gui data
guidata(gui_fig, gui_data);

end

function plot_probe(gui_data,probe_ccf)

%% Plot probe trajectories
hTraj = figure('Name','Probe trajectories');
axes_atlas = axes;
[~, brain_outline] = plotBrainGrid([],axes_atlas);
set(axes_atlas,'ZDir','reverse');
hold(axes_atlas,'on');
axis vis3d equal off manual
view([-30,25]);
caxis([0 300]);
[ap_max,dv_max,ml_max] = size(gui_data.tv);
xlim([-10,ap_max+10])
ylim([-10,ml_max+10])
zlim([-10,dv_max+10])
h = rotate3d(gca);
h.Enable = 'on';
%%
hls = [];
hlStrs = cell(length(probe_ccf),1);
ProbDirectionAll = cell(length(probe_ccf),1);
for curr_probe = 1:length(probe_ccf)
    %% Plot points and line of best fit
    MergedPoints = [probe_ccf(curr_probe).points;probe_ccf(curr_probe).endpoints];
    if max(pdist(MergedPoints)) < 350 % the maximum distance should be larger than probe length
        IsDistanceShort = 1;
    else
        IsDistanceShort = 0;
    end
    r0 = mean(MergedPoints,1);
    xyz = bsxfun(@minus,MergedPoints,r0);
    [U,S,V] = svd(xyz,0);
    histology_probe_direction = V(:,1);
    % (make sure the direction goes down in DV - flip if it's going up)
    if histology_probe_direction(2) < 0
        histology_probe_direction = -histology_probe_direction;
    end
    ProbDirectionAll{curr_probe} = histology_probe_direction; 
    line_eval = [-1000,1000];
    probe_fit_line = bsxfun(@plus,bsxfun(@times,line_eval',histology_probe_direction'),r0);
%     probe_fit_endpoint = ((probe_ccf(curr_probe).endpoints - r0)' .* histology_probe_direction) + r0';
    Online_probeDatapoints = U(:,1) * S(1,1) * (V(:,1))' + r0;
    probe_fit_endpoint = Online_probeDatapoints(end,:);

    plot3(probe_ccf(curr_probe).points(:,1), ...
        probe_ccf(curr_probe).points(:,3), ...
        probe_ccf(curr_probe).points(:,2), ...
        '.','color',gui_data.probe_color(curr_probe,:),'MarkerSize',20);
    plot3(probe_fit_endpoint(1),...
        probe_fit_endpoint(3),...
        probe_fit_endpoint(2),...
        'o','MarkerEdgeColor','r','MarkerFaceColor',[1 0.7 0.2],'MarkerSize',15,'linewidth',2);
    hcl = line(probe_fit_line(:,1),probe_fit_line(:,3),probe_fit_line(:,2), ...
        'color',gui_data.probe_color(curr_probe,:),'linewidth',2);
    hls = [hls,hcl];
    if ~IsDistanceShort
        hlStrs{curr_probe} = sprintf('Probe %d',curr_probe);
    else
        hlStrs{curr_probe} = sprintf('Probe %d Short',curr_probe);
    end
end
legend(hls,hlStrs,'location','NorthEastOutside','box','off');

save_fn1 = [gui_data.slice_im_path filesep 'probe_trajs_3dplot'];
saveas(hTraj,save_fn1);
saveas(hTraj,save_fn1,'png');

% Plot probe areas
hlineRegion = figure('Name','Trajectory areas');
% (load the colormap - located in the repository, find by associated fcn)
allenCCF_path = fileparts(which('allenCCFbregma'));
cmap_filename = [allenCCF_path filesep 'allen_ccf_colormap_2017.mat'];
load(cmap_filename);
for curr_probe = 1:length(probe_ccf)
    curr_axes = subplot(1,gui_data.n_probes,curr_probe);
    
    trajectory_area_boundaries = ...
        [1;find(diff(probe_ccf(curr_probe).trajectory_areas) ~= 0);length(probe_ccf(curr_probe).trajectory_areas)];    
    trajectory_area_centers = trajectory_area_boundaries(1:end-1) + diff(trajectory_area_boundaries)/2;
    trajectory_area_labels = gui_data.st.safe_name(probe_ccf(curr_probe).trajectory_areas(round(trajectory_area_centers)));
    
    image(probe_ccf(curr_probe).trajectory_areas);
    colormap(curr_axes,cmap);
    caxis([1,size(cmap,1)])
    set(curr_axes,'YTick',trajectory_area_centers,'YTickLabels',trajectory_area_labels);
    set(curr_axes,'XTick',[]);
    title(['Probe ' num2str(curr_probe)]);
    
end
save_fn2 = [gui_data.slice_im_path filesep 'probeline_areas'];
saveas(hlineRegion,save_fn2);
saveas(hlineRegion,save_fn2,'png');

%% plot channel areas
hChanArea = figure('Name','Channel areas');
probechnycoords = load(gui_data.probe_chndepth_file,'ycoords'); 
probechnpos = probechnycoords.ycoords / 10; % 10um/px for current atlas
NearBoundExcludeInds = -2:2;
channelPosAreaAll = cell(length(probe_ccf),3);
for curr_probe = 1:length(probe_ccf)
    curr_axes = subplot(1,gui_data.n_probes,curr_probe);
    chnposAll = (round((-1)*probechnpos * (ProbDirectionAll{curr_probe})' + probe_ccf(curr_probe).trajectory_Ends));
    
    % in case any channel position is out of index
    chan_coords_outofbounds = ...
                    any(chnposAll' < 1,1) | ...
                    any(chnposAll' > size(gui_data.av)',1);
    %
    if sum(chan_coords_outofbounds) % if channal out of index position exists
        ChnOutboundInds = chan_coords_outofbounds;
        chn_coords_idx = sub2ind(size(gui_data.av), ...
            chnposAll(~ChnOutboundInds,1),chnposAll(~ChnOutboundInds,2),chnposAll(~ChnOutboundInds,3));
    else
        chn_coords_idx = sub2ind(size(gui_data.av), ...
            chnposAll(:,1),chnposAll(:,2),chnposAll(:,3));
        ChnOutboundInds = [];
    end
    chn_areas = int16(gui_data.av(chn_coords_idx));
    
    chn_area_boundaries = ...
        [1;find(diff(chn_areas) ~= 0);length(chn_areas)];
    NearBoundChnInds = bsxfun(@minus,chn_area_boundaries,NearBoundExcludeInds);
    NearBoundChnVec = unique(NearBoundChnInds(:));
    NearBoundChnVec(NearBoundChnVec < 1 | NearBoundChnVec > numel(chn_coords_idx)) = []; % chn inds out of bound is excluded
    
    if isempty(ChnOutboundInds)
        chn_areasAll = chn_areas;
        chn_areas(NearBoundChnVec) = -1;
        channelPosAreaAll{curr_probe,1} = chn_areas; % -1 indicates near-boundary-not-used channels
        channelPosAreaAll{curr_probe,2} = chn_areasAll;
        chn_area_centers = chn_area_boundaries(1:end-1) + diff(chn_area_boundaries)/2;
        chn_area_labels = gui_data.st.safe_name(probe_ccf(curr_probe).trajectory_areas(uint16(round(chn_area_centers))));
        chnAllAreaNames = gui_data.st.safe_name(chn_areasAll);
        channelPosAreaAll{curr_probe,3} = chnAllAreaNames;
        
    else
        chn_areasAll = int16(zeros(size(probechnpos)));
        chn_areasAll(ChnOutboundInds) = -2;
        Rawchn_areas = chn_areas;
        chn_areas(NearBoundChnVec) = -1;
        chn_areasAll(~ChnOutboundInds) = chn_areas; % exclude out-of-index chn and near-bound chn
        channelPosAreaAll{curr_probe,1} = chn_areasAll;
        
        chn_area_full = int16(zeros(size(probechnpos)));
        chn_area_full(ChnOutboundInds) = -2;
        chn_area_full(~ChnOutboundInds) = Rawchn_areas; % only out-of-index 
        channelPosAreaAll{curr_probe,2} = chn_area_full;
        
        chnAllAreaNames = gui_data.st.safe_name(Rawchn_areas);
        chn_areaNameAll = cell(size(probechnpos));
        chn_areaNameAll(ChnOutboundInds) = {'NaN'};
        chn_areaNameAll(~ChnOutboundInds) = chnAllAreaNames;
        channelPosAreaAll{curr_probe,3} = chn_areaNameAll;
    end
    %
    
    image(chn_areasAll);
    colormap(curr_axes,cmap);
    caxis([1,size(cmap,1)])
    set(curr_axes,'YTick',chn_area_centers,'YTickLabels',chn_area_labels);
    set(curr_axes,'XTick',[]);
    title(['Probe ' num2str(curr_probe)]);
    %
end
%%
save_fn3 = [gui_data.slice_im_path filesep 'chan_areas'];
saveas(hChanArea,save_fn3);
saveas(hChanArea,save_fn3,'png');

%% save prob channel area datas into a excel file and saved in place
save_fn = [gui_data.slice_im_path filesep 'probe_chn_location.xlsx'];
sheetNames = cell(length(probe_ccf),1);
for curr_probe = 1:length(probe_ccf)
   cprobDatas = channelPosAreaAll(curr_probe,:);
   T = table(cprobDatas{:},'VariableNames',{'UsedChnArea','AllChnArea','ChnAreaNames'});
   writetable(T,save_fn,'sheet',curr_probe);
   sheetNames{curr_probe} = sprintf('Probe%d',curr_probe);
   
end
%%
e = actxserver('Excel.Application'); % # open Activex server
ewb = e.Workbooks.Open(save_fn); % # open file (enter full path!)
% reanme sheet names
for curr_probe = 1:length(probe_ccf)
   ewb.Worksheets.Item(curr_probe).Name = sheetNames{curr_probe};% # rename (curr_probe)st sheet 
end
ewb.Save % # save to the same file
ewb.Close(false)
e.Quit
%


end









