function FieldCoefDataAlls = CorrDataProcessFun(AnmPath,varargin)
MatfileName = 'AllFieldDatasNew.mat';
if nargin > 1
    if ~isempty(varargin{1})
        MatfileName = varargin{1};
    end
end
CorrCoefData = 'CorrCoefDataNew.mat';
if nargin > 2
    if ~isempty(varargin{2})
        CorrCoefData = varargin{2};
    end
end
% load All realated datas
AllFieldData_Strc = load(fullfile(AnmPath,MatfileName));
AllFieldData_cell = AllFieldData_Strc.FieldDatas_AllCell;
FieldNum = size(AllFieldData_cell,1);

FieldCoefDataAlls = cell(FieldNum,2,7);
for cfield = 1 : FieldNum
    cfName = AllFieldData_cell{cfield,2};
    cFieldROIInfo_strc = load(fullfile(AnmPath,cfName,CorrCoefData),'ROIdataStrc');
%     FrameIndexStrc = load(fullfile(AnmPath,cfName,CorrCoefData),'FieldImageFrameNum'); % load the frame index file for each session
    cFieldCoefs = AllFieldData_cell{cfield,6}(:,1);
    cFieldDis = AllFieldData_cell{cfield,6}(:,2)*0.718;
    AstROIInds = arrayfun(@(x) strcmpi(x.ROItype,'Ast'),cFieldROIInfo_strc.ROIdataStrc.ROIInfoDatas);
    cFCoefMtx = squareform(cFieldCoefs);
    cFDisMtx = squareform(cFieldDis);
    WithEventROIInds = ~cellfun(@isempty, AllFieldData_cell{cfield,5});
    ActiveAstInds = WithEventROIInds(:) & AstROIInds(:);
    NeuronInds = ~AstROIInds;
    ActiveNeuInds = NeuronInds(:) & WithEventROIInds(:);
    
    % calculate the coef between Ast and neuron
    if sum(AstROIInds)
        Ast_AllNeu_coefs = cFCoefMtx(AstROIInds,NeuronInds);
        Ast_AllNeu_Dis = cFDisMtx(AstROIInds,NeuronInds);
        
        Ast_Ast_coefs = cFCoefMtx(AstROIInds,AstROIInds);
        Ast_Ast_Dis = cFDisMtx(AstROIInds,AstROIInds);
        c1Mask = logical(tril(ones(size(Ast_Ast_coefs)),-1));
        Ast_Ast_coefsVec = Ast_Ast_coefs(c1Mask);
        Ast_Ast_DisVec = Ast_Ast_Dis(c1Mask);
        
        Neu_Neu_coefs = cFCoefMtx(NeuronInds,NeuronInds);
        Neu_Neu_Dis = cFDisMtx(NeuronInds,NeuronInds);
        c2Mask = logical(tril(ones(size(Neu_Neu_coefs)),-1));
        Neu_Neu_coefsVec = Neu_Neu_coefs(c2Mask);
        Neu_Neu_DisVec = Neu_Neu_Dis(c2Mask);
    else
        Ast_AllNeu_coefs = [];
        Ast_AllNeu_Dis = [];
        
        Ast_Ast_coefsVec = [];
        Ast_Ast_DisVec = [];
        
        Neu_Neu_coefsVec = [];
        Neu_Neu_DisVec = [];
    end
    
    % Active Ast with All Neuron coefs
    if sum(ActiveAstInds)
        
        ActAst_ActNeu_coefs = cFCoefMtx(ActiveAstInds,ActiveNeuInds);
        ActAst_ActNeu_Dis = cFDisMtx(ActiveAstInds,ActiveNeuInds);
        
        ActAst_Ast_coefs = cFCoefMtx(ActiveAstInds,ActiveAstInds);
        ActAst_Ast_Dis = cFDisMtx(ActiveAstInds,ActiveAstInds);
        MtxMask = logical(tril(ones(size(ActAst_Ast_coefs)),-1));
        ActAst_AstCoefVec = ActAst_Ast_coefs(MtxMask);
        ActAst_AstDissVec = ActAst_Ast_Dis(MtxMask);
        
        %Active Neu between coefs
        ActNeuCoefMtxs = cFCoefMtx(ActiveNeuInds,ActiveNeuInds);
        ActNeuDisMtxs = cFDisMtx(ActiveNeuInds,ActiveNeuInds);
        ActNeuMask = logical(tril(ones(size(ActNeuCoefMtxs)),-1));
        ActNeuroCoefVec = ActNeuCoefMtxs(ActNeuMask);
        ActNeuroDissVec = ActNeuDisMtxs(ActNeuMask);
    else
        ActAst_AstCoefVec = [];
        ActAst_AstDissVec = [];
        
        ActAst_ActNeu_coefs = [];
        ActAst_ActNeu_Dis = [];
        
        
        ActNeuroCoefVec = [];
        ActNeuroDissVec = [];
    end
    
    FieldCoefDataAlls(cfield,1,1:7) = {cFieldCoefs,Ast_AllNeu_coefs,Ast_Ast_coefsVec,Neu_Neu_coefsVec,...
        ActAst_ActNeu_coefs,ActAst_AstCoefVec,ActNeuroCoefVec};
    FieldCoefDataAlls(cfield,2,1:7) = {cFieldDis,Ast_AllNeu_Dis,Ast_Ast_DisVec,Neu_Neu_DisVec,...
        ActAst_ActNeu_Dis,ActAst_AstDissVec,ActNeuroDissVec};
end