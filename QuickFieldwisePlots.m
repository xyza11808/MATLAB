function hl = QuickFieldwisePlots(Datas,bincents,ax,colors,linetype,PlotType)

DataAvgs = mean(Datas);
DataSEMs = std(Datas)/sqrt(size(Datas,1));

if isempty(PlotType)
    PlotType = 'shadow';
end

if strcmpi(PlotType,'Errorbar')
    hl = errorbar(ax,bincents,DataAvgs,DataSEMs,...
        'Color',colors,'linestyle',linetype,'linewidth',1.5);
    
elseif strcmpi(PlotType,'shadow')
    DataPatch_x = [bincents(:);flipud(bincents(:))];
    DataPatch_y = [DataAvgs+DataSEMs*0.5,fliplr(DataAvgs-DataSEMs*0.5)];

    patch(ax,DataPatch_x,DataPatch_y,1,...
        'FaceColor',[.8 .8 .8],'edgeColor',[.6 .6 .6]);
    hl = plot(ax,bincents,DataAvgs,'Color',colors,'linestyle',linetype,'linewidth',1.5);
    
end

