function SessionRespFracPlot(varargin)
% this function will be used for reading the xls files from outside or
% given corresponded file path, and then plot the cell response fraction of
% different types
if nargin<1
    [fn,fp,fi] = uigetfile({'*.xlsx';'*.xls';'*.*'},'Please select your excel file contains ROI response type.');
    FilePath = fullfile(fp,fn);
    if ~fi
        fprintf('No file being seected, quit analysis...');
        return;
    end
else
    FilePath = varargin{1};
end
[NUmbers,~,Raw] = xlsread(FilePath);
cd(fp);
for NUmVariables = 1 : size(Raw,2)
    if NUmVariables <= size(NUmbers,2)
        SheetContains.(Raw{1,NUmVariables}) = NUmbers(:,NUmVariables);  % store number components
    else
        SheetContains.(Raw{1,NUmVariables}) = Raw(:,NUmVariables); % store char components
    end
end
save([fp,'\SheetVariables.mat'],'SheetContains','-v7.3');
if size(NUmbers,1) == (size(Raw,1) - 1)
    disp('NUmber rows less than raw excel contents, using the first row as variable name.');
    ROInumbers = SheetContains.ROINum;
    ROITypes = SheetContains.ROIType;
    RespTypes = SheetContains.RespType(2:end);
elseif size(NUmbers,1) == size(Raw,1)
    disp('All sheet contents seeme to be numbers, using customized variable names.');
    ROInumbers = SheetContains.ROINum;
    ROITypes = SheetContains.ROIType;
    RespTypes = SheetContains.RespType;
end


if sum(isfield(SheetContains,{'ROINum','ROIType','RespType'}))==3
    ROInumbers = SheetContains.ROINum;
    ROITypes = SheetContains.ROIType;
    RespTypes = SheetContains.RespType(2:end);
    ROIrespSummary.NonResponseROI = ROInumbers(ROITypes == 0); % non-responsive roi index
    ROIrespSummary.LeftSRespROI = ROInumbers(ROITypes == 1 & cellfun(@(x,y) strcmpi(x,'L'),RespTypes));
    ROIrespSummary.RightSRespROI = ROInumbers(ROITypes == 1 & cellfun(@(x,y) strcmpi(x,'R'),RespTypes));
    ROIrespSummary.LeftCRespROI = ROInumbers(ROITypes == 2 & cellfun(@(x,y) strcmpi(x,'L'),RespTypes));
    ROIrespSummary.RightCRespROI = ROInumbers(ROITypes == 2 & cellfun(@(x,y) strcmpi(x,'R'),RespTypes));
    ROIrespSummary.MixedRespROI = ROInumbers(ROITypes == 3);  % mixed selectivity cells
    ROIrespSummary.MixedROIrespType = RespTypes(ROITypes == 3); % mixed response type
    %         ROIrespSummary.RightMRespROI = ROInumbers(ROITypes == 3 & cellfun(@(x,y) strcmpi(x,'R'),RespTypes));
    ROIrespSummary.MixedRespSummary = CellRespAna(ROIrespSummary.MixedROIrespType);
end
save([fp,'\SheetAnaResult.mat'],'ROIrespSummary','-v7.3');
%creating a pie plot to show different response properties
% two different kinds of pie plot, one to show summary response
% fraction. another to show some detailed response fraction
TotalROINum = length(ROInumbers);
SrespSum = (length(ROIrespSummary.LeftSRespROI) + length(ROIrespSummary.RightSRespROI));
CrespSum = (length(ROIrespSummary.LeftCRespROI) + length(ROIrespSummary.RightCRespROI));
MrespSum = length(ROIrespSummary.MixedRespROI);
NrespSum = length(ROIrespSummary.NonResponseROI);
if (SrespSum+CrespSum+MrespSum+NrespSum) ~= TotalROINum
    fprintf('%d %d %d %d %d\n',SrespSum,CrespSum,MrespSum,NrespSum,TotalROINum);
    error('Given response type is not equal to total ROI number, please check your input file.')
end
H_simplePie = figure('position',[400 220 1150 830]);
Labels = {sprintf('SoundResp(%.1f%%)',SrespSum/TotalROINum*100),sprintf('BehavResp(%.1f%%)',CrespSum/TotalROINum*100),...
    sprintf('MixedResp(%.1f%%)',MrespSum/TotalROINum*100),sprintf('NoneResp(%.1f%%)',NrespSum/TotalROINum*100)};
p = pie([SrespSum,CrespSum,MrespSum,NrespSum],Labels);
xx=findobj(gcf,'Type','text');
set(xx,'FontSize',20)
%     set(gca,'FontSize',20);
title('Summarized Session response fraction','FontSize',20);
saveas(H_simplePie,'Sim_Summarized response fraction');
saveas(H_simplePie,'Sim_Summarized response fraction','png');
close(H_simplePie);

%detailed pie plot
PieData = [length(ROIrespSummary.LeftSRespROI),length(ROIrespSummary.RightSRespROI),length(ROIrespSummary.LeftCRespROI),...
    length(ROIrespSummary.RightCRespROI),MrespSum,NrespSum];
FractionD = PieData / TotalROINum * 100; % percentage
LabelsD = {sprintf('LeftSound(%.1f%%)',FractionD(1)),sprintf('RightSound(%.1f%%)',FractionD(2)),sprintf('LeftChoice(%.1f%%)',FractionD(3)),...
    sprintf('RightChoice(%.1f%%)',FractionD(4)),sprintf('MixedResp(%.1f%%)',FractionD(5)),sprintf('NoneResp(%.1f%%)',FractionD(6))};
H_detailedPie = figure('position',[400 220 1150 830]);
pD = pie(PieData,LabelsD);
xx=findobj(gcf,'Type','text');
set(xx,'FontSize',20)
title('Detailed Session response fraction','FontSize',20);
saveas(H_detailedPie,'Detailed response fraction');
saveas(H_detailedPie,'Detailed response fraction','png');
close(H_detailedPie);

