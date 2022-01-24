% tv = readNPY('template_volume_10um.npy'); % grey-scale "background signal intensity"
% av = readNPY('annotation_volume_10um_by_index.npy'); % the number at each pixel labels the area, see note below
% st = loadStructureTree('structure_tree_safe_2017.csv'); % a table of what all the labels mean

% allen_atlas_path = 'E:\MatCode\AllentemplateData';
allen_atlas_path = 'E:\AllenCCF';
tv = readNPY([allen_atlas_path filesep 'template_volume_10um.npy']);
av = readNPY([allen_atlas_path filesep 'annotation_volume_10um_by_index.npy']);
st = loadStructureTree([allen_atlas_path filesep 'structure_tree_safe_2017.csv']);

allen_ccf_npx(tv,av,st);