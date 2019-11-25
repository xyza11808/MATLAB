function FieldDatas_AllCell = IsFieldDataPath_LOADMAT(InputPath)
% check whether input data path have field data path
% Inputfolder = 0;
FieldDatas_AllCell = {};
if ~isfolder(InputPath)
    return;
end
cFolderFiles = dir(fullfile(InputPath,'*2019*'));
if isempty(cFolderFiles)
   return;
else
    WhetherFolders = arrayfun(@(x) x.isdir,cFolderFiles);
    FolderPaths = cFolderFiles(WhetherFolders > 0);
    if isempty(FolderPaths)
        return;
    else
        
        fieldFoldInds = arrayfun(@(x) contains(x.name,'field','IgnoreCase',true) & ...
            contains(x.name,'sess','IgnoreCase',true),FolderPaths);
        fieldFoldNames = arrayfun(@(x) x.name,FolderPaths(fieldFoldInds),'UniformOutput',false);
        fileFolderFullpath = arrayfun(@(x) fullfile(x.folder,x.name),FolderPaths(fieldFoldInds),...
            'UniformOutput',false);
        %
        cUpfoldFieldIndex = FieldSessIndexFun(fieldFoldNames,'field');
        cUpfoldExpIndex = FieldSessIndexFun(fieldFoldNames,'index');
        FieldTypes = unique(cUpfoldFieldIndex);
        %
        NumFields = length(FieldTypes);
        FieldDatas_AllCell = cell(NumFields,6);
        for cf_field = 1 : NumFields
            try
                %%
                FieldDataPath = fullfile(InputPath,sprintf('field%02d',cf_field));
%                 if exist(fullfile(FieldDataPath,'CorrCoefDataNew.mat'),'file') > 0
%                     continue;
%                 end
                
                cf_field_Inds = cUpfoldFieldIndex == FieldTypes(cf_field);
                cField_Index_Nums = cUpfoldExpIndex(cf_field_Inds);
                cField_FullPaths = fileFolderFullpath(cf_field_Inds);
                [~,C_Field_final_Index_Inds] = max(cField_Index_Nums);
                FullROIInfoDatas = fullfile(cField_FullPaths{C_Field_final_Index_Inds},...
                    'Aligned_datas','ROIinfoData.mat');
                ROIdataStrc = load(FullROIInfoDatas);
                ROICenterPos = (arrayfun(@(x) mean(x.ROIpos), ROIdataStrc.ROIInfoDatas, 'UniformOutput', false))';
                ROICenterPosMtx = cell2mat(ROICenterPos);
                ROIdis_mtx = squareform(pdist(ROICenterPosMtx));

                C_Field_ExpNumbers = length(cField_Index_Nums);
                MoveFreeTraceRaw_All = cell(1,C_Field_ExpNumbers);
                for cFieldSess = 1 : C_Field_ExpNumbers
                    cMoveFreeMatFile_path = fullfile(cField_FullPaths{cFieldSess},...
                        'Aligned_datas','RawROIDatas.mat');
                    cMoveFreeMatData = load(cMoveFreeMatFile_path);
                    MoveFreeTraceRaw_All{cFieldSess} = cMoveFreeMatData.MoveFreeTrace(:,101:end);
                    
                end
                FieldDatas_AllCell{cf_field,2} = sprintf('field%02d',cf_field);
                FieldDatas_AllCell{cf_field,3} =  cField_FullPaths;
                FieldDatas_AllCell{cf_field,4} =  InputPath;

                MoveFreeTraceRaw_Mtx = cell2mat(MoveFreeTraceRaw_All);
                MoveFreePrcBaseData = repmat((prctile(MoveFreeTraceRaw_Mtx',8))',1,size(MoveFreeTraceRaw_Mtx,2));
                MoveFreedff_All_Mtx = (MoveFreeTraceRaw_Mtx - MoveFreePrcBaseData)./...
                    MoveFreePrcBaseData;
%                 nROIs = size(MoveFreedff_All_Mtx,1);
                SessFrameNum = cellfun(@(x) size(x,2),MoveFreeTraceRaw_All);
                SessNum = length(SessFrameNum);
                SessBase = 0;
                AdJustMoveFreeData_All_mtx = zeros(size(MoveFreedff_All_Mtx));
                for cSess = 1 : SessNum
                    cSessInds = (SessBase+1):(SessFrameNum(cSess)+SessBase);
                    cSessDatas = MoveFreedff_All_Mtx(:,cSessInds);
                    cSess_baselinedata = repmat((prctile(cSessDatas',15))',1,SessFrameNum(cSess));
                    AdJustMoveFreeData_All_mtx(:,cSessInds) = cSessDatas - cSess_baselinedata;
                    SessBase = SessBase + SessFrameNum(cSess);
                end
                %
                
                FieldDatas_AllCell{cf_field,1} = AdJustMoveFreeData_All_mtx;
                
                
                % calculate the correlation and events detection
                
                
                if ~isdir(FieldDataPath)
                    mkdir(FieldDataPath);
                end
                cd(FieldDataPath);
                
                % performing events detection for current sessions
                % using function for events detection
                FilterOpsAll.Type = 'bandpassfir';
                FilterOpsAll.Fr = 31;
                FilterOpsAll.PassBand2 = 1;
                FilterOpsAll.StopBand2 = 3;
                FilterOpsAll.PassBand1 = 0.005;
                FilterOpsAll.StopBand1 = 0.001;
                FilterOpsAll.StopAttenu1 = 60;
                FilterOpsAll.StopAttenu2 = 60;
                FilterOpsAll.DesignMethod = 'kaiserwin';
                FilterOpsAll.IsPlot = 0;

                % events detection parameters
                EventParas.NoiseMethod = 'Res_std';
                EventParas.PeakThres = 1;
                EventParas.BaselinePrc = 18;
                EventParas.MinHalfPeakWid = 1.5; % seconds
                EventParas.OnsetThres = 1;
                EventParas.OffsetThres = 1;
                EventParas.IsPlot = 1;
                EventParas.ABSPeakValue = 0.2;
                %
                nROIs = size(AdJustMoveFreeData_All_mtx,1);
                if ~isdir('./ROI_events_plot/')
                    mkdir('./ROI_events_plot/');
                end
                cd('./ROI_events_plot/');
                %
                EventsIndsAllROI = cell(nROIs,1);
                for cROI = 1 : nROIs
                    cROITrace = AdJustMoveFreeData_All_mtx(cROI,:);
                    [~,EventIndex,ROIPlots] = TraceEventDetect(cROITrace,FilterOpsAll,EventParas);
                    EventsIndsAllROI{cROI} = EventIndex;
                    if ishandle(ROIPlots{2})
                        title(num2str(cROI,'ROI%d'));
                        ffName = sprintf('ROI%d event Trace plots',cROI);
                        saveas(ROIPlots{2},ffName);
                        saveas(ROIPlots{2},ffName,'png');
                        close(ROIPlots{2});
                    end
                end
                %
                cd ..;
                FieldDatas_AllCell{cf_field,5} = EventsIndsAllROI;
                % correlation analysis
                
                CorrCoefMtx = corrcoef(AdJustMoveFreeData_All_mtx');
                CuroffValues = [0.8,1,1.2,1.4];
                NumCutoffs = length(CuroffValues);

                zz = linkage(CorrCoefMtx,'complete','correlation');
                for c_Cut = 1 : NumCutoffs
                    groups = cluster(zz,'cutoff',CuroffValues(c_Cut),'criterion','distance');
                    Gr_Types = unique(groups);
                    GrNum = zeros(length(Gr_Types),1);
                    for cGr = 1 : length(Gr_Types)
                        GrNum(cGr) = sum(groups == Gr_Types(cGr));
                    end
                    UsedGrNums = cumsum([1;GrNum]);
                    [~,SortInds] = sort(groups);
                    hf = figure('position',[100 100 420 350]);
                    imagesc(CorrCoefMtx(SortInds,SortInds),[-0.2 0.8]);
                    set(gca,'box','off');
                    colorbar('northoutside');
                    set(gca,'xtick',UsedGrNums,'ytick',UsedGrNums);
                    xlabel(sprintf('Group Number %d',length(Gr_Types)));

                    saveas(hf,sprintf('Cutoff value %02d correlation mtx plot New',CuroffValues(c_Cut)*10));
                    saveas(hf,sprintf('Cutoff value %02d correlation mtx plot New',CuroffValues(c_Cut)*10),'png');
                    close(hf);
                end
                nROIs = size(CorrCoefMtx,1);
                ROI_Dis_coef_mask = logical(tril(ones(nROIs),-1));
                ROI_Dis_coefData = [CorrCoefMtx(ROI_Dis_coef_mask),ROIdis_mtx(ROI_Dis_coef_mask)];
                FieldDatas_AllCell{cf_field,6} = ROI_Dis_coefData;
                BincentANDdatas = DisANDCoefplot(ROI_Dis_coefData(:,1),ROI_Dis_coefData(:,2),[]);
                BinCenters = BincentANDdatas{2};
                BinCoefDataAll = BincentANDdatas{1};
                BinCoefDataAvg = cellfun(@mean,BinCoefDataAll);
                BinCoefDataSem = cellfun(@(x) std(x)/sqrt(numel(x)),BinCoefDataAll);
                hhf = figure('position',[100 100 420 320]);
                hold on
                plot(ROI_Dis_coefData(:,2),ROI_Dis_coefData(:,1),'o','MarkerSize',6,...
                    'MarkerEdgeColor','none','MarkerFaceColor',[.7 .7 .7]);
                errorbar(BinCenters,BinCoefDataAvg,BinCoefDataSem,'Color','k',...
                    'linewidth',1.2);
                set(gca,'xtick',0:100:max(ROI_Dis_coefData(:,2)));
                %
                saveas(hhf,'Coef vs Distance plots save New');
                saveas(hhf,'Coef vs Distance plots save New','png');
                close(hhf);

                save CorrCoefDataNew_0921.mat CorrCoefMtx ROICenterPosMtx ROIdis_mtx ROI_Dis_coefData BincentANDdatas ROIdataStrc -v7.3
                %%
            catch ME
                fprintf('Adjust Error for session:\n %s\nField %02d\n',InputPath,cf_field);
                warning(ME.message);
            end
        end
        %
    end
end
                
save(fullfile(InputPath,'AllFieldDatasNew_1115.mat'),'FieldDatas_AllCell','-v7.3');         

