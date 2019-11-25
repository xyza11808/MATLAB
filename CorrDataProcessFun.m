function FieldCoefDataAlls = CorrDataProcessFun(AnmPath)
% load All realated datas
AllFieldData_Strc = load(fullfile(AnmPath,'AllFieldDatasNew.mat'));
AllFieldData_cell = AllFieldData_Strc.FieldDatas_AllCell;
FieldNum = size(AllFieldData_cell,1);

FieldCoefDataAlls = cell(FieldNum,2,4);
for cfield = 1 : FieldNum
    cfName = AllFieldData_cell{cfield,2};
    cFieldROIInfo_strc = load(fullfile(AnmPath,cfName,'CorrCoefDataNew.mat'),'ROIdataStrc');
    cFieldCoefs = AllFieldData_cell{cfield,6}(:,1);
    cFieldDis = AllFieldData_cell{cfield,6}(:,2)*0.718;
    AstROIInds = arrayfun(@(x) strcmpi(x.ROItype,'Ast'),cFieldROIInfo_strc.ROIdataStrc.ROIInfoDatas);
    cFCoefMtx = squareform(cFieldCoefs);
    cFDisMtx = squareform(cFieldDis);
    WithEventROIInds = ~cellfun(@isempty, AllFieldData_cell{cfield,5});
    ActiveAstInds = WithEventROIInds(:) & AstROIInds(:);
    NeuronInds = ~AstROIInds;
    ActiveNeuInds = NeuronInds(:) & WithEventROIInds(:);
    
    % Active Ast with All Neuron coefs
    if sum(ActiveAstInds)
        ActAst_AllNeu_coefs = cFCoefMtx(ActiveAstInds,NeuronInds);
        ActAst_AllNeu_Dis = cFDisMtx(ActiveAstInds,NeuronInds);
        
        ActAst_ActNeu_coefs = cFCoefMtx(ActiveAstInds,ActiveNeuInds);
        ActAst_ActNeu_Dis = cFDisMtx(ActiveAstInds,ActiveNeuInds);
        
        NeuroCoefMtx = cFCoefMtx(NeuronInds,NeuronInds);
        NeuroDissMtx = cFDisMtx(NeuronInds,NeuronInds);
        MtxMask = logical(tril(ones(size(NeuroCoefMtx)),-1));
        NeuroCoefVec = NeuroCoefMtx(MtxMask);
        NeuroDissVec = NeuroDissMtx(MtxMask);
    else
        ActAst_AllNeu_coefs = [];
        ActAst_AllNeu_Dis = [];
        
        ActAst_ActNeu_coefs = [];
        ActAst_ActNeu_Dis = [];
        
        NeuroCoefVec = [];
        NeuroDissVec = [];
    end
    
    FieldCoefDataAlls(cfield,1,1:4) = {cFieldCoefs,ActAst_AllNeu_coefs(:),...
        ActAst_ActNeu_coefs(:),NeuroCoefVec};
    FieldCoefDataAlls(cfield,2,1:4) = {cFieldDis,ActAst_AllNeu_Dis(:),...
        ActAst_ActNeu_Dis(:),NeuroDissVec};
end
        

