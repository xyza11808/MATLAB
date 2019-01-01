cclr
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file');
if ~fi
    return;  
end 
fPath = fullfile(fp,fn);
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessType = 0;
SessPathAll = {};
m = 1;
while ischar(tline)
    if ~isempty(strfind(tline,'######')) % new section flag
        SessType = SessType + 1;
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        SessPathAll{m,2} = SessType;
        m = m + 1;
    end
    tline = fgetl(fid);
end
SessIndexAll = cell2mat(SessPathAll(:,2));
%% processing 8k-32k and 4k-16k sessions data
Sess8_32_Inds = SessIndexAll == 1;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);

Sess4_16_Part1_Inds = SessIndexAll == 2;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%
NumPaths = length(Sess4_16_Part1_PathAll);
FieldChangeDataAll = cell(NumPaths,6);
FieldChangePos816 = cell(NumPaths,2);
IndexedFieldChange = cell(NumPaths,4);
OctIndexFieldChange = cell(NumPaths,2);
for cPath = 1 : NumPaths
    c832Path = Sess8_32PathAll{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    
    cSess832Path = fullfile(c832Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess832TunData = load(cSess832Path);
    cSess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    cSess832ToneBound = cSess832BehavStrc.boundary_result.Boundary;
    cSess832StimOct = log2(cSess832BehavStrc.boundary_result.StimType/min(cSess832BehavStrc.boundary_result.StimType));
    NearBoundInds = abs(cSess832StimOct - cSess832ToneBound) <= 0.4;
    
    cSess416Path = fullfile(c416Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416TunData = load(cSess416Path);
    cSess416BehavStrc = load(fullfile(c416Path,'RandP_data_plots','boundary_result.mat'));
    cSess416ToneBound = cSess416BehavStrc.boundary_result.Boundary;
    cSess416StimOct = log2(cSess416BehavStrc.boundary_result.StimType/min(cSess416BehavStrc.boundary_result.StimType));
    cSess416NearBoundInds = abs(cSess416StimOct - cSess416ToneBound) <= 0.4;
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416ROIIndexFile = fullfile(c416Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    cSess832DataStrc = load(Sess832ROIIndexFile);
    cSess416DataStrc = load(Sess416ROIIndexFile);
    
    CommonROINum = min(numel(cSess832DataStrc.ROIIndex),numel(cSess416DataStrc.ROIIndex));
    CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum) & cSess416DataStrc.ROIIndex(1:CommonROINum);
    
    % response field change analysis
    cd(c832Path);
    c832BoundIndex = cSess832ToneBound/max(cSess832StimOct)*(numel(cSess832StimOct) - 1) + 1;
    [FieldChange,FieldChangeWithIndex832,c832TPCoefDiff,FieldChangeMtx] = TuningfieldChangeFun(c832Path,numel(cSess832DataStrc.ROIIndex),CommonROIIndex,c832BoundIndex);
    NearFieldChangeAll = cell2mat((FieldChange(NearBoundInds))');
    FarFieldChangeAll = cell2mat((FieldChange(~NearBoundInds))');
    FieldChangeDataAll{cPath,1} = NearFieldChangeAll;
    FieldChangeDataAll{cPath,2} = FarFieldChangeAll;
    NoChangeNearInds = abs(cSess832StimOct(c832TPCoefDiff(:,3)) - cSess832ToneBound) <= 0.4;
    FieldChangeDataAll{cPath,5} = [c832TPCoefDiff,NoChangeNearInds(:)];
    FieldChange(:,4) = mat2cell(cSess832StimOct(:) - 1,ones(numel(cSess832StimOct),1));
    OctIndexFieldChange{cPath,1} = FieldChange;
    
    FieldChangeOctDis = abs(cSess832StimOct(FieldChangeWithIndex832(:,2)) - cSess832ToneBound);
    FieldChangePos816{cPath,1} = [FieldChangeWithIndex832(:,1),FieldChangeOctDis(:)];
    IndexedFieldChange{cPath,1} = FieldChangeMtx;
    IndexedFieldChange{cPath,2} = cSess832BehavStrc.boundary_result.StimCorr;
    
    
     % response field change analysis
    cd(c416Path);
    c416BoundIndex = cSess416ToneBound/max(cSess416StimOct)*(numel(cSess416StimOct) - 1) + 1;
    [FieldChange416, FieldChangeWithIndex416, c416TPCoefDiff,FieldChangeMtx416] = TuningfieldChangeFun(c416Path,numel(cSess416DataStrc.ROIIndex),CommonROIIndex,c416BoundIndex);
    NearFieldChangeAll416 = cell2mat((FieldChange416(cSess416NearBoundInds))');
    FarFieldChangeAll416 = cell2mat((FieldChange416(~cSess416NearBoundInds))');
    FieldChangeDataAll{cPath,3} = NearFieldChangeAll416;
    FieldChangeDataAll{cPath,4} = FarFieldChangeAll416;
    NoChangeNearInds416 = abs(cSess416StimOct(c416TPCoefDiff(:,3)) - cSess416ToneBound) <= 0.4;
    FieldChangeDataAll{cPath,6} = [c416TPCoefDiff,NoChangeNearInds416(:)];
    
    FieldChangeOctDis416 = abs(cSess416StimOct(FieldChangeWithIndex416(:,2)) - cSess416ToneBound);
    FieldChangePos816{cPath,2} = [FieldChangeWithIndex416(:,1),FieldChangeOctDis416(:)];
    IndexedFieldChange{cPath,3} = FieldChangeMtx416;
    IndexedFieldChange{cPath,4} = cSess416BehavStrc.boundary_result.StimCorr;
    FieldChange416(:,4) = mat2cell(cSess416StimOct(:) - 1,ones(numel(cSess416StimOct),1));
    OctIndexFieldChange{cPath,2} = FieldChange416;
end

%% 
c832NearFieldAll = cell2mat(FieldChangeDataAll(:,1));
c832FarFieldAll = cell2mat(FieldChangeDataAll(:,2));

c416NearFieldAll = cell2mat(FieldChangeDataAll(:,3));
c416FarFieldAll = cell2mat(FieldChangeDataAll(:,4));

c832NearFieldChangedInds = c832NearFieldAll ~= 0;
c832NearFieldChangedData = c832NearFieldAll(c832NearFieldChangedInds);
c832FarFieldCInds = c832FarFieldAll ~= 0;
c832FarFieldCData = c832FarFieldAll(c832FarFieldCInds);

c416NearFieldCInds = c416NearFieldAll ~= 0;
c416NearFieldCData = c416NearFieldAll(c416NearFieldCInds);

c416FarFieldCInds = c416FarFieldAll ~= 0;
c416FarFieldCData = c416FarFieldAll(c416FarFieldCInds);

%%
IndexedFieldChangeBU = IndexedFieldChange;
IDFields = cellfun(@(x) Six2eightFun(x.RespFieldMtx),IndexedFieldChange(:,1),'UniformOutput',false);
IDFieldsmask = cellfun(@(x) Six2eightFun(x.RespFieldMask),IndexedFieldChange(:,1),'UniformOutput',false);
PassRespAlls = cellfun(@(x) Six2eightFun(x.PassRespField),IndexedFieldChange(:,1),'UniformOutput',false);
for css = 1 : length(IDFields)
    cssBehav = IndexedFieldChange{css,2};
    if length(cssBehav) == 6
        NewcssBehav = nan(1,8);
        NewcssBehav(1:3) = cssBehav(1:3);
        NewcssBehav(6:8) = cssBehav(4:6);
    else
        NewcssBehav = cssBehav;
    end
    IndexedFieldChange{css,2} = NewcssBehav;
end
SessBehavsMtx = cell2mat(IndexedFieldChange(:,2));
%
IDFieldsMtx = cell2mat(IDFields);
IDFieldsMaskMtx = cell2mat(IDFieldsmask);

IndexTypesAll = size(IDFieldsMtx,2);
for cInds = 1 : IndexTypesAll
    cIndsMasks = IDFieldsMaskMtx(:,cInds);
    cIndsMtx = IDFieldsMtx(:,cInds);
    
    cIndsRealMtx = cIndsMtx(cIndsMasks);
    cIndsRealMtxPos = binofit(sum(cIndsRealMtx == 1),numel(cIndsRealMtx));
    
    IndexTypesAll(cInds) = cIndsRealMtxPos;
end
figure;
plot(mean(SessBehavsMtx,'omitnan'));
yyaxis right
plot(IndexTypesAll)

PassRespAllMtx = cell2mat(PassRespAlls);
PassRespInds = sum(PassRespAllMtx,2,'omitnan') > 0;
PassRespSigMtx = PassRespAllMtx(PassRespInds,:);
figure;
plot(mean(PassRespSigMtx > 0))

%% calculate the octive distance and filed change
c832FieldChange_pos_All = cell2mat(FieldChangePos816(:,1));
DecreaseFieldInds = c832FieldChange_pos_All(:,1) == -1;
DecreaseFieldDis = c832FieldChange_pos_All(DecreaseFieldInds,2);
[DecreaseFieldDisy,DecreaseFieldDisx] = hist(DecreaseFieldDis,15);

NoChangeDis = c832FieldChange_pos_All(c832FieldChange_pos_All(:,1) == 0,2);
[NoChangeDisy,NoChangeDisx] = hist(NoChangeDis,15);

IncreaseFieldDis = c832FieldChange_pos_All(c832FieldChange_pos_All(:,1) == 1,2);
[IncreaseFieldDisy,IncreaseFieldDisx] = hist(IncreaseFieldDis,15);

hf = figure('position',[100 100 380 300]);
hold on
hl1 = plot(DecreaseFieldDisx,DecreaseFieldDisy/numel(DecreaseFieldDis),'Color',[0.2 0.2 0.8],'linewidth',2);
hl2 = plot(NoChangeDisx,NoChangeDisy/numel(NoChangeDis),'Color',[0.4 0.4 0.4],'linewidth',2);
hl3 = plot(IncreaseFieldDisx,IncreaseFieldDisy/numel(IncreaseFieldDis),'Color',[0.8 0.2 0.2],'linewidth',2);



%% processing for the 7-28 and 4-16 session
Sess7_28_Inds = SessIndexAll == 4;
Sess7_28PathAll = SessPathAll(Sess7_28_Inds,1);

Sess4_16_Part2_Inds = SessIndexAll == 3;
Sess4_16_Part2_PathAll = SessPathAll(Sess4_16_Part2_Inds,1);

if length(Sess4_16_Part2_PathAll) ~= length(Sess7_28PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%
NumPaths = length(Sess4_16_Part2_PathAll);
FieldChangeDataAll716 = cell(NumPaths,6);
FieldChangePos = cell(NumPaths,2);
for cPath = 1 : NumPaths
    c728Path = Sess7_28PathAll{cPath};
    c416_2Path = Sess4_16_Part2_PathAll{cPath};
    
    cSess728Path = fullfile(c728Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess728TunData = load(cSess728Path);
    cSess728BehavStrc = load(fullfile(c728Path,'RandP_data_plots','boundary_result.mat'));
    cSess728ToneBound = cSess728BehavStrc.boundary_result.Boundary;
    cSess728StimOct = log2(cSess728BehavStrc.boundary_result.StimType/min(cSess728BehavStrc.boundary_result.StimType));
    NearBoundInds728 = abs(cSess728StimOct - cSess728ToneBound) <= 0.4;
    
    cSess416_2Path = fullfile(c416_2Path,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','TaskPassBFDis.mat');
    cSess416_2TunData = load(cSess416_2Path);
    cSess416_2BehavStrc = load(fullfile(c416_2Path,'RandP_data_plots','boundary_result.mat'));
    cSess416_2ToneBound = cSess416_2BehavStrc.boundary_result.Boundary;
    cSess416_2StimOct = log2(cSess416_2BehavStrc.boundary_result.StimType/min(cSess416_2BehavStrc.boundary_result.StimType));
    cSess416_2NearBoundInds = abs(cSess416_2StimOct - cSess416_2ToneBound) <= 0.4;
    
    
    Sess728ROIIndexFile = fullfile(c728Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess416_2ROIIndexFile = fullfile(c416_2Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    
    cSess728DataStrc = load(Sess728ROIIndexFile);
    cSess416_2DataStrc = load(Sess416_2ROIIndexFile);
    
    CommonROINum = min(numel(cSess728DataStrc.ROIIndex),numel(cSess416_2DataStrc.ROIIndex));
    CommonROIIndex = cSess728DataStrc.ROIIndex(1:CommonROINum) & cSess416_2DataStrc.ROIIndex(1:CommonROINum);
    
    % analysis field changes 
    cd(c728Path);
    c728BoundIndex = cSess728ToneBound/max(cSess728StimOct)*(numel(cSess728StimOct) - 1) + 1;
    [FieldChange,FieldChangeWithIndex,c728TPCoefDiff] = TuningfieldChangeFun(c728Path,numel(cSess728DataStrc.ROIIndex),CommonROIIndex,c728BoundIndex);
    NearFieldChangeAll728 = cell2mat((FieldChange(NearBoundInds728))');
    FarFieldChangeAll728 = cell2mat((FieldChange(~NearBoundInds728))');
    FieldChangeDataAll716{cPath,1} = NearFieldChangeAll728;
    FieldChangeDataAll716{cPath,2} = FarFieldChangeAll728;
    NoChangeNearInds728 = abs(cSess728StimOct(c728TPCoefDiff(:,3)) - cSess728ToneBound) <= 0.4;
    FieldChangeDataAll716{cPath,5} = [c728TPCoefDiff,NoChangeNearInds728(:)];
    
    FieldChangeOcts = abs(cSess728StimOct(FieldChangeWithIndex(:,2)) - cSess728ToneBound);
    FieldChangePos{cPath,1} = [FieldChangeWithIndex(:,1),FieldChangeOcts(:)];
    
    
     % analysis field changes 
    cd(c416_2Path);
    c416_2BoundIndex = cSess416_2ToneBound/max(cSess416_2StimOct)*(numel(cSess416_2StimOct) - 1) + 1;
    [FieldChange416_2,FieldChangeWithIndex416_2,c416_2TPCoefDiff] = TuningfieldChangeFun(c416_2Path,numel(cSess416_2DataStrc.ROIIndex),CommonROIIndex,c416_2BoundIndex);
    NearFieldChangeAll416_2 = cell2mat((FieldChange416_2(cSess416_2NearBoundInds))');
    FarFieldChangeAll416_2 = cell2mat((FieldChange416_2(~cSess416_2NearBoundInds))');
    FieldChangeDataAll716{cPath,3} = NearFieldChangeAll416_2;
    FieldChangeDataAll716{cPath,4} = FarFieldChangeAll416_2;
    NoChangeNearInds416_2 = abs(cSess416_2StimOct(c416_2TPCoefDiff(:,3)) - cSess416_2ToneBound) <= 0.4;
    FieldChangeDataAll716{cPath,6} = [c416_2TPCoefDiff,NoChangeNearInds416_2(:)];
    
    FieldChangeOcts416_2 = abs(cSess416_2StimOct(FieldChangeWithIndex416_2(:,2)) - cSess416_2ToneBound);
    FieldChangePos{cPath,2} = [FieldChangeWithIndex416_2(:,1),FieldChangeOcts416_2(:)];
    
end

%%
c728NearFieldAll = cell2mat(FieldChangeDataAll716(:,1));
c728FarFieldAll = cell2mat(FieldChangeDataAll716(:,2));

c416_2NearFieldAll = cell2mat(FieldChangeDataAll716(:,3));
c416_2FarFieldAll = cell2mat(FieldChangeDataAll716(:,4));

[~,p] = ttest2(c416_2NearFieldAll(c416_2NearFieldAll~=0),c416_2FarFieldAll(c416_2FarFieldAll~=0))
[~,p] = ttest2(c728NearFieldAll(c728NearFieldAll~=0),c728FarFieldAll(c728FarFieldAll~=0))

