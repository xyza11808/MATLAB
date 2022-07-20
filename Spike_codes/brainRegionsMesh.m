function hf = brainRegionsMesh(st,BrainAreas, objFilePath, AreaColors, AreaFaceAlpha, varargin)
% function used for plotting brain regions using given color and face alpha
% AreaColors: must be a two-dimensional matrix with three columns, each row
%             is the face color for corresponded area.
% AreaFaceAlpha: one vector with values between [0 1], indicating the
%               transparency of face color

if length(BrainAreas) > 1 && length(AreaFaceAlpha) == 1
    AreaFaceAlpha = repmat(AreaFaceAlpha,length(BrainAreas),1);
end
if ~any(strcmpi(BrainAreas,'root'))
    BrainAreas = ['root';BrainAreas(:)]; % adding the brain outline plots if not included
    AreaColors = [[.7 .7 .7];AreaColors];
    AreaFaceAlpha = [0.5;AreaFaceAlpha];
end

NumofAreas = length(BrainAreas); % only the abbreviation is needed

plotSide = 0; % plot default sides
if nargin > 5
    if ~isempty(varargin{1})
        plotSide = varargin{1}; % value 1 indicates left plot only, 2 indicate right plot only
    end
end
mid_point = 570;     % 1140/2

hf = figure;
hold on;


for cA = 1 : NumofAreas
    cA_nameStr = BrainAreas{cA};
    Name2treeInds = find(strcmpi(st.acronym,cA_nameStr));
    if isempty(Name2treeInds)
        warning('No target brain region named %s, Please check your input values.\n',cA_nameStr);
    else
       AreaIDs = st.id(Name2treeInds);
       objfileFullPath = fullfile(objFilePath,num2str(AreaIDs,'%d.obj'));
       if ~exist(objfileFullPath,'file')
           warning('Unable to find target file name:\n %s ...\n',objfileFullPath);
           continue;
       end
       [v,F] = loadawobj(objfileFullPath);
       v = v/10;
       switch plotSide
           case 1 % left plot only
               index_v = find(v(3,:)>mid_point);
               AllfValueInds = reshape(ismember(F(:),index_v),size(F,1),size(F,2));
               index_F = (sum(AllfValueInds)) > 0;
%                
%                 index_F = [];
%                 for j = 1:size(F,2)
%                     if any(ismember(F(:,j),index_v))
%                         index_F = [index_F j];
%                     end
%                 end
                F(:,index_F) = [];
               
           case 2 % right plot only
               index_v = find(v(3,:)<mid_point);
               AllfValueInds = reshape(ismember(F(:),index_v),size(F,1),size(F,2));
               index_F = (sum(AllfValueInds)) > 0;
               F(:,index_F) = [];
               
           case 0 % plot all
               % all connections were used, need to process nothing
               
           otherwise
               warning('Unkown hemisphere plot option (%d).\n');
       end
       patch('Vertices',v','Faces',F','EdgeColor','none','FaceColor',AreaColors(cA,:),'FaceAlpha',AreaFaceAlpha(cA));
       
       
    end
    

end







