
if ismac
    GrandPath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
elseif ispc
    GrandPath = 'T:\batch\batch70\20200528\anm04';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
end
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);
PossibleInds = cellfun(@(x) strcmpi(x(end-10:end),'result_save'),nameSplit);
PossDataPath = nameSplit(PossibleInds);

TargetMatFile_Inds = cellfun(@(x) ~isempty(dir(fullfile(x, 'CaTrials*.mat'))),PossDataPath);
TargetMatFilePath = PossDataPath(TargetMatFile_Inds);
NumTargPath = length(TargetMatFilePath);


%%
warning off
for cPath = 1 : NumTargPath
    cd(TargetMatFilePath{cPath});
    CPath_matpath = dir('*.mat');
    
    clearvars SavedCaTrials
    load(CPath_matpath(1).name);
    
    ROIRawDatas = cell2mat(SavedCaTrials.f_raw');
    FrameNums = cellfun(@(x) size(x,2),SavedCaTrials.f_raw);
    FrameNums(end) = FrameNums(end) - 10;
    ROINPDatas = cell2mat(SavedCaTrials.RingF');
    ROIRawDatas(:, end-9:end) = [];
    ROINPDatas(:, end-9:end) = [];
    ROIBases = prctile(ROIRawDatas',15);

    BaseMtx = repmat(ROIBases',1,size(ROIRawDatas,2));
    DffMtx = (ROIRawDatas - BaseMtx) ./ BaseMtx;

    ROINPDatas_Base = repmat((prctile(ROINPDatas',15))',1,size(ROIRawDatas,2));

    RingSub_data = ROIRawDatas - ROINPDatas*0.7 + ROINPDatas_Base * 0.7;
    RingSub_Base = prctile(RingSub_data',15);
    RingSub_BaseMtx = repmat(RingSub_Base',1,size(ROIRawDatas,2));
    Dff_RingSub_Mtx = (RingSub_data - RingSub_BaseMtx ) ./ RingSub_BaseMtx;

    %
    NumROIs = size(Dff_RingSub_Mtx,1);
    MoveFreeDataMtx = zeros(size(Dff_RingSub_Mtx));
    for cR = 1 : NumROIs
        RawTrace = Dff_RingSub_Mtx(cR,:);
        [MoveFreetrace, MoveInds, ResidueSTD] =  PossibleMoveArtifactRemoveFun(RawTrace);
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        NumFindPeaks = size(MoveInds,1);
        Possi_FP_Arts = zeros(NumFindPeaks, 1);
        NewMoveFreeTrace = MoveFreetrace;
        for cP = 1 : NumFindPeaks
            cP_EndPointData = RawTrace([min(MoveInds{cP,1}),max(MoveInds{cP,1})]);
            cP_rawData = RawTrace(MoveInds{cP,1});
            if (diff(cP_EndPointData)) > ResidueSTD * 4 && ((min(cP_EndPointData) - min(cP_rawData)) < ResidueSTD*2)
                Possi_FP_Arts(cP) = 1;
                cFP_Inds_scale = MoveInds{cP,1};
                NewMoveFreeTrace(cFP_Inds_scale) = RawTrace(cFP_Inds_scale);
    %             plot(MoveInds{cP,1}, RawTrace(MoveInds{cP,1}),'r');
            end
        end
        [MoveFreeBaseAdj,~]=BLSubStract(NewMoveFreeTrace',8,800);
        [MoveFreetrace2, MoveInds2, ResidueSTD2] =  PossibleMoveArtifactRemoveFun(MoveFreeBaseAdj);
    %     figure('position',[1920 80 1750 420]);
    %     hold on
    %     plot(MoveFreeBaseAdj,'k')
    %     plot(MoveFreetrace2,'r')
    
        % correct for the sharp increase peak again
        NumFindPeaks = size(MoveInds2,1);
        Possi_FP_Arts = zeros(NumFindPeaks, 1);
        NewMoveFreeTrace2 = MoveFreetrace2;
        for cP = 1 : NumFindPeaks
            cP_EndPointData = MoveFreeBaseAdj([min(MoveInds2{cP,1}),max(MoveInds2{cP,1})]);
            cP_rawData = RawTrace(MoveInds2{cP,1});
            if (diff(cP_EndPointData)) > ResidueSTD2 * 4 && ((min(cP_EndPointData) - min(cP_rawData)) < ResidueSTD2*2)
                Possi_FP_Arts(cP) = 1;
                cFP_Inds_scale = MoveInds2{cP,1};
                NewMoveFreeTrace2(cFP_Inds_scale) = MoveFreeBaseAdj(cFP_Inds_scale);
    %             plot(MoveInds2{cP,1}, MoveFreeBaseAdj(MoveInds2{cP,1}),'c');
            end
        end
        MoveFreeDataMtx(cR,:) = NewMoveFreeTrace2;
    end
    
    save dffMatfile.mat MoveFreeDataMtx FrameNums -v7.3
end
warning on