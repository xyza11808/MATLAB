[num,txt,raw] = xlsread('Analysis of complex PSCs in wt and tg mice_v2.xlsx');

NeuDate = raw(2:end,1);
MouseAge = raw(2:end,2);
MouseType = raw(2:end,3);
EIType = raw(2:end,5);
SweepNum = raw(2:end,6);
OccurNum = raw(2:end,7);
%%
UsedDataInds = cellfun(@ischar,MouseAge) & cellfun(@ischar,MouseType) & cellfun(@ischar,EIType);
NeuDateReal = NeuDate(UsedDataInds);
MouseAgeReal = MouseAge(UsedDataInds);
MouseTypeReal = MouseType(UsedDataInds);
EITypeReal = EIType(UsedDataInds);
SweepNumReal = SweepNum(UsedDataInds);
OccurNumReal = OccurNum(UsedDataInds);

%%
AgeTypes = unique(MouseAgeReal);
MouseTypes = unique(MouseTypeReal);
EITypes = unique(EITypeReal);
NeuTypeIndsCell = cell(length(AgeTypes),length(MouseTypes),length(EITypeReal));
NeuTypeDataCell = cell(length(AgeTypes),length(MouseTypes),length(EITypeReal));
NeuTypeRatioCell = cell(length(AgeTypes),length(MouseTypes),length(EITypeReal));
%
for nAge = 1 : length(AgeTypes)
    for nGenetype = 1 : length(MouseTypes)
        for nEItype = 1 : length(EITypes)
            %
            cTypeInds = ~cellfun(@isempty,strfind(MouseAgeReal,AgeTypes{nAge})) & ...
                ~cellfun(@isempty,strfind(MouseTypeReal,MouseTypes{nGenetype})) & ...
                ~cellfun(@isempty,strfind(EITypeReal,EITypes{nEItype}));
            NeuTypeIndsCell{nAge,nGenetype,nEItype} = cTypeInds;
            if sum(cTypeInds)
                cTypeData = [cell2mat(SweepNumReal(cTypeInds)),cell2mat(OccurNumReal(cTypeInds))];
                NeuTypeDataCell{nAge,nGenetype,nEItype} = cTypeData;
                cTypeRatio = cTypeData(:,2)./max(cTypeData(:,1),1);
                NeuTypeRatioCell{nAge,nGenetype,nEItype} = cTypeRatio;
            else
                NeuTypeDataCell{nAge,nGenetype,nEItype} = [];
                NeuTypeRatioCell{nAge,nGenetype,nEItype} = [];
            end
            %
        end
    end
end

save TypeDataSave.mat NeuTypeIndsCell NeuTypeDataCell AgeTypes MouseTypes EITypes NeuTypeRatioCell -v7.3

%%  plot the type ratio distribution based on GeneType and EI type, 
% plot all age data together
AgeColor = jet(length(AgeTypes));

for nGenetype = 1 : length(MouseTypes)
    for nEItype = 1 : length(EITypes)
        %
        DateAcrossAge = NeuTypeRatioCell(:,nGenetype,nEItype);
        linehand = [];
        lineStr = zeros(length(AgeTypes),1);
        hf = figure('position',[100 100,450 380],'Paperpositionmode','auto');
        hold on;
        for nAge = 1 : length(AgeTypes)
            if ~isempty(DateAcrossAge(nAge))
                [Count,centers] = hist(DateAcrossAge{nAge},0:0.05:1);
                hl = plot(centers,Count,'Color',AgeColor(nAge,:),'Linewidth',1.5);
                linehand = [linehand,hl];
                lineStr(nAge) = 1;
            end
        end
        legend(linehand,AgeTypes(logical(lineStr)),'Fontsize',8);
        legend('boxoff');
        title(sprintf('Gene=%s,%s',MouseTypes{nGenetype},EITypes{nEItype}));
        %
        saveas(hf,sprintf('Gene%s_%s ratio distribution plot',MouseTypes{nGenetype},EITypes{nEItype}));
        saveas(hf,sprintf('Gene%s_%s ratio distribution plot',MouseTypes{nGenetype},EITypes{nEItype}),'png');
        close(hf);
    end
end
%% plot all age data together, updated plots
% AgeColor = jet(length(AgeTypes));
AgeGroups = ([2,2,2,2,2,3,3,3,1,1,1])';
GroupTypes = unique(AgeGroups);
GrStrs = {'p7-9','p12-16','p16-21'};
for nGenetype = 1 : length(MouseTypes)
    for nEItype = 1 : length(EITypes)
        %
        if strcmpi(MouseTypes{nGenetype},'Tg')
            cStr = 'r';
        else
            cStr = 'k';
        end
        DateAcrossAge = NeuTypeRatioCell(:,nGenetype,nEItype);
        GroupTypeData = cell(length(GroupTypes),1);
        hf = figure('position',[100 100,450 380],'Paperpositionmode','auto');
        hold on;
        for nGrType = 1 : length(GroupTypes)
            cGrInds = GroupTypes(nGrType);
            GroupTypeData{nGrType} = cell2mat(DateAcrossAge(AgeGroups == cGrInds));
            nDataPoints = numel(GroupTypeData{nGrType});
            xInds = (rand(nDataPoints,1)-0.5)*2*0.2 + cGrInds;
            plot(xInds,GroupTypeData{nGrType}/10,'v','MarkerSize',10,'linewidth',1.8,'color',cStr);
        end
        set(gca,'xtick',GroupTypes,'xticklabel',GrStrs,'ylim',[-0.01 0.1],'ytick',[0 0.05 0.1]);
        ylabel('Occurrence (Hz)','FontSize',16);
        set(gca,'FontSize',16)
        
        title(sprintf('Gene=%s,%s',MouseTypes{nGenetype},EITypes{nEItype}));
        %
        saveas(hf,sprintf('Gene%s_%s ratio Grdistribution plot',MouseTypes{nGenetype},EITypes{nEItype}));
        saveas(hf,sprintf('Gene%s_%s ratio Grdistribution plot',MouseTypes{nGenetype},EITypes{nEItype}),'png');
        close(hf);
    end
end