% allen_atlas_path = 'E:\AllenCCF';
allen_atlas_path = 'E:\MatCode\AllentemplateData';
tv = readNPY([allen_atlas_path filesep 'template_volume_10um.npy']);
av = readNPY([allen_atlas_path filesep 'annotation_volume_10um_by_index.npy']);
st = loadStructureTree([allen_atlas_path filesep 'structure_tree_safe_2017.csv']);


%%
% SliceName = 'sagittal';
figure('position',[100 100 800 340]);
sagAx = subplot(121);
topdownAx = subplot(122);
% plotRecLocsMapByColor(sagAx,topdownAx,{'AUD'},[1 0 0],st,av); % color should have same rows as number of brain regions
plotRecLocsMapByColor(sagAx,topdownAx,AdjAreaStrings,Value2Colors,st,av); % color should have same rows as number of brain regions
