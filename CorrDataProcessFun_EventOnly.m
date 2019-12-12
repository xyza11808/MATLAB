function [FieldCoefDataAlls,SessSynchronyIndex_All] = CorrDataProcessFun_EventOnly(AnmPath,varargin)
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

% FrameIndexStrc = load(fullfile(AnmPath,'FieldImageFrameNum.mat'),'FieldImageFrameNum'); % load the frame index file for each session
FieldEventOnlyDatas = EventOnlyTrace_fun(AnmPath,MatfileName);

FieldCoefDataAlls = cell(FieldNum,2,7);
SessSynchronyIndex_All = cell(FieldNum,5);
for cfield = 1 : FieldNum
    cfName = AllFieldData_cell{cfield,2};
    cFieldROIInfo_strc = load(fullfile(AnmPath,cfName,CorrCoefData),'ROIdataStrc');
    
    cField_eventOnly_data = FieldEventOnlyDatas{cfield};
    cFCoefMtx = corrcoef(cField_eventOnly_data');
    cFieldCoefs = cFCoefMtx(logical(tril(ones(size(cFCoefMtx)),-1)));
%     cFieldCoefs = AllFieldData_cell{cfield,6}(:,1);
    SessSeqSynchronyIndex = Popu_synchrony_fun(cField_eventOnly_data);
    SessSynchronyIndex_All{cfield,1} = SessSeqSynchronyIndex;
    cFieldDis = AllFieldData_cell{cfield,6}(:,2)*0.718;
    AstROIInds = arrayfun(@(x) strcmpi(x.ROItype,'Ast'),cFieldROIInfo_strc.ROIdataStrc.ROIInfoDatas);
%     cFCoefMtx = squareform(cFieldCoefs);
    cFDisMtx = squareform(cFieldDis);
    WithEventROIInds = ~cellfun(@isempty, AllFieldData_cell{cfield,5});
    ActiveAstInds = WithEventROIInds(:) & AstROIInds(:);
    NeuronInds = ~AstROIInds;
    ActiveNeuInds = NeuronInds(:) & WithEventROIInds(:);
    
    SessSeqSynchronyIndex2 = Popu_synchrony_fun(cField_eventOnly_data(NeuronInds,:));
    SessSynchronyIndex_All{cfield,2} = SessSeqSynchronyIndex2;
    SessSeqSynchronyIndex3 = Popu_synchrony_fun(cField_eventOnly_data(ActiveNeuInds,:));
    SessSynchronyIndex_All{cfield,3} = SessSeqSynchronyIndex3;
    
    
    
    % calculate the coef between Ast and neuron
    if sum(AstROIInds)
        SessSeqSynchronyIndex4 = Popu_synchrony_fun(cField_eventOnly_data(AstROIInds,:));
        SessSynchronyIndex_All{cfield,4} = SessSeqSynchronyIndex4;
        
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
        SessSynchronyIndex_All{cfield,4} = [];
        
        Ast_AllNeu_coefs = [];
        Ast_AllNeu_Dis = [];
        
        Ast_Ast_coefsVec = [];
        Ast_Ast_DisVec = [];
        
        Neu_Neu_coefsVec = [];
        Neu_Neu_DisVec = [];
    end
    
    % Active Ast with All Neuron coefs
    if sum(ActiveAstInds)
        SessSeqSynchronyIndex5 = Popu_synchrony_fun(cField_eventOnly_data(ActiveAstInds,:));
        SessSynchronyIndex_All{cfield,5} = SessSeqSynchronyIndex5;
    
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
        SessSynchronyIndex_All{cfield,5} = [];
        
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