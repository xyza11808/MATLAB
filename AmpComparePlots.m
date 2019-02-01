function varargout = AmpComparePlots(TaskData,PassiveData,Comp_Sig,UsedInds,varargin)
Alpha = 0.05;
if nargin > 4
    if ~isempty(varargin{1})
        Alpha = varargin{1};
    end
end
IsCutOffAmpUsing = 0;
if nargin > 5
   if ~isempty(varargin{2})
       IsCutOffAmpUsing = 1; 
       CutOffAmp = varargin{2};
    end
end 
IsBFIndexGiven = 0; 
if nargin > 6
   if ~isempty(varargin{3})
       IsBFIndexGiven = 1; 
       IsBFIndex = varargin{3} > 0;
    end
end 

IsPlot = 1;
if nargin > 7
    if ~isempty(varargin{4})
        IsPlot = varargin{4};
    end
end

if isempty(UsedInds)
    PlotTaskData = TaskData;
    PlotPassData = PassiveData;
    Plot_Significance = Comp_Sig;
    UsedBFInds = IsBFIndex;
else
    PlotTaskData = TaskData(UsedInds);
    PlotPassData = PassiveData(UsedInds);
    Plot_Significance = Comp_Sig(UsedInds);
    UsedBFInds = IsBFIndex(UsedInds);
end
SigSuppreInds = PlotTaskData(:) < PlotPassData(:) & Plot_Significance(:) < Alpha;
SigEnhanceInds = PlotTaskData(:) > PlotPassData(:) & Plot_Significance(:) < Alpha;
NoSigChangeInds = Plot_Significance(:) >= Alpha;

if IsCutOffAmpUsing
    AmpUsageInds = PlotTaskData(:) <= CutOffAmp & PlotPassData(:) <= CutOffAmp;
    NumberVec = [sum(SigSuppreInds & AmpUsageInds);...
        sum(SigEnhanceInds & AmpUsageInds);sum(NoSigChangeInds & AmpUsageInds)];
    if IsBFIndexGiven
        BFTypeNum = [sum(SigSuppreInds & AmpUsageInds & UsedBFInds);...
        sum(SigEnhanceInds & AmpUsageInds & UsedBFInds);sum(NoSigChangeInds & AmpUsageInds & UsedBFInds)];
    end
else
    NumberVec = [sum(SigSuppreInds);sum(SigEnhanceInds);sum(NoSigChangeInds)];
    if IsBFIndexGiven
        BFTypeNum = [sum(SigSuppreInds & UsedBFInds);sum(SigEnhanceInds & UsedBFInds);...
            sum(NoSigChangeInds & UsedBFInds)];
    end
end

if IsPlot
    hf = figure('position',[100 100 350 280]);
    hold on

    plot(PlotTaskData(SigSuppreInds),PlotPassData(SigSuppreInds),'bo','linewidth',1.2);
    plot(PlotTaskData(SigEnhanceInds),PlotPassData(SigEnhanceInds),'ro','linewidth',1.2);
    plot(PlotTaskData(NoSigChangeInds),PlotPassData(NoSigChangeInds),'o','linewidth',1.2,'Color',[.7 .7 .7]);
    if IsBFIndexGiven
        plot(PlotTaskData(UsedBFInds),PlotPassData(UsedBFInds),'c*','linewidth',0.8);
    end
    ComScale = UniAxesScale(gca);
    line(ComScale,ComScale,'Color',[.7 .7 .7],'linewidth',1.5,'linestyle','--');
    xlabel('Task');
    ylabel('Passive');
else
    hf = [];
end

if nargout == 1
    varargout{1} = hf;
elseif nargout == 2
    varargout{1} = hf;
    varargout{2} = NumberVec;
elseif nargout == 3
    varargout{1} = hf;
    varargout{2} = NumberVec;
    if IsBFIndexGiven
        varargout{3} = BFTypeNum;
    else
        varargout{3} = [];
    end
else
    error('Too many output requests.');
end
