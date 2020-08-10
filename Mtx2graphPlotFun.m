function [gNets, gPlth, SubGrInds] = Mtx2graphPlotFun(CorrMtx,CoefThres,SubgraphInds, varargin)

% method to normalized the correlation mtx to [0,1] range
% but abs(corr) value less than 0.2 will be set to zeros
% CorrMtx is the correlation matrix used to generate graph object, and the
% CoefThres is the threshold value used to defined used coef values (abs value) as
% valid connection.
if ~issymmetric(CorrMtx)
    error('The input coef matrix must be a symmetric matrix.');
end
UsedCoefThres = 0.3; 
if ~isempty(CoefThres)
    UsedCoefThres = CoefThres;
    if UsedCoefThres <= 0
        warning('The input coef value threshold is too small, reset to 0.1.\n');
    end
end
IsSubGrIndsGiven = 0;
if ~isempty(SubgraphInds)
    IsSubGrIndsGiven = 1;
    GivenSubgraphInds = SubgraphInds;
end
PlotCorrMtx = CorrMtx;
ZerosInds = abs(PlotCorrMtx) < UsedCoefThres;
NormCorrInds = (PlotCorrMtx+1)/2;
NormCorrInds = NormCorrInds - diag(diag(NormCorrInds));
NormCorrInds(ZerosInds) = 0;
% figure;
% imagesc(NormCorrInds)

%%
hf = figure('position',[100 100 600 450]);
Gnet = Mtx2graph(NormCorrInds);
if ~IsSubGrIndsGiven
    [bin,binsize] = conncomp(Gnet);
    idx = binsize(bin) == max(binsize);
    SGnodes_realIndex = find(idx);
else
    if islogical(GivenSubgraphInds)
        idx = GivenSubgraphInds;
        SGnodes_realIndex = find(idx);
    else
        idx = GivenSubgraphInds;
        SGnodes_realIndex = idx;
    end
end
sg = subgraph(Gnet,idx);
if nargin > 3
    sgplt = plot(sg,varargin{:});
else
    sgplt = plot(sg,'layout','force');
end
sgplt.NodeLabel = SGnodes_realIndex;
sg.Edges.LWidths = 3*sg.Edges.Weight/max(sg.Edges.Weight);
sgplt.LineWidth = sg.Edges.LWidths;
%
Nodeimportant4Size = round(centrality(sg,'degree','Importance',sg.Edges.Weight))/2+1;  %degree(Gnets_01);
sgplt.NodeCData = Nodeimportant4Size; % set the node color as corresponded group index
% sgplt.EdgeColor = sg.Edges.Weight;
for csgNode = 1 : numel(Nodeimportant4Size)
    highlight(sgplt,csgNode,'MarkerSize',Nodeimportant4Size(csgNode));
end
% sg.MarkerSize = 6; % Gnets_01.Nodes.NodeColors+1;

gNets = {Gnet,sg};
gPlth = {sgplt, hf};
SubGrInds = SGnodes_realIndex;

